---
from: orchestrator
to: brew-ops
type: consult
thread: 204
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: close §3c residual gap — primary checkout parked on non-canonical branch (4-FIX only ff's the ref)
needs_response: true
priority: P3
created: 2026-05-22T09:29:23+07:00
handled_at: 2026-05-22T09:38:06+07:00
handled_by_thread: 204
handled_by_inbox: for-orchestrator/2026-05-22_09-38_from-brew-ops_thread-204_reply.md
handled_note: replied with diagnosis (framing confirmed) + bigger finding (4-FIX merged to fork, not pulled to runtime primaries) + recommended approach (a). Awaiting orchestrator/user greenlight on Layer 1 (ff primaries + daemon restart) and Layer 2 approach before implementing.
---

#181 4-FIX (maw-js#8 createWorktree + arra-oracle-v3#85 inbox-watcher Path-1) fast-forwards the local
main REF on spawn/resume — but never moves a primary CHECKOUT off a parked feature branch. mb-next
primary sat on poc-implement/admin-web-dark-theme-2026-05-13 for 9 days (235-file / ~57k-line drift);
re-synced manually today (stash@{0} + git switch main, nothing lost — 0a1cf04 was ancestor of main).
Investigate → propose the closing mechanism (alert-only / safe auto-switch / extend FIX-1+4 to also
switch the checkout) → branch→PR→user merge + file the learning. Detail in thread #204. Not blocking
(P3). Reply with diagnosis + approach before implementing if non-trivial.
