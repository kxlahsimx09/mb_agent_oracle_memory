---
title: ## Auto-Reconcile Production Scenario: Why bank_statement exists before MarkFail
tags: [tester, repo:mobiz-payment-gateway, current, payout, withdrawal-queue, bank-statement, auto-reconcile, statement-scraper, race-condition, discovered-while-testing]
created: 2026-04-17
source: services/withdrawalQueue.go:960-968 (production incident comment) + conversation with user 2026-04-17 explaining Test B scenario
project: github.com/kokarat/mobiz-payment-gateway
---

# ## Auto-Reconcile Production Scenario: Why bank_statement exists before MarkFail

## Auto-Reconcile Production Scenario: Why bank_statement exists before MarkFailed

### The real-world race condition

In SCB dual-control flow, the bank executes the transfer at the APPROVER OTP step — money leaves the account at that moment. The bot may then fail to read the success confirmation (browser crash, network timeout, SCB page hang) and call `safeMarkFailed`, reporting the payout as failed even though the bank already transferred the money.

Meanwhile, the **statement scraper** (a separate process that scrapes Intraday transactions from the bank's internet banking page every 1-5 minutes) independently discovers the outgoing debit and the **matcher** links it to the withdrawal_queue item via amount + destination account matching, writing `matched_queue_id` + `match_status: "matched"` to `bank_statements`.

### Timeline (observed in production: PAY1776286617S2B53L, 2026-04-16)

```
t=0      Bot claims WQ item (pending → processing)
t=2min   Maker submits → bank executes transfer after OTP
t=3min   Statement scraper finds debit → matcher links to WQ
         (WQ is still "processing" at this point — not failed yet)
t=7min   Bot OTP timeout → MarkFailed → WQ "failed"
         → tryReconcileAfterMarkFailed goroutine fires
         → finds the already-matched statement
         → auto-flips payout back to "completed"
```

The statement can exist before MarkFailed because the bank transferred money at t=2min, the scraper found it at t=3min, but the bot didn't report failure until t=7min. The scraper and bot are independent processes racing against each other.

### Why this matters for test design

Test B (test-payout-auto-reconcile.sh, PR #180) plants a matched `bank_statement` row before calling MarkFailed. This mimics the production scenario where the scraper runs faster than the bot fails — which is the exact case observed on PAY1776286617S2B53L. The planted statement bypasses the matcher service (tested elsewhere) and targets only the `tryReconcileAfterMarkFailed` goroutine.

### Two possible timings the system handles

| Timing | What happens |
|---|---|
| Statement matched BEFORE MarkFailed | `tryReconcileAfterMarkFailed` goroutine finds it immediately → auto-flip (Test B exercises this) |
| Statement matched AFTER MarkFailed | The matcher's `finalizePayout` branch checks `payout.status == "failed"` and triggers reconciliation at match time (not covered by Test B — separate code path in the matcher) |

### Source references

- `services/withdrawalQueue.go:960-968` — comment documenting the PAY1776286617S2B53L incident
- `services/withdrawalQueue.go:987-1030` — `tryReconcileAfterMarkFailed` goroutine
- `services/payoutReconciliation.go:56` — `ReconcileFailedPayoutToCompleted` (shared by both auto and manual paths)
- PR #161 (commit `4828a6a`) — original auto-reconcile
- PR #172 (commit `c1ee2da`) — post-fail backward path fix after the production incident

---
*Added via Oracle Learn*
