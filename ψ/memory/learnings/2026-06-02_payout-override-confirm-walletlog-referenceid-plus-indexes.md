---
title: payout override + confirm-completed wallet logs now carry reference_id/reference_type (#510) + 2 wallets_change_logs compound indexes
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - payout
  - wallet
  - wallet-change-log
  - mongodb-index
  - perf
created: 2026-06-02
source: controllers/PayoutController.go:1806,1844,2058,2117@bb02f02; db/indexes.go:78,81@bb02f02
related:
  - 2026-04-15_drift-scheduler-intervals
project: github.com/kokarat/mobiz-payment-gateway
---

W2 track-commit pass (a9a3acb..bb02f02, 2026-06-02). PR #510 `bb02f02`.

## Write-side fix — reference_id/reference_type on override + confirm wallet logs

Four `wallets_change_logs` rows were being created with **unset** `reference_id`/`reference_type`:

- `PayoutController.OverridePayoutStatus` → `mdr_distribution_reversed` (L1806) + `payout_override_refund` (L1844)
- `PayoutController.ConfirmPayoutCompleted` → `payout_confirm_completed` deduct (L2058) + per-partner `mdr_distribution` (L2117)

Because #505 (`a9a3acb`) had just rewired the `/wallet-change-logs` admin search-by-PAY-id path to `resolveSearchToReferenceID()` (looks up `ts_payouts` and filters the indexed `reference_id` instead of a `note` `$regex`), these nil-reference rows became **invisible** to a search even though they existed. Reported case: `PAY1780341235HG6XK0` — a `payout_override_refund` row (+302.40) existed but search returned 0.

Fix sets `ReferenceID = payout.ID` + `ReferenceType = "payout"` on all four, matching the normal payout-create flow (PayoutController.go:746-747). **Forward-fix only**: historical rows stay unlinked; companion one-off `scripts/backfill_payout_wallet_change_log_reference.go` patches prod (dry-run default, `--apply` to write; parses `PAY<10+digits>` from `note`; idempotent on already-set rows). The shared `mdr_distribution` op (also used by deposit/topup/settlement) forced a `note`-prefix Mongo filter + a tightened `\bPAY\d{10,}[A-Z0-9]+\b` regex to avoid scanning 1.9M unrelated rows and matching "PAYMENT"/"PAYABLE" tokens — ampay dry-run: 1,975 updated, scan 1.9M→2K, 0 phantom payout-missing.

## Index fix — two compound indexes on wallets_change_logs

Declared in `db/indexes.go` (so `main.go` `EnsureIndexes()` auto-creates them per brand at boot — repo convention, no standalone migration):

- `{created_at:-1, _id:-1}` — base timeline. Default admin list (no filter, sort `created_at` DESC) was COLLSCAN + in-memory SORT over ~4M rows. Ampay 2026-06-02: **5,182 ms → ~1 ms**.
- `{operation:1, created_at:-1, _id:-1}` — operation-dropdown filter: **2,730 ms → ~1 ms**.

Both align with the controller sort tuple `SetSort(bson.D{{created_at,-1},{_id,-1}})` (the `_id` tie-breaker came from #498 `444a061`). `{reference_type:1,…}` deliberately skipped (no UI filter for it); existing sparse `reference_id_1` already serves search-by-PAY-id.

## Doc

Documented in `docs/current-system.md` §3 `/api/v1/wallet-change-logs` bullet (extends the #505 clause). PR #507 amended (cumulative a011daf..bb02f02). `docs/.baseline` held at `a011daf` — Finance API #483 (`db65a15`) still deferred to a dedicated W1.
