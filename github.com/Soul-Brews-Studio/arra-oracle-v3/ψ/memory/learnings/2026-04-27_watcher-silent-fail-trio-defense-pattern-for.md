---
title: ## Watcher silent-fail trio — defense pattern for fire-and-forget claude wakes
tags: [watcher, silent-fail, maw, wake, tmux, git, defense-in-depth, anti-pattern]
created: 2026-04-27
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# ## Watcher silent-fail trio — defense pattern for fire-and-forget claude wakes

## Watcher silent-fail trio — defense pattern for fire-and-forget claude wakes

`maw wake "$role" --fresh` exits 0 as soon as send-keys lands in tmux. claude inside can still die silently: silent-attach to stale pane, auth 401, prompt corruption, bash template bug. Watcher's `if maw wake ...; then last_run=$now` blindly trusts the exit code → wake "succeeded" recorded while no PR landed → operator gets no signal. Pattern observed live across 3 separate root-causes 2026-04-23 → 04-27.

### The trio (all required)

**1. `--wt "$wake_ts"` — unique pane per wake** (commit `45dea0c`, PR #9)
- Without `--wt`, maw resolves the role's default pane (e.g. `bot-writer-`). When that pane has a still-alive claude session (orphaned from a prior wake or an interactive session), maw exits 0 with "session exists" — never sends the new task.
- Observed 2026-04-25..26: bot-writer's stale claude pid 30317 ran 4 days, swallowed 3 wakes silently; 0 W2/W9 PRs while watcher logged "wake succeeded" each round.
- Fix: pass `--wt "$wake_ts"` (timestamp of THIS wake) so pane name is always unique → maw cannot silent-attach because the target pane doesn't exist yet.

**2. `git pull --ff-only origin main` instead of `git fetch`** (commit `6887ab7`, PR #10)
- `git fetch origin main` only advances `origin/main` ref. Local `main` stays put. maw `git worktree add -b agents/N main` creates worktree from local `main` ref → fresh worktree at stale commit.
- Observed 2026-04-25..27: bank-bot local main stuck at `ffd626b` for 2 days while origin/main moved 6 commits; every wake's worktree was missing the commits the watcher just detected.
- Fix: `pull --ff-only origin main` (errors swallowed, same skip-this-round behavior).

**3. Post-wake PR-existence check** (commit `6887ab7`, PR #10)
- Belt-and-suspenders: arm `pending_wake_ts` after each wake success; on next poll round (after `WAKE_VERIFY_TIMEOUT`, default 60min), query `gh pr list --search "author:@me created:>=$wake_ts"`. If 0 PRs → Telegram alert via tester-telegram bot. Then clear pending state.
- Catches: auth 401, prompt corrupt, send-keys race, any other "wake exit 0 but claude died" mode.

### Anti-pattern

Don't trust maw's exit code alone. `maw wake` exits 0 in too many "looked like it worked" scenarios:
- Pane resolved (silent-attach) → exit 0
- Send-keys succeeded → exit 0
- claude `--continue` returned "No conversation found" → exit 0 (template `||` doesn't fire)
- claude started but auth failed within 1s → exit 0 (already past send-keys)

**Verification ALWAYS needs a separate signal** — PR existence, pane content scrape, or operator-side Telegram cadence check.

### How to apply

When adding new fire-and-forget chains around `maw wake`:
- Always pass `--wt "$unique_id"` (use timestamp or run-id)
- If wake creates a worktree, ensure local main is synced first (or pass origin/main explicitly)
- Schedule a verification check (PR / file / log signal) at T+60min
- On verification fail → Telegram operator with concrete pane name + log path so they can investigate without re-deriving context

---
*Added via Oracle Learn*
