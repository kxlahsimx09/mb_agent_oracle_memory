---
title: Export refresh — TxnId/RefCode columns + shared YYYYMMDD date parsing + new Appl
tags: [technical-writer, repo:mobiz-payment-gateway, current, deposit, payout, export, csv, tenant-filter, super-admin]
created: 2026-05-04
source: controllers/DepositController.go:1939-2080@b04976e + controllers/PayoutController.go:1386-1487@b04976e + helpers/export_date_filter.go:1-57@b04976e + helpers/tenant_filters.go:37,236-260,279@b04976e + helpers/export.go:74-100@b04976e
project: github.com/kokarat/mobiz-payment-gateway
---

# Export refresh — TxnId/RefCode columns + shared YYYYMMDD date parsing + new Appl

Export refresh — TxnId/RefCode columns + shared YYYYMMDD date parsing + new ApplyPayoutTenantFilters (b04976e #395, 2026-05-05). Both ExportDeposits and ExportPayouts now (a) emit `TxnId` (=request_id) and `Ref Code` (=ref_code) CSV columns, (b) sort by `created_date_bkk DESC` to match the list endpoints (and reuse the same indexes), (c) parse date-range via the new `helpers.ApplyExportCreatedDateBKKRange(filter, startDate, endDate)` which accepts BOTH compact `YYYYMMDD` (8 digits, what the list page sends) and `YYYY-MM-DD` / `YYYY-MM-DD HH:MM:SS` via `ParseDateTimeBKK`. End-of-day for plain dates rolls to `235959` only when the parsed value is exactly midnight. ExportPayouts: the prior bespoke `group="client" + username → clients lookup` self-resolution branch is **deleted**, replaced by the new `helpers.ApplyPayoutTenantFilters` which scopes partners by `mdr_profile_id: {$in: partner.MDRProfileIDs}` (or returns empty via `_id=NilObjectID` if the partner has no profiles or a malformed JWT) and otherwise routes through `resolveClientScopeFromJWT`. Admin client_id override on both export handlers now also accepts `user_type == "super_admin"` (was `admin` / empty only). `helpers/export.go` `FormatDateTime` and `FormatDate` now render in Asia/Bangkok timezone (was UTC). The same super_admin scope addition lands in `helpers/tenant_filters.go::resolveClientScopeFromJWT` and `ApplyBankAccountTenantFilters`. Payout CSV column order changed: prior trailing `Request ID` column dropped (data moves into the new `TxnId` column at position 2). Deposit CSV adds `TxnId` after `ID` and `Ref Code` between `Matched` and `Notes`.

---
*Added via Oracle Learn*
