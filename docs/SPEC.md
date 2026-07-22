# kyufy-web — MVP Host App Design Spec (for Claude Code)

> Hand this document to Claude Code together with the engine spec (`kyufy_core/docs/SPEC.md`, Rev 2.4 — this doc is synced to it: prior_year_income_jpy field, 新宿区 demo residence, license attribution on verdict cards, real-seed follow-up questions). The engine is consumed at **v0.1.1**. Colors: `docs/PALETTE.md` is the canonical palette (§3 defers to it).
> Scope: the **thin MVP host app** that mounts the `kyufy_core` engine and provides the demo UI for the hackathon (壁打ち chat → verdict cards). No auth, no billing.
>
> Status: **built and live in production at https://kyufy.com.** Sections below describe what exists, not what is planned.
>
> Repo status: **public** (MIT), fully clean: **no Tailwind Plus** (decision: dropped everywhere, including kyufy-shell — plain Tailwind CSS utilities only, styled per docs/PALETTE.md). No paid-component license bookkeeping applies to this repo.
> The only strictly-private repo is kyufy-shell (Jumpstart Pro is paid, non-redistributable).
>
> Domain-term convention: same as kyufy-core — keep 給付金 / 補助金 / 助成金 / 手当 / 控除 / 要綱 / 該当 / 非該当 / 要確認 in Japanese. UI copy is Japanese (target users are Japanese speakers).

---

# ⚠️ Data provenance — the rule that is never traded away

*(Deliberately unnumbered and placed first: it outranks everything below, and the §-numbers are referenced from code comments, so they stay stable.)*

**Only real, official-source programs may ever be served. A verdict card must never cite a source the user cannot check. A demo beat is never worth a fabricated citation.**

This is a postmortem, not a precaution. It is written here because its absence caused a real failure.

### What happened
The engine ships two seed sets:

| | |
|---|---|
| `KyufyCore.import_dir` → `db/seeds/programs/*.yml` | **Serve this.** Real programs; each requirement quotes its 要綱 verbatim, with a retrieval date and a live `official_url`. |
| `KyufyCore.import_yaml` → `db/seeds/tokyo_programs.yml` | **Never serve this.** The engine's illustrative fixture set, for its own tests. |

`db/seeds.rb` loaded **both**, and it reached production. The fixture set's own header says: *"illustrative content for the MVP demo — NOT an authoritative reproduction of any real program's 要綱."* Its 要綱 excerpts are invented and attributed to real authorities (国税庁 / 東京都福祉局 / 新宿区), and all five of its `official_url`s are dead. On the live 新宿区 demo, **4 of 8 cards were fabricated — including both 該当 results.** A public site about public money was citing sources that do not exist.

Remediated: `import_dir` only (5 programs, 12 requirements), production purged 10 → 5, every remaining URL re-verified 200.

### Why it was invisible
1. **The system test seeded differently from production** — it called `import_yaml` too, so it validated the same bad data and could never have caught this. Tests must load exactly what `db/seeds.rb` loads.
2. **A status-code check would have passed.** `https://www.nta.go.jp/teigakugenzei` returns **302 → an error page that answers 200**. So `test/models/seed_integrity_test.rb` matches on **URL, not HTTP status** — the guard is a deny-list of known-dead URLs and fixture program names, not a liveness probe.

### Standing rules
- `db/seeds.rb` calls `KyufyCore.import_dir` and **never** `KyufyCore.import_yaml`.
- Adding a program means adding a real one to the engine's official-source seed, with a verbatim 要綱 quote, retrieval date, and a URL verified to resolve — including its redirect target.
- **Never add data to make a demo look better.** That pressure is precisely what let the fixtures in. If verified data cannot demonstrate a claim, cut the claim (see §5, where the cross-municipality beat was cut rather than back-filled).
- `test/models/seed_integrity_test.rb` fails the build if fixture programs or known-dead URLs reappear; the system test additionally pins the allowed citation hosts. Extend both when the seed grows.

---

