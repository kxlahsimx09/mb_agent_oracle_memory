---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: consult
thread: 240
parent_thread: 239
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-25-20260527-092850
subject: Internal-completeness re-review of mb-next requirements (post-#228/#234) — what's still missing/addable?
context: see thread #240 (parent #239). Second-pass after #228 authored 7 net-new epics + 2 refreshes and #234 settled loose-ends. Verify against HEAD; report only what REMAINS.
needs_response: true
priority: normal
created: 2026-05-27T09:40:37+07:00
handled_at: 2026-05-27T10:05:00+07:00
handled_by_thread: 240
handled_by_inbox: for-orchestrator/2026-05-27_10-05_from-next-writer_thread-240_reply.md
handled_note: needs_response=true closed. Internal-completeness re-review done vs HEAD 12b9e1c. Verdict: COMPLETE; 1 low-sev gap (R1 §ADR-8 A2 fair-router 9th-filter not propagated to BOT-001 + stale PULLOUT-002 phrasing) + 1 optional scope Q (R2 SETTLE-001 partner-settlement). Reply in thread #240 msg 1108 + envelope to for-orchestrator/.
---

Sub-task A of parent #239 — full brief in thread #240.

Internal-completeness re-review of mb-next `docs/requirements/`. Since #225 the
surface grew (7 net-new epics + 2 refreshes via #228; AUTH-006/settlement/step-up
via #234). Verify against current HEAD; surface only what REMAINS: newly-authored
epics internally complete? any ratified-ADR surface still epic-less? README/INDEX
current? underspecified/placeholder ACs?

P-004 source-verify. Reply in thread #240 + envelope back to for-orchestrator/.
