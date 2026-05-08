---
title: `buildEntityLogFilter` (commit `39141ff`, PR #423, 2026-05-07) now resolves the 
tags: [technical-writer, repo:mobiz-payment-gateway, current, wallet-change-log, buildEntityLogFilter, wallet-owner-union, audit-trail, schema-divergence]
created: 2026-05-07
source: controllers/WalletChangeLogController.go:203-225,414-477@39141ff
project: github.com/kokarat/mobiz-payment-gateway
---

# `buildEntityLogFilter` (commit `39141ff`, PR #423, 2026-05-07) now resolves the 

`buildEntityLogFilter` (commit `39141ff`, PR #423, 2026-05-07) now resolves the wallet up-front and unions `entity_id` over `[wallet._id, wallet.owner_id]` so a single audit query surfaces rows written under both legacy schemas. The drift it papers over: `PayoutRequestController` writes its wallet-change-log row with `entity_type=wallet, entity_id=wallet._id`, while `PayoutController` admin-cancel and `MaintenanceCancelScheduler` refunds write `entity_type=client, entity_id=client._id` (= `wallet.owner_id`) for the *same money*. Production case `PAY1778147890YG2SPK` showed only the deduct on the wallet's audit page even though the matching refund existed in `wallets_change_logs` — the single-ID `entity_id` filter caught one half. The helper is shared by `/wallet-change-logs/entity/:entityId` (admin), `/wallet-change-logs/me`, `/wallet-change-logs/me/export`, and `ExportEntityWalletChangeLogs`. Lookup uses a 3-second context (find by `_id`, fall back to `{owner_id: entityID}`) and falls back to the original single-ID filter if neither matches, so non-wallet legacy callers don't break. Adds ~5ms (one wallet `FindOne`) per request. `GetWalletChangeLogsByEntity` previously built its own inline operation/date filter; the same PR pointed it at `buildEntityLogFilter`, which means it now also gains the `?search=` `$or` over `note`/`reason`/`changed_by` (was admin-list-only before) and the wallet/owner union — operation + date-range semantics unchanged. `GetWalletChangeLogsStats` is global aggregation and still does not pass through this helper. The doc'd longer-term fix (called out in the commit message) is to standardize on `entity_type=wallet` at the write paths and backfill historical rows; this PR is explicitly a backend-only union, no migration.

---
*Added via Oracle Learn*
