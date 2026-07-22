require "application_system_test_case"

# The whole demo on the Null adapters — deterministic, zero network (SPEC §4/§9).
class AssessmentFlowTest < ApplicationSystemTestCase
  setup do
    # Real, official-source programs only — the same set db/seeds.rb loads. Deliberately NOT
    # KyufyCore.import_yaml: that fixture set carries invented 要綱 excerpts and dead URLs, and
    # a test seeded differently from production is how it reached the live site unnoticed.
    KyufyCore.import_dir
  end

  test "新宿区 demo profile renders the full verdict spread with citations" do
    visit root_path

    # 18歳・自営業: old enough to fail 子育て応援＋ and the 雇用保険 requirement, young enough
    # for 018サポート — so the full 該当 / 非該当 / 要確認 spread comes from real programs.
    fill_in "年齢", with: 18
    fill_in "お住まいの市区町村", with: "新宿区"
    fill_in "世帯人数", with: 3
    fill_in "前年の所得", with: 864_000
    select "自営業・フリーランス", from: "就業状況"
    select "個人", from: "対象"
    click_on "判定する"

    # The three-verdict spread from the real seed (該当 / 非該当 / 要確認 badges).
    assert_selector "article span", exact_text: "該当"
    assert_selector "article span", exact_text: "非該当"
    assert_selector "article span", exact_text: "要確認"

    # Real-seed cards with quoted 要綱 citations and license attribution.
    assert_selector "article h2", text: "018サポート"
    assert_selector "article h2", text: "一般教育訓練給付金"
    assert_selector "article blockquote", minimum: 1
    assert_text "出典: 厚生労働省（PDL1.0）"

    # Every card links to a real official page. The fixture set that briefly shipped to
    # production cited pages that 404, so pin the hosts we actually verified.
    official_links = page.all("article a[href^='https://']").map { |a| a[:href] }.uniq
    assert official_links.any?, "expected official_url links on the cards"
    official_links.each do |href|
      assert_match %r{\Ahttps://(www\.fukushi\.metro\.tokyo\.lg\.jp|www\.hellowork\.mhlw\.go\.jp|www\.city\.suginami\.tokyo\.jp|www\.tz-points\.jp)/},
                   href, "unexpected citation host — is a fixture program seeded?"
    end
    assert_text "これは参考判定です。最終確認は各制度の公式窓口で行ってください。"

    # No raw PKs anywhere in the DOM: cards are identified by prefixed ids only,
    # and no element leaks a bare numeric database id.
    cards = page.all("article[id]")
    assert cards.any?, "expected verdict cards"
    cards.each do |card|
      assert_match(/\A\h+_prog_[A-Za-z0-9]+\z/, card[:id], "card DOM id must use the prefixed program id")
    end
    assert_no_match(/\b(?:program|requirement)_id["']?\s*[:=]\s*["']?\d+\b/, page.html,
                    "raw numeric ids must not reach the DOM")
  end

  test "blank required intake fields show Japanese validation messages" do
    visit root_path

    click_on "判定する"

    assert_text "お住まいの市区町村を入力してください"
    assert_text "年齢を入力してください"
    assert_no_selector "article"
  end

  test "杉並区 profile surfaces the 住民税非課税 逆質問 and re-assesses inline" do
    visit root_path

    fill_in "年齢", with: 40
    fill_in "お住まいの市区町村", with: "杉並区"
    click_on "判定する"

    assert_text "住民税は非課税ですか?（お住まいの通知書で確認できます）"

    within(".bg-primary-50", text: "住民税は非課税ですか") do
      choose "はい"
      click_on "回答して再判定"
    end

    # The enriched round appends to the chat history.
    assert_text "住民税非課税: はい"
  end
end
