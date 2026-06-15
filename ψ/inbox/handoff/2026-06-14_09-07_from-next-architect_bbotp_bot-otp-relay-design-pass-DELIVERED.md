# next-architect → bbotp: Bot OTP Relay #next gateway design-pass DELIVERED (Phase A)

**2026-06-14 · campaign bbotp · branch `campaign/bbotp` · PR #494 · Oracle thread #19**

Phase A step 1/2 (next-architect) DONE. next-pm follows (promotes BBOT-010, gated on this).
Phase B build team (next-dev / next-tester / next-code-reviewer / next-investigator) fires after.

## What this is
The missing **#next Supabase-gateway design** for the bot-OTP relay. Premise-corrected thread
#19: `mb-next-bank-bot/docs/flows/bot-otp-relay.md` is the **#current** bank-bot FLOW (Go/Mongo),
NOT a #next design — the relay was Deferred Phase-2 (`epic-bank-bot-integration.md:36`), stubbed
PHASE2_NOT_PORTED, no `bot-otp` EF. Owner GO'd the pull-forward (orchestrator-relayed); I ruled
the open design decisions.

## Deliverables (committed, PR #494 → main)
- `docs/design/bot-otp-relay/README.md` — build-ready contract (§1 read EF · §2 write EF · §3
  schema · §4 single-use · §5 composition map · §6 promotion · §7 §ADR-6 amendment text · §8
  Phase-B handoff)
- `docs/design/bot-otp-relay/schema.sql` — illustrative DDL (otp_logs + get_bot_otp/save_bot_otp
  + otp_producer_credentials + verify_otp_producer + grants + 24h sweep). NOT a migration.
- `docs/adr.md` — §ADR-6 §Amendment 2026-06-14 (OR1/OR2/OR3), ratification-pending/reviewer-gated.
- `next-architect_bbotp_findings.md` (worktree root).

## The rulings (binding)
1. **bot-otp READ EF** = `GET /functions/v1/bot-otp/:acc/:ref`; auth **§ADR-7 BK7 bot key**
   (`botKeyAuth`, per-account) — the `bot-config` pattern; G6-D JWT does NOT bind (BK1 superseded).
   Response `{success,data:{otp,source,reference_code,expires_at}}` FIDELITY-BINDING; 404
   collapses expired/never-posted.
2. **bot-otp-log WRITE EF** = `POST /functions/v1/bot-otp-log`; producer auth = **dedicated
   FLEET-SCOPED `otpp_…` HMAC credential**, distinct from bot key + BBOT-007 sim-secret, no
   per-account binding. Append-only, no Idempotency-Key. SIM uses `env='sim'` cred row.
3. **otp_logs** = `bank_account_id` FK (no user_id), index `(bank_account_id, otp_expires_at
   DESC, reference_code, created_at DESC)`, TTL 5min on `app_now()` (§ADR-20 T1), SV7b/SV8 posture.
4. **single-use = EXPIRY-ONLY, NOT consume-on-read** (breaks unmodified-bot reread + lost-OTP/no
   KTB IMAP fallback; replay already covered by 1:1 binding + K2 revoke + bank single-use).
5. **promote** via §ADR-6 §Amendment + new **BBOT-010** in epic-bank-bot-integration ("Phase-2
   pulled forward").

## Authority
Pull-forward = owner-GO'd (orchestrator-relayed; not directly witnessed). OR1–OR3 + BBOT-010 =
architect-authored, **next-code-reviewer-gated**, owner-merge (§ADR-6 Fargate / BK1–BK7 pattern).
No code rides this amendment.

## Next actors
- **next-pm:** author BBOT-010, move line-36 Deferred row, set cross-refs (§ADR-6 Amendment /
  §ADR-7 BK7 / §ADR-9 WC1 / BBOT-005/006/007). Gated on PR #494.
- **next-dev (Phase B):** migration (otp_logs + RPCs + otp_producer_credentials + verify_otp_producer
  + mint port + pg_cron) off schema.sql; bot-otp EF (botKeyAuth); bot-otp-log EF (new
  `_shared/otp-producer-auth.ts`). Decide `OTP_PRODUCER_ENC_KEY` vs reuse `BOT_CRED_ENC_KEY`.
- **next-tester:** virtual-clock expiry (app_now advance→404); ref vs `_`; binding matrix; dup
  collapse; cross-account read denial.
- **brew-ops (parallel):** bank-bot `getOTP` → README §1.4 envelope; SIM OTPService → sim producer
  cred; fidelity test vs a bot-otp stub.
