---
title: Writer faithfulness-fix that contradicts a RATIFIED ADR → flag for §Amendment + 
tags: [next-product-writer, repo:mb-next-payment-gateway, next, faithfulness, decision, trade-off, handoff, adr]
created: 2026-05-27
source: thread #243 msg 1123/1124/1126 (SETTLE channel-fix HOLD, 2026-05-27)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Writer faithfulness-fix that contradicts a RATIFIED ADR → flag for §Amendment + 

Writer faithfulness-fix that contradicts a RATIFIED ADR → flag for §Amendment + ratification; do NOT unilaterally rewrite the S2 story (even when directed to "fix it now").

A "freshness/faithfulness" doc fix is only safe to author unilaterally when it propagates an ALREADY-ratified decision (e.g. R1 = §ADR-8 §Amendment A2) or corrects a current-system grounding detail that does NOT contradict the ADR (e.g. B1 = pullout demand-refill liveness, leaving §ADR-12 D3 untouched; B2 = DTR refund capture, FLOW deferral intact). The moment a directed "faithfulness fix" would make an S2 story CONTRADICT its still-ratified ADR, it stops being a writer-doc edit and becomes an architect §Amendment + user-ratification job.

Worked instance (thread #243, 2026-05-27): orchestrator addendum directed next-writer to correct SETTLE-001 — production settlement is dashboard/JWT+RBAC `settlement:create` with NO API-Key route, but the ratified §ADR-12 D1 taxonomy models it as an API-Key machine caller with `Idempotency-Key`. next-writer flagged the §ADR-12 D1 contradiction in the reply (msg 1123) rather than silently shipping the rewrite; the architect (msg 1124) and orchestrator (msg 1126) agreed and HELD the edit pending a §ADR-12 §Amendment + ratification. The half-started SETTLE edits were discarded (uncommitted) so the PR stayed clean as the three safe fixes.

Rule of thumb: classify each directed fix as (a) propagate-ratified / (b) grounding-correction-not-contradicting-ADR / (c) contradicts-a-ratified-ADR. Ship (a) and (b); for (c), flag + let the architect amend and the user ratify FIRST, then author the epic edit citing the ratified amendment. P-004 (Code is Truth) makes production win over the ADR claim, but the reconciliation route is an ADR amendment, not a unilateral S2 rewrite. Grounds in AGENTS.md §8 reality-first rule. Companion to [[feedback_adr_amendment_supersession]] and [[feedback_spec_self_contradiction_impl_discretion]].

---
*Added via Oracle Learn*
