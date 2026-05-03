---
title: W1 refine pass 1 — §ADR-10 Wallet Table baseline (`#provisional` `[RATIFICATION_
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-10, wallet-table, wallet, mdr, audit, lock-ordering, single-table-discriminated, mutation-vs-ledger, thread-6-drift-closure, baseline, pass-1, provisional, ratification-pending, substrate-convergence-6-instances, thread-57-opened, architecture-vs-design-discipline]
created: 2026-04-30
source: docs/adr.md@b264be5 §ADR-10 + evidence bundle (4 mobiz learnings) cited in §Revision log + thread #57 messages
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine pass 1 — §ADR-10 Wallet Table baseline (`#provisional` `[RATIFICATION_

W1 refine pass 1 — §ADR-10 Wallet Table baseline (`#provisional` `[RATIFICATION_PENDING:57]`).

Closes the load-bearing "wallet-table schema + locking strategy" deferral marked in §ADR-4b §Negative #ii (and referenced across §ADR-4a refund + §ADR-4d admin-paid via §ADR-4b reuse). Pure architecture pass per user steering carried forward from §ADR-9 ("อยากจะให้จบแค่ ส่วนที่เป็น architecture decision เท่านั้น"). Body 73 lines (well under 150-line extract threshold; comparable to §ADR-9 baseline 67 lines).

Five decisions, each [RATIFICATION_PENDING:57]:
- C1 wallet shape       = single `wallets` table + owner_type discriminator + is_owner system-residual flag (parity with mobiz)
- C2 balance model      = mutation + wallet_change_logs Phase-1; Phase-2 ledger trigger-driven (GDPR / audit-incident drivers)
- C3 audit topology     = 3-table parity (wallet_change_logs + transactions + mdr_shared) Phase-1; Phase-2 consolidation trigger
- C4 MDR fan-out        = N-rows per partner per source doc + explicit mdr_skip audit row (closes mobiz thread #6 silent-skip drift structurally)
- C5 lock-ordering      = canonical FOR UPDATE by wallet.id ASC as architectural invariant across atomic-RPCs touching ≥2 wallets

Six trade-off alternatives evaluated and rejected: A per-actor split (RLS multiplication / no security gain), B pure-ledger Phase-1 (forces SERIALIZABLE / ripples 3 ratified ADRs), C hybrid (2 writes / no Phase-1 driver), D Phase-1 audit consolidation (needs read-pattern audit), E preserve silent-skip (carries known drift forward), F per-RPC lock-order (one missing canonical = deadlock). 6 revisit triggers documented.

Prior-art bundle: 4 mobiz learnings (wallet_change_logs reference_id PR #171 / thread #6 silent-skip drift / is_owner residual flag / request_id prefix) + §ADR-3 substrate parent + §ADR-4a/4b/4d call sites + §ADR-2 RLS alignment + W10 first-run constraints register (no inheritance-surface constraint applies). Input 5 not needed (Input 1 cited mobiz code lines models/wallets.go:19 + controllers/DepositController.go:902-908 + services/distributeMDRFees line-precise via prior learnings).

Threads opened: #57 (5 sub-questions C1-C5). Threads closed: none. Commit: b264be5. PR #8 (open, not merged; stacks on §ADR-9 PR #7). Trace chain candidate: §ADR-9 pass-1.5+2 ratified (c327e4d9) — §ADR-10 specifies the wallet substrate that §ADR-9 producers (atomic-RPCs writing outbox rows) operate on.

Pre-Input-5 checkpoint NOT triggered this pass — no "current does X" claim made without prior-learning citation. Instance-#7 escalation (from §ADR-9 pass-1 retro projection) does not recur this pass.

Notable architectural patterns:

1. **Drift closure as architectural decision (Decision #4)** — system-wide drift from mobiz thread #6 (silent inactive-partner skip across both matcher path + admin-approve path) closed structurally by elevating "every MDR-profile partner produces exactly one audit row per finalize" to architectural invariant. Pattern: when drift is system-wide AND has known recommended fix in mobiz prior-art, lifting it into next-system architecture is the appropriate place to close it. Architecture decides "this cannot recur in next-system shape".

2. **Coordination rule as architectural invariant (Decision #5)** — first instance of explicitly elevating cross-RPC coordination rule (canonical lock-order) to architectural status. Rationale: deadlock prevention is cross-RPC concern; if any single RPC author forgets, system-wide invariant breaks. Setting at architecture level means every future wallet-RPC author inherits the rule from §ADR-10 instead of re-deriving. Pattern shape: when a rule is cross-RPC AND missing-it = incident-class, architecture is the right place.

3. **Phase-1/Phase-2 trigger-driven staging (Decisions #2 + #3)** — mirrors §ADR-2 RBAC Phase-1/Phase-2 staging discipline. Phase-1 = parity Phase-2 = trigger-driven on named drivers (GDPR / audit-incident / read-pattern-audit). Avoids premature abstraction while keeping evolution paths explicit.

4. **Substrate convergence count → 6** (5 ADRs ratified atop mobiz substrate now: §ADR-4a/4b/4c/4d/9 + §ADR-10 Phase-1 parity). §ADR-10 Decisions #1-#3 are parity ports of mobiz design intent; Decisions #4 + #5 close known drift / set new architectural invariant.

5. **Architecture-vs-design discipline carried forward from §ADR-9** — body 73 lines vs §ADR-9 baseline 67 lines. Decisions name *the shape + the invariant*, defer *the SQL + the columns + the values*. Same pattern of "names the shape, not the seconds" applied to canonical lock-order (names "by wallet.id ASC", defers exact ORDER BY clause + advisory-lock id allocation + Postgres deadlock-retry to impl pass).

Next-pass candidate: §ADR-10 ratification (pass 2) when user answers C1-C5 — same shape as §ADR-4b/4c/4d/9 ratification cycles. Estimated 30-45 min if straight-ratification, longer if pass-1.5 revise needed (unlikely given prior-art coverage; possible if user surfaces follow-up question on lock-order semantics or `mdr_shared` collapse).

After §ADR-10 ratifies: Idempotency contract ADR for client-facing payment APIs (60-90 min) is the next standalone candidate, then Payment Source-Flow ADR (Settlement scheduling + Pullout + Direct-Transfer + Payout creation; 120-180 min, may need split).

---
*Added via Oracle Learn*
