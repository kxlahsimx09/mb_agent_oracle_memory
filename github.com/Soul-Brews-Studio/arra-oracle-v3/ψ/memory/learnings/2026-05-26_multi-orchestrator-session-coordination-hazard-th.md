---
title: Multi-orchestrator-session coordination hazard: the inbox-loop-closure Stop hook
tags: [orchestrator, multi-session, cross-campaign-collision, whole-dir-exception, sibling-ownership, stale-state-on-resume, inbox-loop-closure-hook, directed-inbox, thread-216, thread-234, repo:arra-oracle-v3, fleet]
created: 2026-05-26
source: orchestrator wt-21 — observed during SLO campaign #201 (2026-05-26): redundant Q2/Q3 surface vs wt-20's #234 ownership
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Multi-orchestrator-session coordination hazard: the inbox-loop-closure Stop hook

Multi-orchestrator-session coordination hazard: the inbox-loop-closure Stop hook's WHOLE-DIR exception (orchestrator sees ALL campaigns, §11e/§214) means a SECOND concurrent orchestrator session gets flagged on envelopes belonging to a SIBLING orchestrator session's campaign.

OBSERVED 2026-05-26: wt-21 (driving SLO campaign #201/#216) was repeatedly Stop-hook-flagged on envelopes for campaign #234 (settlement/auth #230/#235/#236), which wt-20 owned + was actively driving. wt-21 redundantly surfaced the #234 Q2/Q3 user-escalations to the user — but wt-20 had ALREADY relayed the user's verdicts (thread #236 msg 1084: user ratified Q3 + posed a Q2 clarifying question). The redundant surface was a §11k cross-session collision (duplicate user-escalation).

LESSON — before acting on a cross-campaign envelope the whole-dir Stop hook surfaces, STATE-GROUND its thread first (arra_thread_read):
- If status=answered/closed, OR recent messages are authored by a sibling orchestrator session (different `wtNN` in the author handle), the sibling owns + drives it (§151) → archive with a handled_note, do NOT re-surface/re-dispatch.
- Confirmation signal that a sibling owns it: the sibling grabs the envelope out of the shared `for-orchestrator/` root mid-turn → your Read/Edit fails 'file does not exist' (wt-20 did this for #230/#235/#236).
- Only drive a cross-campaign envelope yourself if state-grounding shows NO active owner (envelope sits unswept, thread not progressing) AND the user-decision would otherwise drop.

The whole-dir exception assumes ONE orchestrator hub; concurrent orchestrator sessions generate cross-campaign false-positives. Mitigation until the gate is made session-campaign-aware: state-ground every whole-dir-surfaced envelope against its thread status + author-wtNN before acting; default to hands-off + handled_note when a live sibling owns it.

---
*Added via Oracle Learn*
