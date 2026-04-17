---
title: Workflow 4 scaffold (2026-04-16, GMT+7) — Wrote initial `workflow-4-reconcile-dr
tags: [technical-writer, repo:mobiz-payment-gateway, current, decision, workflow, drift, reconciliation, handoff]
created: 2026-04-16
source: Conversation with Mobiz, 2026-04-16 GMT+7, brew-ops-oracle session. User requested an initial workflow-4 draft to read and iterate on.
project: github.com/kokarat/mobiz-payment-gateway
---

# Workflow 4 scaffold (2026-04-16, GMT+7) — Wrote initial `workflow-4-reconcile-dr

Workflow 4 scaffold (2026-04-16, GMT+7) — Wrote initial `workflow-4-reconcile-drift.md` for `technical_writer`. Pending live-run validation by `pg-writer-oracle`; agent will likely refine on first use.

## Design summary
Workflow 4 is the drift-queue cleanup pass. It does not discover drift (that happens in workflows 1/2); it processes the `#drift` learnings already in the vault and produces exactly one of three outcomes per item:

- **(A) Fix doc** (doc stale, code right) — rewrite doc + `// verified:` cite + `#resolution` learning + `arra_supersede(oldDriftId, newResolutionId)`.
- **(B) Fix code — escalate** (doc encodes invariant, code violates) — **no doc edit**; open GitHub issue, file `#regression-candidate` learning (related to drift, NOT superseding — drift stays open until code fix lands), `arra_handoff` to backend team.
- **(C) Obsolete/duplicate** — resolution learning with reason; supersede.

## Key disciplines the workflow enforces
1. Never calls `arra_supersede` on a (B). The drift stays open as a live queue marker until code is fixed.
2. One resolution learning per drift. Batching violates the `supersedes:` pointer.
3. `#resolution` ≠ `#drift`. Resolution learnings carry the former, not the latter — prevents the queue from growing on each close.
4. Drift > 6 months without `related:` trace → "archaeological"; park, don't resolve blind.
5. §9 "Known drift" table in `docs/current-system.md` is the public-facing state and must stay in sync.
6. `docs/.baseline` is NOT bumped — reconciliation is not re-verification; that's workflow 1.

## House-style choices
- H1 `# Workflow N — <Title>`; one-sentence reference quote below.
- Sections: When to run · When NOT to run · Preconditions · Inputs · Outputs (with a three-row outcome table — this is the shape unique to workflow 4) · Steps (with time estimates) · Templates · DoD · Pitfalls · Escalation · Change log.
- Explicit "this workflow is complete only when" checklist in DoD.
- Pitfalls section carries a 7-item list focused on the triage error modes that plausibly cost the most (calling B an A; silent doc rewrites; mass-closing; forgetting §9 sync).

## Deliberate omissions
- No `docs/drift-queue.md` owned doc. The queue lives in Oracle vault as `#drift` learnings; a materialized doc would drift from the vault itself (irony noted). `docs/current-system.md` §9 is the only doc-side mirror.
- No auto-run. The workflow requires human intent ("reconcile drift" / queue depth ≥ 5) — premature auto-close of drift is the #1 way to silently erase real regressions.

## Why this was interesting enough to log
Workflow 4 is the first workflow where the primary output is **metadata-only** (resolution learnings + supersede calls) with doc edits as secondary. It forces the writer discipline that "closing a drift" is not the same as "fixing a doc" — and that (B) cases must NOT close the drift, which is counterintuitive. Logging so the pattern survives the writer's first real-world run.

## Tags
- technical-writer + repo:mobiz-payment-gateway + current (3-layer)
- workflow + drift + reconciliation (feature)
- decision + handoff (special — this is the authoritative first draft awaiting live refinement)

---
*Added via Oracle Learn*
