---
title: maw wake/hey hardening bundle — 6 commits on `fix/wake-prompt-injection-outside-
tags: [brew-ops, hardening-bundle, maw-js, live-use-discovery, pattern, wake, hey, fleet, repo:maw-js, 2026-04-19]
created: 2026-04-19
source: 6 commits on fix/wake-prompt-injection-outside-brace-group branch, 2026-04-19 brew-ops session
project: github.com/soul-brews-studio/maw-js
---

# maw wake/hey hardening bundle — 6 commits on `fix/wake-prompt-injection-outside-

maw wake/hey hardening bundle — 6 commits on `fix/wake-prompt-injection-outside-brace-group` of `github.com/Soul-Brews-Studio/maw-js` (off main at `82b739f`, not yet merged/pushed as of 2026-04-19):

```
c55a32a  feat(wake): auto-symlink .agent + .claude into new worktrees
6fb07f9  fix(hey/detection): detect claude when pane_current_command is a version string
f5199db  fix(wake): --fresh creates new isolated window, never kills running ones
0a67437  feat(wake): --fresh = fresh everything (SUPERSEDED by f5199db)
f371701  fix(wake): defensive direnv prefix — silent no-op when not installed
80c52c9  fix(wake): inject -p <prompt> INSIDE the { ... } command group
```

## What each fix addresses

1. **`-p` injection bug** — prior wake.ts did `${buildCommandInDir(...)} -p '${task}'` which appended `-p '...'` AFTER the closing `}` of the `cd && { claude || claude; }` compound. zsh parse-error. Fix: thread `prompt` through buildCommand + buildCommandInDir, inject `-p '<escaped>'` INSIDE each claude invocation on both primary + fallback branches.

2. **Defensive direnv prefix** — `direnv allow . && eval "$(direnv export zsh)"` fired on every wake, printing `command not found` on machines without direnv (e.g., pre-install, new worker). Benign-for-behaviour (the `&&` short-circuited; rest still ran) but noisy. Fix: guard with `command -v direnv >/dev/null && { ... }`. Silent when absent, identical when present.

3. **`--fresh` spawn-new-not-kill** — initial attempt (0a67437) killed the existing oracle window to force respawn. Bug: if that was the last window in a tmux session, the session died with it, taking unrelated panes in the session down too. Observed live: `maw wake pg-writer --fresh` killed `03-payment-gateway:pg-writer-oracle` which was the last window → session vanished → user's running claude on `pg-tester-oracle` also died. Fix (f5199db): auto-synthesise `--newWt = "fresh"` when `--fresh` without `--task`, let existing worktree-numbering produce unique names (wt-1-fresh, wt-2-fresh, ...), use `${oracle}-${wtName}` for window names under --fresh so no collision. Never touch existing windows.

4. **claude 2.x version-string detection** — `maw hey <oracle>` checks `pane_current_command` matches `/claude|codex|node/i` to confirm an active agent. Claude 2.x sets its process title to the version string ("2.1.114") via OSC-2 or similar; that fools the regex. Observed live: `maw hey pg-writer "..."` reported "no active Claude session (running: 2.1.114)" with claude clearly running. Fix: expand regex in 8 call sites to also match `^\d+\.\d+\.\d+$` (semver pattern). Also added pane_title fallback in the primary user-facing path (comm.ts:271) as belt-and-suspenders.

5. **Auto-symlink `.agent` + `.claude` into new worktrees** — `git worktree add` only checks out tracked files. Soul-Brews-Studio pattern has `.agent/` + `.claude/` as gitignored (agent scaffolds + Oracle preamble + MCP settings). Fresh worktrees had neither: agents spawned in them couldn't find SKILL.md or workflow references, SessionStart hook didn't fire, Oracle preamble never loaded. Observed live: bot-writer W2 in `bank-bot.wt-3-fresh` reported "ไฟล์ไม่มีอยู่ในโปรเจกต์นี้ครับ" when asked to read its W2 spec. Fix (c55a32a): new `linkAgentScaffoldsInto(mainPath, wtPath)` helper, called after `git worktree add`. Idempotent, absolute-path symlinks, silent skip if source missing or target present.

## Meta-pattern (why this bundle exists)

**Every single bug was discovered by live use, not test suite.** The 24 unit tests across 3 files passed 100% at every commit (before + after each fix). The bugs lived in:

- **Shell quoting edge cases** (`} -p '...'`) — tests used mocked command strings, not real shell eval.
- **Environment presence** (direnv missing) — tests assumed a dev-machine environment.
- **tmux session side-effects** (kill-last-window-kills-session) — tests don't spin up real tmux.
- **Claude process-title behaviour** (version string leak) — tests mock the pane-command query.
- **Filesystem ignore rules interacting with git worktree** (`.agent/` gitignored) — tests use bare temp dirs.

The pattern: **maw's surface is thin wrappers over tmux + shell + git. Unit tests verify the wrappers; real bugs live in the cracks between systems.** The only reliable test is invoking the real command in the real environment and watching what happens. Retrospective on this bundle: the dev-feedback loop that caught each bug was `maw wake` → observe pane → debug → fix → retry. 3-5 min per cycle.

Recommendation for next hardening round: consider adding a lightweight **live smoke script** that runs `maw wake --fresh <dummy-task>` → checks pane has claude process → sends a benign `maw hey` → checks reply arrives → `maw sleep` + cleanup. Runs in ~30 seconds against real tmux + real claude. Would have caught 4 of 6 bugs pre-merge.

## What the branch still needs before it ships

- Not yet merged back to `main` — sitting on feature branch.
- Not yet pushed to origin — all 6 commits are local-only (user's explicit choice: "ยังไม่ต้อง pr").
- When pushing: regular PR review against `main`. No destructive history changes needed.

Tags: brew-ops, repo:maw-js, memory, fleet, wake, hardening-bundle, live-use-discovery, pattern, 2026-04-19

---
*Added via Oracle Learn*
