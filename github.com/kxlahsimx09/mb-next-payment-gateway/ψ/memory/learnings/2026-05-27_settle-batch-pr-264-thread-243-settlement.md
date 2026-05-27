---
title: SETTLE batch (PR #264, thread #243) — settlement = dashboard JWT + RBAC, partner
tags: [next-product-writer, repo:mb-next-payment-gateway, next, source-flows, settlement, wallet-ledger, decision, faithfulness, s2-ratified]
created: 2026-05-27
source: docs/requirements/epic-source-flows.md + epic-wallet-ledger.md + epic-deposit.md (PR #264); thread #243; §ADR-12 §Amendment 2026-05-27
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# SETTLE batch (PR #264, thread #243) — settlement = dashboard JWT + RBAC, partner

SETTLE batch (PR #264, thread #243) — settlement = dashboard JWT + RBAC, partner-self Phase-1, enqueue-at-approve; WALLET partner-freeze corrected.

Authored the SETTLE batch off updated main (PR #261 merged @e958bc8), citing the now-ratified §ADR-12 §Amendment 2026-05-27 (SC1-4, PR #262) + §ADR-8 §Scope-correction AF4 (#246). This lands the channel correction that was HELD two sessions ago (it had contradicted the then-ratified §ADR-12 D1; the architect amended D1, so it's now citable rather than a unilateral rewrite). No substrate change — doc faithfulness.

Five items across epic-source-flows.md + epic-wallet-ledger.md + epic-deposit.md:
1. SETTLE-001 — initiation channel corrected from machine/API-Key+Idempotency-Key to **dashboard JWT + RBAC `settlement:create`** (SC1, no API-Key route, no Idempotency-Key); initiator matrix {admin any · client-self · sub-client · partner-self} (SC2); the `[open question: partner Phase-1?]` marker RESOLVED → ratified IN-SCOPE (SC3, 140 partner-initiated settlements in prod); **enqueue moved create→admin-approve** while freeze stays at create (M1) → `EnqueueWithdrawal(source_type=settlement, priority 4)`.
2. SETTLE-002 — admin-only approve→enqueue (the freeze settles out on bank-success, NOT at approve — corrected the prior "approve = settle out" framing); `entity_type=partner` on admin-create; reject-release made owner-agnostic.
3. SRCFLOW-001 — two settlement rows (machine/API-Key + admin-UI) collapsed to one `Settlement (dashboard)` row; settlement leaves the §ADR-11 Idempotency-Key surface; taxonomy 4 rows.
4. WALLET-epic SC4 — corrected the "partners never freeze" over-statements (WALLET-001 edge, WALLET-003 journey+edge, WALLET-005 edge): a partner-self settlement freezes a partner wallet; the freeze is OWNER-AGNOSTIC (§ADR-10 D1 owner_type=partner + AM6 uniform frozen + §ADR-12 M1) — pre-satisfied substrate, no change. MDR fan-out still only credits balance (a credit never reserves).
5. DEPOSIT-011 pin — 1-line deferred-defense-in-depth cross-ref → §ADR-8 §Scope-correction AF4(B) (per-txn band enforcement at enqueue/queue-validation for directly-addressed debits; revisit when the DT-refund flow that debits a client wallet is authored).

Durable arc: the SETTLE channel fix took THREE sessions — drafted+discarded (contradicted ratified D1) → flagged → architect amended D1 → authored citing the amendment. The amendment-first discipline (per [[feedback_writer_fix_contradicts_ratified_adr]]) produced a clean ADR-backed S2 story instead of a doc that contradicts its ADR. The amendment even pre-named the exact WALLET spots to fix (SC4 writer-handoff), so item 4 was a precise lift, not a hunt. AUTH-005 (epic-auth-rbac.md) remains a separate pending dispatch.

---
*Added via Oracle Learn*
