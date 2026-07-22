require "test_helper"

# Regression guard. The engine ships two seed sets and only one is fit to serve:
#
#   db/seeds/programs/*.yml  — real programs, verbatim 要綱 quotes, live official_urls
#   db/seeds/tokyo_programs.yml — self-described "illustrative content ... NOT an
#     authoritative reproduction of any real program's 要綱", with invented excerpts
#     attributed to 国税庁 / 東京都福祉局 / 新宿区 and five dead official_urls
#
# The fixture set was briefly seeded into production, putting fabricated citations and 404
# links on a public site about public money. These tests make that failure loud and local:
# they run against the app's own seeds, offline, in under a second.
class SeedIntegrityTest < ActiveSupport::TestCase
  # Every program the fixture set introduces. None may ever be seeded by this app.
  FIXTURE_PROGRAM_NAMES = [
    "定額減税（所得税・個人住民税）",
    "東京都子育て世帯物価高騰支援給付金",
    "新宿区高齢者福祉タクシー利用助成",
    "新宿区就学援助",
    "さいたま市子育て応援給付金"
  ].freeze

  # Known-dead URLs from that set, kept explicit so the failure message names the problem
  # rather than just a count. The nta.go.jp one answers 200 — it 302s to an error page — so
  # matching on URL is the reliable check, not an HTTP status.
  DEAD_URLS = [
    "https://www.nta.go.jp/teigakugenzei",
    "https://www.fukushi.metro.tokyo.lg.jp/kyufu/bukka-shien",
    "https://www.city.shinjuku.lg.jp/fukushi/koreisha-taxi",
    "https://www.city.shinjuku.lg.jp/kyoiku/shugaku-enjo",
    "https://www.city.saitama.lg.jp/kosodate/ouen-kyufu"
  ].freeze

  # Purge first: db/seeds.rb is idempotent (`if Program.none?`), so against a database still
  # holding an earlier seed it would no-op and quietly assert about stale rows. Transactional
  # tests roll this back. This is not incidental — a test database left holding the fixture
  # set is exactly the kind of drift this file exists to catch.
  setup do
    KyufyCore::Program.destroy_all
    load Rails.root.join("db/seeds.rb")
  end

  test "the app seeds only real, official-source programs" do
    assert KyufyCore::Program.any?, "expected the seed to load programs"

    seeded = KyufyCore::Program.pluck(:name)
    leaked = seeded & FIXTURE_PROGRAM_NAMES

    assert_empty leaked,
      "illustrative fixture programs must never be seeded (db/seeds.rb must not call " \
      "KyufyCore.import_yaml). Leaked: #{leaked.join(', ')}"
  end

  test "no seeded program cites a known-dead official_url" do
    cited = KyufyCore::Program.pluck(:official_url)

    assert_empty cited & DEAD_URLS,
      "a seeded program cites a URL known to 404: #{(cited & DEAD_URLS).join(', ')}"
  end

  test "every seeded program has an official_url and every citation has source text" do
    KyufyCore::Program.find_each do |program|
      assert program.official_url.present?, "#{program.name} has no official_url"
      assert_match %r{\Ahttps://}, program.official_url, "#{program.name} official_url is not https"
    end

    # A requirement carrying a 要綱 excerpt is what makes a verdict auditable; blank raw_text
    # would render an empty blockquote on the card.
    KyufyCore::Requirement.where.not(raw_text: nil).find_each do |requirement|
      assert requirement.raw_text.strip.present?,
        "requirement #{requirement.id} has blank raw_text"
    end
  end
end
