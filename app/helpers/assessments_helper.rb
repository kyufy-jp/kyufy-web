module AssessmentsHelper
  # Verdict badge colors per docs/PALETTE.md's UI-role table.
  VERDICT_BADGE_CLASSES = {
    eligible:     "bg-success-50 text-success-700",
    ineligible:   "bg-danger-50 text-danger-600",
    needs_review: "bg-warning-50 text-warning-600"
  }.freeze

  def verdict_label(verdict)
    t("kyufy.verdicts.#{verdict}")
  end

  def verdict_badge(verdict)
    tag.span(verdict_label(verdict),
             class: "inline-block rounded-full px-3 py-1 text-sm font-semibold " \
                    "#{VERDICT_BADGE_CLASSES.fetch(verdict.to_sym)}")
  end

  # Japanese label for a requirement kind. The engine owns this vocabulary as of v0.1.1
  # (Requirement::KIND_LABELS) and uses it in its own explanations, so deferring keeps the
  # card's 【所得】 chip and the sentence beneath it from drifting apart.
  def reason_kind_label(kind)
    KyufyCore::Requirement.kind_label(kind)
  end
end
