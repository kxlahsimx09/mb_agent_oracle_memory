---
title: brew-ops thread-89 resolution — 5 stale handoffs processed, all no-action; dispa
tags: [handoff, inbox, drift, audit, brew-ops, vault, campaign-108, thread-89]
created: 2026-05-16
source: brew-ops thread-89 processing 2026-05-16
project: github.com/soul-brews-studio/arra-oracle-v3
---

# brew-ops thread-89 resolution — 5 stale handoffs processed, all no-action; dispa

brew-ops thread-89 resolution — 5 stale handoffs processed, all no-action; dispatch count was drifted (campaign #108 Step 1)

Tags: #repo:arra-oracle-v3 #memory #vault #handoff #brew-ops #drift #decision

## Context
Thread #89 (campaign #108 fan-out) dispatched a P1 to process "9 handoffs stale >14d, 22 pending total" per the 2026-05-16 workflow-5 audit reconciliation (thread #89 msg 254).

## Drift found (audit claim vs filesystem truth — P-004)
Filesystem reality on 2026-05-16: the canonical inbox `~/.arra-oracle-v2/ψ/inbox/handoff/` holds **6 files**, of which **4 are stale >14d**; plus **1 stale handoff still misfiled** in `_universal/ψ/inbox/handoff/` (the architect ADR-8 file, never relocated by commit 83960aa). Real total = **5 stale / 7 pending**, not 9 / 22.

The audit's "5 newly-stale 04-27/04-28 cohort" — `transactionmatcher`, `cross-repo-sync ktb-transfer`, `w8-revision ktb-login-otp`, `bot-writer botconfig-pullout` — **do not exist anywhere in the vault** (keyword search across all of `ψ/` returns nothing; `git ls-files` confirms never tracked). msg 254 over-counted by 4 phantom files. The orchestrator dispatched P1 on the inflated number. The severity reclassification (P0→P1) still holds: 5 stale >14d is still >3 = §10 FAIL P1.

## The 5 real stale handoffs — all NO ACTION NEEDED (recommendations already absorbed)
1. `2026-04-21_brew-ops_pre-existing-double-wrap-cleanup` — recommended arra_supersede on 11 `title: ---` double-wrap rows. Verified: 0 files with `^title: ---` remain in the central repo; all 10 surviving `2026-04-19_title-*` learnings now carry clean prose `title:` frontmatter. Corruption resolved by the stripFrontmatterWrap guard + reindex. Recommendation moot.
2. `2026-04-22_brew-ops_verify-legacy-name-format` — flagged retro `2026-04/19/06.13_w2-track-commit-dispatcher-maintenance.md` for legacy `name:`-only. Verified: that retro now has proper `title:` + `type: retrospective`. Resolved.
3. `2026-04-22_brew-ops_workflow-gaps-memory-drift` — proposed P2 (arra_supersede discipline in workflow-8/thread-resolve). Verified: workflow-thread-resolve.md carries the exact proposed "ruled-/resolution-/followup" rule; workflow-8-flow-map.md has 8 (mobiz) / 7 (bank-bot) arra_supersede mentions. P2 absorbed. P3/P4/P1 are 24-day-old proposals predating the orchestrator phase; workflow files have evolved substantially since — re-evaluating them is a fresh task, not a stale-handoff carryover.
4. `2026-04-24_architect_cross-role-drift-adr-8-ratified` (was misfiled in `_universal/`) — ADR-8 fully ratified (pass-1..4 learnings all present) + impl-architect 3-day sprint closed 2026-05-08 with 6 PoCs merged. Routing items absorbed. Its 2 dead-code drift findings preserved below for pg-writer discoverability rather than re-dispatched (22d old, self-classified low-urgency / non-production-affecting): `SelectBankForPayout` dead code + sort-metric drift (`services/bankRotation.go:61-64,240-241,276-287 @ mobiz 19e0bed`); `countTodayCompletedTransactions` dead code (`scheduler/withdrawal_dispatcher.go:444-471 @ mobiz 19e0bed`).
5. `2026-04-28_yellow-test-1777383324455` — 38-byte test artifact. Safe archive.

All 5 git mv'd to `ψ/inbox/handoff/done/2026-05-16/`. Moving #4 also resolves its `_universal/` misfiling.

## Lesson
Workflow-5 audit reconciliation counts must be verified against the filesystem before dispatch — msg 254 named 4 handoff files that never existed. A stale-handoff audit should `ls` + `git ls-files` the inbox, not carry forward names from a prior snapshot or thread text.

---
*Added via Oracle Learn*
