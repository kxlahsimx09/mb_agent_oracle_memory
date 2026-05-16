---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 89
parent_thread: 108
parent_oracle: orchestrator
subject: thread-89 done — 10 stale handoffs (audit count was right); 5 archived, 5 un-misfiled to owners
needs_response: false
priority: normal
created: 2026-05-16T11:34:00+07:00
---

# thread #89 resolved — campaign #108 Step 1, sub-thread 4 of 5

Done. Thread #89: msg 266 (initial) + msg 269 (correction). Cite: `learning_2026-05-16_brew-ops-thread-89-resolution-corrected-10-sta` (supersedes `...-5-stale-handoffs-p`).

## Note: my first-pass reconciliation had an error — now corrected

My initial reply (msg 266) wrongly claimed the audit "over-counted by 4 phantom files." It did not. That was a search-scope error: `~/.arra-oracle-v2/ψ` is a symlink, and the misfiled sink `_universal/ψ/inbox/handoff/` is a *sibling* of `ψ/`, invisible to a `find` under `ψ/`. The cohort files are real. **Audit msg 254's 9/22 was accurate** (real stale is actually 10 — it missed one).

## Corrected reconciliation

- Total pending = canonical `ψ/inbox/handoff/` 6 + `_universal/ψ/inbox/handoff/` 16 = **22** ✓
- Stale >14d = **10** (audit said 9 — under-counted by one, missed `2026-04-30_…botconfigcontroller-line-shift`). P1 severity correct.

## `_universal/` is a systemic misfiling sink — needs a tooling fix

`arra_handoff` falls back to `_universal/ψ/inbox/handoff/` when project detection fails; recipients only sweep canonical, so handoffs land in a hole. Commit 83960aa (2026-04-22) relocated 2 such files + flagged fork PR #3 to make `arra_inbox` scan `_universal/` — but **16 files have accumulated there since**. Recurring drift. Durable fix needed: `arra_handoff` project-detection hardening, or `arra_inbox` + the inbox-watcher must scan `_universal/`. Recommend a dedicated sub-thread.

## Disposition of all 10 stale handoffs

**5 brew-ops-owned, verified-obsolete → archived to `ψ/inbox/handoff/done/2026-05-16/`:**
1. `2026-04-21_double-wrap-cleanup` — 0 `title: ---` rows remain; corruption resolved by guard + reindex.
2. `2026-04-22_verify-legacy-name-format` — flagged retro now has proper `title:`/`type:`.
3. `2026-04-22_workflow-gaps` — proposed P2 supersede-discipline is live in workflow-8 + workflow-thread-resolve; P3/P4/P1 are stale pre-orchestrator proposals.
4. `2026-04-24_architect_adr-8` — ADR-8 ratified, impl-architect sprint closed 2026-05-08; absorbed (also un-misfiled from `_universal/`).
5. `2026-04-28_yellow-test-1777383324455` — test artifact.

**5 cross-repo handoffs addressed to bot-writer/pg-writer → relocated `_universal/` → canonical `ψ/inbox/handoff/`** so the owners' `arra_inbox` sweep sees them. brew-ops does NOT close these (§6 ownership — they are bot-writer/pg-writer doc work, several still live):
- `2026-04-27_…botconfig-pullout-trigger` (bot-writer, FYI, self-declared no-action)
- `2026-04-27_…transactionmatcher-transaction-date` (bot-writer, P2 — live: deposit-auto-match doc annotation)
- `2026-04-27_…cross-repo-sync-ktb-transfer` (pg-writer, verification spot-check)
- `2026-04-27_…w8-revision-ktb-login-with-otp` (bot-writer — **live**: W8 revision from thread #23 Q4 human verdict)
- `2026-04-30_…botconfigcontroller-line-shift` (bot-writer, P3 line-shift)

**Recommendation:** these 5 are now visible in canonical inbox but unwoken. If campaign #108 wants them cleared, dispatch them to bot-writer / pg-writer — their residual staleness is owner backlog, not a brew-ops item.

## Still open in for-brew-ops/

Thread #110 (P0 — LanceDB bge-m3 vector index degraded) remains unprocessed — left for a dedicated wake. Vector search confirmed FTS5-only this session. Note: `learning_2026-05-16_lancedb-bge-m3-manifest-drift-3rd-occurrence` already exists — this is the 3rd occurrence of that incident.

— brew-ops, 2026-05-16 11:34 GMT+7
