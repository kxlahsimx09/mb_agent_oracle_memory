---
title: maw team send delivers to a VOID when lanes are spawned via team-dispatch-helper
tags: [orchestrator, maw, team-dispatch, send-keys, injection, tmux, silent-fail]
created: 2026-06-12
source: orchestrator-buildteam wt-26, thread #16
project: github.com/soul-brews-studio/arra-oracle-v3
---

# maw team send delivers to a VOID when lanes are spawned via team-dispatch-helper

maw team send delivers to a VOID when lanes are spawned via team-dispatch-helper.sh — use direct tmux send-keys by window NAME instead.

**Observed (2026-06-12, orchestrator-buildteam wt-26, campaigns secres/livegate):** `maw team send <slug> <role>` returned "✓ message sent" for 3 consecutive relays, but the text never appeared in ANY tmux pane (verified by grepping scrollback of all 8 windows). Root cause hypothesis: the helper runs `maw team spawn` WITHOUT --exec only to capture the claude command, then launches its own `tmux new-window` — so maw's team registry never learns the real pane; sends go to the stale/nonexistent registered target and report success. An earlier "successful" relay was a coincidence: the target lane had independently read the same envelope from for-orchestrator/, creating the illusion that team send worked.

**Why it matters:** silent dispatch loss — the orchestrator believes instructions were delivered (CLI says ✓), lanes idle or proceed without the new context. Worst case: owner decisions (merge authority, task verdicts) never reach the lane.

**How to apply:**
1. After spawning via team-dispatch-helper.sh, deliver ALL follow-up messages with `tmux send-keys -t '<session>:<window-name>' -l -- "$MSG"` + separate Enter (bracketed-paste discipline), never `maw team send`.
2. Target by window NAME, never index (windows renumber when any window dies — same session this bit us: window 1 changed identity mid-campaign).
3. Step 3.5 preflight stands: capture-pane before (stale input = owed work) and after (text still at ❯ → one bare Enter).
4. Verify delivery by capturing the pane and seeing the turn submitted/spinner — "✓ message sent" from the CLI proves nothing.

**Same session, related anomaly:** a stray `/agents-sdk` slash-command turn was SUBMITTED into an idle lane (next-tester-livegate) by an unidentified sender — the build2-class injection but submitted, not just typed. Lane handled it correctly (refused to fabricate a task). Tripwire v2 now also greps recent scrollback for submitted `^❯ /<cmd>` turns. Leftover disbanded-team windows (next-live-tester-live, next-tester-regression from bankbot2) increase index-mistarget risk — fleet hygiene should reap them by NAME with ownership verification.

---
*Added via Oracle Learn*
