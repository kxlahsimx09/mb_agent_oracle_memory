---
title: W1 refine pass 2 — §ADR-10 Wallet Table ratified `#decision` (thread #57 closed 
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-10, wallet-table, ratified, decision, pass-2, single-straight-ratification-first-instance, thread-57-closed, drift-closure-as-decision-pattern, coordination-rule-as-architectural-invariant-pattern, substrate-convergence-6-instances]
created: 2026-05-01
source: docs/adr.md@bc49512 §ADR-10 + thread #57 closed messages 116-118
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine pass 2 — §ADR-10 Wallet Table ratified `#decision` (thread #57 closed 

W1 refine pass 2 — §ADR-10 Wallet Table ratified `#decision` (thread #57 closed via single straight-ratification).

User ratified all five sub-questions C1-C5 in single response 2026-05-01 GMT+7: "เลือกตามที่แนะนำทุกข้อเลยครับ". **First instance of single straight-ratification shape in repo** — §ADR-4b/4c/4d/9 all involved either multiple back-and-forth ratification messages or pass 1.5 within-scope revise before ratification. §ADR-10 is the first ADR where user reviewed pass-1 + open-ratification-questions, then ratified all architect-recs in one response with zero follow-up question.

Pure marker-strip + status-promotion pass. Body unchanged from baseline (73 lines); no body content changed, no Decision #6 added, no scope expansion. Single commit bc49512.

Ratifications (single quote covers all five):
- C1 single discriminated wallet table + is_owner flag — parity
- C2 mutation + change-log Phase-1; Phase-2 ledger trigger (GDPR / audit-incident)
- C3 3-table audit parity Phase-1; Phase-2 consolidation trigger
- C4 N-rows fan-out + explicit mdr_skip — closes mobiz thread #6 silent-skip drift structurally
- C5 canonical wallet.id ASC FOR UPDATE order — architectural invariant

Wallet substrate now ratified. §ADR-4a Decision #7 step (ii) refund + §ADR-4b Decision #5 steps (iii)(iv)(v) credit+audit+fan-out + §ADR-4d (admin paid via §ADR-4b reuse) — three atomic-boundary call sites — have architectural specification to reference. §ADR-4b §Negative #ii ("wallet table must support row-locked update without deadlock... deferred to data-model design pass") deferral now structurally closed.

Substrate convergence count → 6 (5 of 5 mobiz-substrate-relevant decisions converge with mobiz intent: D1-D3 parity ports + D4 closes drift via mobiz-recommended fix shape + D5 introduces new architectural invariant).

Velocity comparison: §ADR-9 was 80 min from baseline to ratified (with pass 1.5 cost-coalescing + Decision #6); §ADR-10 is ~10 min from baseline to ratified (pure straight-ratification). Velocity improved as user trusts architect-rec quality + format consistency across passes.

Pattern recorded — single-straight-ratification heuristic: appropriate when (i) all architect-recs grounded in mobiz prior-art (parity) or named-pattern (drift-closure / coordination-rule), (ii) Phase-1/Phase-2 staging explicitly named so user doesn't worry about premature commitment, (iii) trade-offs all rejected with rationale inline at decision-line. §ADR-10 satisfied all three; §ADR-9 had architecture-decision shape less crystallized in pass-1 (cost-coalescing implicit; Decision #6 absent), driving pass 1.5 revise. Pattern: **the cleaner the pass-1 architecture-decision shape, the more likely single-straight-ratification works.**

Two new architectural patterns confirmed durable from §ADR-10:

1. **Drift-closure-as-decision (Decision #4)** — system-wide drift from mobiz thread #6 (silent inactive-partner skip) closed structurally by elevating to architectural invariant. Pattern: when drift is (a) system-wide AND (b) has known recommended fix in mobiz prior-art AND (c) fix changes data semantics → architecture closes structurally rather than per-RPC implementation fix. Sets up next-system to **structurally not recur**, not just "fixed in this PR".

2. **Coordination-rule-as-architectural-invariant (Decision #5)** — canonical lock-order across all wallet-touching RPCs. Pattern: when rule is (a) cross-RPC AND (b) missing-it = incident-class → architecture is the right place. Every future RPC author inherits rule from §ADR-10 instead of re-deriving.

Both patterns first surfaced in §ADR-10 baseline pass-1 retro; pass-2 ratification confirms them as durable lessons (user accepted Decision #4 + #5 without pushback or revise → patterns work).

Threads closed: #57 (closing-message message_id 118 with full ratification quote + commit citation). Threads opened: none. Commit: bc49512. PR #8 (open, not merged; stacks on §ADR-9 PR #7).

Trace chain: c327e4d9 (§ADR-9 ratified) → e003baff (§ADR-10 pass-1 baseline) → this pass (§ADR-10 pass-2 ratified). Cross-ADR producer/consumer/substrate chain extends.

§ADR-10 lifecycle: pass-1 baseline (#provisional) → pass-2 ratification (#decision) on single branch architect/w1-refine-adr-wallet-table-2026-04-30 + PR #8. Two-pass lifecycle (no pass 1.5 needed).

Open thread inventory in territory after this pass: only #45 (fleet-control, claude-last-pending; no architect action). Zero in-territory active threads.

Today's session: 4 W1 passes — §ADR-9 baseline (17:12) + §ADR-9 ratification (18:09) + §ADR-10 baseline (18:30) + §ADR-10 ratification (this pass). Total: 2 ratified ADRs in single session. Velocity track strong.

Next-pass candidate: Idempotency contract ADR for client-facing payment APIs (deposit-create + payout-create). 60-90 min. Decision space: client-supplied Idempotency-Key vs server-derived txn_id; dedup-index location; TTL of dedup keys; conflict semantics. Smaller pass than wallet/callback; can fit if user keeps pace. After Idempotency: Payment Source-Flow ADR (Settlement scheduling + Pullout + Direct-Transfer + Payout creation; 120-180 min, may need split).

---
*Added via Oracle Learn*
