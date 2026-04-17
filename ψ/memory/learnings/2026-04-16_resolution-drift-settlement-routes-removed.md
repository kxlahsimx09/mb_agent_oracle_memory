---
title: resolution — settlement UPDATE/DELETE/CANCEL drift closed (DRIFT-7)
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - settlement
  - resolution
source: CLAUDE.md:634-658 + routes/settlement.go:11-34 @ a4d806f
supersedes:
  - 2026-04-15_drift-settlement-routes-removed
related:
  - 2026-04-15_drift-settlement-routes-removed
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# Resolution — DRIFT-7 settlement UPDATE/DELETE/CANCEL removed

## Drift class (original)

CLAUDE.md §"Settlement Management" listed `PUT /:id` (update), `PUT /:id/status`, `PUT /:id/cancel`, and `DELETE /:id` — none of which exist in `routes/settlement.go` at HEAD. The route file has only approve and reject as state-changing verbs.

## Resolution path (taken)

(A) fix-doc.

## What changed

- Doc: CLAUDE.md §"Settlement Management" — removed the four stale bullets (`PUT /:id`, `PUT /:id/status`, `PUT /:id/cancel`, `DELETE /:id`); added `PUT /:id/reject`; prepended a note that no admin UPDATE/DELETE/CANCEL exists, with citations to the two comment lines in `routes/settlement.go` that explain the removals ("if data is wrong, reject and create new one" and "settlements must be kept for audit log").
- Doc: §"Settlement Workflow" — removed the "Partner/Client cancels" step (which cited the removed `/cancel` route).
- Doc: SSE Events line — changed from "create, update, approve, cancel" to "create, approve, reject".
- Code: unchanged.

## How I verified

Read `routes/settlement.go` full file (34 lines). Re-read CLAUDE.md §"Settlement Management" post-edit. The SSE-event list was changed based on the code path only — I did not inspect every SettlementController publish call, so the new list is a claim, not a full verification. Next Workflow 2 pass on settlement code should cross-check.

## Residual

SSE-event claim is unverified in detail (see above). Safe default: the `settlements` channel publishes on whatever controller actions now exist (create, approve, reject).
