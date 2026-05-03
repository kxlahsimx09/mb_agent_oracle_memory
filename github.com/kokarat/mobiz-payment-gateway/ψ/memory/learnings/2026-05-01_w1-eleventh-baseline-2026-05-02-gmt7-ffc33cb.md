---
title: W1 eleventh baseline (2026-05-02 GMT+7) — `ffc33cb..c5ee388` NEUTRAL across the 
tags: [tester, repo:mobiz-payment-gateway, current, w1-eleventh-baseline, validate-no-flip, pullout, restart-bot, ssh-refactor, destcap-window, summary]
created: 2026-05-01
source: docs/test-index.md @ c5ee388 + git log ffc33cb..c5ee388 + services/pulloutDemand.go:23-49 + services/botOpsService.go @ 08ab0b8
project: github.com/kokarat/mobiz-payment-gateway
---

# W1 eleventh baseline (2026-05-02 GMT+7) — `ffc33cb..c5ee388` NEUTRAL across the 

W1 eleventh baseline (2026-05-02 GMT+7) — `ffc33cb..c5ee388` NEUTRAL across the suite

Two production-surface commits in range — both NEUTRAL for all 46 tests; 0 status flips, 0 newly-broken, 0 newly-added.

Commit summary:
1. `c5ee388` (PR #351) — Pullout DestCap settled-unsynced window 15m → 60m, operator-tunable via app_settings key `pullout_settled_unsynced_window_minutes`. Tier 3 fix for the 2026-05-01 overflow incident on bank `4212114916` (peak 408,838 against 99.5k–105.5k cap; 14 large pullouts inside 24h with `amount == random_amount`). Touches `services/pulloutDemand.go::SumSettledPulloutAmountsToDest`. Static check: zero test-*.sh hits on `pullout_settled_unsynced_window_minutes` or `SumSettledPulloutAmounts`. Same pullout-coverage umbrella as PRs #316/#322/#323/#336/#342/#345 — no pullout integration test exists at all. New 🟢 coverage gap filed.
2. `08ab0b8` (PR #357) — `POST /api/v1/system-banks/:id/restart-bot` swapped from DO droplet-reboot (60–90s async, 202) to SSH `systemctl restart bank-bot && systemctl is-active bank-bot` (~5s sync, 200). New `SSH_PRIVATE_KEY` / `SSH_PRIVATE_KEY_PATH` env dependency on top of `DO_TOKEN`. 503 when secrets missing; 502 for upstream failures. Touches `services/botOpsService.go` + `controllers/SystemBankController.go::RestartBot`. Static check: zero test-*.sh hits on `restart-bot`, `RestartBot`, `botOpsService`, or `SSH_PRIVATE_KEY`. Same coverage gap as PR #346 (the original endpoint) — external dependencies make the action itself a poor integration-test candidate; permission gating deserves a permission-matrix assertion. Existing 🟢 row updated, not duplicated.

Carryover: prior baseline's STALE (test-settlement-cancel.sh), SUPERSEDED pair (test-payout-cancel.sh, test-raw-resp.sh), ON_HOLD pair (test-payout-confirm-completed.sh + test-payout-auto-reconcile.sh — Oracle thread #2), UNKNOWN pair (test-payout-override.sh + test-payout-ktb-post-otp-waiting-to-review.sh — thread #16) all unchanged. Neither `c5ee388` nor `08ab0b8` interacts with MarkFailed callback or the override/post-OTP routes, so the pending-thread set is unaffected.

Cadence note: this is a no-flip pass; per workflow §Step 5, no per-row arra_learn is mandatory (none of STALE/WRONG-SETUP/FLAKY rolled over with new findings). Filing this single summary entry to keep the W1 cadence searchable and to give future-me a paper trail on the two NEUTRAL commits without forcing a dedicated learning per commit.

---
*Added via Oracle Learn*
