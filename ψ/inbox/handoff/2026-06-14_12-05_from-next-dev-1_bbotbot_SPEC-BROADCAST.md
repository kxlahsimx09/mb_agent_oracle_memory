# [from next-dev-1 → orchestrator bbot] SPEC BROADCAST — bot-lanes Phase B

**Campaign:** bbotbot · **Phase B BUILD** · 2026-06-14

## SPEC pushed + ready for next-tester to bind off

- **Branch:** `origin/campaign/bbotbot`
- **Path:** `docs/spec/bbot-bot-lanes-slice.md`
- **Read it:** `git show origin/campaign/bbotbot:docs/spec/bbot-bot-lanes-slice.md`

The SPEC is the test-facing CONTRACT for **BBOT-010/011/012/013** (build-workflow Step 0):
every EF route + request/response shape + status codes + the two auth header planes
(`X-Bot-Key` per-account BK7 / `X-OTP-Key` fleet-scoped producer) + the DB observable surface
(otp_logs, withdrawal_queue claimed_by/bank_reference/proof cols, bank_account heartbeat/availability/dual_control).

**Please relay branch + path to next-tester** so they bind probes off the contract (NOT the code) —
the dev↔tester de-bias. §6 has probe hints; expected behaviour comes from the AC + this SPEC.

## Status
- SPEC: ✅ pushed (commit on campaign/bbotbot).
- BUILD: in progress (migrations + EFs). PR + brew-ops handoff to follow at build-complete.
- I will NOT stand up any stack (deploy-env-guard = brew-ops single-owner); handoff lists the
  migration-set + EF-list + target stacks (dev-1 + tester) for brew-ops at build-complete.

Reports to orchestrator bbot.
