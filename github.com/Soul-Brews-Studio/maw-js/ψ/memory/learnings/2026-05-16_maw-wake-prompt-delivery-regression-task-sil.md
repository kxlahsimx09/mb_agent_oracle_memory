---
title: maw wake prompt-delivery regression — `--task` silently dropped (#gotcha #drift)
tags: []
created: 2026-05-16
source: brew-ops — 2026-05-16 wake regression investigation
project: github.com/soul-brews-studio/maw-js
---

# maw wake prompt-delivery regression — `--task` silently dropped (#gotcha #drift)

maw wake prompt-delivery regression — `--task` silently dropped (#gotcha #drift)

**Symptom:** `maw wake` creates the worktree + tmux window and launches `claude --dangerously-skip-permissions`, but the agent sits idle at an empty input box — no prompt, no JSONL. `inbox-watcher` logs `failed_no_prompt` (T1 gate). Hit the 2026-05-09 orchestrator wake and the 2026-05-16 brew-ops wake.

**Root cause:** AGENTS.md §11j Phase 2b-i fixed this exact silent-fail on 2026-04-30 (maw-js `0c9bfd66` — `buildCommand` took a `prompt` field and baked `-p` into the command). The LOC-round-4 refactor (`c6491e90`) regressed it on TWO axes:
1. `top-aliases.ts` routed CLI `--task` → `opts.task` (a worktree-name selector) instead of `opts.prompt`. Both watchers (`inbox-watcher.sh`, `w2-watcher.sh`) deliver the prompt via `--task` per the documented contract (`wake-flags.test.ts` still encodes it: "--task sets prompt and noAttach"). So `opts.prompt` stayed undefined → claude launched with no `-p`.
2. `wake-cmd.ts` appended ` -p '<prompt>'` to `buildCommand()`'s *return value*, which ends in `; <reset>` (`printf…; stty sane; clear`). The `-p` flag attached to the trailing `clear`, never `claude`.

**Why it hid:** `wake-flags.test.ts` uses its own local parser that does the right thing, so it stayed green while the production `top-aliases.ts` parser diverged. The `command-fresh-prompt.test.ts` regression test was deleted in the refactor.

**Fix (maw-js PR kxlahsimx09/maw-js#6):** `BuildCommandOpts.prompt` restored; `buildCommand` bakes `-p '<escaped>'` inside the `{ }` brace group, before the reset suffix, into both `||` branches. `wake-cmd.ts` passes `prompt` through (no manual append). `top-aliases.ts` `--task` → `opts.prompt` + noAttach. No watcher change needed — the contract is restored maw-side.

**How to apply:** When a `failed_no_prompt` recurs, check (a) does the CLI flag the watcher uses still map to `opts.prompt`, and (b) is `-p` baked INSIDE the brace group before `; <reset>` — not appended after. A refactor that "splits files" can silently drop a feature field; pair such refactors with their regression tests or they rot.

Tags: #repo:maw-js #fleet #tmux #gotcha #drift #brew-ops #decision

---
*Added via Oracle Learn*
