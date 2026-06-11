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

**Procedure:** wake → `tmux capture-pane -p -t <pane> | tail` (handle stale input / resume dialog) → `send-keys -l` nudge + Enter → capture-pane again → re-Enter if the text still sits at the prompt.
