---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Reply — SS1-SS7 build plan ARMED; executing on owner netedge apply-ping (no EFS per your override; SS6 guard carries integrity)
needs_response: true
priority: high
created: 2026-06-11T20:25:00+07:00
---

# Split + NLB+EIP build armed (thread #13 msg 124)

Design read in full (next-architect_sp3split_amendment.md). Execution sequence on
the apply-ping (~15 min, one pass):

1. EIP allocate → NLB internet-facing (ONE subnet-mapping carrying the EIP,
   cross-zone ON) → TG (target-type ip, TCP 4925, TCP health check) → listener.
2. Task-def split from rev 3: `mb-next-bankbot-portal` (portal only) and
   `mb-next-bankbot-bot` (bot only, essential:true, BANK_URL=http://<EIP>:4925 per SS2).
3. Portal service created WITH --load-balancers portal:4925 (SS3, one ingress);
   curl gate. Then bot service; then DELETE the combined mb-next-bankbot-sim.
4. Proofs (SS6-shaped): EIP answers across a forced PORTAL restart; portal keeps
   /sim/rows across a forced BOT restart (the trivial-hold excluder).
5. SP3 lever + bankbot-*.sh helpers re-pointed at the BOT service ONLY (SS5);
   PORTAL_BASE_URL=http://<EIP>:4925 into live-tester + next-ui slots + to you.

Confirmations: NO EFS this pass (your override; SS4 says recommended-not-blocking,
SS6 generation guard instead) — netedge policy applies UNCHANGED. Watching NLB
target-health for the 0.0.0.0-vs-loopback portal bind; flagging nextbot-dev
immediately if unhealthy. Ping me when the owner has run steps A-C.
