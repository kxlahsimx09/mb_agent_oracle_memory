---
title: §ADR-12 §Amendment 2026-05-27 RATIFIED + PROMOTED (thread #244 user GO; PR #262 
tags: [system-architect, repo:mb-next-payment-gateway, next, settlement, source-flows, adr-12, decision, partner, wallet]
created: 2026-05-27
source: docs/adr.md §ADR-12 §Amendment 2026-05-27 (PR #262, commit c19fe76); thread #244 msg 1132 user ratification
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# §ADR-12 §Amendment 2026-05-27 RATIFIED + PROMOTED (thread #244 user GO; PR #262 

§ADR-12 §Amendment 2026-05-27 RATIFIED + PROMOTED (thread #244 user GO; PR #262 ready-for-merge) — settlement channel correction + partner-self Phase-1 now binding `#decision`.

## Ratification
User CONFIRMED all four (SC1·SC2·SC3·SC4) via orchestrator relay (thread #244 msg 1132). Promotion pass flipped the `[RATIFICATION_PENDING:244]` markers → ratified `#decision` and bound the corrected §ADR-12 D1 base table. PR #262 un-drafted + marked ready-for-merge; per charter §9 the architect did NOT merge (user's action).

## What is now binding `#decision`
- **SC1** settlement channel = human dashboard JWT + RBAC `settlement:create`, NOT machine/API-Key, NO Idempotency-Key (leaves the §ADR-11 surface). Corrects the prior D1 "Settlement (client API)" mis-classification.
- **SC2** initiator matrix {admin (any tenant) · client-self · sub-client · partner-self}, tenant-scoped per §ADR-13 F1/F4; admin-only approve → `EnqueueWithdrawal(source_type=settlement, priority 4)`; freeze-at-CREATE unchanged (M1), enqueue-at-APPROVE.
- **SC3** partner-self settlement Phase-1 IN-SCOPE.
- **SC4** partner-wallet dependency already satisfied by §ADR-10 D1 + AM6 + M1 (no substrate amendment); WALLET-epic "partners never freeze" doc-correction = next-writer follow-on.

## §ADR-12 D1 base table is now 4 rows (was 5)
The two Settlement rows (client-API + admin-UI) collapsed to a single `Settlement (dashboard)` row. Decision #1 "5 rows" → "4 rows"; the Rationale + the #60-era C1 §Resolved carry a supersession pointer (the #60 record preserved per P-001).

## Promotion pattern (instance #2 of #246 A1/A4)
marker-flip-on-GO + base-table-bind in place + PRESERVE the DRAFT revision-log entry (P-001) + PREPEND a promotion revision-log entry. Money-movement scope ratified by the user before binding (charter §9, the #236 M1/M2 path).

## Still open / sequenced
next-writer epic batch (SETTLE-001/002 + SRCFLOW-001 + WALLET-epic SC4) dispatches AFTER PR #261 merges (epic-source-flows.md conflict-avoidance) — orchestrator owns sequencing. PR #262 awaits the user's merge. AUTH-005 = HOLD (not actioned). Companion: [[2026-05-27_adr-12-amendment-2026-05-27-drafted-pr-262-ra]] (draft pass) + the corrected-R2 ruling.

---
*Added via Oracle Learn*
