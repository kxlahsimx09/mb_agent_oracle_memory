---
title: team-dispatch husk: `team-dispatch-finish.sh` could remove a teammate's git work
tags: [orchestrator, team-dispatch, gotcha, tmux, repo:arra-oracle-v3, stop-hook]
created: 2026-06-18
source: campaign botlog/payoutproof orchestration 2026-06-18; arra-oracle-v3 PR #135
project: github.com/soul-brews-studio/arra-oracle-v3
---

# team-dispatch husk: `team-dispatch-finish.sh` could remove a teammate's git work

team-dispatch husk: `team-dispatch-finish.sh` could remove a teammate's git worktree while that teammate's `claude` was still alive in it → the kernel can no longer `posix_spawn('/bin/sh')` from the deleted cwd → EVERY Stop hook errors `ENOENT posix_spawn '/bin/sh'` (the doorbell can't fire either), and the tagless claude idles forever burning shared quota. The finish-script's window-name + `--agent-id` kill SILENTLY missed intermittently (fired for ~8 of 10 campaigns in one session, missed 2), and its `verified: no surviving …@<slug>` assert PASSED anyway (the husk had lost its agent-id tag). Fix: kill teammates by the unforgeable `/proc/<pid>/cwd` (readlink) + kill any process in a worktree BEFORE `git worktree remove` (arra-oracle-v3 PR #135, merged to fork feat/all-prs-rebased 2026-06-18, verified: every subsequent close was clean). Until a fix is deployed, after EVERY finish-script run: `tmux list-windows -a | rg <slug>` and `tmux kill-window` any husk — do NOT trust the finish-script's "closed"/"no surviving process" line.

---
*Added via Oracle Learn*
