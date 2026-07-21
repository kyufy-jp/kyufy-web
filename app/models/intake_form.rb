# The intake form (SPEC §2.1): collects the engine Profile's fields, validates them in
# Japanese, and converts to the plain hash KyufyCore.assess expects. Session-only — this
# is an ActiveModel value object, never persisted (no-PII rule, SPEC §4).
class IntakeForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :age, :integer
  attribute :residence, :string
  attribute :household_size, :integer
  attribute :prior_year_income_jpy, :integer
  attribute :employment, :string
  attribute :target, :string, default: "individual"
  # 逆質問-only field (never on the main form): true / false / nil (unknown).
  attribute :resident_tax_exempt, :boolean

  EMPLOYMENTS = {
    "employee"      => "会社員・パート",
    "self_employed" => "自営業・フリーランス",
    "unemployed"    => "無職・休職中"
  }.freeze

  TARGETS = {
    "individual" => "個人",
    "business"   => "事業者"
  }.freeze

  validates :residence, presence: true
  validates :age, presence: true,
                  numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: true }
  validates :household_size, numericality: { only_integer: true, greater_than: 0, allow_nil: true }
  validates :prior_year_income_jpy, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :employment, inclusion: { in: EMPLOYMENTS.keys, allow_blank: true }
  validates :target, inclusion: { in: TARGETS.keys }

  # The engine Profile hash. Blank strings become nil (missing info → the engine's
  # fail-safe 要確認 path); false must survive, so no compact of booleans.
  def to_profile
    {
      age: age,
      residence: residence.presence,
      household_size: household_size,
      prior_year_income_jpy: prior_year_income_jpy,
      employment: employment.presence,
      target: target.presence,
      resident_tax_exempt: resident_tax_exempt
    }
  end

  # Human summary for the user-side chat bubble.
  def summary_items
    items = []
    items << "#{age}歳" if age
    items << residence if residence.present?
    items << "世帯#{household_size}人" if household_size
    items << "前年の所得 #{ActiveSupport::NumberHelper.number_to_delimited(prior_year_income_jpy)}円" if prior_year_income_jpy
    items << EMPLOYMENTS[employment] if employment.present?
    items << TARGETS[target] if target.present?
    items << "住民税非課税: #{resident_tax_exempt ? 'はい' : 'いいえ'}" unless resident_tax_exempt.nil?
    items
  end
end
