# Programs come from the mounted kyufy_core engine — the app has no models of its own
# (SPEC §4). Idempotent: skip when programs already exist (re-seed via db:seed:replant).
#
# ONLY the real, official-source programs (db/seeds/programs/*.yml) are loaded: each one's
# raw_text is a verbatim quote from the cited 要綱, with a retrieval date and a live
# official_url.
#
# The engine also ships KyufyCore.import_yaml (db/seeds/tokyo_programs.yml). Do NOT load it
# here. That file says of itself: "illustrative content for the MVP demo — NOT an
# authoritative reproduction of any real program's 要綱." Its 要綱 excerpts are invented and
# attributed to real authorities (国税庁 / 東京都福祉局 / 新宿区), and all five of its
# official_urls are dead — four hard 404s plus one that 302s to nta.go.jp/error/404.htm, so a
# naive status check reports 200. It was briefly served in production; see the guard test in
# test/models/seed_integrity_test.rb, which fails if a dead-URL program is ever seeded again.
#
# Fixtures are fine for engine tests. They must never back a public site telling people what
# public money they may be entitled to.
if KyufyCore::Program.none?
  KyufyCore.import_dir
end
puts "Seeded #{KyufyCore::Program.count} program(s), #{KyufyCore::Requirement.count} requirement(s)."
