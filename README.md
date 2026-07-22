# kyufy-web

The thin MVP host app for **kyufy** — a single 壁打ち (wall-bounce) chat screen that mounts the
[`kyufy_core`](https://github.com/kyufy-jp/kyufy_core) assessment engine and shows, for a person's
situation, which Japanese public benefits (給付金・補助金・助成金・手当・控除) they may be entitled
to — each with **該当 / 非該当 / 要確認** and cited evidence (a quoted 要綱 excerpt + the official
source link).

> **これは参考判定です。最終確認は各制度の公式窓口で行ってください。**
> This is a reference assessment only. Always confirm at each program's official window.

This app exists so the hackathon demo has a real screen without dragging in the commercial shell
(no auth or billing needed for the MVP), and without putting UI code in the public engine gem.
Auth, billing, and the production UI live in a separate private app (`kyufy-shell`) — not here.

## What it does — one screen

1. **Intake** — a compact form collects the profile (age / residence 市区町村 / household size /
   前年の所得 / employment / target).
2. **Follow-up questions (逆質問)** — when the engine can't determine a requirement from a
   directly-answerable field, the missing question is asked inline; answering re-assesses.
3. **Verdict cards** — one per program, streamed in via Turbo Streams: verdict badge, category
   chip + 所管, per-requirement reasons with the quoted 要綱 excerpt, official link, and license
   attribution when the source carries one.

Nothing about the user is persisted — assessment state is session-only, mirroring the engine's
no-PII rule.

## Data provenance

Every program served here comes from the engine's **real, official-source seed**
(`db/seeds/programs/*.yml`): each requirement quotes its 要綱 verbatim, records the retrieval
date, and links a live official page. The engine also ships an *illustrative* fixture set for
its own tests — this app never loads it, and `test/models/seed_integrity_test.rb` fails the
build if it ever reappears. Assessments concern public money, so a card must never cite a source
that cannot be checked.

## Stack

- **Rails 8.1 / Ruby 4.0**, Hotwire (Turbo + Stimulus), no React.
- **Tailwind CSS v4** (plain utilities; palette from [`docs/PALETTE.md`](docs/PALETTE.md)).
- **PostgreSQL + [pgvector](https://github.com/pgvector/pgvector)** (required by the engine).
- **Japanese-monolingual**: `default_locale :ja` + rails-i18n.

## Getting started

Requires Ruby 4.0.6 and PostgreSQL with the `vector` extension. The engine is pulled from
its public repo at a pinned release tag, so no side-by-side checkout is needed:

```bash
bin/setup        # bundle, prepare the database, load the packaged seed
bin/dev          # boot the app (http://localhost:3000)
```

To take a new engine release, tag it in
[`kyufy_core`](https://github.com/kyufy-jp/kyufy_core), bump the `tag:` in the `Gemfile`, and
run `bundle update kyufy_core`. To develop against an unreleased engine change, point the
Gemfile at a local checkout temporarily (`gem "kyufy_core", path: "../kyufy_core"`) — just
don't commit that.

Then enter a profile (e.g. `18 / 新宿区 / 3人世帯 / 前年の所得 864000 / 自営業`) and submit — the
seeded programs produce a 該当 / 非該当 / 要確認 spread with citations.

## LLM adapter (no credentials required)

Verdicts always come from the engine's rules; an LLM only writes the grounded explanations.
The adapter is switched by `KYUFY_LLM`, and the **default demos with zero credentials and zero
network**:

| `KYUFY_LLM`           | Adapter                              | Notes                                             |
| --------------------- | ------------------------------------ | ------------------------------------------------- |
| `null` *(default)*    | Null (deterministic)                 | No keys, no network — the demo can't die on stage |
| `anthropic`           | Claude                               | Reads `KYUFY_ANTHROPIC_API_KEY` (a dedicated key) |
| `openai` / `opencode` | OpenAI-compatible / OpenCode / local | Reads `KYUFY_OPENAI_*`                             |

Keys live in the environment only — never in the repo.

## Testing

```bash
bin/ci                 # the full local suite: rubocop, security scans, tests, seeds
bin/rails test         # unit tests
bin/rails test:system  # system tests (Null adapters — deterministic, zero network)
```

## Architecture

```
kyufy_core   (public gem, MIT)   … assessment engine. No UI.
kyufy-web    (this repo, public) … thin Rails app. Mounts kyufy_core.  ← the demo
kyufy-shell  (future, private)   … commercial shell. Replaces this app at monetization.
```

Design specs live in [`docs/SPEC.md`](docs/SPEC.md) and [`docs/PALETTE.md`](docs/PALETTE.md).

## License

[MIT](LICENSE).
