---
title: `GET /api/v1/withdrawal-queue/stats` now honours the `source_type` query param (
tags: [technical-writer, repo:mobiz-payment-gateway, current, withdrawal-queue, api]
created: 2026-04-22
source: controllers/WithdrawalQueueController.go:177-227@29a57c1
project: github.com/kokarat/mobiz-payment-gateway
---

# `GET /api/v1/withdrawal-queue/stats` now honours the `source_type` query param (

`GET /api/v1/withdrawal-queue/stats` now honours the `source_type` query param (`controllers/WithdrawalQueueController.go:184,192-196@29a57c1`, PR #260, 2026-04-22). Previously the stats endpoint accepted `start_date` and `end_date` but ignored `source_type`, so the top-cards (Pending / Processing / Success / Failed totals) showed numbers across every source type even when the list below was filtered to a single source. Added path: the query param is read at line 184, and when non-empty, `matchFilter["source_type"]` is added before the `$group` pipeline. Empty/missing is a no-op — existing callers unaffected. Tenant-scope filter (`helpers.ApplyWithdrawalQueueTenantFilters`) still applies first, so source_type narrows the tenant-scoped result rather than bypassing it. This closes the UX mismatch between the list endpoint and the summary cards on the withdrawal-queue admin page.

---
*Added via Oracle Learn*
