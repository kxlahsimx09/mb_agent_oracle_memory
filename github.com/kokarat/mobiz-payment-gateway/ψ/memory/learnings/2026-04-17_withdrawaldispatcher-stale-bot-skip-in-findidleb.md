---
title: WithdrawalDispatcher: stale-bot skip in `findIdleBanks` (PR #206, f7f43bc).
tags: [technical-writer, repo:mobiz-payment-gateway, current, scheduler, withdrawal-queue, bank-bot]
created: 2026-04-17
source: scheduler/withdrawal_dispatcher.go:387-396@f7f43bc
project: github.com/kokarat/mobiz-payment-gateway
---

# WithdrawalDispatcher: stale-bot skip in `findIdleBanks` (PR #206, f7f43bc).

WithdrawalDispatcher: stale-bot skip in `findIdleBanks` (PR #206, f7f43bc).

Banks whose `bot_last_checked` is more than **5 minutes** stale are now skipped during dispatch — even if `bot_status` is still `online`. Implemented in `scheduler/withdrawal_dispatcher.go:387-396`:

```go
if bank.BotLastChecked > 0 {
    lastChecked := bank.BotLastChecked.Time()
    staleMinutes := time.Since(lastChecked).Minutes()
    if staleMinutes > 5 {
        log.Printf("[WithdrawalDispatcher] Bank %s (%s) skipped: bot status stale (%.0f min since last update)", ...)
        continue
    }
}
```

Subtle behaviour worth remembering:
- **`BotLastChecked == 0` (never reported) is NOT treated as stale.** The guard is `> 0`. A freshly seeded bank that has never gotten a heartbeat passes through this check.
- The bank is **skipped** for the current tick — not unlocked, not flipped offline. So `bot_status` remains whatever it was. Next tick, same skip if still stale.
- The 5-minute threshold is hardcoded, not driven by `app_settings`.
- Sits **after** the offline/error skip and **before** the maintenance-window skip in the filter loop.

Why it matters for ops: a bot whose process died but never updated `bot_status` (e.g. SIGKILL, host reboot) used to keep getting dispatched until the next bank-status report. Now dispatch stops within 5 min of the last heartbeat regardless of stored status.

---
*Added via Oracle Learn*
