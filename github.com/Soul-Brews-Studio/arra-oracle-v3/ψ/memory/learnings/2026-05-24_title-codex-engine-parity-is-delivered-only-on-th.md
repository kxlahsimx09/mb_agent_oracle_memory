---
title: title: codex engine-parity is delivered only on the human-driven Telegram path, 
tags: [drift, codex, engine-parity, loop-closure, stop-hook, directed-inbox, inbox-watcher, wake, brew-ops, repo:cross, fleet, gotcha, decision]
created: 2026-05-24
source: brew-ops review of PRs maw-js#9 + arra-oracle-v3#92 + mb_agent_oracle_memory#7 (2026-05-24)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# title: codex engine-parity is delivered only on the human-driven Telegram path, 

title: codex engine-parity is delivered only on the human-driven Telegram path, NOT the autonomous directed-inbox path (loop-closure "both runtimes" claim is overstated)

#drift #repo:cross #fleet #brew-ops #codex #engine-parity #loop-closure #gotcha

**Context.** The 2026-05-24 codex-parity bundle is three coordinated PRs: maw-js #9 (engine-aware `buildCommand`), arra-oracle-v3 #92 (bot codex support + Stop-hook install on both runtimes + unify bootstrap), mb_agent_oracle_memory #7 (engine-aware charter docs). Reviewed end-to-end on 2026-05-24.

**The drift (P-004 — code is truth, the claims overstate it).** PR #92's learning (`…_loop-closure-stop-hook-policy-must-be-installed-on.md` / `…_-for-both.md`) says §11d/§11l loop-closure is now "enforced symmetric" / "Codex now gets equivalent Stop-hook registration". The code does not actually enforce it for codex:

1. **The Stop hook is built on Claude Code's hook contract.** `scripts/inbox-loop-closure-hook.sh` reads its identity from a JSON stdin payload: `sid=$(... | jq -r '.session_id')` (lines ~45-46), then reverse-looks-up that sid in the inbox-watcher state files. The installer writes a Claude-shaped `.hooks.Stop[].hooks[].command` object into `~/.codex/hooks.json`. Codex configures via `~/.codex/config.toml` (different schema) — that file is most likely never read. Even if codex ran the script, the stdin payload is not `{session_id:...}`, so `sid` is empty → self-gating "no watcher record → no-op" → the hook **fail-opens on every codex session**. The install reports success and creates the file, but the gate does not engage.

2. **`scripts/inbox-watcher.sh` has ZERO codex awareness** (0 matches for `codex`/`session_meta`/`rollout` on both base `feat/all-prs-rebased` and PR #92 head). PR #92 only prepends the bootstrap block to the watcher's prompt. So for a codex oracle: T1 delivery verify greps `~/.claude/projects` for `inbox: <fname>` (codex writes `~/.codex/sessions/rollout-*.jsonl`) → false `failed_no_prompt`; session-id capture reads the claude UUID from the JSONL filename (codex sid lives in `session_meta.payload`) → never captured → no `--resume` → `--fresh` every follow-up → session sprawl; and the Stop hook's self-gating needs a `session_id=<sid>` the watcher never wrote.

3. **maw-js #9's codex `--resume` support has no producer.** `buildCommand` can now emit `codex resume "<id>"`, but nothing in the autonomous path captures a codex sid to feed it. The two PRs do not meet in the middle for codex. (Also: the combined `--resume` + `--task` path — the real directed-inbox follow-up shape — is untested, and whether `codex resume <id> '<prompt>'` auto-submits the positional prompt is unverified.)

**Net.** Codex parity is real for the **human-driven Telegram bot** flow (PR #92 made `bot.sh` + `codex-watcher.sh` + `/history` `/ctx` `/quota` fully codex-aware). It is **not** delivered for the **autonomous agent-to-agent directed-inbox + loop-closure** flow. Note the docs are honest where the learning is not: AGENTS.md §11l follow-up and brew-ops SKILL both say "codex parity is tracked separately / current implementation: Claude Code hook" — so the doc and the PR #92 learning disagree.

**Secondary hygiene drift — committed learnings ≠ indexed learnings.** For each of the three 2026-05-24 facts there are TWO files with different slugs. The Oracle-indexed set (`…codex-path-is-not-claude-compatible-res`, `…installed-on`, `…protocol-separately`) is **untracked** in `mb_agent_oracle_memory` (won't survive clone / git soul-sync). The set committed by PR #7 (`…resume-and-prompt-are-engine`, `…installed-for-both`, `…protocol-vs-en`) is the one NOT in the Oracle index. So `arra_search` results diverge from git — breaking the vault's "git is source of truth" invariant.

**How to apply.**
- When reviewing/merging this bundle, treat codex loop-closure as **not yet functional** — do not rely on the Stop hook gating codex sessions. The real fix is the §11l follow-up: inject the hook via `maw wake` (engine-specific plumbing), and verify codex even has a Stop/session-end hook before claiming parity. The inbox-watcher must additionally learn the codex JSONL path (`~/.codex/sessions/rollout-*.jsonl`), the `inbox: <fname>` T1 grep against it, and `session_meta.payload` sid capture.
- Reconcile the duplicate learnings: pick one slug per topic, `git add` it, `arra_supersede` the other (do not delete — P-001), re-index so committed == indexed.
- Review comments posted on all three PRs (2026-05-24) with file:line evidence.

related: [[2026-05-24_loop-closure-stop-hook-policy-must-be-installed-on]] [[2026-05-24_maw-wake-codex-path-is-not-claude-compatible-res]] [[2026-05-24_agent-charters-should-describe-protocol-separately]] [[2026-04-30_title-maw-wake-template-silent-fail-blocks-phase]]

---
*Added via Oracle Learn*