## 0. Position in the architecture
```
kyufy_core   (public gem, MIT)      … assessment engine. No UI.
kyufy-web    (this repo, public)    … thin Rails app. Hotwire + plain Tailwind UI. Mounts kyufy_core.  ← hackathon demo & submitted デモURL
kyufy-shell  (future, private)      … Jumpstart Pro commercial shell. Replaces kyufy-web at monetization phase.
```
- kyufy-web exists so the hackathon MVP has a real screen without dragging in Jumpstart Pro (overkill: MVP needs no auth/billing) and without polluting the public gem with paid UI code.
- **Deployed with Kamal 2** onto the maintainer's existing Hetzner instance, sharing it with several other Rails apps. Image on `ghcr.io`; `kamal-proxy` routes by host, so all of them share ports 80/443; PostgreSQL runs as a same-host accessory bound to localhost. Domain: **kyufy.com** (Cloudflare DNS → Hetzner, Proxied). Host inventory, IPs, ports, and the deploy runbook live in `docs/LOCAL.md` (gitignored) — **never commit them here; this repo is public.** `config/deploy.yml` therefore reads the server address from `KYUFY_DEPLOY_HOST` rather than hardcoding it.
- **TLS**: Cloudflare is in **Flexible** mode, matching `proxy.ssl: false` — the origin speaks plain HTTP. Rails sets **both** `assume_ssl` and `force_ssl`; `force_ssl` alone against an HTTP origin is the classic Flexible-mode redirect loop. The Cloudflare→origin hop is unencrypted, which is acceptable for this no-PII demo but must become Full (strict) before kyufy-shell handles billing.
- **Cross-municipality generality is a design capability, not a demo beat.** `KyufyCore::Geo` normalizes free-text residence to JIS X 0401/0402 codes across all 47 prefectures and the 20 政令指定都市 (including さいたま市 and its 10 wards), with designated-city ward→parent resolution and a fail-safe carve-out when normalization fails. That is what makes the engine municipality-agnostic. It is stated in prose because the *served* seed currently covers Tokyo programs only — we do not perform a demo we cannot back with verified data (§5).
- **Future migration note (public summary)**: the billing production app (kyufy-shell) will run on a separate instance; cutover is a Cloudflare A-record flip (Proxied → instant switch, instant rollback). kyufy-web stays alive until the shell is proven — no "point of no return" migration day.

## 1. Stack
- **Rails 8.1.3 / Ruby 4.0.6**, plain `rails new` (no Jumpstart Pro). Repo name `kyufy-web` (hyphen; apps use hyphens, only the gem uses underscore `kyufy_core`). Rails app module: `KyufyWeb`.
- **Hotwire (Turbo + Stimulus)** for the chat flow. No React.
- **Tailwind CSS (plain utilities — no Tailwind Plus, no component kits)** for the UI (forms, cards, badges, layout), styled per docs/PALETTE.md. The single screen is simple enough to hand-build.
- PostgreSQL + pgvector (required by the mounted engine).
- Gems: `kyufy_core`, tailwindcss-rails, rails-i18n, kamal. Keep it minimal.
- **The engine is pinned to a released tag**, resolved from its public repo — no side-by-side checkout, and CI/deploy need no credentials:
  ```ruby
  gem "kyufy_core", git: "https://github.com/kyufy-jp/kyufy_core.git", tag: "v0.1.1"
  ```
  A tag rather than tracking `main` so the demo cannot shift underfoot mid-hackathon. To take an engine change: tag a release there → bump `tag:` here → `bundle update kyufy_core`. To work against an unreleased change, point at a local checkout temporarily (`path: "../kyufy_core"`) and don't commit it.
- Conventions: mainstream Rails SaaS-template conventions. **This repo is PUBLIC — pasting any code from paid templates (Jumpstart Pro etc.) would be redistribution; write all code fresh, imitate shape only.** (Maintainer-local reference paths live in `docs/LOCAL.md`, gitignored.)

## 2. UI scope — ONE screen (the 壁打ち screen)
A single chat-style page. Flow:

1. **Intake**: a short form or first chat turn collecting the Profile per SPEC §7 (age / residence 市区町村 / household_size / **prior_year_income_jpy** (label it 前年の所得 — 所得, not 収入) / employment / target individual・business). Prefer a compact form for MVP (faster than free-text parsing); free-text chat is stretch.
2. **Follow-up questions (逆質問)** — *as implemented; this is a decided scope, not a shortfall.* When the engine reports an undeterminable requirement, it may attach a `follow_up` question to that reason. Exactly one of those is **answerable inline**: 住民税は非課税ですか?（お住まいの通知書で確認できます） — because it is the only canned question with a matching `Profile` field (`resident_tax_exempt`). Answering it re-posts the enriched profile and re-assesses. See `AssessmentsController::ANSWERABLE_FOLLOW_UPS`.

   Every other undeterminable requirement — child's birthdate (018サポート), 障害者手帳の有無 (東京ゼロエミポイント), purchase/installation conditions — renders as a **要確認 card carrying its 要綱 citation and the question as guidance**. That is the correct fail-safe: the card tells the user exactly what to verify and where, rather than guessing at a 該当. Expanding `Profile` with fields like `has_disability_certificate` or a child birthdate is **post-MVP**, to be done only if demo rehearsal shows those 要確認 cards feel weak.
