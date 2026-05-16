---
title: brew-ops thread-89 resolution (CORRECTED) — 10 stale handoffs; audit 9/22 count 
tags: [handoff, inbox, drift, audit, brew-ops, vault, _universal, misfiling, campaign-108, thread-89, arra_handoff]
created: 2026-05-16
source: brew-ops thread-89 processing 2026-05-16 (corrected)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# brew-ops thread-89 resolution (CORRECTED) — 10 stale handoffs; audit 9/22 count 

brew-ops thread-89 resolution (CORRECTED) — 10 stale handoffs; audit 9/22 count was accurate; _universal/ is an active misfiling sink

Tags: #repo:arra-oracle-v3 #memory #vault #handoff #brew-ops #drift #decision #gotcha

## Supersedes
This corrects `learning_2026-05-16_brew-ops-thread-89-resolution-5-stale-handoffs-p`, which wrongly claimed the audit "over-counted by 4 phantom files." That was a SEARCH-SCOPE ERROR, not an audit error.

## The search error (gotcha)
`~/.arra-oracle-v2/ψ` is a symlink to `mb_agent_oracle_memory/ψ`. The misfiled-handoff sink `_universal/ψ/inbox/handoff/` is a SIBLING of `ψ/`, NOT under it — so it is unreachable from `~/.arra-oracle-v2/` and invisible to `find -L ~/.arra-oracle-v2/ψ ...`. The "phantom" 04-27/04-28 cohort files exist; they live in `<central-repo>/_universal/ψ/inbox/handoff/`. Lesson: any inbox/handoff audit MUST scan `_universal/ψ/inbox/handoff/` in the central repo (`mb_agent_oracle_memory`) in addition to canonical `ψ/inbox/handoff/`, because `arra_handoff` falls back to `_universal/` when project detection fails.

## Corrected reconciliation (2026-05-16)
- Total pending = canonical `ψ/inbox/handoff/` 6 + `_universal/ψ/inbox/handoff/` 16 = **22** — audit msg 254 was right.
- Stale >14d = canonical 4 + `_universal/` 6 (architect 22d, 4×04-27 cohort 19d, 1×04-30 16d) = **10**. Audit said 9 — it missed `2026-04-30_..._pg-writer-bot-writer-handoff-botconfigcontroller-line-shift.md`. Minor UNDER-count, not over-count.

## _universal/ is a systemic misfiling sink (#drift)
Commit 83960aa (2026-04-22) relocated 2 misfiled handoffs and noted a tool fix (arra-oracle-v3 fork PR #3 — make `inbox.ts` scan `_universal` + per-project dirs). Whether or not PR #3 merged, `_universal/ψ/inbox/handoff/` has since accumulated 16 files (04-27 → 05-15). `arra_handoff` still drops handoffs there on project-detection failure, and they are invisible to recipients who only sweep canonical. This is a recurring drift — every handoff filed via `arra_handoff` without a resolvable project lands in a hole. Needs a durable fix: either `arra_handoff` project-detection hardening, or `arra_inbox` + the watcher must scan `_universal/`.

## Disposition of the 10 stale handoffs
- 5 brew-ops-owned & verified-obsolete (3 brew-ops self double-wrap/legacy-name/workflow-gaps + architect ADR-8 + yellow-test) → `git mv` to `ψ/inbox/handoff/done/2026-05-16/`. All recommendations verified already-absorbed (see superseded learning for the per-file verification evidence — that part was correct).
- 5 cross-repo handoffs addressed to bot-writer/pg-writer (4×04-27 cohort + 04-30 line-shift) → relocated from `_universal/ψ/inbox/handoff/` to canonical `ψ/inbox/handoff/` so their owners' `arra_inbox` sweep can see them. brew-ops does NOT archive these as "done" (§6 ownership — they are bot-writer/pg-writer doc-maintenance tasks, several still live: #2 transactionmatcher annotation, #4 ktb-login-otp W8 revision from thread #23 Q4 human verdict, #5 line-shift). Their residual staleness is owner backlog, not brew-ops's.

---
*Added via Oracle Learn*
