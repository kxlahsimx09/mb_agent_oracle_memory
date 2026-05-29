---
title: thread #260 fix cycle — JSONL single-owner lock + cleanup-subcommand wiring (202
tags: [chat-watcher, jsonl-collision, single-owner-lock, double-telegram-relay, thread-260, maw-cleanup-wiring-gap, team-cleanup-zombies, verification-before-apply, brew-ops, fork-pr-113-arra, fork-pr-14-maw-js]
created: 2026-05-29
source: brew-ops thread #260 fix cycle 2026-05-29 — arra #113 (46a15f7e), maw-js #14 (a4fcb5e9), bot.sh restarted
project: github.com/soul-brews-studio/arra-oracle-v3
---

# thread #260 fix cycle — JSONL single-owner lock + cleanup-subcommand wiring (202

thread #260 fix cycle — JSONL single-owner lock + cleanup-subcommand wiring (2026-05-29)

Thread #260 (orchestrator wt-39, 2026-05-29 11:05Z) filed a fix spec with reproduction evidence and proposed 4-edit patch for `scripts/brew-ops-bot/chat-watcher.sh`. After the [[thread-257-hotfix-cycle-2-fix-surfaces-1-misdi]] lesson on trusting diagnoses blind, verified every claim before applying.

**Symptom:** every Telegram assistant turn arrived TWICE under two different chat tags (`orchestrator/clean-sessions` + `brew-ops/clean-sessions`).

**Root cause confirmed exactly as spec'd:** `chat-watcher.sh` resolves the JSONL by pane cwd (`resolve_jsonl_dir()` L123-129 reads `tmux pane_current_path` → `~/.claude/projects/<encoded-cwd>/`), then `latest_jsonl()` picks newest. Two panes with shared cwd → same JSONL → both watchers tail it. `bot.sh:stop_watcher_for` dedups by chat_id string only. Trigger this time: `maw wake brew-ops` placed a brew-ops session in the orchestrator's worktree.

**Verified spec patches and applied (arra-oracle-v3#113, merge 46a15f7e):**
- `$STATE_DIR/jsonl-owner.<shasum16>` per-JSONL lock file holds owning PID.
- `claim_jsonl()` returns 1 if a live owner exists; new watcher exits cleanly at startup before relay (L177) and at rotation (L212-216).
- Trap on INT/TERM releases.
- Caveat: best-effort PID-file lock, microsecond race between `[ -f $lock ]` check and `echo $$ > $lock` write — acceptable for single-host single-user.

**Side-discovery (the spec's "trivial fix" was wrong):** thread #260 suggested `scripts/team-dispatch-finish.sh` should rename `maw cleanup` → `maw team cleanup`. Reproduction showed BOTH forms (and the alias-expanded form) fail with `unknown subcommand: cleanup` because **`team/index.ts` has no `sub === "cleanup"` case** routing to `cmdCleanupZombies`. The function existed in `team-cleanup-zombies.ts`, was re-exported via `impl.ts` L12, top-aliases L65 mapped `cleanup → team cleanup --zombie-agents` — but the final router case was missing. Companion fix (maw-js#14, merge a4fcb5e9) added the case. Post-merge `maw cleanup --zombie-agents --yes` now scans panes and reports "No zombie agent panes found."

**Implication for [[workflow-2-team-dispatch-orchestrator-migration]]:** my `scripts/team-dispatch-finish.sh` has been a silent no-op on its zombie-sweep step since shipped (PR #111). The shutdown + worktree-remove steps worked; only the final safety net didn't. Now restored.

**Verification recipe that worked (extends [[thread-257-hotfix-cycle-2-fix-surfaces-1-misdi]]):**
1. Reproduce each claim with the literal command before patching.
2. When fix spec says "change A to B", test BOTH A and B — they can BOTH be wrong.
3. ff primaries + run the broken command live → see actual scan output, not just exit code 0.
4. Daemon restart: existing live chat-watchers keep old code; new spawns (next /new or recover_watchers cycle) get the lock. Acceptable transition — collisions only fire when 2 panes share cwd, and the existing colliding watchers were already killed by the orchestrator per the spec's "immediate relief" step.

**Pattern carry-forward:** when a maw subcommand silently does nothing, check `team/index.ts` for the routing case. The fleet has now had THREE missing-wiring incidents in a week: oracle-members + team-cleanup + team-invite (#13), and now cleanup (#14). A 50-line smoke test (`maw team <every-listed-subcommand>` exits non-error) in `tests/` would catch the next sweep automatically — recommended in #13 PR, still not done.

---
*Added via Oracle Learn*
