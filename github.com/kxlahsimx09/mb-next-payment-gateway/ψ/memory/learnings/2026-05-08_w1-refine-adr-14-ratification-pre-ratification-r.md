---
title: W1 refine §ADR-14 ratification (pre-ratification revised pass 1.5 + pass 2 combi
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-14, fleet-control, ratification, pass-15, pass-2, combined-pass-instance-4, implementation-contract-only-revise-sub-pattern-instance-2, decision, thread-80-closed, e6-restart-aware-catchup, process-start-time-filter-pattern-instance-1-new, no-op-post-restart-result-enum, user-pushback-instance-27-operational-edge-case-not-specd-in-baseline, 13-adrs-decision-phase-3-provisional-remaining]
created: 2026-05-08
source: docs/adr.md@29363ac §ADR-14 + docs/design/fleet-control/{broadcast-channel,audit-table}.md@29363ac (post pass-1.5 §5.2 restart-aware catchup spec); thread:#80 messages 192-194
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine §ADR-14 ratification (pre-ratification revised pass 1.5 + pass 2 combi

W1 refine §ADR-14 ratification (pre-ratification revised pass 1.5 + pass 2 combined) — thread #80 closed; E1-E6 resolved; §ADR-14 promotes `#provisional` → `#decision`. Architecture-decision phase: 13 ADRs `#decision`; 3 live `#provisional` remain.

User direction *"E1-E6 โอเค"* + flagged E6 concern *"E6 เรื่อง reconnect กับ crash แล้ว restart เพราะถ้า restart command อาจไม่จำเป็น ต้องดูเรื่องนี้ด้วยนะ"*. E1/E2/E3/E4/E5 straight-ratified. E6 pre-ratification revised pass 1.5: architect added restart-aware catchup logic inline as implementation contract (mechanical implication of E5 idempotency + E6 catchup mechanism; NOT new architectural decision).

E6 restart-aware catchup spec (NEW pass 1.5):

1. PROCESS_START_TIME captured at bot startup (in-memory const; Date.now())
2. Catchup query (existing): SELECT unacked trigger rows WHERE issued_at > now() - 5 min
3. For each command in catchup, apply restart-aware filter:
   - if command_type == 'reboot_session' AND cmd.issued_at < PROCESS_START_TIME:
     ack with result='no_op_post_restart' (skip apply; restart effective reboot; rate-limit risk avoided)
   - else: normal apply + ack with result='success'/'fail'
4. New `result` enum value 'no_op_post_restart' added to fleet_command_log CHECK constraint
5. Per-command-class applicability:
   - F1/F2 (config-poll path): not in catchup; pollLoop handles separately
   - F3 reboot_session: restart filter applies (only command class with redundancy)
   - F4 halt_pool: idempotent state command; re-apply OK
6. Bot-down >5 min coverage:
   - F3: bot restart = effective reboot; missing catchup OK
   - F4: covered by config-flag fallback (existing)
   - F1/F2: pollLoop handles
7. §ADR-15 alert candidate (future amendment): no_op_post_restart rate spike → bot crashing frequently

Verdicts:
- E1 substrate split (hybrid: config-poll + Realtime broadcast) — (a) ratified
- E2 Phase-1 command catalog (F1/F2/F3/F4; defer F5) — (a) ratified
- E3 auth model (admin JWT + RBAC fleet-control:*) — (a) ratified
- E4 audit table (fleet_command_log 2-row append-only; pattern instance #4) — (a) ratified
- E5 idempotency (bot-side dedup via command_id, TTL 5min) — (a) ratified
- E6 failure-mode fallback + restart-aware catchup — pre-ratification revised pass 1.5; ratified post-revise

Patterns surfaced this pass:

1. **Combined pass 1.5 + pass 2 lifecycle — instance #4** (after §ADR-9 cost-coalescing 2026-04-30 + §ADR-13 Decision #2 Option D 2026-05-03 + §ADR-15 D6 catalog expansion 2026-05-06). When user provides ratification + revise direction in single message, combined pass saves a separate revise commit cycle.

2. **Implementation-contract-only revise sub-pattern — instance #2** (after §ADR-4b D2 amendment D1 failure-handling 2026-05-06). When user-flagged concern is mechanical implication of already-ratified primitives (not new architectural decision), surface as implementation contract (design doc + body note) rather than re-ratification cycle. At instance #2 reaches candidate-durable; instance #3 → durable threshold per W1 §Port-from-mobiz protocol rule 2. Brew-ops handoff candidate when 3rd instance emerges.

3. **User-pushback-as-design-force instance #27** — operational-edge-case-not-spec'd-in-baseline → user catches at ratify time. Pattern: when ratifying spec for retry-driven / catchup-driven / connection-restoration mechanism, user typically asks "what about crash+restart vs reconnect?" → implementation contract should distinguish process-continuity from network-continuity.

4. **PROCESS_START_TIME filter for crash-vs-reconnect distinction — instance #1 (NEW pattern)**. Useful primitive for any retry-driven mechanism where some imperatives are accomplished by the restart itself. Could apply to other architectural primitives in future (e.g. callback dispatcher reconnect; matcher cascade restart). Pattern candidate for W1 §Inputs heuristic update or brew-ops handoff when 2nd instance emerges.

5. **Operational edge-case checklist for catchup/retry mechanisms — emerging pattern candidate**. Future spec for retry-driven mechanisms should include explicit distinction between: (a) network drop + reconnect, (b) process crash + restart, (c) host restart, (d) clock skew between bot host and Postgres. This pass covered (a) + (b); future amendments may add (c) + (d). Brew-ops handoff candidate.

User-pushback-as-design-force instance count: 26 → 27. Pre-Input-5: 18 → 18 (no new code-read; restart-aware logic derived from existing primitives).

Architecture-decision phase post-ratify:
- 13 ADRs `#decision` (§ADR-1 through §ADR-13 + §ADR-4b/4d amendments + §ADR-4b D2 amendment + §ADR-15 + **§ADR-14**)
- **3 live `#provisional`** remain — §ADR-13 amendment thread #82 + §ADR-16 thread #83 + §ADR-4d D1 amendment thread #84 (Track 1/2/3 of 3-track derivative plan from thread #81)
- After all 3 Track ratify: 0 live `#provisional`; full Phase-1 architectural surface complete; Phase-1 implementation kickoff fully unblocked per §11k orchestrator + thread #66 next-dev developer agent

Same-day cycle: §ADR-14 ratification ~2 days from baseline (2026-05-06 → 2026-05-08); within typical W1 cadence (longer than §ADR-15 1.5-hour same-day cycle because user ratified 2 days later, not architectural complexity).

Threads closed: #80. Threads opened: none. Commit: `29363ac`. PR #19 (3 commits total: baseline + baseline-backfill + ratify pass 1.5+2).

Next pass candidate: ratify thread #82 + thread #83 + thread #84 — all 3 are Track 1/2/3 of 3-track derivative plan from thread #81 correction; #84 ratification depends on #82 ratifying first (F1+F2 actor tier + create-time triple patterns). After all 3 ratify: full Phase-1 architectural surface complete.

---
*Added via Oracle Learn*
