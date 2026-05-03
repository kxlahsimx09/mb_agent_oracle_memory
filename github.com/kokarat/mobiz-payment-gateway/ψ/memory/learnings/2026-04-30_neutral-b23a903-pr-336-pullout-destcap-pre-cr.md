---
title: NEUTRAL — b23a903 (PR #336) Pullout DestCap pre-credit + settled-unsynced reserv
tags: [tester, repo:mobiz-payment-gateway, current, coverage-gap, pullout, withdrawal-queue]
created: 2026-04-30
source: services/withdrawalQueue.go@b23a903 + services/pulloutDemand.go@b23a903 + scheduler/scheduler.go@b23a903 + integration-tests/test-*.sh (zero pullout-queue exercise)
project: github.com/kokarat/mobiz-payment-gateway
---

# NEUTRAL — b23a903 (PR #336) Pullout DestCap pre-credit + settled-unsynced reserv

NEUTRAL — b23a903 (PR #336) Pullout DestCap pre-credit + settled-unsynced reserve — no test impact + 🟢 coverage gap

What landed: two-layer fix to the dest-cap window between MarkSuccess and the next bot balance scrape.
  Layer 1 — services/withdrawalQueue.go::MarkSuccess pre-credits system_banks.{balance, available_balance} on the dest bank inside the success transaction for source_type=pullout (matched by bank_code + account_number; balance_updated_at deliberately NOT touched so the bot scrape remains the canonical "last scrape" marker). Best-effort: log on failure but don't abort. External destinations (no matching system_bank) silently match zero rows.
  Layer 2 — services/pulloutDemand.go::SumSettledPulloutAmountsToDest reserves settled-but-unsynced pullout amounts (status=success completed AFTER destBank.BalanceUpdatedAt, capped to a 15-min window) in the headroom check. Wired into three callsites: scheduler.executeTask, PullOutTaskController.ExecutePullOutTaskNow, BotConfigController.SyncBalance. Effective balance is now: destBank.Balance + pending + settled-unsynced. Skip / reduce log lines updated to break out the two reserved totals.

Why NEUTRAL: zero integration-tests/test-*.sh files exercise pullout-queue mechanics end-to-end. grep -l "/pullout-tasks\|pullout_tasks" test-*.sh → empty. The single "pullout" match in test-payout-ktb-post-otp-waiting-to-review.sh:12 is a header-comment narrative line. Pre-credit is gated on source_type == "pullout"; existing tests use payout / settlement / topup / direct_transfer source_types and therefore see no pre-credit. The headroom helper is invoked only from pullout-specific call paths.

Coverage gap (filed 🟢 Nice-to-have): no integration test validates the pre-credit semantics, the settled-unsynced 15-min window, or the operator-visible skip/reduce log lines that distinguish the two reservation totals. Deferred under the same "no pullout integration test exists" umbrella as PRs #316/#322/#323. The umbrella now lists 4 PRs (316/322/323/336) — candidate for a focused integration test once a pullout dest-bank harness exists.

Impact if unfixed: zero on the existing 44 tests; pullout dest-cap regression risk continues to live operationally without a tripwire.

---
*Added via Oracle Learn*
