---
title: Drift in `payout-auto-reconcile-from-statement` Q(a) — matcher auto-reconcile pa
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, unimplemented-alert-surface, flow:payout-auto-reconcile-from-statement, payout, matcher, auto-reconcile, w4-queue]
created: 2026-04-22
source: services/transactionMatcher.go:1001-1010@4aaec2c + services/payoutReconciliation.go:146-158@4aaec2c
project: github.com/kokarat/mobiz-payment-gateway
---

# Drift in `payout-auto-reconcile-from-statement` Q(a) — matcher auto-reconcile pa

Drift in `payout-auto-reconcile-from-statement` Q(a) — matcher auto-reconcile path's wallet-insufficient-balance dead-end has no alert surface. When `ReconcileFailedPayoutToCompleted` at `services/payoutReconciliation.go:149` aborts the session transaction because `client.wallet.balance < payout.amount + payout.fee`, the statement at `services/transactionMatcher.go:971-985` has already flipped `match_status="matched"` (non-session write, persists), the transactions row at `:994` has been inserted (non-session write, persists), but the reconcile itself is a no-op — `finalizePayout` at `:1009-1010` logs `[Matcher] Auto-reconcile FAILED for %s: %v` and swallows. No SSE event, no Telegram alert, no admin surface. Payout stays `failed`, client wallet stays refunded, merchant keeps seeing the `payout.failed` callback as authoritative, but the bank actually debited — classic double-refund setup if merchant processes the failed callback and re-credits their end-user. The existing recovery path (admin `PUT /payouts/:id/confirm-completed`) faces the same balance constraint, so manual admin resolution is also blocked unless the wallet is back to a consistent state. Ratified 2026-04-22 via Oracle thread #37 Q(a) as **drift — needs PR** (same disposition as deposit sibling `2026-04-19_drift-deposit-auto-match-finalizedeposit-does-no.md`); code_reviewer sign-off required per AGENTS.md §9 financial code. Suggested remediation shape: publish distinct SSE event (e.g., `payouts/reconcile_blocked`) and Telegram alert to ops within 15-minute SLA window so manual resolution is possible before double-refund window closes. Not fixed in this W8 pass (pg-writer authors docs, not code). Related: 2026-04-19 deposit-side drift on different failure mode (wallet FindOne error proceeds anyway) — this one is session-abort (cleaner failure) but still silent-alert gap.

---
*Added via Oracle Learn*
