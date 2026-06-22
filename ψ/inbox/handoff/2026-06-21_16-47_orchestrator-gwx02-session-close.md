---
from: orchestrator (campaign 41-o-business-gap)
date: 2026-06-21T16:46:00+07:00
topic: SESSION CLOSE — GW-X-02 Model-B over-draw: decided → ADR → built → reviewed → sealed → MERGED; deploy routed to brew-ops
status: code DONE + merged to main both repos; only deploy (brew-ops) + live-test (live-tester) remain
tags: [#repo:mb-next-payment-gateway, #repo:mb-next-bank-bot, #gw-x-02, #41-o-business-gap, #handoff, #session-close, #orchestrator]
---

# Handoff → next session: GW-X-02 Model-B — code merged, deploy pending brew-ops

## What got done this session (full chain, one sitting)
Owner picked GW-X-02 (withdrawal over-draw) from the `41-o-business-gap` parity register and drove it end-to-end:
1. **Decision**: Model B = reserve-at-claim (`available = balance − reserved`; claim reserves, settle no-op, fail/sweep release, bot-scrape overwrite+reset, stale-balance freshness reject+alert). Owner confirmed (c) separate in-flight pass NOT needed.
2. **Ratified + MERGED** ADR/AC — PR #681 → `793daf5` (§ADR-4a §Amendment 2026-06-21 + `docs/spec/withdrawal-balance-reservation-slice.md` AC-1..9 + open-questions §2 + parity GW-X-02 row).
3. **Built + reviewed + sealed + MERGED both sides:**
   - Gateway **PR #682 → `ff216fe`** — migration `20260621000900` + EF `bot-balance` (4-arg). pgTAP **47/47**.
   - Bankbot **PR #35 → `403c2c9`** — un-stub `updateBalance`, push `{balance, available_balance, scraped_at}`, miss≠zero.
   - Adversarial review caught 1 BLOCKER (stale-base migration) + 2 money bugs (scrape-reset boundary; CHECK-stuck-claim); seal caught the `balance_updated_at` bot-clock trust boundary (fixed with `LEAST(scraped_at, app_now())` clamp).

## What REMAINS (not code)
1. **DEPLOY — brew-ops single-owner** (deploy-env-guard blocks the orchestrator window). Envelope ready: `ψ/inbox/for-brew-ops/2026-06-21_16-32_from-orchestrator_deploy-gwx02-model-b.md` (full runbook: `ψ/inbox/handoff/2026-06-21_16-29_brewops-deploy-gwx02-model-b.md`).
   - ⚠️ MONEY-CRITICAL ORDER: STAGING first → **bankbot BEFORE gateway** → warm-up backfill `balance_updated_at` → prod. Inverting freezes the withdrawal lane (freshness guard reject-all).
   - ⛔ Dispatch was NOT triggered: the `brew-ops-fleet-town2` window had **unsent input "ลบ wt-46 ทิ้งเลย"** in its box — do NOT `maw wake`/send-keys over it (would corrupt). Clear that input first, then `maw wake brew-ops` to deliver the envelope. (brew-ops also flagged a duplicate `wt-46-o-business-gap` worktree making fuzzy wake ambiguous — wt-41 is the live one.)
2. **LIVE test J1–J4** — next-live-tester: `ψ/inbox/handoff/2026-06-21_13-25_livetest-gwx02-overdraw-journey.md`.
3. **next-pm**: post-deploy, flip parity GW-X-02 Resolution → "merged #682/#35 · deployed".

## Still owner-pending in 41-o-business-gap (short list)
GW-REC-01 (self-healing parser), BOT-D-02 (SCB browser-recycle), GW-SCH-02 (maintenance lockdown), + blacklist gap (#2 — in bizgap findings but NOT in the master register; verify/add).

## Retro
`ψ/memory/retrospectives/2026-06/21/16.45_orchestrator-gwx02-model-b-overdraw-build-merge.md`
