---
title: arra_handoff `_universal/` inbox misfiling sink — root cause + fix (campaign #10
tags: [brew-ops, repo:arra-oracle-v3, memory, handoff, mcp-tools, gotcha, drift, project-detection, campaign-108]
created: 2026-05-16
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# arra_handoff `_universal/` inbox misfiling sink — root cause + fix (campaign #10

arra_handoff `_universal/` inbox misfiling sink — root cause + fix (campaign #108 / thread #114)

## Symptom
Handoffs written via `arra_handoff` when project detection failed landed in
`<vault>/_universal/ψ/inbox/handoff/` — a directory recipients and `arra_inbox`
do not sweep (they sweep canonical vault-root `ψ/inbox/handoff/`). Result: an
invisible hole. 10 handoffs (2026-05-02 … 2026-05-15) accumulated there,
including next-impl PoC session-closes and pre-Input-5 escalations. It also
caused brew-ops's own #89 first-pass miscount — a `find` under `ψ/` cannot see
the sibling `_universal/ψ/` tree.

## Root cause
`src/tools/handoff.ts` — `detectProject(ctx.repoRoot)?.toLowerCase() || '_universal'`
then `path.join(vaultRoot, project, 'ψ','inbox','handoff')`. On detection
failure `project = '_universal'`, so the handoff nested under `_universal/`
instead of the canonical inbox. `detectProject` returns null when `repoRoot`
is unset or the resolved path has no `github.com/owner/repo` (or `/Code/x/y/z`)
segment.

## Fix
`handoff.ts`: on detection failure, file to the canonical vault-root
`ψ/inbox/handoff/` (the dir recipients + `arra_inbox` actually sweep) instead
of `_universal/`. `project` is now `string | null`; the `_universal/` nesting
path is removed for handoffs. This stops NEW misfiling at the source — the
stronger of the two options in thread #114 (vs. only making readers scan
`_universal/`). `learn.ts` keeps its `_universal` fallback: a cross-cutting
learning with no project is legitimately `_universal`-scoped; a handoff is a
notification that must be found.

## Reconciliation
The 10 stranded files were `git mv`'d from `_universal/ψ/inbox/handoff/` to
canonical `ψ/inbox/handoff/` (P-001: moved, not deleted; history preserved).

Tags: #brew-ops #repo:arra-oracle-v3 #memory #handoff #mcp-tools #gotcha #drift #campaign-108

---
*Added via Oracle Learn*
