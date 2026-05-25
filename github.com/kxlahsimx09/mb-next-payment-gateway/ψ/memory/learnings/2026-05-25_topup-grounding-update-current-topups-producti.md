---
title: topup grounding update — current `topups` production shape still supports §ADR-1
tags: [next-product-writer, repo:cross, migration-map, topup, client-self-topup, current-data, requirement-grounding, production-db-mcp, s2-ratified]
created: 2026-05-25
source: dpay MCP aggregate topups 2026-05-25 Asia/Bangkok; docs/adr.md §ADR-16
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# topup grounding update — current `topups` production shape still supports §ADR-1

topup grounding update — current `topups` production shape still supports §ADR-16, but the count has moved since the ADR proof.

During workflow-1 source sweep for the Client Self-Topup requirement epic on 2026-05-25, dpay MCP returned `topups` count = 192, not the 22 records cited in §ADR-16's 2026-05-07 verification.

Current breakdown:
- status 0 pending: 1 record, `processed=true` count 0, no approver recorded.
- status 1 approved: 182 records, all `processed=true`, all have `approved_by` present.
- status 2 rejected: 9 records, none processed, all have `approved_by` present.
- amount range: 10,000 to 120,000 THB; average about 72,846.61 THB.
- `callback_url`, `customer_id`, and `deposit_id` were absent across all 192 sampled/aggregated records.
- slip evidence and MDR distribution were present on the 182 approved records.

Interpretation for requirements: the ADR's numeric evidence is stale, but its product claim remains supported by current data: topup is still a B2B client-business balance top-up, admin-reviewed, distinct from customer-facing deposits, with no external callback surface. Requirement sources should cite the 2026-05-25 count rather than restating the old 22-record figure as current.

---
*Added via Oracle Learn*
