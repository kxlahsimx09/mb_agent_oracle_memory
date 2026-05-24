---
title: loop-closure Stop-hook policy must be installed on both runtimes (claude + codex)
tags: [arra-oracle-v3, inbox-loop-closure, stop-hook, codex, claude, engine-parity]
created: 2026-05-24
source: brew-ops implementation bundle 2026-05-24 (PR #92)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# loop-closure Stop-hook policy must be installed on both runtimes (claude + codex)

loop-closure Stop-hook policy must be installed on both runtimes (claude + codex).

Observed pre-fix shape:
- hook policy existed, but installer only deployed into ~/.claude/hooks + ~/.claude/settings.json
- codex sessions could run without identical harness-level §11d/§11l gate

Fix in PR #92 (commit 6bba3dd):
- installer refactored to register_stop_hook(runtime, hooks_dir, settings_json)
- deploy/register for both runtimes:
  - claude: ~/.claude/hooks + ~/.claude/settings.json
  - codex: ~/.codex/hooks + ~/.codex/hooks.json
- keep idempotent registration and per-runtime backups
- hook wording generalized to Agent CLI; policy logic unchanged (self-gated by inbox-watcher session ownership)

Validation:
- bash -n scripts/inbox-loop-closure-hook.sh
- bash -n scripts/install-inbox-loop-closure-hook.sh

Reviewer intent: installer parity only; no business-logic redesign.

---
*Added via Oracle Learn*
