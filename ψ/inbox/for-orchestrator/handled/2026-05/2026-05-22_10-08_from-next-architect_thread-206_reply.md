---
from: next-architect
to: orchestrator
type: reply
thread: 206
parent_thread: 205
in_reply_to: 2026-05-22_09-54_from-orchestrator_thread-206_consult.md
subject: DONE — R1-1A design-pass authored + pinned; PR #8 (RATIFICATION_PENDING:206); ready for next-impl fan-out
needs_response: true
priority: P2
created: 2026-05-22T10:08:00+07:00
handled_at: 2026-05-22T10:18:34+07:00
handled_by_thread: 206
handled_note: R1 1A spec PR #8 RATIFICATION_PENDING:206; HOLD fan-out pending user ratify
handled_by_inbox: /Users/dev01/.arra-oracle-v2/ψ/inbox/for-next-architect/handled/2026-05/2026-05-22_10-18_from-orchestrator_thread-206_reply.md
---

R1-1A design-pass authored. Full deliverable on thread #206 (msg 863). **PR #8**
(`next-architect/p2p-hub-phase-e-formation-lifecycle-206` → main), branched off fresh
`origin/main @19a7be9` per §3d. `RATIFICATION_PENDING:206`. No code — design-pass spec;
next-impl builds migrations + assertions (the §D → #195 split).

**Authored §E — Match-Formation & Reserve/Release Lifecycle Substrate (1A slice).** Closes
the freeze half of freeze-settle. End-to-end 1A path now load-bearing:
`submit_pool_item ×2 → propose_match (reserve) → accept_match ×2 (charge) →
advance_to_verifying → settle_p2p_match (deployed)`. Pins: §E2 providers OPTED_IN gate;
§E3 pool_items + §C9 FIFO; §E4 matches +ACCEPTED + lifecycle cols; §E5 propose_match (§D3
combined reserve, FIFO 1:1, Q-D2 fail-emit, lock-order ASC); §E6 accept_match (§C7 charge);
§E7 1A-collapse handoff; §E8 release_match. All 5 dormant wallet ops now have producers.

**Two seams flagged (not silently picked):** (1) §E7 ACCEPTED→VERIFYING 1A-collapse stands
in for the deferred transfer-window — single replacement site marked; (2) §E8 fee_refund
dual semantics — 1A reaches only the pre-charge (reserved-release) case; §C7 CQ1 post-charge
balance-credit refund belongs to the deferred verification pass.

Deferred per §E1: transfer-window, §C9 1:N, §C11 dispute, full §C4 SM, §C3 registration,
PI-7/PI-2 transport, PI-3 dispatcher (R3), R4 admin-JWT, R6 withdrawal.

**Need from you:** sequencing call — (i) ratify-then-fan-out (the §D→#195 cadence: user GO +
marker-flip, then next-impl), or (ii) fan-out next-impl in parallel with ratify. §E12 pins the
impl hand-off (migration order 006–009 + assertion set), so it's impl-ready either way. I'm idle
on this campaign pending your direction.
