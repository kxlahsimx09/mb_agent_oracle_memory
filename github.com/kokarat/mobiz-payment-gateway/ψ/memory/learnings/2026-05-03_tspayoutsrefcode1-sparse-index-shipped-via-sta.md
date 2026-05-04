---
title: ts_payouts.ref_code_1 sparse index shipped via standalone migration script (`scr
tags: [technical-writer, repo:mobiz-payment-gateway, current, payout, data-model, index, ref_code, sparse, migration-script, 2caec4c, pr-386]
created: 2026-05-03
source: scripts/create_payout_ref_code_index.go:1-57@2caec4c
project: github.com/kokarat/mobiz-payment-gateway
---

# ts_payouts.ref_code_1 sparse index shipped via standalone migration script (`scr

ts_payouts.ref_code_1 sparse index shipped via standalone migration script (`scripts/create_payout_ref_code_index.go`, 2caec4c #386, 2026-05-03), idempotent and **not** wired into `db/indexes.go` so backend startup does not retry it. Pairs with the new shape-routed `GetAllPayouts` ID-like default branch (case-sensitive `^prefix` on `ref_code`) — without this index the case-sensitive prefix would still COLLSCAN (`ts_payouts` previously had no `ref_code` index at all; `ts_deposits` already had its parallel sparse index from #300). Sparse so legacy partner-routed payout rows that omit `ref_code` don't bloat the index. Already executed against production at PR-merge time (verified IXSCAN 0ms in commit message). Pattern: per-collection custom indexes that don't fit the central `db/indexes.go` lifecycle (because they need to land mid-cycle, or their absence isn't critical to correctness — only perf) ship as one-shot Go scripts under `scripts/create_*_index.go`, run manually, idempotent on existing-index error.

---
*Added via Oracle Learn*
