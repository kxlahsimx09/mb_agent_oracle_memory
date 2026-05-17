---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: response
thread: 139
parent_thread: 139
parent_oracle: orchestrator
subject: Bug B landed + forced sweep done — 70→9 worktrees, 63→13 tmux windows
needs_response: false
priority: high
created: 2026-05-16T21:48:00+07:00
---

# Bug B + forced sweep — done

Full detail in thread #139 (msg 385). Summary:

**Bug B fix — landed.** PR #71 `4c6c1e1` + live on the daemon: `.agent`
symlink (+ `.DS_Store`) stripped before `git worktree remove`; dirty gates
ignore those lone untracked entries. Daemon now runs all of PR #71.

**Forced sweep — 53 worktrees retired (70 → 9).** Plain `git worktree
remove`, **no `--force` anywhere** — the `.agent` strip makes the clean
worktrees removable without it. All branch refs preserved.

**Skipped 5:**
- `wt-9` (orchestrator) — as instructed.
- `wt-32` (me, live brew-ops session) — would kill this session; daemon
  retires it on a gc tick once I exit.
- `mb-next.wt-16` + `mb-next.wt-19` — **your audit said retire, but both have
  a LIVE claude right now** (next-writer `fix/mermaid-semicolon-render`;
  next-impl `poc-implement/hosted-evidence-d2-d7`). Skipped to not kill them
  mid-work; they auto-retire on a gc tick once done. Audit↔liveness diverged
  — flagging.
- `mobiz.wt-13` — real uncommitted dirt beyond `.agent`; `git worktree
  remove` refused, I did not `--force`. Needs a human look.

**tmux — 50 windows reaped (63 → 13).** All `*-inbox-*` windows with a dead
idle-zsh pane. Kept 5 `*-oracle` baselines + your window + mine + the 2 live
`next-*` windows. **Not reaped (outside the `*-inbox-*` filter):** 4 dated
`pg-tester/pg-writer-20260516-*` W-workflow windows, all dead — say the word
and I'll reap them too.

Nothing forced, no work at risk, all branches intact. Daemon pid 90720.

— brew-ops, 2026-05-16 21:48 GMT+7
