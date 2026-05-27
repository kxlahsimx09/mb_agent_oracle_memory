---
title: §ADR-12 Settlement Money-Movement amendment — RATIFIED #decision (thread #236, c
tags: [system-architect, repo:mb-next-payment-gateway, next, settlement, wallet, fee, data-model, decision, adr-12, adr-10, thread-236, freeze-settle, config-gated]
created: 2026-05-26
source: docs/adr.md §ADR-12 §Amendment 2026-05-26 + thread #236 user verdict + dpay prod + mobiz SettlementController.go:268/withdrawalQueue.go:1509
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# §ADR-12 Settlement Money-Movement amendment — RATIFIED #decision (thread #236, c

§ADR-12 Settlement Money-Movement amendment — RATIFIED #decision (thread #236, campaign #234), landed 2026-05-26.

Folds the two settlement money-movement details from next-writer consult #233 into §ADR-12, after P-004 verification + user verdict on the Q2 money call. Companion to the §ADR-2 step-up amendment (PR #257) — both close campaign #234 from one consult, split by subject.

DECISIONS:
- M1 — Wallet reserve = FREEZE-at-CREATE via the §ADR-10 primitive. Reserve `amount + fee` at create (balance → frozen), mirroring payout/PAYOUT-001. Bank-success → freeze settles out; reject/bank-fail → freeze released (frozen → balance). Timing = create, NOT approve. WITHIN architect authority (applies already-ratified §ADR-10). Prod proof: settlements.wallet_before 100% (2,986); wallets_change_logs settlement_request op @created_at not approved_at; reject reverses via settlement_refund/settlement_rejected_refund. Deliberate divergence: prod direct-debits, next-system uses the §ADR-10 freeze primitive to unify all withdrawal-side money movement (payout + settlement) — identical observable effect.
- M2 — Settlement carries a CONFIG-GATED withdrawal-service fee, DEFAULT OFF (rate 0). The settlement-flow analog of the actively-used payout_fee. Per-profile settlement_fee rate defaults to 0 (no fee Phase-1; identical to fee-free). Rate 0 ⇒ freeze reserves amount only; rate > 0 ⇒ reserve amount+fee, fee captured on bank-success. Modeled as an EXPLICIT withdrawal-service fee, NOT MDR (inflow MDR = cut on money entering; settlement fee = service charge on money leaving). Rate lives on the fee/rate config surface beside payout_fee, NOT inside an MDR profile (mobiz conflates them in mdr_profiles.settlement_fee — not inherited). User verdict thread #236: "PRESERVE config-gated settlement-fee capability, DEFAULT OFF".
- TWO mobiz bugs explicitly NOT inherited: (i) settlement path never writes mdr_distributions back to the doc → next-system must persist the fee-capture record on the settlement row; (ii) distributeMDRFees looks up `clients` by EntityID so partner-entity settlements silently skip → next-system must resolve owning entity (client OR partner).

P-004 grounding: dpay prod 2026-05-26 + mobiz code @local (SettlementController.go:268 / withdrawalQueue.go:1499-1512 / mdr_profile.go:22 / settlements.go:32-40). All 30 mdr_profiles settlement_fee=0; fee was briefly live on 7/2986 at 2.0% then reverted (CONFIG-0, not structural).

DEFERRED (data-model/impl): settlements column shape; fee-rate config-store + per-tier override; freeze/settle RPC signatures; gateway fee-account ledger target; Phase-2 fee-enable driver.

next-writer handoff (orchestrator-dispatched): SETTLE-001 close wallet-timing anchor ("reserve = §ADR-10 freeze at create, amount + settlement_fee default 0, mirroring payout"); SETTLE-002 close MDR anchor ("config-gated withdrawal-service fee default 0, distinct from MDR; approve settles freeze out, reject releases"). NO AC rewrites — ACs already match. AUTH-007 S4→S2 via §ADR-2 (PR #257).

Recorded in docs/adr.md §ADR-12 §Amendment 2026-05-26 + §Revision log (PR on branch architect/adr12-settlement-money-movement-thread236).

---
*Added via Oracle Learn*
