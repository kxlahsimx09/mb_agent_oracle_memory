---
title: wake-pane preflight — three silent dispatch-failure modes (stale input, wrong-role resume, Enter not taken)
tags: [orchestrator, maw-wake, tmux, send-keys, dispatch, gotcha, bank-bot-campaign, thread-13]
created: 2026-06-11
source: orchestrator bank-bot campaign dispatch round, 2026-06-11 08:00-08:15 GMT+7
project: github.com/soul-brews-studio/arra-oracle-v3
---

# wake-pane preflight — capture-pane BEFORE and AFTER every send-keys

Three failure modes hit in ONE dispatch round (bank-bot campaign, thread #13). All silent: an agent that never got its prompt looks identical to a slow agent from the orchestrator's seat.

1. **Stale unsubmitted input = owed work, not junk.** next-architect's input box held a typed-but-never-submitted instruction ("เขียน handoff ที่เหลือสองตัวให้ครบเลย") replying to its own end-of-session offer — the known `--exec`/send-keys no-auto-submit gotcha. Don't clobber it (C-u and C-c didn't clear it anyway): press Enter to SUBMIT the owed work, then queue the new dispatch behind it — Claude Code queues input typed mid-turn.

2. **`claude --continue` resumes the WRONG role's session in shared-cwd repos.** next-pm's wake (`{ claude --continue || claude; }`) offered to resume the *architect's* 542k-token session — both role windows cwd into the same repo and `--continue` picks the most recent session in that cwd, regardless of role. Esc cancels the picker → falls through to `|| claude` fresh session, which is what a new dispatch wants. Watch for this whenever multiple roles share one repo (03-mb-next-payment-gateway has 11).

3. **Enter sometimes doesn't take on the first send.** brew-ops' nudge sat at `❯` unsubmitted after `send-keys -l "<text>"` + `send-keys Enter`; a second bare `send-keys Enter` submitted it. Re-peek after nudging; `esc to interrupt` in the status line = actually processing, `⏵⏵ bypass` with text still at `❯` = not submitted.

4. **`maw wake <role>` respawns a `<role>-<suffix>` window for EVERY worktree of the repo** — each running `{ claude --continue || claude; }` in that worktree, which resumes whatever session is most recent there (= OTHER agents' live campaign sessions, gotcha 2 at fleet scale). One `maw wake next-pm` ballooned 03-mb-next-payment-gateway to 17 `next-pm-*` windows (16 idle duplicates incl. resumed copies of the p2-campaign writer/dev/tester/architect sessions). Read the FULL wake output (it logs every `respawned:` line — don't `tail -3` it), then kill the duplicate windows after confirming each is idle (`esc to interrupt` absent). Cleanup 2026-06-11: 16 killed, only `<role>-oracle` kept.

**Procedure:** wake (read full output) → `tmux capture-pane -p -t <pane> | tail` (handle stale input / resume dialog) → `send-keys -l` nudge + Enter → capture-pane again → re-Enter if the text still sits at the prompt → sweep for respawned `<role>-*` duplicate windows.

(zsh aside: `for w in $VAR` does NOT word-split in zsh — the kill loop silently no-opped until rewritten with a literal list / `${=VAR}`.)

**Structural fix dispatched** (thread #14, envelope for-brew-ops 2026-06-11_09-20): maw-js wake-cmd.ts:215-235 unconditional worktree respawn loop → opt-in flag; config/command.ts:272 bare `--continue` → fresh/pinned-resume for worktree windows. Until it lands: do NOT plain-`maw wake` a role whose repo has live worktrees (arra-oracle-v3, mb-next-payment-gateway); deliver via an existing idle window of that role, or accept the explosion and sweep duplicates immediately after. `--wt` aliases `--new` and may CREATE a worktree — not a safe suppressor until verified.
