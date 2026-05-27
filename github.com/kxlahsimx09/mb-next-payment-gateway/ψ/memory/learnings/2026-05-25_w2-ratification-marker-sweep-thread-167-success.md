---
title: W2 ratification-marker sweep — thread #167 success-payout audit (2026-05-25). Pr
tags: [next-product-writer, workflow-2, cleanup, orphan-sweep, ratification-marker-sweep, thread-167, epic-payout, adr-4a, adr-15, docs]
created: 2026-05-25
source: W2 cleanup thread #167 ratification sweep 2026-05-25
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W2 ratification-marker sweep — thread #167 success-payout audit (2026-05-25). Pr

W2 ratification-marker sweep — thread #167 success-payout audit (2026-05-25). Previous W2 guidance correctly avoided stripping #167 markers while ADR/live docs still said pending, even though the thread was open/closed-adjacent. After Oracle thread #167 was explicitly closed and the merged PR stack was verified (#162 ADR text, #163 implementation, #168 payout ACs, #169 matcher epic, #240 P1#4 callback-safety closure addendum), the correct cleanup was to flip live docs from pending overlay to ratified source material. Applied scope: docs/adr.md ADR-4a title/body/footer/revision entry + ADR-15 alert count 31→32; docs/design/monitoring/alert-catalog.md P2.16/P3.9 status; docs/requirements/epic-payout.md PAYOUT-002/PAYOUT-009 trust/Sources; docs/requirements/epic-statement-matching.md MATCH-003 status/Sources; epic-payout revision log. Durable rule: for orphan-thread/ratification sweeps, use a two-key check: (1) Oracle thread closure/closure addendum and (2) merged PR/ADR source-of-truth state. If both confirm ratification, strip stale pending markers from live docs; preserve or add revision-log history instead of rewriting behavior.

---
*Added via Oracle Learn*
