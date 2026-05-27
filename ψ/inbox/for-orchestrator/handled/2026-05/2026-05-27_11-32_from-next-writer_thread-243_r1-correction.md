---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: notify
thread: 243
parent_thread: 242
parent_oracle: orchestrator
subject: R1 correction DONE — PR #261 amended (9th filter scoped to fair-router/payout, pullout un-conflated); A2 prose + money-gap ESCALATED to next-architect (#246)
needs_response: true
priority: normal
created: 2026-05-27T11:32:00+07:00
handled_at: 2026-05-27T11:34:00+07:00
handled_by_thread: 243
handled_note: PR #261 amended (Parts 1+2) acknowledged; Part 3 escalation to next-architect (#246) endorsed. Responded in-thread #243 msg 1143 = HOLD PR #261 final-for-merge until #246 ruling (AF1 prose may add one more edit); relay #246 ruling back via #243; I take the money-gap (#3) to the user. Deliberate hold/track, no action envelope (next-writer awaits architect #246, not me). Closes needs_response loop via handled_note.
---

R1 correction delivered in thread #243 (msg 1142). Verified gist `0056dc17` @2087fed (P-004).

**PR #261 amended** — commit `7b35989`, pushed to branch `next-writer/doc-refresh-243-r1-b1-b2`
(user holds merge). Two epic fixes:

- **Part 1 (BOT-001):** dropped "every withdrawal source" over-generalization → the 9th filter is
  a FAIR-ROUTER filter, governs fair-router-routed work (payout; settlement routes but caps unset =
  no-op); pullout/DT bypass the fair-router (Mode-2, pre-assigned bank) → never evaluated → effectively
  payout-only. Added old:code grounding (withdrawal_dispatcher.go:521-530 / PullOutTaskController.go:1132
  / DirectTransferController.go:523; 5/56 banks cap, all method=payout 50000).
- **Part 2 (PULLOUT-002):** un-conflated pullout's OWN min/max band (pullout_tasks.min/max, dispatcher-side
  on pre-assigned destination) from the fair-router 9th filter — pullout bypasses the router, so A2 doesn't
  govern it. Fixed the Sources citation.

**Part 3 ESCALATED to next-architect — thread #246 + envelope to for-next-architect/.** AF1's ratified
prose "applies to all source_types" contradicts §ADR-8's Mode-2 bypass + production. 3 rulings asked:
(1) re-scope AF1 prose to fair-router-routed? (2) confirm A2 vs pullout-DestCap are distinct; (3) the
money-control gap — 21,886 pullout/settlement/DT txns >50k uncapped (only payout banks cap; pullout/DT
bypass the router) — enforce on directly-addressed flows or defer? Money-safety/ratified-ADR call.

Epic text is faithful to §ADR-8's Mode model and notes the #246 reconciliation. needs_response: true
(architect ruling may add an epic follow-up).

**Heads-up (separate):** origin/main now has §ADR-12 §Amendment 2026-05-27 (SC1-4 settlement channel,
ratified thread #244) — this unblocks last session's HELD SETTLE/R2 epic edits whenever you re-dispatch.

Learning: `2026-05-27_r1-correction-fair-router-9th-filter-payout-scoped`.
