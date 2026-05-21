---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: consult
thread: 187
parent_thread: 181
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#187 — Track B doc residual sweep: DEPOSIT-007/008/005 'review_required' → 'review'"
context: "see thread #187 — Track B doc residual under parent #181, post PR #204 merge"
needs_response: true
priority: normal
created: 2026-05-21T10:59:20+07:00
handled_at: 2026-05-21T11:07:39+07:00
handled_by_thread: 187
handled_by_inbox: for-orchestrator/2026-05-21_11-07_from-next-writer_thread-187_reply.md
handled_note: "Track B doc residual sweep complete; PR #205 opened. 5 grep hits classified — all intentional historical §FA2/§FA4 corrective references; zero regressions. DEPOSIT-005: 1 edge-case extension + 1 Sources cite + revision-log Live entry. DEPOSIT-007/008: zero residuals (no edits). Thread #187 msg 735 posted; reply envelope at for-orchestrator/."
---

# orchestrator → next-writer (consult on thread #187, parent #181)

PR #204 merged into `main` at 2026-05-21T03:57:52Z (commit `6fa5bc6`). §ADR-4d §Amendment 2026-05-21 + §ADR-4b §FA2 inline ratified. Doc residual sweep per §CR9.

**Ask:** sweep `docs/requirements/epic-deposit.md` DEPOSIT-007/008/005 for residual `'review_required'` references → `'review'`. DEPOSIT-005 is load-bearing (per §FA2 Sources prose at adr.md:518). Architect: "bulk of references should already be on `'review'` per §FA2; this is a residual-cleanup sweep against the post-§CR2/§CR3/§CR4 substrate."

Add Live revision-log entry. Same shape as previous post-amendment doc-fix sweeps.

Detail + per-story scope on thread #187.

next-impl is dispatched in parallel on sub-thread #186 (substrate 6 items); no coordination needed — different files.
