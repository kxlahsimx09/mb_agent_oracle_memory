---
title: team-dispatch-helper.sh delivers the task as a SYSTEM PROMPT, never as an initia
tags: [orchestrator, team-dispatch, team-dispatch-helper, fleet-infra, brew-ops, system-prompt-file-vs-initial-turn, kickoff-delivery-gap, spawn-prompt-not-a-turn, tmux-send-keys-separate-enter, skill-behavior-mismatch, mb-next-payment-gateway, repo:arra-oracle-v3, fleet]
created: 2026-05-30
source: scripts/team-dispatch-helper.sh lines 117/134 + ps of spawned next-writer@gapqw2; orchestrator session 2026-05-30
project: github.com/soul-brews-studio/arra-oracle-v3
---

# team-dispatch-helper.sh delivers the task as a SYSTEM PROMPT, never as an initia

team-dispatch-helper.sh delivers the task as a SYSTEM PROMPT, never as an initial user turn — spawned teammate has no kickoff (root cause of the gapqwin/gapqw2 "agent ignores brief" failures)

SYMPTOM (2 instances, 2026-05-30): orchestrator dispatches next-writer via scripts/team-dispatch-helper.sh --prompt "<task>". The spawned agent does NOT do the task: instance 1 (campaign gapqwin, PR #281) did unrelated standing-agenda work (CF-gateway pointers from a design-doc "open work" marker); instance 2 (gapqw2) replied "I need to find my instructions first" when given a bare "begin, do your instructions" kickoff. Only when the orchestrator sent the FULL task text as an actual first user turn (or wrote it to a TASK_BRIEF.md and told the agent to read+execute it) did the agent do the right 3 edits.

ROOT CAUSE (read from the script + ps of the spawned proc):
- helper line 117: `maw team spawn "$CAMPAIGN" "$ROLE" --model "$MODEL" --prompt "$PROMPT"` — the team plugin routes --prompt into a `--system-prompt-file` (confirmed: spawned proc ran `claude … --system-prompt-file .../<role>-spawn-prompt.md`).
- helper line 134: `tmux new-window -n "$win" -c "$WT_PATH" "$cmd"` launches claude with NO positional `[prompt]` (claude usage = `claude [options] [command] [prompt]`; the positional is the initial user turn).
- Net: the task becomes the agent's SYSTEM PROMPT (frames behavior) but nothing KICKS OFF a turn. A fresh claude with a system prompt and no opening user message just sits idle / drifts to whatever standing agenda it infers.
- SKILL workflow-2-team-dispatch.md line 71 ("The prompt body is the entire dispatch contract") implies the helper delivers the task — but it does not deliver it as a turn. Doc ⇄ behavior mismatch.

NOT the same as the earlier two gapqwin failures (those were: orchestrator-guard window-name misfire — since FIXED by user to self-gate correctly + spawn in a separate window `<role>-<campaign>`; and role-agenda-override). This is a THIRD, distinct, still-open defect: the kickoff-delivery gap.

FIX (owner: brew-ops; orchestrator must not edit fleet scripts/SKILLs — scope + guard):
- Preferred (A): keep system-prompt-file for ROLE IDENTITY only; deliver the TASK as the first user turn — after `tmux new-window`, `tmux send-keys -t <pane> -l "<task>"` then a SEPARATE `tmux send-keys -t <pane> Enter` (bracketed-paste eats a same-call trailing Enter — observed: a text+Enter in one send-keys leaves the line un-submitted in the input box).
- Alt (B): append the task as the positional `[prompt]` to the generated claude cmd at line 134 so the agent opens with the task as turn 1.
- Interim (C): document in workflow-2 SKILL that the orchestrator MUST send the task as an explicit first turn (send-keys -l text, then separate Enter) after team-dispatch-helper, because the helper only frames it as a system prompt.

OPERATIONAL NOTE: when sending a kickoff via tmux send-keys to a claude TUI, ALWAYS send the text and the Enter as two separate send-keys calls — combining them leaves the message queued/unsent (root cause of the gapqwin 0-commits-22min stall earlier the same day).

Verified-against-HEAD still held: the 3 quick-win edits (CALLBACK-001 WC9 timeout AC, AUTH-007 S3 replay-scope edge case, INDEX Deferred-Payout-Surfaces/PAYOUT-011) were re-confirmed needed (grep=0) before this dispatch; BOT-001 + PULLOUT-002 stayed dropped (shipped PR #261).

---
*Added via Oracle Learn*
