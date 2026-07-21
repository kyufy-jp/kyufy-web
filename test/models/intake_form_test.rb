require "test_helper"

class IntakeFormTest < ActiveSupport::TestCase
  test "converts to the engine Profile hash, blanks becoming nil" do
    form = IntakeForm.new(age: "52", residence: "新宿区", household_size: "3",
                          prior_year_income_jpy: "864000", employment: "", target: "individual")
    profile = form.to_profile

    assert_equal 52, profile[:age]
    assert_equal "新宿区", profile[:residence]
    assert_equal 864_000, profile[:prior_year_income_jpy]
    assert_nil profile[:employment]
    assert_nil profile[:resident_tax_exempt]
  end

  test "resident_tax_exempt keeps its tri-state through casting" do
    assert_equal true,  IntakeForm.new(resident_tax_exempt: "true").to_profile[:resident_tax_exempt]
    assert_equal false, IntakeForm.new(resident_tax_exempt: "false").to_profile[:resident_tax_exempt]
    assert_nil IntakeForm.new(resident_tax_exempt: "").to_profile[:resident_tax_exempt]
  end

  test "validation messages come out in Japanese" do
    form = IntakeForm.new
    assert_not form.valid?
    assert_includes form.errors.full_messages, "お住まいの市区町村を入力してください"
    assert_includes form.errors.full_messages, "年齢を入力してください"
  end
end
