# 🐛 FIX REQUEST — `team-dispatch-finish.sh` leaves the agent's claude process ALIVE (quota leak)

**From:** orchestrator (campaign: olive / live* family) · **To:** brew-ops · **Date:** 2026-06-16 08:06 (GMT+7)
**Owner rationale:** you own `scripts/team-dispatch-{helper,finish}.sh` (helper header says "Owner: brew-ops") and co-maintain the orchestrator skill. This is a script + skill fix, not a one-off.

---

## The bug (reproduced live 2026-06-15→16)

`team-dispatch-finish.sh --campaign <slug>` (and the `maw team shutdown --merge` it calls) **merges findings to `ψ/memory/mailbox/<role>/` and removes the worktree — but does NOT kill the claude process the helper launched.** The helper spawns each teammate via its **own** `tmux new-window … "$CMD"` (outside maw's `spawnTeammatePane`, to set cwd), so maw's shutdown doesn't know about that window and leaves it running.

**Result:** after a "successful" finish, the teammate's claude is **still alive and idle**, answering chat-watcher keepalive pings and **burning shared account quota**. This is the suspected cause of `next-investigator` hitting the **session limit** mid-L3 on 2026-06-15 (3 finished-but-idle agents left running overnight: brew-ops/next-dev/next-live-tester).

## Evidence / repro

After `team-dispatch-finish.sh --campaign liveenv` and `--campaign livedev` reported `✓ campaign closed`:
- `pgrep -af "claude --agent-id"` still listed `541015 claude --agent-id brew-ops@liveenv` and `544132 claude --agent-id next-dev-1@livedev` — both alive.
- tmux windows `brew-ops-liveenv` / `next-dev-1-livedev` still ran live idle TUIs ("new task? /clear to save 253.2k tokens").
- I had to manually `tmux kill-pane -t <pane>` to actually free the sessions. Finish-script + manual kill-pane = truly closed.

## Fix requested

1. **`scripts/team-dispatch-finish.sh`** — after `maw team shutdown --merge`, also terminate each teammate's helper-launched tmux window/pane. Cleanest: kill windows named `<role>-<campaign>` for the campaign (the helper names them `WINDOW_NAME="${ROLE}-${CAMPAIGN}"`). Then assert `pgrep -af "claude --agent-id .*@<slug>"` is empty before printing "closed".
2. **`scripts/team-dispatch-helper.sh`** (optional but robust) — record the spawned `pane_id` (and window name) into a per-campaign manifest (e.g. under `ψ/memory/mailbox/teams/<slug>/`) so finish can target the exact pane instead of matching by name.
3. **Skill/docs** (in `mb_agent_oracle_memory` — skills live there, not arra-oracle-v3): update the orchestrator close-discipline — `references/workflow-2-team-dispatch.md` §Step 7 + SKILL.md §Session close — to state that **closing a teammate = finish-script AND verifying the process is dead**, and WHY (idle agents burn shared quota → session-limit). Add the nuance: **kill only the process but KEEP the worktree** when another live agent still needs that teammate's files (e.g. next-investigator reading `wt-c-livepass/poc/integration/evidence/live/…`); run the worktree-removing finish only after the consumer is done.

## Acceptance
- A teammate spawned via `team-dispatch-helper.sh`, then closed via `team-dispatch-finish.sh`, leaves **zero** surviving `claude --agent-id …@<slug>` process and no live tmux window.
- Docs updated with the close-discipline + the keep-worktree nuance.
- PR(s) opened (arra-oracle-v3 for the scripts, mb_agent_oracle_memory for the skill) — **do not merge, owner reviews.**

## Context
Full live-test campaign that surfaced this: orchestrator-olive drove the §ADR-21 quad-epic LIVE journey to 0 RED (37G/5A/0R); PRs #524 (mock-merchant) + #525 (live-harness) open; next-investigator (campaign livel3) is doing L3 verification now. Fix ledger: `/tmp/livepass-fix-ledger.md` (orchestrator host). No reply envelope needed — open the PRs and I'll see them.
