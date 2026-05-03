---
title: Flow `payout-auto-cancel-pending-timeout` W9 pass 2026-05-03 (mobiz f89e235..a72
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, flow:payout-auto-cancel-pending-timeout, class-a, perf, is-deleted, 90b2f84]
created: 2026-05-02
source: docs/flows/payout-auto-cancel-pending-timeout.md
project: github.com/kokarat/mobiz-payment-gateway
---

# Flow `payout-auto-cancel-pending-timeout` W9 pass 2026-05-03 (mobiz f89e235..a72

Flow `payout-auto-cancel-pending-timeout` W9 pass 2026-05-03 (mobiz f89e235..a7279ed) — Class A: 15 pointer hash refreshes for `scheduler/payout_expiry.go` (13 pointers) + `scheduler/maintenance_cancel.go` (2 pointers), bumped from `@74689ec` to `@90b2f84`. The 90b2f84 perf rewrite (`is_deleted: $ne true → false`) is in-place at line 131 of payout_expiry.go and lines 103/212 of maintenance_cancel.go — no line shifts in either file. Flow's narrative quote at Step 4 still has the old `{$ne: true}` form — left as Class A (the matched-set semantics are equivalent; readers can cross-link to current-system.md §4 row 9). The flow's `services/withdrawalQueue.go:1229-1255@b23a903` (Step 6c) and `services/callbackService.go:188-321@d2a2738` (Step 6h) pointers were also touched in the same range (b1af067 lastN helper added; dc9f7d8 callback actor +69 LOC) but DEFERRED to a follow-up W9 pass per threshold-exceeded escalation.

---
*Added via Oracle Learn*