3. **Verdict cards**: one card per Program, streamed via Turbo Streams:
   - Badge: 該当 / 非該当 / 要確認
   - Program name + category chip (給付金/補助金/助成金/手当/控除) + authority (所管)
   - Per-requirement reasons: verdict + explanation + **quoted 要綱 excerpt** (visually distinct, e.g. left-border blockquote) + link to `official_url` + **license attribution when present** (small text under the quote, e.g. 「出典: ○○（CC BY 4.0）」 — the reason's `license` field from SPEC §7; nil → omit the line). This is the endpoint of the license-threading chain; CC BY compliance is satisfied here.
   - Fixed disclaimer at the card footer: 「これは参考判定です。最終確認は各制度の公式窓口で行ってください。」
4. **Empty/edge states**: no matching programs → friendly guidance; engine error → apologetic retry.

That's the whole app. No nav to build beyond a header with the kyufy logo/wordmark and a footer (disclaimer + GitHub link to kyufy_core).

## 3. Visual design — Palette 19 (Refactoring UI)
Character: Enterprise — indigo trust + warm orange accent. Chosen because: indigo reads as public-money trustworthy without copying デジタル庁 blue or Zaim green; orange carries the positive "money you can receive" energy; supporting colors map 1:1 to the three verdicts.

### Tailwind version & config — canonical source: `docs/PALETTE.md`
**Decided: Tailwind v4** (what tailwindcss-rails currently bundles; CSS-first). Do not pin v3. Design tokens live in `application.css` as an `@theme` block — copy it verbatim from PALETTE.md. The block **wipes Tailwind's default palette** (`--color-*: initial`, then re-declares white/black) so only the kyufy palette is usable: `bg-indigo-500` or `text-gray-600` will simply not exist, which structurally prevents off-palette drift — especially in generated code. If a build error points at an unknown color utility, that's the discipline working; use the palette equivalent from PALETTE.md's UI-role table.
**Do not hand-type color values from this SPEC.** The single source of truth for all scales is `docs/PALETTE.md`, which contains the full 10-shade values (Hex + HSL) for every family — primary (Indigo) / accent (Orange Vivid) / neutral (Cool Grey) / success / danger / warning, plus a reserved-unused magenta — with a copy-paste `theme.extend.colors` block and a UI-role quick-reference table. Copy the config from there verbatim. (An earlier revision of this SPEC embedded an abridged config with partial supporting scales; that duplication caused drift and is intentionally removed — PALETTE.md wins.)

### Usage rules
- **Neutrals dominate (60–70%)**: page bg `neutral-50`, card bg white, headings `neutral-900`, body `neutral-700`, borders `neutral-100/200`.
- **Primary (indigo)**: main CTA (判定する) `primary-500`, hover `primary-400`, active `primary-700`; links `primary-600`; chat bubbles (assistant) `primary-50` bg.
- **Accent (orange)**: sparingly — the single most important CTA on screen, or highlighting the 該当 count in a summary line. Never for large surfaces.
- **Verdict badges** (pill style): 該当 = `success-700` text on `success-50` bg; 非該当 = `danger-600` on `danger-50`; 要確認 = `warning-600` on `warning-50`.
- **要綱 quote block**: `neutral-50` bg, `primary-300` left border, `neutral-700` text, cite link `primary-600`.
- Contrast: all chosen text/bg pairs above meet WCAG AA; keep it that way when adjusting.

## 4. Implementation notes
### Localization (Japanese-monolingual — not i18n abstraction)
"Out of scope: i18n beyond Japanese" means no locale switching — it does NOT mean skipping Japanese setup. Without this, Rails-generated strings (validation errors, number/date helpers) come out in English and leak into the demo:
- `config.i18n.default_locale = :ja`, `config.i18n.available_locales = [:ja]`.
- Add the **rails-i18n** gem — supplies Japanese ActiveRecord/ActiveModel error messages ("〜を入力してください") and date/number formats. Without it, an empty intake field shows "Age can't be blank" mid-demo.
- **Verdict labels live in `config/locales/ja.yml`** (`kyufy.verdicts.eligible: 該当` / `ineligible: 非該当` / `needs_review: 要確認`) — the engine returns symbols (SPEC §7); the mapping is used by badges, cards, and tests, so centralize it.
- All other screen copy (form labels, disclaimer, follow-up prompts) may be written directly in views — extracting every string to locale files is overkill for MVP.

- Controller flow: `AssessmentsController#create` → `KyufyCore.assess(profile:)` → renders verdict cards as a **Turbo Stream response** appended to the chat frame. Note: responses, not broadcasts — there are no channels and nothing is pushed over a socket, which is why production Action Cable is `async` and the box runs no Redis. Follow-ups re-post the enriched profile.
- Session-only state; nothing persisted about the user (mirrors the engine's no-PII rule). The app has **no models of its own**: `IntakeForm` is an ActiveModel value object, and every persisted table belongs to the mounted engine.
- One Stimulus controller for the chat form UX (disable-on-submit, scroll-to-latest).
- **Seeds: `KyufyCore.import_dir` only — 5 real programs, 12 requirements.** See the data-provenance rule above; this is the one line in this file that must not be "improved" for demo purposes.
- LLM adapter configured in an initializer, switched by ENV. **`KYUFY_LLM=null` is the default and what production runs**: the engine's deterministic Null adapters, zero credentials and zero network, so the demo cannot die on stage from a rate limit or outage. `anthropic` (`KYUFY_ANTHROPIC_API_KEY`) and `openai`/`opencode` (`KYUFY_OPENAI_*`) are opt-in. Verdicts always come from the engine's rules — the LLM only writes the grounded explanation prose, so switching adapters cannot change a 該当 into a 非該当.

## 5. Demo choreography (what the 1-minute video shows)

Every beat below is reproducible against the live site with the served seed. Nothing here is
aspirational — if a beat stops matching reality, change the beat, not the data.

### Path A — the full verdict spread (primary)
1. Land on kyufy.com → clean intake form.
2. Enter **18歳 / 新宿区 / 3人世帯 / 前年の所得 864,000円 / 自営業** → submit.
   *Why this profile:* it produces all three verdicts **from real programs alone** — old enough to fail 子育て応援＋ and the 雇用保険 requirement, young enough to qualify for 018サポート. The earlier 52歳 profile yields no 該当 from verified data, and reaching for a 該当 anyway is exactly what let the fixture set in.
3. **4 verdict cards stream in — 該当 1 / 非該当 2 / 要確認 1:**

   | Verdict | Program |
   |---|---|
   | 該当 | 018サポート |
   | 非該当 | 子育て応援＋（プラス） |
   | 非該当 | 一般教育訓練給付金 |
   | 要確認 | 東京ゼロエミポイント |

   Each card shows its verbatim 要綱 excerpt, a working official link, and — on 一般教育訓練給付金 — the license attribution 「出典: 厚生労働省（PDL1.0）」, closing the license-threading chain.
4. Scroll to show the disclaimer + kyufy_core GitHub link in the footer.

### Path B — means-testing and the 逆質問 (second path)
Switch residence to **杉並区**. 杉並区エアコン購入費助成 appears as 要確認 and the engine surfaces its 逆質問: **住民税は非課税ですか?（お住まいの通知書で確認できます）**. Answer はい inline → the profile re-posts and the requirement resolves. This demonstrates the 壁打ち loop and means-tested assessment on real data.

### Cut: the cross-municipality beat
Earlier drafts switched residence to さいたま市中央区 to show cross-municipality generality. **That beat is cut.** The Saitama program it relied on was part of the illustrative fixture set and has been removed; a さいたま市中央区 resident now correctly sees only the national program. The capability is real and lives in `KyufyCore::Geo` (§0), so it is stated in prose — but it is **not** performed, and a Saitama program will **not** be added to the seed to restore it. Back-filling data to rescue a demo beat is the same pressure that produced the fabricated citations; the rule outranks the beat.

## 6. Out of scope (MVP)
Auth, billing, accounts, マイナ/freee real integration (mock or absent), multi-page navigation, i18n beyond Japanese, dark mode.
