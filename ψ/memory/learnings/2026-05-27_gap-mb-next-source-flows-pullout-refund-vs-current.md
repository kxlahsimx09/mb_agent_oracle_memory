---
title: gap — mb-next epic-source-flows vs current production (campaign #239 sub-B / thread #241, post-#228/#234)
tags:
  - technical-writer
  - repo:cross
  - migration-map
  - current
  - target
  - pullout
  - direct-transfer
  - deposit
  - settlement
  - scheduler
  - withdrawal-queue
  - rate-limit
  - login-security
created: 2026-05-27
source: mb-next docs/requirements/@12b9e1c vs mobiz code@2087fed (kokarat/mobiz-payment-gateway); thread #241 / parent campaign #239
project: github.com/kxlahsimx09/mb-next-payment-gateway
related:
  - 2026-05-26_gap-mb-next-requirements-vs-current-production
---

Second-pass #current-lens re-analysis after #228/#234 authored the 7 net-new epics. Verifies the freshly-authored epics against current production at HEAD. Full report on Oracle thread #241 msg 1111 + envelope `for-orchestrator/2026-05-27_09-56_from-pg-writer_thread-241_response.md`. All claims re-verified directly in mobiz code, not only via the code-mapping sub-agent.

## A3 rate-limits — now CLEAN (was prior-pass MED gap)
CLIENT-002 + AUTH-006 capture per-client/per-scope/dual-window/fail-open + exact prod caps (deposit 1000/min+600k/day, payout 1000/min+300k/day) as Phase-1 baseline. Matches `helpers/ratelimit.go` + `DepositRequestController.go:240` + `PayoutRequestController.go:212@2087fed`. Closed by #229/§ADR-11-A3. No action.

## B1 [MED] Pullout demand-refill — default-OFF + opposite trigger dropped
PULLOUT-001 (epic-source-flows.md@12b9e1c) frames 4 co-equal LIVE drain triggers; AC1 treats all as live. Production:
- Demand-refill is config-gated **default OFF**: `BotConfigController.go:562@2087fed` `if !helpers.GetAppSettingBool(SettingKeyPayoutDemandRefillEnabled, false) { return }`. Threshold default 50000, cooldown 10min (`services/pulloutDemand.go:370-384@2087fed`).
- Demand-refill fires on a payout **DEST balance LOW (pull in)** — OPPOSITE to the drain's source-too-full (push out); "sharing only the SyncBalance entry point" (`BotConfigController.go:557-560@2087fed`). Old threshold-drain chain `EvaluatePulloutRefill`/`IsRefillChain` removed 2026-04-27 (`pulloutDemand.go:21-26`). Live default-on auto-paths = scheduler-tick + manual only.
- PULLOUT-002 (S4 do-not-lose) cites the demand-refill learning but carries neither caveat.
Ask: mark demand-refill default-OFF (mirror PAYOUT-008 "ships off") + note dest-low refill condition.

## B2 [MED] DTR-001 "DT never touches a wallet" (S2) contradicted by prod deposit-refund-via-DT; DTR-002 drops money-movement half
DTR-001 edge + epic intro assert as S2 universal: "a direct transfer never touches a wallet … no freeze/settle step." Production deposit-refund IS a `direct_transfer` (`transfer_type="refund"`) that moves wallet money — `controllers/DepositController.go@2087fed`:
- `RefundDeposit:2553`, gated `enable_deposit_refund` default-false `:2556`, TOTP step-up.
- Wallet debit at create: `walletDebit := deposit.FinalAmount + refundFee` `:2731`; atomic `$inc {balance,available} -walletDebit` w/ `available:$gte` guard `:2735-2747`.
- Builds refund DTR `:2763-2789`; credits wallet back if insert fails `:2790-2794`.
- Uncertain → `deposit.status="refund_pending_review"`, admin reconciles via `ResolveRefund POST /deposits/:id/refund/resolve` `:2907,:3011-3094`; cancel/reject credits wallet back via `SyncDepositRefundStatus`.
DTR-002 (S4 "do-not-lose record of current behaviour") captures only "marked refund + reference + status syncs back" — omits the wallet debit/credit-back + refund_pending_review reconciliation.
The DEPOSIT-011/DTR-002 deferral (§ADR-4d thread #101) is a recorded decision, NOT the finding. Finding = unfaithful capture: DTR-001 universal has no refund carve-out; DTR-002 loses the production detail it exists to hold.
Ask: carve out refund subtype from DTR-001; enrich DTR-002 with wallet-movement + uncertain-state reconciliation (TOTP step-up plausibly covered by AUTH-007 — cross-ref).

## SECONDARY [LOW] account brute-force lockout lifecycle absent from AUTH-005
Prod: 5 failed logins → lock; users permanent `is_locked` (admin-unlock only), merchant/client/partner 15-min Redis window (`helpers/login_lock.go` MaxLoginAttempts=5; code-finder-sourced, not directly re-verified). AUTH-005 covers "rate-limited + audited" + delegates brute-force "to the platform"; permanent-lock-then-admin-unlock lifecycle not named. Likely deliberate platform-delegation; verify-not-assert.

## Scope + caveat
Deep-audited only source-flows + client-api + auth-rbac rate-limit (the 3 named surfaces). SETTLE-001/002 faithful post-M1/M2; partner-initiated settlement is an open-question, not a drop. NOT re-audited: match/wallet/topup/bot-dispatch/callback/admin-audit/fleet/monitoring. Analyzed vs committed HEAD 12b9e1c — main mb-next checkout had a dirty working tree (staged deletions of all 7 #228 epics + reverted INDEX/README; a wt-25 mid-op local artifact, not a requirements state).
