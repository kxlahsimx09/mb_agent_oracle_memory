---
title: Decision (2026-04-16, GMT+7) — Activated `bot-writer-oracle` as the second activ
tags: [technical-writer, repo:cross, repo:bank-bot, repo:mobiz-payment-gateway, current, decision, bot-writer, fleet, skill-layout, handoff]
created: 2026-04-16
source: Conversation with Mobiz, 2026-04-16 GMT+7, brew-ops-oracle session. User requested expansion of technical_writer coverage to bank-bot.
project: github.com/kokarat/bank-bot
---

# Decision (2026-04-16, GMT+7) — Activated `bot-writer-oracle` as the second activ

Decision (2026-04-16, GMT+7) — Activated `bot-writer-oracle` as the second active instance of `technical_writer` in the Soul-Brews fleet. Now N-instance writer (not two-instance).

## Shape of the change

### New instance
- **Role**: `technical_writer` (same role as `pg-writer-oracle`)
- **tmux window**: `bot-writer-oracle`
- **Repo**: `kokarat/bank-bot` (Node.js + Playwright, 10 KLOC, SCB+KTB live, KBANK+BBL planned)
- **Tag prefix**: `#repo:bank-bot` + `#current`
- **Fleet file**: `bank-bot/.agent/fleet/20-bank-bot.json` + synced copy in `~/.config/maw/fleet/` (maw runtime reads the latter — lesson from 2026-04-16 fleet drift)
- **SKILL.md**: copied verbatim from pg-writer's SKILL; drift between copies will be a `#drift #cross` learning going forward
- **References**:
  - `workflow-1-baseline-current.md` — Node.js flavor (bot-specific stack inputs + template; shape matches mobiz's W1 but content differs — entrypoint is `app.js` not `main.go`; per-bank adapters in `banks/<bank>/` replace controllers; IMAP+SSE+Playwright replace HTTP routing)
  - `workflow-2-track-commit.md` — bank-bot territory map; thresholds scaled down (5 files / 300 LOC instead of 10 files / 500 LOC); session-level retro rule imported from tester's W2
  - `workflow-4-reconcile-drift.md` — copied verbatim (stack-agnostic process)
  - workflow-3 (target-system) — not included now; will activate when `bank-bot-next` target repo exists
- **Safety reinforcement**: bot-specific rule added — selectors/credentials/OTP/anti-detection/session-reuse changes require code_reviewer sign-off (same weight as financial code on mobiz side)

### Changes to mobiz charter (`kokarat/mobiz-payment-gateway/.agent/AGENTS.md`)
- §5 "Deployed in sibling repos" block replaced the target-only mention; now lists `bank-bot` current + target as separate entries
- §5a rewritten from "Two-instance pattern" to "Multi-instance pattern" with 4-row table (pg-writer active, bot-writer active, two target instances planned). Added coordination rules about cross-repo fact tagging (`#repo:cross`) and SKILL.md mirror drift.
- §7a repo-scope tag enumeration extended to include `#repo:bank-bot` + `#repo:bank-bot-next` (future)

### Bank-bot's own charter (`kokarat/bank-bot/.agent/AGENTS.md`)
- Created fresh, structured parallel to mobiz's AGENTS.md so agents can read either charter and recognize the same sections
- Acknowledges that the repo-local `ψ/` directory is NOT the canonical vault (legacy content from a prior setup; user confirmed not theirs). Canonical vault is `~/.arra-oracle-v2/ψ/memory/`.
- §5 lists only `bot-writer-oracle` active today; `bot-tester-oracle` flagged as potential future addition; `bot-next-writer-oracle` as eventual target-repo sibling.
- §9 safety includes bot-specific clauses (selectors/credentials/OTP/anti-detection immutable without review; never disable retry/backoff to speed up tests — banks notice)

## Why the multi-instance pattern won over "one writer covering two repos"
- Baseline time budget of W1 (`~90 min` for Go backend) — adding bank-bot would push past 150 min, breaking the workflow's own time discipline.
- `docs/current-system.md` would mix Go and Node.js — analogous to §3 rule "Current and Target, never mixed" applied to stacks.
- `.baseline` file lives per-repo; two repos → two anchors → can't be one instance's state.
- Commits can't span two GitHub repos. Separate branches, separate PRs.
- The §5a two-instance-pattern already predicted this shape — extending 2→N is a natural generalization, not a new idea.

## Open questions the user flagged for the future
- **bank-bot target repo (`bank-bot-next`)** — when it exists, bot-next-writer-oracle spawns; workflow-3 becomes applicable for bot-writer too.
- **bot-tester-oracle** — not yet; bank-bot testing story is currently covered by tests/*.test.js which aren't wired to the tester discipline yet.
- **.agent/ extraction** — user plans to move .agent/ content to its own dedicated repo + symlink into each project. Today's fleet-sync-via-cp workaround becomes obsolete once symlinks are in place.

## Files created / modified

Created in `bank-bot/.agent/`:
- AGENTS.md (full charter, parallel to mobiz)
- fleet/20-bank-bot.json
- skills/technical-writer/SKILL.md (verbatim copy)
- skills/technical-writer/references/workflow-1-baseline-current.md (Node.js flavor)
- skills/technical-writer/references/workflow-2-track-commit.md (bank-bot territory)
- skills/technical-writer/references/workflow-4-reconcile-drift.md (verbatim copy)

Synced:
- ~/.config/maw/fleet/20-bank-bot.json (runtime copy; maw discovers via this path, not the repo one)

Modified in `mobiz-payment-gateway/.agent/`:
- AGENTS.md §5 "Deployed in sibling repos" block, §5a multi-instance table, §7a repo-scope enumeration

## Tags
- technical-writer + repo:cross + current (3-layer; writes spans both repos)
- decision + handoff + bot-writer + bank-bot + fleet + skill-layout

## Lesson carried into this setup from prior session work
- Charter vault path note (added to both AGENTS.md copies): `~/.arra-oracle-v2/ψ/memory/` is the only indexed path. Writing to repo-local `ψ/` = invisible to search. This was the #1 trap from earlier today; preempted on both writer instances.
- Fleet sync trap (`.agent/fleet/` ↔ `~/.config/maw/fleet/`): handled by `cp` at setup time; will be replaced by symlink when .agent/ extraction lands.

---
*Added via Oracle Learn*
