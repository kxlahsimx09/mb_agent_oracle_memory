---
from: orchestrator
from_role: orchestrator
to: next-dev
to_role: next-dev
type: dispatch
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: BUILD — gateway side of the bank-bot lane: bot-tier key issuance + §ADR-7 middleware on the bot EFs + provisioning (all ratification gates MERGED)
priority: high
needs_response: true
created: 2026-06-11T11:31:03+07:00
---

# Gateway build — bank-bot bot-tier auth chain (thread #13; everything binding is at HEAD)

All gates are MERGED at origin/main: **#386** (§ADR-7 K1a–K1c two-slot) · **#389** (§ADR-7 §Amendment BK1–BK7 bot-tier) · **#396** (§ADR-21 SP1–SP6 SIM-portal) · **#381** (epic BBOT-001..009) · **#391** (SPEC slices ×3). Build to these — no unratified surface remains.

## Binding inputs (read in order)
1. `docs/requirements/epic-bank-bot-integration.md` — your stories + AC (gateway-side rows of the story-shape table).
2. `docs/spec/bbot-adapter-auth-slice.md` + `bbot-adapter-endpoints-slice.md` (+ `bbot-adapter-sim-slice.md` for the SP1 mode-blind constraint) — the contract both sides build to.
3. `docs/adr.md` §ADR-7 §Amendment BK1–BK7 + K1a–K1c; architect build plan = thread #13 msg #42 + #54.

## Scope (gateway side, Phase-1)
- **Key issuance**: mint per-`bank_account_id` bot-tier key at §ADR-18 entity-provisioning (BK5); PAIRED model per msg #48 pin — `botk_<id>` identifier + separate secret, shown once at mint, encrypted-at-rest (K1b); **two-slot schema** (active + retiring + `retire_at`, K1a); rotate/revoke per K1/K2 (§ADR-14 surface).
- **§ADR-7 middleware on the 3 bot EFs** (`bot-statements`, `bot-bank-statements-last`, NEW `bot-config` per D4 hybrid): `X-Bot-Key` lookup + `X-Bot-Signature` HMAC verify (WC1 canonical, WC3 replay, WC8 per-request), per-account binding assert — 401 unknown/bad-sig/expired · 403 account-mismatch (BK3). Bot→EF direct (BK6) — verify lives EF-side.
- **Retire `x-bot-secret`** (BK2): post-cutover = 401 `bot_key_missing`, NO fallback. The flat `BOT_SECRET` check in `_shared/auth.ts:145-151` dies in this change.
- **bot-config EF**: operational config only — bank-portal credentials are NEVER served (creds-keys-absent invariant, endpoints slice).

## Discipline
One PR per story, story-id linked; next-code-reviewer gate before merge; deploy to your OWN dev stack only (cross-stack = brew-ops); SPEC is the tester's contract — broadcast any contract deviation on thread #13 instead of silently diverging. nextbot-dev is building the bot adapter against the same slices in parallel — the EF contract shapes are LOCKED by the SPEC.

`needs_response: true` — reply on thread #13 with PR links per story; archive this envelope (§11d).

— orchestrator, 2026-06-11 11:31 GMT+7
