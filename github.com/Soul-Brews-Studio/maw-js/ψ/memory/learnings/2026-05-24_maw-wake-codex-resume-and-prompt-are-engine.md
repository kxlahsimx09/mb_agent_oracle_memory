---
title: maw wake codex path is not claude-compatible — resume/prompt must be engine-specific
tags: [maw-js, repo:maw-js, fleet, wake, codex, engine-parity, directed-inbox, bugfix, resume, prompt]
created: 2026-05-24
source: brew-ops implementation bundle 2026-05-24 (PR #9)
project: github.com/soul-brews-studio/maw-js
---

# maw wake codex path is not claude-compatible — resume/prompt must be engine-specific

maw wake codex path is not claude-compatible — resume/prompt must be engine-specific.

#repo:maw-js #fleet #wake #codex #engine-parity #gotcha

**Observed shape (pre-fix):** fleet role could pin `engine=codex`, but `buildCommand()` still reused Claude assumptions in key places:

1. **Resume wiring used `--resume` flag form**, which is valid for `claude` but invalid for top-level `codex`.
2. **Prompt injection always used `-p '<text>'`**, where `-p` means *profile* for Codex CLI, not prompt text.
3. **No built-in codex fallback command** when fleet pinned `engine=codex` but local `commands.codex` config was absent.
4. **Claude-only continuable-session probe** (`~/.claude/projects/...`) could incorrectly mark codex runs as `fresh` even though codex resume semantics are different.

This produced a high-risk failure mode for directed-inbox campaigns: watcher had a valid campaign/session mapping, but codex wake command composition could misroute resume or drop intent, breaking parity with claude campaign continuity.

**Fix applied (PR #9, commit 184d0590):**

- `src/config/command.ts`
  - Add codex fallback (`engine=codex` + missing `commands.codex` ⇒ command defaults to `codex`).
  - Make resume engine-aware:
    - `claude` keeps `--resume "<id>"`
    - `codex` rewrites to `codex resume "<id>" ...`
  - Make prompt injection engine-aware:
    - `claude` keeps `-p '<prompt>'`
    - `codex` uses positional prompt `'<prompt>'`
  - Skip claude-only `hasContinuableSession()` probe when engine is codex.
- `test/build-command-contract.test.ts`
  - Add regression tests for codex fallback command, codex resume form, and codex positional prompt.

**Validation run (green):**

- `bun test test/build-command-contract.test.ts`
- `bun test test/build-command-cwd.test.ts test/build-command-permission-mode.test.ts test/build-command-channel-env.test.ts`

**Reviewer intent:** this patch is not a style cleanup; it closes a protocol correctness gap where codex sessions were launched with claude-shaped flags. The goal is campaign-stable wake/resume behavior under mixed `claude|codex` fleet engines.

---
*Added via Oracle Learn*
