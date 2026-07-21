module AssessmentsHelper
  # Verdict badge colors per docs/PALETTE.md's UI-role table.
  VERDICT_BADGE_CLASSES = {
    eligible:     "bg-success-50 text-success-700",
    ineligible:   "bg-danger-50 text-danger-600",
    needs_review: "bg-warning-50 text-warning-600"
  }.freeze

  # Requirement kinds (engine enum) → short Japanese labels.
  REASON_KIND_LABELS = {
    income:     "所得",
    age:        "年齢",
    residence:  "居住地",
    household:  "世帯",
    employment: "就労",
    other:      "その他"
  }.freeze

  def verdict_label(verdict)
    t("kyufy.verdicts.#{verdict}")
  end

  def verdict_badge(verdict)
    tag.span(verdict_label(verdict),
             class: "inline-block rounded-full px-3 py-1 text-sm font-semibold " \
                    "#{VERDICT_BADGE_CLASSES.fetch(verdict.to_sym)}")
  end

  def reason_kind_label(kind)
    REASON_KIND_LABELS.fetch(kind.to_sym, kind.to_s)
  end
end
