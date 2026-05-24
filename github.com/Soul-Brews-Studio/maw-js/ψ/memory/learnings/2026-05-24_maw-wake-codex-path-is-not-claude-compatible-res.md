---
title: maw wake codex path is not claude-compatible — resume/prompt must be engine-spec
tags: [maw-js, wake, codex, resume, prompt, engine-parity]
created: 2026-05-24
source: brew-ops implementation bundle 2026-05-24 (PR #9)
project: github.com/soul-brews-studio/maw-js
---

# maw wake codex path is not claude-compatible — resume/prompt must be engine-spec

maw wake codex path is not claude-compatible — resume/prompt must be engine-specific.

Observed pre-fix shape:
1) resume used claude-style --resume flag against codex
2) prompt used -p (codex interprets as profile)
3) no built-in codex fallback when commands.codex missing
4) claude-only continuable-session probe affected codex flow

Fix in PR #9 (commit 184d0590):
- codex fallback command defaults to "codex" when engine pin exists but commands.codex absent
- resume routing becomes engine-aware: claude keeps --resume, codex uses "codex resume <session-id>"
- prompt routing becomes engine-aware: claude uses -p, codex uses positional prompt
- skip claude-only continuable-session probe for codex engine
- add regression tests in test/build-command-contract.test.ts

Validation:
- bun test test/build-command-contract.test.ts
- bun test test/build-command-cwd.test.ts test/build-command-permission-mode.test.ts test/build-command-channel-env.test.ts

Reviewer intent: this is a protocol-correctness fix, not style cleanup; codex campaign wake/resume must be continuity-safe like claude.

---
*Added via Oracle Learn*
