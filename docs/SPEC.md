# kyufy-web — MVP Host App Design Spec (for Claude Code)

> Hand this document to Claude Code together with the engine spec (`docs/SPEC.md`, Rev 2.4 — this doc is synced to it: prior_year_income_jpy field, 新宿区 primary demo profile, license attribution on verdict cards, real-seed follow-up questions). Colors: `docs/PALETTE.md` is the canonical palette (§3 defers to it).
> Scope: the **thin MVP host app** that mounts the `kyufy_core` engine and provides the demo UI for the hackathon (壁打ち chat → verdict cards). No auth, no billing.
>
> Repo status: **public** (MIT). Tailwind Plus HTML components are used as part of a real application UI, which its license explicitly permits even for open-source End Products. Two obligations follow:
> 1. Add this note to the README: "UI components in this app are based on Tailwind Plus (licensed to the author). They are part of this application's UI; please do not extract and reuse them as standalone components/templates."
> 2. LICENSE is MIT for the application code; the README note above marks the Tailwind Plus-derived UI as the exception. Never turn this repo into anything resembling a component library or theme (that WOULD violate the Tailwind Plus license).
> The only strictly-private repo is kyufy-shell (Jumpstart Pro is paid, non-redistributable).
>
> Domain-term convention: same as kyufy-core — keep 給付金 / 補助金 / 助成金 / 手当 / 控除 / 要綱 / 該当 / 非該当 / 要確認 in Japanese. UI copy is Japanese (target users are Japanese speakers).

---

## 0. Position in the architecture
```
kyufy_core   (public gem, MIT)      … assessment engine. No UI.
kyufy-web    (this repo, public)    … thin Rails app. Hotwire + Tailwind Plus UI. Mounts kyufy_core.  ← hackathon demo & submitted デモURL
kyufy-shell  (future, private)      … Jumpstart Pro commercial shell. Replaces kyufy-web at monetization phase.
```
- kyufy-web exists so the hackathon MVP has a real screen without dragging in Jumpstart Pro (overkill: MVP needs no auth/billing) and without polluting the public gem with paid UI code.
- Deploys to the maintainer's existing Hetzner instance as one of several Rails apps. Domain: **kyufy.com** (Cloudflare DNS → Hetzner, Proxied). Host inventory, IPs, and the future kyufy-shell migration plan live in `docs/LOCAL.md` (gitignored).
- **Future migration note (public summary)**: the billing production app (kyufy-shell) will run on a separate instance; cutover is a Cloudflare A-record flip (Proxied → instant switch, instant rollback). kyufy-web stays alive until the shell is proven — no "point of no return" migration day.

## 1. Stack
- **Rails 8.1.3 / Ruby 4.0.6**, plain `rails new` (no Jumpstart Pro). Repo name `kyufy-web` (hyphen; apps use hyphens, only the gem uses underscore `kyufy_core`). Rails app module: `KyufyWeb`.
- **Hotwire (Turbo + Stimulus)** for the chat flow. No React.
- **Tailwind CSS + Tailwind Plus (HTML version)** components for the UI shell (forms, cards, badges, layout).
- PostgreSQL + pgvector (required by the mounted engine).
- Gems: `kyufy_core` (path/git), tailwindcss-rails. Keep it minimal.
- Conventions: mainstream Rails SaaS-template conventions. **This repo is PUBLIC — pasting any code from paid templates (Jumpstart Pro etc.) would be redistribution; write all code fresh, imitate shape only.** (Maintainer-local reference paths live in `docs/LOCAL.md`, gitignored.)

## 2. UI scope — ONE screen (the 壁打ち screen)
A single chat-style page. Flow:

