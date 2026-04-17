---
title: ## CORRECTION: Auto-Reconcile — OTP must have SUCCEEDED for statement to exist
tags: [tester, repo:mobiz-payment-gateway, current, payout, auto-reconcile, bank-statement, otp, race-condition, correction]
created: 2026-04-17
source: scheduler/withdrawal_dispatcher.go:777 + services/withdrawalQueue.go:960-968 + user correction 2026-04-17
project: github.com/kokarat/mobiz-payment-gateway
---

# ## CORRECTION: Auto-Reconcile — OTP must have SUCCEEDED for statement to exist

## CORRECTION: Auto-Reconcile — OTP must have SUCCEEDED for statement to exist

### Supersedes previous explanation

Previous learning (`2026-04-17_auto-reconcile-production-scenario-why-bankst.md`) incorrectly described the scenario as "OTP timeout → bank transferred anyway". This is wrong: if OTP was never received by the bank, the bank does NOT execute the transfer and no outgoing statement exists.

### Correct precondition for auto-reconcile

The bank statement (proof of transfer) can only exist if **the OTP was accepted by the bank and the transfer was executed**. The bot marks "failed" not because OTP failed at the bank, but because the bot **lost track of the successful result**:

1. **OTP confirmed but bot lost the response** — Bot clicks Confirm OTP → HTTP request reaches SCB → SCB validates + executes transfer → but bot's browser crashes / network drops / timeout before reading the success popup. Bot's error handler calls safeMarkFailed.

2. **Bot process crash after OTP** — OTP was entered and accepted. Transfer executed. Then bot process dies (OOM, Droplet restart). No one calls markSuccess. After 10 minutes the dispatcher's processing-timeout fires MarkFailed with message "bot may have crashed. Check bank statement before retrying." (scheduler/withdrawal_dispatcher.go:777).

3. **Ambiguous bank response** — SCB returns a non-standard page (session expired popup, blank page, error page) AFTER actually executing the transfer. Bot interprets the page as failure.

### The critical moment

```
Bot clicks "Confirm OTP"
    → HTTP POST leaves bot → arrives at SCB
    → SCB validates OTP → EXECUTES transfer (money moves)
    → SCB starts rendering response...
    
    ╔════════════════════════════════════════════════════════╗
    ║  Between OTP submit and reading the response is the   ║
    ║  window where "bank succeeded but bot doesn't know"   ║
    ║  can happen. Crash here = money moved + bot says fail  ║
    ╚════════════════════════════════════════════════════════╝
    
    → If bot reads success popup: markSuccess (normal path)
    → If bot crashes/timeouts here: markFailed (auto-reconcile case)
```

### Why pure OTP timeout does NOT trigger auto-reconcile

If bot never received OTP (email/SMS timeout) or never entered it → bank never received OTP → bank does NOT execute → no outgoing statement → tryReconcileAfterMarkFailed finds no matched statement → returns early → payout stays "failed" → admin must manually investigate.

This is Test A's scenario (PR #179), not Test B's.

### Correction to timeline

Wrong: "t=2min Maker submits → ธนาคารโอน" (maker alone doesn't cause transfer in dual-control)
Right: "t=2min Maker submits → transfer REQUEST created at bank. t=5min Approver enters OTP → bank EXECUTES transfer. t=7min Bot crashes → markFailed. Statement scraper finds the executed transfer."

The transfer happens at the APPROVER step (OTP acceptance), not the MAKER step.

### Source

- `scheduler/withdrawal_dispatcher.go:777` — processing timeout error message explicitly says "Check bank statement before retrying"
- `services/withdrawalQueue.go:960-968` — production incident PAY1776286617S2B53L
- Conversation with user 2026-04-17 who caught the logical error

---
*Added via Oracle Learn*
