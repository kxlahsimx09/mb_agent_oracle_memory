---
title: orchestrator dispatch — fleet-debug investigation resolved auto (no escalation) 
tags: [orchestrator, decision-authority, 2a-trivial-direct, accepted, fleet-debug, tmux, inbox-watcher, gotcha, thread-156, thread-155]
created: 2026-05-17
source: parent thread #156 — brew-ops investigation reply msg 450
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator dispatch — fleet-debug investigation resolved auto (no escalation) 

orchestrator dispatch — fleet-debug investigation resolved auto (no escalation) 2026-05-17

Request: user asked the orchestrator to "handle the thread #155 problem" — a post-restart backlog marker (thread #156) about a #155 dispatch envelope that appeared to sit unprocessed for ~1h.
Classification: single-agent dispatch (2a) to brew-ops. Reused the existing open backlog thread #156 as the working thread rather than opening a new one (thread-discipline: fewer/coarser threads). parent_session stamped (§151) so the reply routed back to the dispatching session.
Confidence at dispatch: HIGH — user instructed directly.
Outcome: brew-ops root-caused it in ~13 min. The backlog note's premise was wrong — it was NOT a PR #77 dispatch-routing regression. The watcher fired, spawned, and T1-VERIFIED the #155 worker correctly. The worker self-terminated mid-turn running an ad-hoc `tmux kill-window` mass-reap with no guard excluding its own host window; the envelope then correctly reached `failed_stuck` (T2 backstop). No fix PR, no watcher change.
User reaction: accepted.

Decision-authority + fleet-pattern lessons:
1. A backlog note's stated premise ("zero log entries, no worker spawned") is a CLAIM, not ground truth (P-004). Dispatch the worker to verify the premise itself, not just to act on it — brew-ops disproved it with the watcher log + state file.
2. Orchestrator-facing hazard: do NOT dispatch ad-hoc tmux-window / worktree reaping tasks to tmux-resident workers — a worker runs inside a tmux window and an unguarded `tmux kill-window` reap kills its own host before it can close the inbox loop (§11c/§11d). Window/worktree reaping belongs to the inbox-watcher gc, a non-tmux daemon that cannot kill itself. The #155 "forced worktree sweep" dispatch should never have been created — gc was healthy and self-cleaned 33→6 on cadence.
3. The T2 `failed_stuck` gate is the correct backstop when a worker is SIGHUP-killed mid-turn (no `Stop` event fires, so the §11l Stop hook cannot engage) — this performed as designed.

PR numbers confirmed for future reference: #75 = §151 sticky thread→session ownership; #77 = §153 dispatch-side sticky routing / worker dedup. Both routed #155 correctly.

---
*Added via Oracle Learn*
