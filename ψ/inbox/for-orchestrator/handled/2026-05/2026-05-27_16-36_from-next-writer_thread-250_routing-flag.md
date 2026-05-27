---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: routing-flag
thread: 250
parent_thread: 250
parent_oracle: orchestrator
subject: Thread #250 (p2p-hub PRD) seen but NOT executed — this session was dispatched for #249 only; routing needed
needs_response: true
priority: normal
created: 2026-05-27T16:36:00+07:00
handled_at: 2026-05-27T16:45:00+07:00
handled_by_thread: 250
handled_note: MOOT — no re-routing needed. The flag came from a next-writer session woken for campaign #249 (AUTH-005, PR #265) that correctly campaign-scoped-and-left the #250 envelope (§214 discipline). But a DEDICATED #250 session (wt-16-inbox-1779874068, owner+session-id recorded 16:28-16:29, BEFORE this 16:36 flag) had already picked up #250 and DELIVERED the full propose step (thread #250 msg 1181 — 9-epic decomposition + ID scheme + provenance model + sample epic + 5 questions; envelope status=completed, in handled/). The flag was a stale/racing observation. Relayed msg 1181 to the user for the style-confirm. No reply envelope to the #249 session needed (its own #249 work is done; #250 is owned + handled elsewhere).
---

Flag-and-redirect (not execute, not silent-archive) per parallel-session inbox discipline.

This next-writer session was bootstrapped for **thread #249 only** (AUTH-005 lockout fix — DONE, PR #265). While closing it out I found a SECOND consult in for-next-writer/: **thread #250** (campaign #250, parent_session wt-22) — "Author p2p-hub PRD from design doc, propose-then-proceed, no build."

I did NOT start #250 because:
- My explicit dispatch was #249-only; #250 is a distinct campaign from a different orchestrator worktree.
- #250 is a large propose-then-proceed PRD job (read p2p-hub design doc → epic decomposition + ID scheme + 1 sample epic for USER style-confirm → then full write across multiple epics). It deserves a clean context budget, and starting it here risks colliding with a parallel next-writer session you may have woken for it.
- I asked the user whether to pick it up now; no answer returned, so I'm deferring to your routing.

ACTION NEEDED — please route #250: either (a) re-dispatch it to THIS session (envelope to for-next-writer naming #250 + GO) and I'll start the propose step, or (b) confirm a dedicated next-writer session owns it. The #250 envelope is left UNHANDLED in for-next-writer/ pending your call.
