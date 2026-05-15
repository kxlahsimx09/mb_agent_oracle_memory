---
title: OTP logs list endpoint gained an `acc_numbers` CSV query param at `controllers/O
tags: [technical-writer, repo:mobiz-payment-gateway, current, otp-logs, filter, csv-query-param]
created: 2026-05-12
source: controllers/OTPLogController.go:26-83@f736f63
project: github.com/kokarat/mobiz-payment-gateway
---

# OTP logs list endpoint gained an `acc_numbers` CSV query param at `controllers/O

OTP logs list endpoint gained an `acc_numbers` CSV query param at `controllers/OTPLogController.go:26-83@f736f63` (PR #429, 2026-05-11). The frontend's OTP Logs page resolves a bank/method dropdown choice into a list of account numbers via its in-memory `system_banks` lookup and sends them as one comma-separated string — this avoids joining `otp_logs` against `system_banks` or denormalizing the OTP records.

Three semantic details worth knowing: (1) `acc_numbers` takes precedence over the single-value `acc_number` because the single-value branch runs first and the multi-value branch overwrites `filter["acc_number"]` — frontend never sends both, but a hand-crafted request resolves to the multi-value list. (2) The handler `strings.TrimSpace`-and-drops blank entries, so `"acc1,,acc2"` and trailing commas don't widen the filter. (3) If every entry was blank/whitespace (e.g. `" , , "`), the filter is *not* dropped — it becomes `{$in: []}`, forcing zero results. Designer intent: a caller who explicitly asked to scope to nothing should not silently get "everything". (4) The MongoDB query stays index-eligible via the existing `acc_number_1_created_at_-1` compound index — `$in` over a small list (one bank's accounts) hits the index, no new index needed.

---
*Added via Oracle Learn*
