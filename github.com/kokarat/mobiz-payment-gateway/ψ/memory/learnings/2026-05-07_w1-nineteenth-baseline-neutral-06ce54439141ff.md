---
title: W1 nineteenth baseline NEUTRAL — `06ce544..39141ff` (PR #423 only) — `wallet-cha
tags: [tester, repo:mobiz-payment-gateway, current, w1-nineteenth-baseline, neutral, wallet-change-logs, audit-trail, coverage-gap]
created: 2026-05-07
source: controllers/WalletChangeLogController.go:217-446@39141ff + integration-tests/test-*.sh (HTTP-endpoint grep returned 0 hits)
project: github.com/kokarat/mobiz-payment-gateway
---

# W1 nineteenth baseline NEUTRAL — `06ce544..39141ff` (PR #423 only) — `wallet-cha

W1 nineteenth baseline NEUTRAL — `06ce544..39141ff` (PR #423 only) — `wallet-change-logs` HTTP-filter union of wallet._id + owner_id is invisible to all 49 tests.

What happened: the only production-surface commit since W1 eighteenth (`06ce544`) is `39141ff` (PR #423), which fixes `controllers/WalletChangeLogController.go::buildEntityLogFilter` to look up the wallet (by `_id`, fallback `owner_id`) and emit `entity_id: {$in: [wallet._id, owner_id]}` so the paginated list, `/me`, CSV export, and `GET /wallet-change-logs/entity/:id` paths surface BOTH the `entity_type=wallet` deduct row written by `PayoutRequestController` AND the `entity_type=client` refund row written by admin-cancel + `MaintenanceCancelScheduler`. Stats endpoint untouched. Production case PAY1778147890YG2SPK was the trigger.

Why it's NEUTRAL across the suite: every test that touches `wallets_change_logs` does so via direct `mongosh` `db.wallets_change_logs.countDocuments(...)` queries — `test-payout-override.sh:451-468`, `test-payout-confirm-completed.sh:396-477`, `test-payout-admin-cancel.sh:259/343/383`, `test-payout-auto-reconcile.sh:474/535-560`, `test-settlement-confirm-review.sh:423/518-523`, `test-deposit-refund.sh:286-292`, `test-payout-ktb-post-otp-waiting-to-review.sh:397`, `test-payout-scb-post-otp-waiting-to-review.sh:405`. NO test calls the affected HTTP endpoint (`grep -lE "/wallet-change-logs/|/wallet-change-logs\?|api/v1/wallet-change-logs" integration-tests/test-*.sh` → 0 hits). Tests scope their counts by `reference_id` (the source operation's OID), which is independent of the entity_id key — so both `entity_type=wallet` and `entity_type=client` rows for the same payout share `reference_id` and the test sees both regardless of HTTP filter shape.

Why this matters for next session: the bug class PR #423 fixes (audit page misleading customers/ops by hiding half the audit trail behind a single-ID filter) is exactly the regression-tripwire shape that elevating coverage from "DB direct via mongosh" to "HTTP endpoint contract" would catch. A future refactor reverting to single-ID filter would be silent in the integration suite at HEAD. New 🟢 gap appended to `docs/test-coverage-gaps.md` covers this surface: seed two rows under both entity keys for the same wallet, call the HTTP endpoint, assert both rows return.

Counts: V=44, S=1, W=0, F=0, SUP=2, ON_HOLD=2, UNK=0 (49 total). Zero status flips. Pattern library not modified. No helpers/, no mock-bank/, no test changes in range.

---
*Added via Oracle Learn*
