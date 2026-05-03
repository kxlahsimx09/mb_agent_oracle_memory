---
title: withdrawal_queue gained two derived lookup fields at b1af067 (#375, 2026-05-02).
tags: [technical-writer, repo:mobiz-payment-gateway, current, withdrawal-queue, perf, regex-to-equality, matcher, b1af067, pr-375]
created: 2026-05-02
source: models/withdrawal_queue.go:62-71@b1af067 + services/withdrawalQueue.go:282-285,1617-1625@b1af067 + services/transactionMatcher.go:1004-1027@b1af067
project: github.com/kokarat/mobiz-payment-gateway
---

# withdrawal_queue gained two derived lookup fields at b1af067 (#375, 2026-05-02).

withdrawal_queue gained two derived lookup fields at b1af067 (#375, 2026-05-02). `models.WithdrawalQueue.DestBankCodeLower` (`ToLower(TrimSpace(DestBankCode))`) and `DestAccountLast4` (last 4 chars of DestAccountNumber). Both `bson:"omitempty"`. Populated at enqueue time by `services.EnqueueWithdrawal` via the new `lastN` helper. The payout matcher's P3 fallback path in `services.matchPayout` (`services/transactionMatcher.go:1004-1027`) now queries `dest_bank_code_lower: <lowercased>` and `dest_account_last4: <last4>` for equality — replacing the prior `{$regex: "(?i)kbank"}` + `{$regex: "4396$"}` predicates, which disabled every index. Production observation 2 พ.ค. 2026 17:11 BKK: the regex query scanned the whole withdrawal_queue collection on every bank-statement scrape (one of the matcher's hottest call sites). Backfill via `scripts/backfill_withdrawal_queue_lookup_fields.go` — idempotent bulk-write filling both fields on legacy rows + creates the supporting compound index `{system_bank_account, amount, dest_account_last4, dest_bank_code_lower}`. Old code keeps working without the new fields (it simply ignored them); new code reads them. Migration must run BEFORE deploying the new query path so legacy rows match.

---
*Added via Oracle Learn*
