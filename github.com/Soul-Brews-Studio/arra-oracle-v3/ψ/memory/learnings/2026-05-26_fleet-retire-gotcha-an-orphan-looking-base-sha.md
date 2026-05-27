---
title: FLEET-RETIRE GOTCHA — an "orphan-looking" base-SHA worktree may be a LIVE siblin
tags: [brew-ops, repo:cross, fleet, worktree-retire, sticky-ownership, inbox-watcher, gotcha]
created: 2026-05-26
source: campaign #237 fleet cleanup, thread #237, 2026-05-26 GMT+7
project: github.com/soul-brews-studio/arra-oracle-v3
---

# FLEET-RETIRE GOTCHA — an "orphan-looking" base-SHA worktree may be a LIVE siblin

FLEET-RETIRE GOTCHA — an "orphan-looking" base-SHA worktree may be a LIVE sibling-orchestrator campaign's §151 owner worktree. Do NOT infer orphan from "branch at base SHA + no feature work + not in the dispatching orchestrator's owner records."

Observed 2026-05-26 (campaign #237, brew-ops fleet cleanup): orchestrator wt-20 asked me to retire 6 closed-campaign worktrees (#225/#228/#234) and to ADJUDICATE mb-next-payment-gateway.wt-4-inbox-1779786440 (branch agents/4-inbox-1779786440 @ base SHA b8facce, no commits), which it suspected was a stray sibling spawn from #228.

Verdict: wt-4 was NOT an orphan. `~/.cache/inbox-watcher/sessions/next-architect/thread-231.owner` pointed to exactly that worktree. Thread #231 ("P2P hub Phase B catalogue") was status=pending (active) and authored by a DIFFERENT orchestrator session — claude@arra-oracle-v3.wt-22-20260526-150947, not the wt-20 that dispatched the cleanup. wt-4 sits at base SHA with no commits because #231 is a propose-then-DISCUSS analysis task (no code expected). Retiring it would have killed an in-flight campaign and orphaned #231.

ADJUDICATION RULE before retiring any worktree: (1) `grep -rl <worktree-id> ~/.cache/inbox-watcher/sessions/` to find which thread owns it; (2) `arra_thread_read <that-thread>` and check status — only status=closed is retire-eligible; pending/active = LEAVE. Two concurrent orchestrator sessions (wt-20 + wt-22) can each own separate campaigns, so absence from ONE orchestrator's owner records ≠ orphan — §151 sticky ownership is per-(oracle,wake-key), spanning sessions. base-SHA + no-commits is normal for analysis/review/discuss tasks and is NOT evidence of orphanhood.

Mechanics that worked: agents had already exited to an idle zsh shell, so "sleep" = `tmux kill-window` (no maw `sleep` verb exists; use `maw kill`/`tmux kill-window`). Target windows by NAME not index — tmux renumber-windows is on, so indices shift after each kill. `git worktree remove` WITHOUT --force is the dirty-gate (all 6 were clean). Cache eviction = plain `rm` of exact `sessions/<oracle>/thread-<id>.{owner,session-id,session-engine}` files (ephemeral ~/.cache, not vault → no P-001 issue). Tooling footgun: this sandbox's zsh loses PATH inside `for`/`eval` loop bodies (`git`/`sed`/`basename` → "command not found"); run destructive commands as top-level statements, not loop bodies, or a spurious "FAILED" masks that the command never ran.

---
*Added via Oracle Learn*
