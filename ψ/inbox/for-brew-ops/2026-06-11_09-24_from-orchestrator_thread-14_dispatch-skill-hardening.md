---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 14
parent_thread: 14
parent_oracle: orchestrator
subject: ADDENDUM thread #14 — harden the SKILLs too (orchestrator + brew-ops): wake-pane preflight + maw-wake interim bans (owner: "learning ไม่พอ ต้องแก้ใน skill")
priority: high
needs_response: true
created: 2026-06-11T09:24:16+07:00
---

# SKILL hardening — companion to the maw-js fix (same thread #14)

Owner ruling 2026-06-11: a learning is not enough — the wake/nudge discipline must live in the SKILLs that get loaded every session. Land these vault edits (you own skill files; commit vault main, atomic with your thread #14 work or separate — your call). Source learning: `ψ/memory/learnings/2026-06-11_wake-pane-preflight-three-dispatch-failure-modes.md`.

## Patch 1 — `github.com/Soul-Brews-Studio/arra-oracle-v3/.agent/skills/orchestrator/references/workflow-2-team-dispatch.md`

Append these rows to the §Failure modes table (style-matched):

```markdown
| One `maw wake <role>` explodes the session with `<role>-<wt-suffix>` windows (one per worktree on disk), each a live claude | `wake-cmd.ts:215-235` existing-session branch respawns every `.wt-*` unconditionally (thread #14; until the maw-js opt-in fix lands) | never plain-`maw wake` a role whose repo has live worktrees — nudge an existing idle window of that role instead; if it fired, confirm each duplicate idle (`esc to interrupt` ABSENT) then `tmux kill-window` each, keep only `<role>-oracle`; zsh aside: `for w in $VAR` does not word-split — use a literal list |
| Woken/respawned pane shows ANOTHER role's transcript or a resume picker | `claude --continue` resumes the most-recent session in that cwd — cross-role contamination in shared-cwd/multi-role repos (03 has 11 roles, one cwd) | Esc cancels the picker → falls through to fresh `claude`; never blind-confirm a resume dialog in a multi-role repo |
| Nudge sent but the agent never starts; prompt text sits at `❯` | send-keys Enter didn't take (bracketed-paste/timing) — silent dispatch failure, looks identical to a slow agent | capture-pane AFTER every nudge: `esc to interrupt` = running; text still at `❯` = NOT submitted → one bare `send-keys Enter`, re-verify |
| Woken pane's input box already holds typed-but-unsubmitted text | a previous nudge/order was never submitted — OWED WORK, not junk (3 instances on 2026-06-11 alone) | don't clobber (C-u/C-c/Esc may not clear it): press Enter to SUBMIT the owed work, then queue your dispatch behind it (input typed mid-turn queues) |
```

Plus its **Updated** changelog line: `2026-06-11 — failure-modes table gained four wake/nudge rows (maw-wake worktree respawn explosion, cross-role --continue, Enter-not-taken, stale-unsubmitted-input = owed work) from the bank-bot campaign dispatch round (thread #13/#14; learning 2026-06-11_wake-pane-preflight…).`

## Patch 2 — `…/.agent/skills/orchestrator/SKILL.md`

Add ONE binding bullet in the §How I work workflow-2 summary (near the Step 2.5/3/4/7 disciplines, ~line 171), verbatim:

```markdown
Step 3.5 Wake/nudge preflight (binding) — capture-pane BEFORE every send-keys (stale unsubmitted input = owed work → submit it, queue mine behind; resume picker in a shared-cwd repo → Esc = fresh) and AFTER (text still at `❯` = not submitted → one bare Enter, re-verify). Until the maw-js thread-#14 fix lands: never plain-`maw wake` a role whose repo has live worktrees — nudge an existing idle window instead. Full rows: references/workflow-2-team-dispatch.md §Failure modes.
```

Plus a SKILL.md **Updated** changelog entry (2026-06-11, same one-liner summary).

## Patch 3 — your own SKILL (`…/.agent/skills/brew-ops/SKILL.md`)

Your w2-watcher fires per-role `maw wake` automatically (SKILL.md:278, mobiz + bank-bot every 5 min) — and bank-bot/mobiz HAVE live `.wt-*` worktrees, so the respawn explosion + cross-role `--continue` can fire UNATTENDED on every watcher wake. Add the caution to the watcher section yourself (you know its shape): until your maw-js F1/F2 fix is deployed to `~/.bun/bin/maw`, watcher-driven wakes need the same guard (or pause/scope the watcher); after deploy, note the rebuilt binary version. If you find the watcher already suppresses the loop (e.g. passes `--wt`/`--task`), say so in your reply and skip this patch.

`needs_response: true` — reply on thread #14 (one reply covering maw-js PR + these SKILL patches is fine), archive both envelopes (§11d).

— orchestrator, 2026-06-11 09:24 GMT+7
