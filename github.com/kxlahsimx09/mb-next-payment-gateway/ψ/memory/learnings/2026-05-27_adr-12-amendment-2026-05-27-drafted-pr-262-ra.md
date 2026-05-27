---
title: §ADR-12 §Amendment 2026-05-27 DRAFTED (PR #262, RATIFICATION_PENDING:244) — sett
tags: [system-architect, repo:mb-next-payment-gateway, next, settlement, wallet, source-flows, adr-12, adr-10, decision, provisional, partner]
created: 2026-05-27
source: docs/adr.md §ADR-12 §Amendment 2026-05-27 (PR #262); thread #244 msg 1129; §ADR-10 D1+AM6 + §ADR-12 M1
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# §ADR-12 §Amendment 2026-05-27 DRAFTED (PR #262, RATIFICATION_PENDING:244) — sett

§ADR-12 §Amendment 2026-05-27 DRAFTED (PR #262, RATIFICATION_PENDING:244) — settlement channel + partner-self Phase-1; and the SC4 resolution: partner-wallet dependency is ALREADY satisfied by ratified substrate.

## The amendment (thread #244 user GO, msg 1129; campaign #239)
Drafted into docs/adr.md as `##### Amendment 2026-05-27` under §ADR-12, `[RATIFICATION_PENDING:244]`, PR #262 (draft, do-not-merge until user ratifies — the #236 M1/M2 path). Four decisions:
- **SC1** settlement channel = dashboard JWT + RBAC `settlement:create`, NOT machine/API-Key, NO Idempotency-Key — corrects the ratified §ADR-12 D1 "Settlement (client API)" row (this is why it's an architect amendment, not a writer doc-edit: D1's caller/idempotency columns are its ratified core, P-004).
- **SC2** initiator matrix {admin, client-self, sub-client, partner-self}; admin-only approve → `EnqueueWithdrawal(source_type=settlement, priority 4)`; freeze-at-CREATE unchanged (M1), enqueue at APPROVE.
- **SC3** partner-self settlement Phase-1 IN-SCOPE.
- **SC4** see below.

## SC4 — the durable resolution (was a flagged dependency, now resolved)
The earlier corrected-R2 ruling FLAGGED "partner-self settlement ⟹ partner wallet must be Phase-1" as an open dependency. RESOLVED: it is **already satisfied by ratified substrate, no §ADR-10/§ADR-12 amendment needed**:
- §ADR-10 D1 models `owner_type ∈ {client, partner, system}` (single discriminated wallets table).
- §ADR-10 AM6 gives EVERY wallet (incl. partner) a uniform `{balance, frozen}` schema.
- §ADR-12 M1 freeze-at-create is **owner-agnostic** (keyed on the settlement's wallet, not the owner type).
So a partner wallet freezing for a partner-self settlement is mechanically supported today. The ONLY downstream effect is documentation: the WALLET epic (`epic-wallet-ledger.md`) asserts partners NEVER freeze (WALLET-001 edge "frozen is meaningful only on the payout side", WALLET-003, WALLET-005 edge "Partner changes only touch balance") — those simplifying claims become inaccurate once a partner can settle, and need a next-writer faithfulness edit (post-ratification follow-on, NOT an ADR change).

## Durable method note
When a new flow reuses an existing substrate primitive, check whether the primitive is owner/type-agnostic before assuming a substrate change is needed — here the freeze primitive + discriminated wallet table already covered the "new" partner case; the only gap was a doc over-simplification. Mirrors [[feedback_adr_amendment_supersession]] (scan the full amendment chain) — §ADR-10 D1 + AM6 + §ADR-12 M1 together already answered it.

AUTH-005 = HOLD per user (not actioned). Base D1 table left untouched while pending; binds at promotion pass on GO.

---
*Added via Oracle Learn*
