require "test_helper"

# The create action's branches, exercised with the engine's assessment swapped out so
# these stay fast and independent of the seed. The happy path is covered end-to-end by
# the system test; here we pin the SPEC §2.4 edge states, which the system test can't
# easily reach with the real seed (national programs always match, so it never empties).
class AssessmentsControllerTest < ActionDispatch::IntegrationTest
  test "an engine error renders the apologetic retry state" do
    with_assess(->(**) { raise KyufyCore::Error, "boom" }) do
      post assessment_path, params: valid_params, as: :turbo_stream
    end

    assert_response :success
    assert_match "エラーが発生しました", @response.body
  end

  test "no matching programs renders friendly guidance, not cards" do
    with_assess(->(**) { KyufyCore::Result.new([]) }) do
      post assessment_path, params: valid_params, as: :turbo_stream
    end

    assert_response :success
    assert_match "見つかりませんでした", @response.body
    assert_no_match(/<article/, @response.body)
  end

  test "a blank required field re-renders the form with a Japanese error" do
    post assessment_path, params: { intake_form: { residence: "" } }, as: :turbo_stream

    assert_response :success
    assert_match "を入力してください", @response.body
    assert_no_match(/<article/, @response.body)
  end

  private

  def valid_params
    { intake_form: { age: 52, residence: "新宿区", target: "individual" } }
  end

  # minitest 6 dropped minitest/mock (no #stub), so swap KyufyCore.assess by hand and
  # restore the original in an ensure block.
  def with_assess(replacement)
    original = KyufyCore.singleton_class.instance_method(:assess)
    KyufyCore.define_singleton_method(:assess, replacement)
    yield
  ensure
    KyufyCore.singleton_class.define_method(:assess, original)
  end
end
