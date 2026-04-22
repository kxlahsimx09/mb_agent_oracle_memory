---
title: Claude Code desktop-app sessions: discovery surface without tmux
tags: [brew-ops, repo:maw-js, repo:cross, fleet, claude-code, discovery, pattern, jsonl, lsof, macos]
created: 2026-04-22
source: maw-js issue #709 + live verification dev01 2026-04-22
project: github.com/soul-brews-studio/maw-js
---

# Claude Code desktop-app sessions: discovery surface without tmux

# Claude Code desktop-app sessions: discovery surface without tmux

The human's primary Claude Code workflow is the **macOS app at `/Applications/Claude.app`** launched into a git worktree, NOT `claude` CLI inside tmux. `tmux capture-pane` therefore does NOT work as a "view terminal" mechanism for these sessions — there is no tmux pane.

**Why:** Claude.app spawns processes under `/Users/<user>/Library/Application Support/Claude/claude-code/<version>/claude.app/Contents/MacOS/claude`, reparented off the Claude desktop app, not off a shell. `ps` shows them but the command line contains only the claude binary path + flags — no cwd reference.

**How to apply:** Fleet-lens discovery must NOT rely on tmux. The reliable surface is:

1. `~/.claude/projects/<encoded-cwd>/<uuid>.jsonl` — every session ever opened. Path encoding is `/` → `-`. mtime on the jsonl file = last activity timestamp. First line is usually the initiating user prompt; last `type:"assistant"` entry is "currently doing what".
2. `ps -eo pid,ppid,command | grep claude` — filter rows where command starts with the Library claude path. Exclude `Helpers/disclaimer` wrappers (they always have a child claude pid; prefer the child).
3. `lsof -p <pid> | awk '$4=="cwd"'` — ~100–300ms per pid on macOS; cache 5s. This gives the real working dir = the worktree path.
4. `git worktree list --porcelain` at the main repo — map cwd → branch + worktree name.
5. Parent-pid chain walked upward — classify trigger as `maw-wake`, `tmux`, `Terminal.app`, `iTerm2`, `Dock` (Claude.app launch).

**JSONL format is append-only** with line objects like `{type, sessionId, timestamp, content, ...}`. Types observed: `queue-operation`, `user`, `assistant`, `tool-use`, `tool-result`, `pr-link`. Files routinely exceed 4MB — never `readFileSync` a transcript; stream-tail from the end.

**tmux capture-pane remains useful as a bonus** for agents spawned via `maw wake` (which DO run in tmux windows named `<role>-oracle`). A complete fleet-lens must union both surfaces, keyed on worktree path as the stable identity.

**Sensitive content:** transcripts contain whatever the human typed, including pasted credentials. The discovery endpoint must stay localhost-bound (maw :3456 already is) and must NOT be proxied through the federation HMAC `/api/peer/exec` channel in Phase 1.

**Plan tracked in:** https://github.com/Soul-Brews-Studio/maw-js/issues/709

---
*Added via Oracle Learn*
