---
title: Dispatcher tests without real bot must drain assigned queue items + unlock banks
tags: [tester, repo:mobiz-payment-gateway, current, dispatcher, test-infrastructure, helper-pattern, no-real-bot, flow:withdrawal-queue-dispatch-and-claim]
created: 2026-04-24
source: scheduler/withdrawal_dispatcher.go:475-548 + services/withdrawalQueue.go:603-615 + integration-tests/test-dispatcher-stale-bot-skip.sh
project: github.com/kokarat/mobiz-payment-gateway
---

# Dispatcher tests without real bot must drain assigned queue items + unlock banks

Dispatcher tests without real bot must drain assigned queue items + unlock banks between iterations, or the per-bank cap (1-5 tier-random) blocks further assignment

`scheduler/withdrawal_dispatcher.go:475-548` (`findBestBankForItem`) caps assignment per bank per round:

```go
inflight := bankInitialQueueLoad[bank.ID] + int64(bankAssignedCount[bank.ID])
if inflight >= int64(cap) { continue }
```

where `cap` is tier-randomized (1..5 for <5 items, 3..5 for 5-19, 4..5 for 20-99, 5 at ≥100). `bankInitialQueueLoad` comes from `services.OutstandingCountForBank` which counts `status IN (pending, processing)` for that bank. In a no-real-bot test, items stay `pending` after the dispatcher assigns them (no MarkSuccess to drain). Over several iterations, Bank A accumulates inflight items until `inflight >= cap` — then dispatcher refuses to assign more even though Bank A is the only eligible bank (e.g., when Bank B is stale).

Similarly, `dispatchForBank` locks the bank's `working_status` to `busy` after each round (`:660`), and `findIdleBanks` filters `working_status in ["ready", "", null]` (`:329-332`) — so subsequent rounds can't even consider the bank unless unlocked.

Fix pattern — runtime-iteration helpers that are TEST-ONLY, not production:

```bash
# Drain assigned items so OutstandingCountForBank stays low
drain_bank_queue() {
  mongo updateMany(
    {system_bank_id: {$in: [A, B]}, status: {$in: ["pending","processing"]}},
    {$set: {status: "success", completed_at: ..., updated_at: ...}}
  )
}

# Reset working_status after dispatchForBank busy-locks it
unlock_both_banks() {
  mongo updateMany({_id: {$in: [A, B]}}, {$set: {working_status: "ready"}})
}
```

Call both helpers after each enqueue iteration AND in the final `wait_for_assignment` poll loop. Without them, runtime iteration hits 4/5 timeout and the assertion can't run.

Tester `test-dispatcher-stale-bot-skip.sh` (2026-04-24) uses this pattern. Future dispatcher-behavior tests (stale-timeout + post-fail reconcile PR #249, idle-only dispatcher PR #239, per-bank cap PR #237) will likely need the same helpers — consider hoisting into `integration-tests/helpers/setup-infra.sh` once a 2nd or 3rd test needs them.

Safety note: `drain_bank_queue` bypasses services.MarkSuccess entirely — skips the goroutine side effects (MDR distribution, wallet reversal, callbacks, SSE). That's fine for dispatcher-routing tests (not asserting on those side effects), but if a future test needs the side-effect path exercised, it should use the real `/bot/queue/:id/success` endpoint instead.

---
*Added via Oracle Learn*