1. **Intake**: a short form or first chat turn collecting the Profile per SPEC §7 (age / residence 市区町村 / household_size / **prior_year_income_jpy** (label it 前年の所得 — 所得, not 収入) / employment / target individual・business). Prefer a compact form for MVP (faster than free-text parsing); free-text chat is stretch.
2. **Follow-up questions (逆質問)**: if the engine reports undeterminable requirements, render the missing fields as follow-up prompts in the chat stream; user answers inline. Real-seed examples: child's birthdate (018サポート), 障害者手帳の有無 (ゼロエミポイント, age<65), 住民税は非課税ですか?（お住まいの通知書で確認できます） (杉並区/means-tested), and — when residence was coarser than a program's scope (ancestor admission) — どちらの区・市にお住まいですか?
3. **Verdict cards**: one card per Program, streamed via Turbo Streams:
   - Badge: 該当 / 非該当 / 要確認
   - Program name + category chip (給付金/補助金/助成金/手当/控除) + authority (所管)
   - Per-requirement reasons: verdict + explanation + **quoted 要綱 excerpt** (visually distinct, e.g. left-border blockquote) + link to `official_url` + **license attribution when present** (small text under the quote, e.g. 「出典: ○○（CC BY 4.0）」 — the reason's `license` field from SPEC §7; nil → omit the line). This is the endpoint of the license-threading chain; CC BY compliance is satisfied here.
   - Fixed disclaimer at the card footer: 「これは参考判定です。最終確認は各制度の公式窓口で行ってください。」
4. **Empty/edge states**: no matching programs → friendly guidance; engine error → apologetic retry.

That's the whole app. No nav to build beyond a header with the kyufy logo/wordmark and a footer (disclaimer + GitHub link to kyufy_core).

## 3. Visual design — Palette 19 (Refactoring UI)
Character: Enterprise — indigo trust + warm orange accent. Chosen because: indigo reads as public-money trustworthy without copying デジタル庁 blue or Zaim green; orange carries the positive "money you can receive" energy; supporting colors map 1:1 to the three verdicts.

### Tailwind config — canonical source: `docs/PALETTE.md`
**Do not hand-type color values from this SPEC.** The single source of truth for all scales is `docs/PALETTE.md`, which contains the full 10-shade values (Hex + HSL) for every family — primary (Indigo) / accent (Orange Vivid) / neutral (Cool Grey) / success / danger / warning, plus a reserved-unused magenta — with a copy-paste `theme.extend.colors` block and a UI-role quick-reference table. Copy the config from there verbatim. (An earlier revision of this SPEC embedded an abridged config with partial supporting scales; that duplication caused drift and is intentionally removed — PALETTE.md wins.)

### Usage rules
- **Neutrals dominate (60–70%)**: page bg `neutral-50`, card bg white, headings `neutral-900`, body `neutral-700`, borders `neutral-100/200`.
- **Primary (indigo)**: main CTA (判定する) `primary-500`, hover `primary-400`, active `primary-700`; links `primary-600`; chat bubbles (assistant) `primary-50` bg.
- **Accent (orange)**: sparingly — the single most important CTA on screen, or highlighting the 該当 count in a summary line. Never for large surfaces.
- **Verdict badges** (pill style): 該当 = `success-700` text on `success-50` bg; 非該当 = `danger-600` on `danger-50`; 要確認 = `warning-600` on `warning-50`.
- **要綱 quote block**: `neutral-50` bg, `primary-300` left border, `neutral-700` text, cite link `primary-600`.
- Contrast: all chosen text/bg pairs above meet WCAG AA; keep it that way when adjusting.

## 4. Implementation notes
- Controller flow: `AssessmentsController#create` → calls `KyufyCore.assess(profile:)` → broadcasts verdict cards via Turbo Streams into the chat frame. Follow-ups re-post the enriched profile.
- Session-only state; nothing persisted about the user (mirrors the engine's no-PII rule).
- One Stimulus controller for the chat form UX (disable-on-submit, scroll-to-latest).
- Seeds come from the engine's seed (3–5 programs). The app itself has no models beyond what the engine provides.
- LLM adapter configured in an initializer: OpenCode for demo, NullAdapter fallback via ENV so the demo never dies on stage (`KYUFY_LLM=null` → deterministic demo mode).

## 5. Demo choreography (what the 1-minute video shows)
1. Land on kyufy.com → clean intake form.
2. Enter profile (Tokyo 23-ward resident per SPEC Rev 2.2 — e.g. 新宿区 / 3人世帯 / child in household …) → submit. (Stretch demo beat: switch residence to さいたま市中央区 mid-demo to show cross-municipality generality.)
3. One 逆質問 appears (e.g. 前年所得) → answer inline.
4. Verdict cards stream in: one 該当 (green), one 要確認 (yellow), with quoted 要綱 + official links visible.
5. Scroll to show the disclaimer + kyufy_core GitHub link in the footer.

## 6. Out of scope (MVP)
Auth, billing, accounts, マイナ/freee real integration (mock or absent), multi-page navigation, i18n beyond Japanese, dark mode.
