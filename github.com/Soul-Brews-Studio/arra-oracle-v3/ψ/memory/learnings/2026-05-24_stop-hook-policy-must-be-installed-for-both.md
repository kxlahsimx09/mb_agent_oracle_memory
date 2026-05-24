---
title: loop-closure Stop-hook policy must be installed on both runtimes (claude + codex)
tags: [brew-ops, repo:arra-oracle-v3, fleet, hooks, loop-closure, codex, claude, engine-parity, inbox-protocol]
created: 2026-05-24
source: brew-ops implementation bundle 2026-05-24 (PR #92)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# loop-closure Stop-hook policy must be installed on both runtimes (claude + codex)

loop-closure Stop-hook policy must be installed on both runtimes (`claude` + `codex`) to keep §11d/§11l enforcement symmetric.

#repo:arra-oracle-v3 #fleet #hooks #loop-closure #engine-parity

**Observed shape (pre-fix):** `scripts/inbox-loop-closure-hook.sh` enforces the right policy, but installer deployment was Claude-only:

- deployed hook into `~/.claude/hooks/`
- registered Stop hook in `~/.claude/settings.json`

Codex sessions could therefore run without the same harness-level close-out gate, creating asymmetric behavior between engines for the exact same directed-inbox protocol.

**Fix applied (PR #92, commit 6bba3dd):**

- `scripts/install-inbox-loop-closure-hook.sh`
  - factor installer into reusable `register_stop_hook(runtime, hooks_dir, settings_json)`
  - deploy and register for both runtimes:
    - `claude`: `~/.claude/hooks/` + `~/.claude/settings.json`
    - `codex`: `~/.codex/hooks/` + `~/.codex/hooks.json`
  - keep idempotent duplicate detection + per-runtime backup before mutation.
- `scripts/inbox-loop-closure-hook.sh`
  - update runtime wording from Claude-specific to Agent CLI generic.
  - no policy logic change (same self-gating via inbox-watcher session ownership).

**Important boundary:** this is **installer parity**, not protocol redesign. The hook still enforces existing §11c–§11l invariants; the patch ensures both engines are under the same gate by default.

**Validation run (green):**

- `bash -n scripts/inbox-loop-closure-hook.sh`
- `bash -n scripts/install-inbox-loop-closure-hook.sh`

**Reviewer intent:** verify that this is additive/safe for running nodes:

1. deployment remains idempotent,
2. existing Claude behavior is preserved,
3. Codex now gets equivalent Stop-hook registration without changing business logic.

---
*Added via Oracle Learn*
