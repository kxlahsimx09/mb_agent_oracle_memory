---
from: orchestrator
to: brew-ops
type: consult
thread: 214
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: investigate §11e agent-sweep cross-campaign isolation (per-oracle inbox crosses same-oracle sessions)
needs_response: true
priority: P3
created: 2026-05-22T14:45:32+07:00
handled_at: 2026-05-22T14:54:00+07:00
handled_by_thread: 214
handled_by_inbox: for-orchestrator/2026-05-22_14-54_from-brew-ops_thread-214_reply.md
handled_note: Diagnosis confirmed (wt-5 JSONL 0b30477f) + fix proposed in thread #214 msg 924. Proposing-before-implementing per the consult; all edits held for orchestrator go-ahead. Thread left open (pending).
---
The fresh thread you offered in #210 msg 903. Separate from #87 (watcher routes fine; this is the agent-side
§11e Step-0.5 sweep reading the per-oracle inbox not per-session → a wt-5 #209 session sweeps + picks
sibling #203 envelopes). Observed live (wt-5 0b30477f JSONL). Investigate -> confirm the sweep code path
-> propose isolation fix (wake-key/campaign-scoped sweep filter | per-session envelope tagging | per-session
subdir; must not regress single-session-per-oracle common case) -> branch->fork PR->user merge + learning.
Propose before touching the sweep. P3 (no data loss, hardening). Detail thread #214.
