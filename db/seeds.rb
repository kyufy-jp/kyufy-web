# Programs come from the mounted kyufy_core engine — the app has no models of its own
# (SPEC §4). Idempotent: skip when programs already exist (re-seed via db:reset).
#
# Two packaged seed sets load together:
#   - import_yaml: the curated Tokyo demo set, which guarantees the 新宿区 demo profile a
#     full 該当 / 非該当 / 要確認 spread (documented in the engine's ingestion test).
#   - import_dir:  the real official-source programs (018サポート, 東京ゼロエミポイント, …)
#     that carry verbatim 要綱 citations, license attribution, and the 逆質問 demo beats.
if KyufyCore::Program.none?
  KyufyCore.import_yaml
  KyufyCore.import_dir
end
puts "Seeded #{KyufyCore::Program.count} program(s), #{KyufyCore::Requirement.count} requirement(s)."
