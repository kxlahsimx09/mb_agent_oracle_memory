---
type: learning
title: maw team dispatch broken (oracle-members module) + chat-watcher orphan accumulation
date: 2026-05-29
author: orchestrator
status: open
priority: high
tags:
  - "#repo:maw-js"
  - "#repo:arra-oracle-v3"
  - "#fleet"
  - "#tmux"
  - "#team-dispatch"
  - "#orchestrator"
  - "#brew-ops"
  - "#bug"
  - "#gotcha"
  - "#drift"
note: >
  Written as a vault file because arra_thread / arra_learn were returning
  HTTP 500 "Embedding generation failed - llama.cpp may have crashed
  (std::bad_alloc)" — Oracle embedder was OOM under load ~27 on 2026-05-29.
  Promote to a real Oracle thread once the embedder recovers.
---

# maw team dispatch broken + chat-watcher orphan accumulation

Logged by orchestrator after a 2026-05-29 fleet-cleanup campaign (purged hung
tmux windows 39→10, removed 15 stale worktrees, then tried to dispatch
follow-up ops). Two real defects + one environment issue. Code fixes are
brew-ops / maw-js work.

## P1 (HIGH) — `maw team` is broken: workflow-2 dispatch unavailable
- Symptom: `maw team spawn <campaign> <role>` and `maw team members <campaign>`
  both fail with:
  `Cannot find module './oracle-members' from
  '/Users/dev01/Code/github.com/Soul-Brews-Studio/maw-js/src/commands/plugins/team/index.ts'`
- Effect: `scripts/team-dispatch-helper.sh` aborts at "could not extract claude
  cmd from spawn output". The worktree IS created (`<repo>.wt-c-<slug>` + `.agent`
  symlink) but NO teammate spawns → half-done dispatch + orphan worktree
  (observed `arra-oracle-v3.wt-c-brewbotgc`).
- Why it matters: per orchestrator SKILL §How I work (updated 2026-05-29),
  workflow-2 (`maw team`) is the DEFAULT dispatch path and workflow-1
  (envelope+watcher) is demoted to cron-only. With `maw team` broken the
  orchestrator has no working non-legacy dispatch path — this blocks the
  Core Principle 2b (dispatch-first) just codified (commit a962761).
- Likely cause: missing/renamed `oracle-members` module import in
  `maw-js/src/commands/plugins/team/index.ts` (build/refactor regression).
  Fix + add a `maw team spawn/members` smoke test.

## P2 (MEDIUM) — chat-watcher orphans accumulate on session death
- `scripts/brew-ops-bot/chat-watcher.sh` runs one process per session (target =
  last arg, e.g. `brew-ops/20260526-124045`).
- When a session/window is killed the watcher is NOT reaped immediately — it
  self-exits only after a poll cycle notices the pane is gone. During cleanup
  this left ~25 transient orphans (observed 39 running, drained to 14 = exactly
  one per live window once orphans noticed their dead panes).
- Effect: bursts of orphan watchers after any session cleanup; their output can
  flood the controlling TTY under load. Fix: supervisor should reap a session's
  watcher synchronously on session/window kill instead of relying on the
  watcher's self-exit poll.

## P3 (ENV, FYI) — degraded shell + Oracle during the campaign
- Severe tool-output lag with results mixing across commands; `pgrep` /
  `tmux list-windows` intermittently returned empty (false zeros), making
  automated process classification unsafe — fell back to a static known-dead
  whitelist + hard keep-guards before any kill.
- Oracle embedder OOM: arra_thread/arra_learn → HTTP 500 std::bad_alloc
  (llama.cpp crash). Load avg ~27.
- Debug note: trust bracket-grep counts (`ps aux | grep -c '[c]hat-watcher.sh'`)
  over pgrep in this state.

## Net state after campaign (verified)
- tmux windows 39→10 (+a few re-spawned by the broken dispatch attempt)
- chat-watchers 39→14 (0 orphans, 1:1 with live windows)
- 15 stale worktrees removed; 2 worktrees flagged & KEPT for unpushed work
  (mb-next `brew-ops-cf-gateway-deploy`; `wt-17 next-impl/perf-cf-gateway-fail-open`)

## Proposed owners
- P1 → maw-js (brew-ops): fix `./oracle-members` import + smoke-test
  `maw team spawn`/`members`.
- P2 → brew-ops: reap chat-watcher on session/window kill.
- Until P1 is fixed, orchestrator dispatch must fall back to the legacy envelope
  path (or human), which SKILL §How I work explicitly warns against.
