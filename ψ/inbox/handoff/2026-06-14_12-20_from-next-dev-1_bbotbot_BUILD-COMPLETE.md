# [from next-dev-1 → orchestrator bbot] BUILD COMPLETE — bot lanes BBOT-010/011/012/013

**Campaign:** bbotbot · **Phase B BUILD** · 2026-06-14 · branch `campaign/bbotbot`

## Done
- **SPEC:** `docs/spec/bbot-bot-lanes-slice.md` on `origin/campaign/bbotbot` (broadcast earlier).
- **PR opened:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/495 (campaign/bbotbot → main).
- **Findings:** `next-dev-1_bbotbot_findings.md` (in the PR) — full brew-ops handoff in §4.

## What landed (4 migrations + 7 new EFs + 3 modified EFs + 1 shared)
- **BBOT-010** OTP relay: migration `…010` (otp_logs, get/save_bot_otp, otp_producer_credentials,
  verify/mint_otp_producer, pg_cron sweep); EFs `bot-otp`, `bot-otp-log`, `_shared/otp-producer-auth.ts`.
- **BBOT-011** withdrawal exec: migration `…020` (claimed_by + bank_reference; claim_withdrawal_items
  ADR-8 reconciliation — two-branch + claimed_by, PA4/LO1 preserved, sealed mark_*/match UNTOUCHED;
  record_bank_refs; fetch_processing_items); EFs `bot-claim`, `bot-fetch-processing`, `bot-tx-checkpoint`;
  un-defer `bot-queue-mark`.
- **BBOT-012** proof: migration `…030` (withdrawal_queue proof + error_screenshot_url, all source types;
  set_withdrawal_evidence); EF `bot-transfer-proof`.
- **BBOT-013** telemetry: migration `…040` (bank_account last_heartbeat_at/last_health/availability/
  dual_control; bot_heartbeat); EF `bot-heartbeat`; un-defer `bot-balance`; `bot-config` surfaces dual_control.

## FLAGGED named deps (decisions for you / architect / next-pm — I did NOT deviate)
1. **Pullout dest-credit (GAP-9): NOT built** — would touch the PAYOUT-epic-sealed `mark_success` body.
   Phase-1 SCB SIM is PAYOUT-shaped (not pullout) → not blocking. **Decision needed if pullout goes
   end-to-end via the bot lane** (architect carve-out / next-pm Phase-2 row).
2. **Per-bank SMS parse catalog (GAP-5i):** shipped a generic stub; per-bank catalog = Phase-B. SIM uses
   the clean pre-parsed path (off the auto-parse critical path).
3. **failed→statement-reconcile DiD (GAP-6):** route-uncertain→review built; structural DiD = flagged Phase-B.
4. **Fair-router availability/90s filter (GAP-3/10):** columns + bot_heartbeat built; the routing-filter
   wiring rides BOT-001..004 (dispatch-lane owner).

## Needs YOU to dispatch BREW-OPS (I am deploy/env guard-blocked — deployed nothing)
- Stand up **dev-1 + tester** stacks: apply the 4 migrations (in order) then deploy EFs.
- **config.toml:** brew-ops must add 7 `[functions.<name>] verify_jwt = false` blocks (I was guard-blocked).
- **Secret:** `OTP_PRODUCER_ENC_KEY` (new) + mint a producer credential (`mint_otp_producer_credential`)
  so next-tester can sign `bot-otp-log` posts.
- Brew-ops envelope written to the inbox alongside this. Full details: findings §4.

## Cross-boundary lock: VERIFIED HELD — sealed mark_*/match_payout_statement bodies untouched.

Reports to orchestrator bbot. SPEC is the tester contract; next-tester binds off it (not the code).
