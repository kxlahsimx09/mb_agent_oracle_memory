---
title: Dispatcher stale-bot skip uses bot_last_checked; never-reported banks (BotLastCh
tags: [tester, repo:mobiz-payment-gateway, current, dispatcher, stale-bot, edge-case, discovered-while-testing, flow:withdrawal-queue-dispatch-and-claim]
created: 2026-04-24
source: scheduler/withdrawal_dispatcher.go:372-381@7557402 + models/system_bank.go:86-88 + integration-tests/test-dispatcher-stale-bot-skip.sh
project: github.com/kokarat/mobiz-payment-gateway
---

# Dispatcher stale-bot skip uses bot_last_checked; never-reported banks (BotLastCh

Dispatcher stale-bot skip uses bot_last_checked; never-reported banks (BotLastChecked==0) are NOT skipped by this filter

`scheduler/withdrawal_dispatcher.go:372-381` (PR #206 `f7f43bc`) adds a 5-minute staleness filter inside `findIdleBanks`. But the guard reads:

```go
if bank.BotLastChecked > 0 {
    lastChecked := bank.BotLastChecked.Time()
    staleMinutes := time.Since(lastChecked).Minutes()
    if staleMinutes > 5 { continue }
}
```

The `> 0` guard means banks whose `bot_last_checked` has never been set (field value = zero datetime) are **not skipped by this filter**. Those banks flow through to the next check in the pipeline. In practice, protection for never-reported banks relies on the earlier `bot_status: "offline"|"error"` filter (`:366-370`), which is the separate-source mechanism. If a bank was freshly created and no bot has ever called `POST /bank-status/report`, its `bot_status` may default to `""` (or whatever the model zero value is) — which is NEITHER "offline" nor "error" — so it might still be treated as eligible. Worth confirming against the model default in a future pass.

Tester `test-dispatcher-stale-bot-skip.sh` (2026-04-24) deliberately does NOT assert on this edge; filed here as the follow-up.

Related coverage-gap row worth auditing: `22451ef` "Stale-bot 5-min skip" used `working_at` as the field name in the proposed test description — that is wrong. The actual implementation reads `bot_last_checked`. The test uses the correct field; the gap row has been annotated.

---
*Added via Oracle Learn*
