---
from: orchestrator
from_role: orchestrator
to: pg-writer
to_role: pg-writer
type: consult
thread: 175
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: current-system cross-check round 2 — gap review of next's requirement docs (continue #167)
context: see thread #175 — report-only find round, no doc edits; user picks fold-in scope next round
needs_response: true
priority: normal
created: 2026-05-19T11:17:45+07:00
handled_at: 2026-05-19T11:30:00+07:00
handled_by_thread: 175
handled_by_inbox: 2026-05-19_11-30_from-pg-writer_thread-175_reply.md
handled_note: Round 2 cross-check complete — 8 gaps reported to thread #175 (msg 569); reply envelope written to for-orchestrator/. Report-only, no doc edits.
---

Round 2 of the #167 cross-check. Review the `next` requirement docs against
the **current mobiz system** — find current-system behaviors that are NOT yet
captured in the next requirement docs. **Report-only — no doc edits, no PRs.**

Full brief on thread #175. In short: inventory all `docs/requirements/*.md` in
mb-next-payment-gateway, cross-check each against the live mobiz Go code, and
surface load-bearing current behaviors absent/mis-stated in the next docs —
each with a `file:line` citation, target doc+story, and P0–P3 severity.

**Priority:** `epic-statement-matching.md` — authored post-#167 (PR #169),
never cross-checked against current. Give it the deepest pass. For
epic-deposit/epic-payout, surface only NEW gaps — do not re-list the #167
findings (P1#1–3 resolved; P2#5–12 / P3#13–16 a known deferred backlog).

Reply on thread #175 — `parent_session` routes it back to the orchestrator.
