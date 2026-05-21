---
title: A dispatched worker that mass-`tmux kill-window`s will kill its own host window 
tags: [gotcha, tmux, fleet, inbox, brew-ops, repo:arra-oracle-v3, drift, worktree-sweep]
created: 2026-05-17
source: brew-ops root-cause, thread #156 (dispatch-miss #155)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# A dispatched worker that mass-`tmux kill-window`s will kill its own host window 

A dispatched worker that mass-`tmux kill-window`s will kill its own host window and silently abort its inbox loop.

**Incident (2026-05-17, thread #155 → root-caused on #156):** brew-ops worker session 2e6e1abc (wt-50-inbox-1779014713) was dispatched a "forced worktree sweep". It did the sweep correctly, then its final action was an ad-hoc reap: `tmux list-windows -a … | while …; do tmux kill-window -t "$tgt"; done`. The worker runs *inside* a tmux window; the reap had no guard excluding the current window. The JSONL ends abruptly the instant that command returned — no following assistant turn, no `Stop` event — the signature of the claude process being SIGHUP-killed when its own pane was torn down (`tmux kill-window` destruction is async server-side, so the Bash command completes and returns output, then the pane dies). The worker never posted its thread reply, never wrote a reply envelope, never archived the inbox envelope → watcher correctly raised `failed_stuck` at T2.

**Why it looked like a routing bug (it was not):** the orchestrator's backlog note claimed "zero watcher-log entries, no worker spawned" and suspected the #77 dispatch-side routing change. False — the watcher log had fire + owner + VERIFIED lines and the state file showed `verified_at` set. Routing (#75 §151 ownership, #77 §153 dedup) worked; `failed_stuck` ≠ `failed_no_prompt`.

**Rules:**
1. Workers must NOT mass-kill tmux windows. Window/worktree reaping belongs to the inbox-watcher gc — a non-tmux daemon that cannot kill itself. It reaps via `maw kill "*:*${wt_suffix}*"` (suffix-targeted) and gates on `claude_alive_at` before touching a worktree.
2. If a forced reap is ever unavoidable, exclude the current window: `tmux display -p '#{window_id}'` / `$TMUX_PANE`, and check pane liveness.
3. The §11l loop-closure Stop hook CANNOT catch a SIGHUP-killed session (no `Stop` event fires). The inbox-watcher T2 `failed_stuck` gate is the only backstop for a worker killed mid-turn — it worked here.

**Diagnostic tell:** a worker JSONL that ends right after a tool_result with no assistant turn and no error record = process killed mid-turn, not a graceful stop or a crash.

Tags: #repo:arra-oracle-v3 #fleet #inbox #gotcha #tmux #brew-ops

---
*Added via Oracle Learn*
