---
title: DestCap guard now reads `services.EffectiveDestBalance(dest)` = `max(dest.Balanc
tags: [technical-writer, repo:mobiz-payment-gateway, current, pullout, destcap, balance-mapping, cross-repo-sync]
created: 2026-05-01
source: services/pulloutDemand.go:88-96@e1496a2 + scheduler/scheduler.go@e1496a2 + controllers/PullOutTaskController.go@e1496a2 + controllers/BotConfigController.go@e1496a2
project: github.com/kokarat/mobiz-payment-gateway
---

# DestCap guard now reads `services.EffectiveDestBalance(dest)` = `max(dest.Balanc

DestCap guard now reads `services.EffectiveDestBalance(dest)` = `max(dest.Balance, dest.AvailableBalance)` (mobiz `e1496a2` #345, 2026-04-30). Replaces direct reads of `destBank.Balance` at all four DestCap call-sites: scheduler/scheduler.go (legacy PullOutScheduler path), controllers/PullOutTaskController.go (manual ExecuteNow), controllers/BotConfigController.go (drain branch + new demand-refill branch).

Why max instead of either field directly: bank-bot SCB balance mapping was swapped on 2026-04-30 (companion bank-bot PR #110) so `system_banks.balance` may now carry "ยอดเงินสดที่ใช้ได้" (after-holds cash) and `available_balance` carries the account total. Because the swap rolls out gradually across the fleet, different bots write the two fields with opposite meanings during the transition. The DestCap guard cares about account total (the number bank operators don't want to overflow), so reading whichever field currently carries the larger number is a defensive read that picks account-total side regardless of which mapping the scraping bot is on. Erring high prevents overflow; erring low at worst delays one tick.

Repro that motivated the fix: bank `8204104078` reached balance 155k against a 99.5k–105.5k cap band on 2026-04-30 because guard saw 38k of after-holds cash instead of the ~90k account total — pullout headroom calc accepted a 66k random pullout that pushed the total past cap.

`MarkSuccess` pre-credit (services/withdrawalQueue.go:879-933@b23a903) `$inc`s both fields equally so they stay in sync after pullouts settle — `EffectiveDestBalance` is forward-compatible with that path. Returns 0 when `dest == nil`. Sister to `IsPayoutDest` and called in lockstep at every guard call-site.

Cross-repo sibling: bank-bot 84e6649 (PR #110) shipped the same day; both fixes ship independently.

---
*Added via Oracle Learn*
