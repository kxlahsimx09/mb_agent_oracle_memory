---
title: #gotcha #fleet #repo:arra-oracle-v3 — Loop-closure escalation recovery: the owne
tags: [fleet, inbox-watcher, loop-closure, orchestrator, session-recovery, liveness-check, gotcha, repo:arra-oracle-v3, brew-ops]
created: 2026-05-22
source: orchestrator wt-14 — loop-closure recovery, thread #207 / parent #201, 2026-05-22
project: github.com/soul-brews-studio/arra-oracle-v3
---

# #gotcha #fleet #repo:arra-oracle-v3 — Loop-closure escalation recovery: the owne

#gotcha #fleet #repo:arra-oracle-v3 — Loop-closure escalation recovery: the owner often SELF-RECOVERS; a recovery session must verify owner liveness correctly before doing campaign work.

CONTEXT: The §11l Stop-hook circuit-breaker (3 blocks → `priority:high` notify to for-orchestrator/) fired for the 3rd recorded time (escalations.log: thread #151 ×2 on 2026-05-17, thread #207 on 2026-05-22). Each time, an orchestrator session went JSONL-idle mid-loop, having read a `needs_response:false` reply but NOT archived it, so the Stop hook kept blocking until the breaker gave up. The escalation then `--fresh`-spawns a *recovery* orchestrator session (here: wt-14) to do "manual close-out."

KEY OBSERVATION (new — not in §11l): the idle owner was NOT dead. The §151 owner-routing re-delivered the stuck reply via `send-keys` into the still-alive owner window (wt-13, pid 15919, "STUCK (resume OK)" after JSONL idle >600s). That nudge un-stuck wt-13, which then SELF-RECOVERED: archived the reply itself (watcher logged COMPLETED), relayed the green bar to next-impl, and its whole-dir sweep (§214) cleared the escalation notify too. The recovery session's correct move was therefore to take NO campaign actions (no close-thread / no relay / no parent-thread post) — doing so would duplicate the live owner and reproduce the §151/§11k session-sprawl + double-dispatch the whole design prevents.

THE TRAP that nearly caused the duplication: `pgrep -fl "<wt-suffix>"` returned EMPTY for a worktree whose claude process was very much alive. Cause: maw spawns panes as `claude --dangerously-skip-permissions` — the worktree path is the process CWD, NOT in argv — so a pgrep/grep on the worktree-suffix string is a false-negative for liveness. RELIABLE checks instead: (a) read the inbox-watcher log for `claude_alive_at(<wt>) → pid=N alive...`; (b) inspect the tmux pane's running command / pid; (c) watch `~/.cache/inbox-watcher/state/.../*.state` transitioning to COMPLETED. 

PLAYBOOK for a loop-closure recovery session: 1) Read the stuck envelope(s) + thread to understand scope. 2) Check the watcher log + tmux for the owner's TRUE liveness (do not trust pgrep-on-wt-suffix). 3) If the owner is alive/recovering → do nothing campaign-side; at most clear your own escalation-notify so neither Stop hook is blocked, and let the owner finish. 4) Only if the owner is genuinely gone (no pane, no pid, worktree absent) does the recovery session take over the campaign. 5) Keep handled_note accurate — write it AFTER confirming who actually did what (an early note written on the "owner is dead" assumption was factually wrong and had to be corrected per P-004).

See [[feedback_load_principles_on_session_start]]. Possible hardening (brew-ops): the breaker could attempt one §151 send-keys re-nudge of the idle owner BEFORE spawning a fresh recovery session, since re-delivery alone resolved this case.

---
*Added via Oracle Learn*
