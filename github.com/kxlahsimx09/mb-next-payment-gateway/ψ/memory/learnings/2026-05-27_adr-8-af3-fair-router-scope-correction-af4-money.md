---
title: ADR-8 AF3 fair-router-scope correction + AF4 money-gap — ruling for next-writer 
tags: [system-architect, repo:mb-next-payment-gateway, next, withdrawal-queue, bot-dispatch, fair-router, decision, trade-off, money-safety, adr]
created: 2026-05-27
source: docs/adr.md §ADR-8 §Scope-correction 2026-05-27 @PR#263 (thread #246)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# ADR-8 AF3 fair-router-scope correction + AF4 money-gap — ruling for next-writer 

ADR-8 AF3 fair-router-scope correction + AF4 money-gap — ruling for next-writer thread #246 (parent #243, PR #261 R1 correction).

§ADR-8 §Amendment 2026-05-26 (A2) AF1's ratified prose "the filter applies to **all** withdrawal source_types (payout / settlement / direct_transfer / pullout)" contradicts §ADR-8 Decision-1's own Mode model + production. Structural fact (from ADR-8's own ratified Decision-1): the 9th eligibility filter lives inside `findBestBankForItem` (the fair-router); Decision-1 routes ONLY Mode-1 substitutable work (payout + settlement) through the fair-router. Mode-2 directly-addressed flows (pullout + direct_transfer) pre-assign their bank and never enter `findBestBankForItem` — so a fair-router filter cannot evaluate them.

Ruling (3 parts, landed in docs/adr.md §Scope-correction 2026-05-27, PR #263):
- AF3 (ratified #decision — port-fidelity prose correction, within architect authority, no new decision surface): re-scope AF1 to fair-router-routed Mode-1 work. The band stays a bank-account attribute (AF1's framing stands), but the filter is payout-effective today — 5/56 banks set a cap, all method=payout @50000; settlement enters the router but cap=0 (no-op); pullout/DT bypass. AF1's "all source_types" clause inline-annotated with AF3 pointer (P-001 preserves original prose).
- AF3b (confirmed): pullout's own pullout_tasks.min/max band + DestCap is a DISTINCT dispatcher-side mechanism (evaluated on the pre-assigned destination), not the fair-router 9th filter; the two only share a min/max shape. PULLOUT-002's separate-mechanism treatment is correct.
- AF4 ([RATIFICATION_PENDING:246] — money-safety → human ratify, charter §9; NOT architect-self-bound): the gist flags 21,886 pullout/settlement/DT txns >50k with no per-txn cap (band lives only in the fair-router=payout-effective; Mode-2 flows bypass it; enqueue validation withdrawalQueue.go:225-251 checks balance+outstanding, NOT min/max). This is current behavior verbatim, and those flows are admin-gated (pullout/DT pre-name destination + DestCap; settlement admin-approved per §ADR-12 §Amendment 2026-05-27). Two readings: (A) faithful-port — band stays a fair-router/payout filter, Mode-2/settlement rely on admin-approval+DestCap+RBAC (recommended Phase-1); (B) promote the band to a bank-account invariant enforced at enqueue-validation for all source_types — closes the gap, makes AF1 literal, but is deliberate divergence + money-material. Recommend ship (A); record (B) as deferred defense-in-depth for the user — explicitly because DT-refund (DEPOSIT-011/§ADR-4d) DOES debit a client wallet.

Pattern: §Scope-correction = §H3-Fix / §Substrate-correction (in-scope prose fix of a self-contradicting ratified amendment → #decision from first commit, no marker-flip) — here applied to a port-fidelity OVER-generalization (AF1 claimed wider scope than the ported mechanism has). No epic rework: next-writer PR #261 (commit 7b35989) already shipped BOT-001/PULLOUT-002 faithful to the Mode model; AF3 ratifies the ADR text to match. next-writer correctly HELD the ADR reinterpretation rather than unilaterally editing ratified text (P-004) — correct lane discipline.

Sources (P-004): thread #246 msg 1141 + thread #243 msg 1139/1142; next-writer gist 0056dc17 @2087fed; §ADR-8 Decision-1 (Mode model) + Decision-2 (filter stack) + §Amendment 2026-05-26 AF1/AF2; current-system vault 2026-04-30_withdrawaldispatcher-honors-per-bank-withdrawalmi + 2026-04-24_current-system-prior-art-findbestbankforitem-u.

---
*Added via Oracle Learn*
