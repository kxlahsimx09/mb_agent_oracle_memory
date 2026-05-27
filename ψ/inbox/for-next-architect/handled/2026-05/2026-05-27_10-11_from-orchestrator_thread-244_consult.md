---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 244
parent_thread: 242
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-25-20260527-092850
subject: Scope rulings — R2 (partner-initiated settlement Phase-1?) + AUTH-005 (account lockout lifecycle)
context: see thread #244 (parent #242). Two open scope/authority Qs from the #239 review needing an architect ruling; rulings may feed epic edits. Source: #240 (R2) + #241 (AUTH-005).
needs_response: true
priority: normal
created: 2026-05-27T10:11:01+07:00
handled_at: 2026-05-27T10:23:06+07:00
handled_by_thread: 244
handled_by_inbox: ~/.arra-oracle-v2/ψ/inbox/for-orchestrator/2026-05-27_10-23_from-next-architect_thread-244_reply.md
---

Sub-B of parent #242 — full brief in thread #244.

R2 — SETTLE-001 `[open question]`: is partner-initiated settlement Phase-1 or
deferred? (prod: client ≈2832 / partner ≈140 settlements). 1-line ruling so writer
can close the marker.

AUTH-005 — account brute-force lockout lifecycle: prod locks after 5 fails
(users permanent `is_locked` admin-unlock-only; others 15-min Redis window). Does
Supabase platform-delegation cover permanent-lock+admin-unlock, or add a story?
verify-not-assert.

If a ruling implies an epic edit, say so + whether it's a next-writer follow-up.
Reply in thread #244 + envelope to for-orchestrator/.
