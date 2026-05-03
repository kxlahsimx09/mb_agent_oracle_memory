---
title: Cross-repo sync — mobiz e1496a2 (#345 DestCap effective-balance fix) ↔ bank-bot 
tags: [technical-writer, repo:cross, repo:mobiz-payment-gateway, repo:bank-bot, current, cross-repo-sync, destcap, balance-mapping, pullout]
created: 2026-05-01
source: services/pulloutDemand.go@e1496a2 + bank-bot scb adapter@84e6649
project: github.com/kokarat/mobiz-payment-gateway
---

# Cross-repo sync — mobiz e1496a2 (#345 DestCap effective-balance fix) ↔ bank-bot 

Cross-repo sync — mobiz e1496a2 (#345 DestCap effective-balance fix) ↔ bank-bot 84e6649 (PR #110 SCB balance mapping swap), both landing 2026-05-01 GMT+7. Shared concept: `system_banks.balance` semantic was swapped on the bank-bot side so it now carries "ยอดเงินสดที่ใช้ได้" (after-holds) while `available_balance` carries the account total. The mobiz DestCap guard previously read `destBank.Balance` directly, underreporting dest liquidity on payout banks where the after-holds figure is below the account total — accepting pullouts that overflowed the account-total cap. Mobiz fix is defensive: reads `max(Balance, AvailableBalance)` via new `services/pulloutDemand.go EffectiveDestBalance(*SystemBank)` helper at all four guard call-sites (services/pulloutDemand.go, scheduler/scheduler.go, controllers/PullOutTaskController.go, controllers/BotConfigController.go). Erring high prevents overflow; erring low at worst delays one tick. Both PRs ship independently.

Trace link could not be added because mobiz W2 trace 5900d287 already has a prev link to the prior-day W9 chain head (67c366cd). Recorded as semantic sibling here per workflow-2 §Caveat. Sibling bank-bot trace: 16fe84a6-4805-4718-b4b3-8ccc3828cefc (track-commit 4b968a4..84e6649). Mobiz trace: 5900d287-20a2-4883-bef1-55e52e74c857.

---
*Added via Oracle Learn*
