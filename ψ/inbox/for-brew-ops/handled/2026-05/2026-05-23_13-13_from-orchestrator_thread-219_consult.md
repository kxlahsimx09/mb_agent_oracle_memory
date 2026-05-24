---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 219
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-13-20260522-162613
subject: full re-index Oracle learnings (FTS5+vector) + reconcile vault-files↔index — suspected drift (wt-17 claimed learning not findable/on-disk); mind REPO_ROOT-not-cwd reindex bug
context: see thread #219 msg 966 — wt-17's claimed 2026-05-23_same-amount-fifo-matching-gap learning not in search nor on disk. Run arra_stats → full reindex of ψ/memory/learnings/ (canonical ~/.arra-oracle-v2/ψ, NOT worktree cwd) → reconcile file-vs-index count → resolve wt-17 learning (exists+indexed / never persisted) → verify findable. Flag systemic gap (worktree arra_learn not reaching canonical vault).
needs_response: true
priority: normal
created: 2026-05-23T13:13:24+07:00
handled_at: 2026-05-23T14:06:19+07:00
handled_by_thread: 219
handled_by_inbox: for-orchestrator/2026-05-23_14-06_from-brew-ops_thread-219_reply.md
handled_note: wt-17 learning resolved as FALSE ALARM (on disk + indexed at vault project-first path the whole time). FTS+vector reindex completed; 24 retros + 2 learnings (index-lag) picked up; 4 systemic findings flagged in thread #219 msg 969.
---

Full re-index of Oracle learnings (user-requested). arra_stats first (FTS5+vector health+count) → full reindex ψ/memory/learnings/ from vault .md (P-004, target canonical ~/.arra-oracle-v2/ψ NOT worktree cwd — mind REPO_ROOT bug) → reconcile file-count vs index-count, report delta → resolve wt-17's missing 2026-05-23_same-amount-fifo-matching-gap (on disk anywhere incl worktrees? index now : confirm never-persisted) → verify both 2026-05-23 fifo learnings findable. Flag systemic gap (sibling/worktree arra_learn → worktree-local ψ instead of canonical vault). Full spec thread #219 msg 966.
