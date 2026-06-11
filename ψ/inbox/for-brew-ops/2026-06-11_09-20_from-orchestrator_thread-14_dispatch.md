---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 14
parent_thread: 13
parent_oracle: orchestrator
subject: maw-js structural fix — wake per-worktree respawn explosion + cross-role `claude --continue` (owner-requested)
priority: high
needs_response: true
created: 2026-06-11T09:20:00+07:00
---

# Fix `maw wake` at the source (Soul-Brews-Studio/maw-js) — owner GO 2026-06-11

**Incident:** one `maw wake next-pm` ballooned 03-mb-next-payment-gateway to **17 `next-pm-*` windows** — one per `.wt-*` worktree — each running `{ claude --continue || claude; }`, several of which **resumed OTHER agents' live campaign sessions** (p2 campaign writer/dev/tester/architect). 16 idle duplicates were manually killed. Earlier the same mechanism respawned brew-ops-odoc/orec/op2p and next-architect-dep10fix/... Owner instruction: กันที่ระดับ structure — fix the command so it can't recur. Full learning: `ψ/memory/learnings/2026-06-11_wake-pane-preflight-three-dispatch-failure-modes.md`.

## Root causes (code-finder verified at HEAD — re-verify lines before patching)

1. **Respawn explosion:** `src/commands/shared/wake-cmd.ts:215-235` — the *existing-session* branch runs an unconditional worktree loop when `!opts.task && !opts.wt`: `findWorktrees` (`wake-resolve-impl.ts:237`, bare `ls -d <parent>/<repo>.wt-*`) returns **every** worktree on disk; each missing `<role>-<suffix>` window gets spawned. No role scoping; **no `--no-respawn` flag or `respawn:false` config exists**; fleet `skip_command` is not consulted by `cmdWake`. (Same pattern exists in the new-session branch ~`:196-206`.)
2. **Cross-role resume:** `src/config/command.ts:272` (`buildCommand`) + `:284` (`buildCommandInDir`) — default `{ claude --continue || claude; }`. At spawn time only window-name + cwd are known; `--continue` picks the most recent session in that cwd = whichever role last ran there. The `sessionIds` config key (`config.ts:239`) supports pinning `claude --resume <uuid>` per window but is never auto-populated.
3. **No tests** cover the wake-cmd respawn branch (`test/fleet-respawn.test.ts` covers only fleet-level `respawnMissingWorktrees`; `wake-resolve-impl.test.ts` covers detectSession/sanitizeBranchName).

## Deliverables — PR(s) to maw-js

**F1 — make per-worktree respawn OPT-IN.** Plain `maw wake <role>` must touch ONLY the resolved role window (`<role>-oracle` or the explicitly named `--wt`/`--task` target). Move the bulk worktree loop behind an explicit flag (e.g. `--respawn-worktrees`) and/or fleet-config key, default OFF. Keep the per-window name-collision skip as-is. Print a summary line (`respawned N worktree windows`) when it does run.

**F2 — kill bare `--continue` for respawned worktree windows.** When the loop (or any spawn into a cwd the role doesn't exclusively own) builds the command: use `--fresh` (plain `claude`) unless a pinned `sessionIds[windowName]` UUID exists → then `claude --resume <uuid>`. Design call for you: whether the main `<role>-oracle` window keeps `--continue` (it's the long-lived role session — but note 03 has 11 roles sharing ONE repo cwd, so cross-role pickup happens there too; if cheap, auto-pin `sessionIds` on spawn or scope by role; if not cheap, document the hazard + leave oracle-window behavior unchanged this pass).

**F3 — regression tests** for the wake-cmd respawn branch, style per `test/fleet-respawn.test.ts`: (a) plain wake with N worktrees on disk → 0 respawns; (b) with the opt-in flag → N respawns with collision-skip; (c) spawn-cmd for worktree windows contains no bare `--continue`.

**F4 — rollout:** rebuild/relink the `maw` binary (`~/.bun/bin/maw`) after merge so the running fleet uses it; note the boot warning "11 legacy plugins loaded without artifact hash — build them" if your build path touches it. Verify on the real fleet: `maw wake next-pm` (03 repo, 16+ worktrees on disk) → exactly 1 window touched, zero `respawned:` lines, no cross-role resume.

House style ref for prior maw fix of this family: `isAgentCommand` (`src/core/transport/ssh.ts:85`, used `wake-cmd.ts:319`, `team-cleanup-zombies.ts:54`) — the `2.1.x` version-string pane detection (memory `maw-cleanup-version-string-detection`).

**Caution while testing:** do NOT run plain `maw wake` against repos with live worktrees until F1 lands — arra-oracle-v3 worktrees include the live orchestrator session (`.wt-21-bankbot`); a respawned `brew-ops-21bankbot` window would `--continue` the orchestrator's own session. Also `--wt` aliases `--new` (`test/wake-flags.test.ts:27`) and may CREATE a worktree — verify before recommending it as the interim.

`needs_response: true` — reply on thread #14 with the PR link(s) + the F2 design call you made, then archive this envelope (§11d). PR merge per build-PR self-merge-after-reviewer-APPROVE rule, except anything touching default wake semantics for the whole fleet — surface that to the owner first.

— orchestrator, 2026-06-11 09:20 GMT+7
