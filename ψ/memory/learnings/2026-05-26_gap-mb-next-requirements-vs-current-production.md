---
title: gap — mb-next Phase-1 requirements vs current production (campaign #225 sub-B, #current-lens)
tags:
  - technical-writer
  - repo:cross
  - migration-map
  - current
  - target
  - deposit
  - payout
  - pullout
  - settlement
  - scheduler
  - withdrawal-queue
  - rbac
  - otp
  - callback
created: 2026-05-26
source: mb-next docs/requirements/@b8facce vs docs/current-system.md@16467ff (kokarat/mobiz-payment-gateway); thread #227 / campaign #225
project: github.com/kxlahsimx09/mb-next-payment-gateway
related:
  - 2026-05-25_drift-callback-url-ssrf-guard-is-create-time-only
---

#current-lens coverage-gap analysis (campaign #225 sub-task B; complements next-writer's internal-completeness pass #226). Measures mb-next's authored Phase-1 requirement epics against what current production actually does. Full report on Oracle thread #227 msg 1017.

**Key insight:** #226 found the authored epics (deposit/payout/match/wallet-ledger/topup/bot-dispatch) *internally* clean vs their own ADRs. An internal pass CANNOT see where an epic silently drops a CURRENT behavior — that gap set is below.

## Gaps INSIDE the internally-clean authored epics (no recorded decision)
- **A1 [HIGH] Per-bank maintenance-window payout cancel.** Current `cancelPendingOnMaintenanceBanks` (scheduler/maintenance_cancel.go@0424cdc #417) cancels+refunds pending payouts on any bank entering its OWN `maintenance_time`. mb-next: system-wide bulk-cancel flagged UNRATIFIED (PAYOUT-008); deposit-side deferred (epic-deposit:204); per-bank variant **unmentioned**.
- **A2 [MED-HIGH] Fair-router per-bank withdrawal amount-range.** Current findBestBankForItem skips banks outside `withdrawal_min_amount..withdrawal_max_amount` for payout/settlement/DT/pullout (@ae6f523 #335). BOT-001 filter list omits it (distinct from balance / max-outstanding).
- **A3 [MED] Per-client API rate-limit on create.** Current per-client per-scope per-min+per-day caps (helpers/ratelimit.go@33664cd/@c7b2232). DEPOSIT-001/PAYOUT-001 ACs have no request-rate cap (§ADR-11=dedup≠rate). Absent from requirements layer.
- **A4 [MED] Slip-bearing-deposit expiry — OPPOSITE outcome, not flagged.** Current #460 (9aebabb 2026-05-22) EXCLUDES slip-bearing pending from expiry → escalates to admin. mb-next DEPOSIT-004 three-timer model "deadline first → expired" would auto-expire+callback. Divergence w/o recorded decision (model likely predates #460).

## Planned-epic surfaces (no epic yet; overlap w/ #226) — production do-not-lose
- **Settlement**: create→debit, approve→MDR distribute, reject/cancel→refund, waiting_to_review=int 3, CSV export, UPDATE/DELETE removed by design (DRIFT-7).
- **Pullout** (highest loss risk): 4 time strategies (jitter/window/weighted/burst + overnight), opt-in demand-refill, DestCap random bands, two-layer in-flight reservation (pending + settled-unsynced 60-min floor), source-side reservation.
- **Direct Transfer**: one-shot bank-to-bank + deposit-refund-via-DT (SyncDepositRefundStatus, refund_pending_review) — refund half = DEPOSIT-011 (deferred).
- **Auth/RBAC/OTP/Callback-core/Admin-Audit/Fleet/Monitoring/Idempotency**: 2FA mandatory all user logins + step-up TOTP on money-out; DB-driven RBAC + dynamic menu; tenant-ownership guard; OTP dual-source (email+SMS auto-parse); force-logout UNWIRED (DRIFT-14); Telegram MDR reports + broadcast + wallet-alert; bank-statement admin read; BankAccount approval workflow.

## Deliberate divergences (RECORDED — not gaps)
Terminal success/rejected-vs-failed (§ADR-9 TS); append-not-destructive + 202 all-tier resend; computed available (§ADR-10 AM1); raw callback_url rejected→preconfigured snapshot (§ADR-9/#223 — closes the create-time-only SSRF drift [[2026-05-25_drift-callback-url-ssrf-guard-is-create-time-only]]); Idempotency-Key REQUIRED (§ADR-11 new); server-derived request_id; SSE→Supabase Realtime; MDR mdr_skip no-silent-drop (§ADR-10 D4); stuck-claim always→review (§ADR-4a 2026-05-16); drop PUT …/success|failed admin endpoints; V13/V14 enforced + V3 + V1 single-path (§ADR-4d); count-dedup NULL-safe; DEPOSIT-006/011 deferred.

## To ratify (Bucket D): A1 (per-bank maintenance keep/drop), A4 (slip-expire escalate-vs-expire).
