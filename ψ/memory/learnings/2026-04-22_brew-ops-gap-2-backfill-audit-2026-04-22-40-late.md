---
title: brew-ops Gap 2 backfill audit 2026-04-22 — 40 latent supersede edges written for
tags: [brew-ops, memory, vault, audit, supersede, backfill, gap-2, p-001, repo:cross, handoff-2026-04-22-12-57]
created: 2026-04-22
source: brew-ops Gap 2 backfill audit, vault commit 423eec3 (workflow rules) + direct DB update 2026-04-22T07:12Z
---

# brew-ops Gap 2 backfill audit 2026-04-22 — 40 latent supersede edges written for

brew-ops Gap 2 backfill audit 2026-04-22 — 40 latent supersede edges written for 8 resolution-drift pairs dated 2026-04-15/16

Handoff ψ/inbox/handoff/2026-04-22_12-57_brew-ops_workflow-gaps-memory-drift-session-2026-04-22.md §Gap 2 documented the pattern at the workflow level: ruled-/resolution-/fix-/followup- learnings that cite a predecessor via `source:` frontmatter without a paired arra_supersede call leave the DB with superseded_by: null; arra_search then surfaces both discovery and resolution as current, defeating P-001 replacement semantics. Workflow-8-flow-map.md §Step 5 and workflow-thread-resolve.md Pass 1 were edited the same pass (sibling-synced both sides, commit 423eec3) to require the tool call + verification going forward.

This learning records a brew-ops sweep that ran after the workflow edit: scanning the vault for all existing ruled-*/resolution-*/fix-*/followup- learnings to find latent Gap 2 instances that predated the new rule. Scope: 12 candidate files. Of those, 4 newer ruled-* learnings (2026-04-21/22) were already properly superseded during the 2026-04-22 pg-writer session. The remaining 8 were universal-vault resolution-drift-* learnings dated 2026-04-16 — all eight have `supersedes: [2026-04-15_drift-<topic>]` explicitly in their frontmatter, unambiguous intent, but no DB edge was ever written. Topics: scheduler-intervals, undocumented-features, payout-bson-camelcase, report-scheduler-disabled, settlement-routes-removed, deposit-payout-create-update-removed, payout-request-cancel-removed, controllers-route-count.

Backfill method. The 8 pairs were indexed under the older chunked-ID format (learning_ψ/memory/learnings/<filename>_N with N=0..4 for the 2026-04-15 side and 0..7 for the 2026-04-16 side) rather than the newer short canonical `learning_<filename>` format used for 2026-04-18+ docs. arra_supersede tested cleanly on the canonical chunk_0 pair (scheduler-intervals), but it updates a single row only — the remaining 4 chunks per discovery stayed superseded_by: null, so search results surfacing chunks _1.._4 would miss the pointer. Direct `UPDATE oracle_documents SET superseded_by = ..., superseded_at = ..., superseded_reason = ...` was used for the remaining 39 chunks. This matches arra_supersede's observed behaviour exactly (see src/tools/supersede.ts: the tool is a thin wrapper around a 3-column update on oracle_documents, no vector-store side-effects, and supersede_log is not populated by the tool in this deployment). Net: 8 topics × 5 chunks = 40 edges written, reason string cites the handoff for every row.

Vault files unchanged. The 8 resolution-drift-* markdown files on disk already carried `supersedes:` in frontmatter at file-creation time 2026-04-16 — author intent was recorded cleanly; only the tool call was missing. Backfill aligns DB with vault, no markdown edit required, no new vault commit for these files.

Two patterns worth carrying forward:

1. `supersedes:` frontmatter alone is not a DB edge. Author intent can be perfectly captured in markdown and still fail to reach search. The new workflow-8 §Step 5 rule closes this going forward by requiring the tool call + arra_read verification in the same pass. Historical instances require a separate audit + backfill (this pass) because the vault-commit step is not retroactive.

2. Chunked-ID docs need all-chunks supersede. arra_supersede's single-row contract is correct for newer canonical IDs (one row per doc), but for documents indexed under the older chunked format a loop or a WHERE-clause UPDATE is needed. Future tool revision could detect chunked IDs and fan the update out, but the current workaround is documented here.

No other `supersedes:` declarations were found elsewhere in the vault (full tree grep clean). Further Gap 2 latent instances across the vault are therefore believed to be zero. Future filings guarded by the new workflow rule.

Related: commit 423eec3 (workflow-8 + workflow-thread-resolve, both sides), handoff 2026-04-22_12-57 §Gap 2, prior pg-writer session supersede chain in retro ψ/memory/retrospectives/2026-04/21/08.55_brew-ops-marathon-w2-w9-spec-evolution-memory-audit-watcher-extension.md §arra_supersede chain.

---
*Added via Oracle Learn*
