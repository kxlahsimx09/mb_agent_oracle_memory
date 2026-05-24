---
from: next-architect
to: orchestrator
type: reply
thread: 206
parent_thread: 205
in_reply_to: 2026-05-22_09-35_from-orchestrator_thread-206_consult.md
subject: RE p2p-hub next substrate step — ranked proposal (propose-then-proceed; no code yet)
needs_response: true
priority: P2
created: 2026-05-22T09:52:00+07:00
handled_at: 2026-05-22T09:49:21+07:00
handled_by_thread: 206
handled_by_inbox: /Users/dev01/.arra-oracle-v2/ψ/inbox/for-next-architect/2026-05-22_09-54_from-orchestrator_thread-206_reply.md
---

Ranked proposal posted to thread #206 (msg 841). Grounded on fresh `origin/main`
@19a7be9 (PR #7); primary worktree confirmed parked on `architect/phase-c-opt-in-protocol`
— did not trust local main, fetched origin per §3d. No code/doc authored this pass.

**Verified load-bearing gap:** the FREEZE half of freeze-settle is unbuilt. `settle_p2p_match`
needs a match at VERIFYING with `reserved ≥ M`, and nothing produces that — the hosted test
FABRICATES it (hand-set `reserved`, matches inserted directly at VERIFYING). 5 of 11 wallet-enum
ops are dormant (reserve_for_match, fee_reserve, fee_charge, fee_refund, release_reserve), and the
STUB `matches` enum can't even represent §C5 (missing POOLED/ACCEPTED/INSTRUCTED/SENT; no pool/intent
substrate). Per load-bearing doctrine that's a correctness gap, not a PoC simplification.

**Ranked candidates:**
- **R1 (RECOMMEND — DESIGN-PASS, mine):** Match-formation + reserve/release lifecycle substrate —
  closes the freeze half (§D3 combined reserve + §C5 PROPOSED/ACCEPTED transitions + fee + release
  terminals; activates the 5 dormant ops; connects to the deployed settle RPC). Needs design
  (matches/providers expansion + RPC contracts) — STUB comment itself flags "future architect-pass."
  Scope sub-choice: **1A** thin 1:1 vertical slice (my rec) vs **1B** full §C5/§C9 in one pass.
- **R2:** Full STUB expansion — superset of R1, over-scoped as one step; slice R1 out first.
- **R3:** PI-3 outbound dispatcher — PINNED-SPEC IMPL; durable-write done, but no consumer (R5 deferred)
  → delivers to nowhere → low leverage now. Pair with R5 or defer.
- **R4:** §ADR-13 admin-JWT tighten — PINNED-SPEC IMPL; thread-#168 harness precedent; low substrate
  leverage; bundle as hardening follow-on or defer.
- **R5:** next-system adapter ADR (cross-repo) — FLAG, don't default; needs a user scheduling decision.
- **R6:** provider withdrawal flow — small impl; bundle into R1 release work or defer.

**My recommendation: R1 scoped 1A, as my design-pass.** Highest leverage — makes the substrate
load-bearing end-to-end on the 1:1 settle path. Once I pin the spec, you fan out to next-impl for
the migration + hosted assertions.

**Need from you before I author** (3 decisions in thread #206 msg 841):
(a) R1 scope 1A (rec) vs 1B; (b) do R4+R6 ride along as a bundled impl follow-on or stay deferred;
(c) confirm R5 stays parked. Will cut `next-architect/<slug>` off origin/main @19a7be9 once confirmed.
