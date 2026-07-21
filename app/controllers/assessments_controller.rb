# The ONE screen (SPEC §2): intake form → KyufyCore.assess → verdict cards streamed into
# the chat frame via Turbo Streams. Session-only — nothing about the user is persisted.
class AssessmentsController < ApplicationController
  # 逆質問 whose answers a Profile field can carry back (SPEC §2.2). The other canned
  # question (雇用保険期間) has no Profile field, so its 要確認 card carries the question
  # as guidance instead — intended fail-safe, not a gap.
  ANSWERABLE_FOLLOW_UPS = {
    KyufyCore::FOLLOW_UP_QUESTIONS[:resident_tax_exempt] => :resident_tax_exempt
  }.freeze

  def new
    @intake_form = IntakeForm.new
  end

  def create
    @intake_form = IntakeForm.new(intake_form_params)

    unless @intake_form.valid?
      return render turbo_stream: turbo_stream.replace("intake_form", partial: "intake_form",
                                                       locals: { intake_form: @intake_form })
    end

    result = KyufyCore.assess(profile: @intake_form.to_profile)
    @round_id = SecureRandom.hex(4)
    @program_results = result.program_results
    @programs_by_prefix_id = KyufyCore::Program.all.index_by(&:prefix_id)
    @follow_up_questions = answerable_follow_up_questions(@program_results)
  rescue StandardError => e
    Rails.logger.error("assessment failed: #{e.class}: #{e.message}")
    render :error
  end

  private

  def intake_form_params
    params.fetch(:intake_form, {}).permit(:age, :residence, :household_size,
                                          :prior_year_income_jpy, :employment, :target,
                                          :resident_tax_exempt)
  end

  # Distinct engine 逆質問 that map to a Profile field the user hasn't answered yet.
  # Returns [question, field] pairs for the inline answer forms.
  def answerable_follow_up_questions(program_results)
    program_results.flat_map(&:reasons)
                   .filter_map { |reason| reason[:follow_up] }
                   .uniq
                   .filter_map do |question|
      field = ANSWERABLE_FOLLOW_UPS[question]
      [ question, field ] if field && @intake_form.public_send(field).nil?
    end
  end
end
