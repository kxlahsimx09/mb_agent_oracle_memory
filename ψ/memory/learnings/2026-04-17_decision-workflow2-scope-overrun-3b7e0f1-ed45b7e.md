---
title: Workflow-2 scope overrun 3b7e0f1..ed45b7e — escalated to Workflow 1
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - drift
  - decision
  - workflow-2
  - scope-overrun
related:
  - 2026-04-16_name-payout-auto-reconcile-three-convergent
  - 2026-04-17_pr-179-180-onhold-markfailed-double-callb
source: git log 3b7e0f128825b50098b6f47637f358faddc9b9de..ed45b7e0ba7f12c32d107c59b728ba5d0c5c457a
created: 2026-04-17
project: github.com/kokarat/mobiz-payment-gateway
---

# Workflow-2 scope overrun 3b7e0f1..ed45b7e — escalated to Workflow 1

## Observation

Workflow-2-track-commit was initiated 2026-04-17 (pg-writer) against the range
`3b7e0f1 (baseline, 2026-04-16)` → `ed45b7e (HEAD, 2026-04-17)`. Classification
step (workflow-2 §Step 3) showed 14 in-territory files touched, with one
file (`scheduler/report_scheduler.go`) exceeding the fast-fix threshold alone
(402 LOC of behaviour change in a single commit). Both conditions defined in
workflow-2 "Full-pass escalation" trigger:

1. ~10-file ceiling exceeded (14 > 10).
2. "New top-level concept / major rewrite" — report_scheduler churn is 128
   inserted / 274 deleted in PR #198 (`7880334`) plus a 117-line follow-up in
   PR #199 (`a3570a9`); this is a scheduler redesign, not a fast-fix target.

## In-territory files in range

| Directory | Files | Notable commits |
|---|---|---|
| `controllers/` | DepositController, PayoutController, PayoutRequestController, TelegramController, WithdrawalQueueController | #185, #186, #187, #190, #193, #197, #198, #199 |
| `routes/` | pullout_logs, pullout_task | #175 (fix pullout — route method mismatch) |
| `models/` | deposit, withdrawal_queue | #187 (deposit.approved_by), #193 (withdrawal_queue.batch_id) |
| `scheduler/` | report_scheduler | #198 (revamp), #199 (hourly fix) |
| `services/` | payoutReconciliation, transactionMatcher, withdrawalQueue | #188, #189, #194, #195, #196, #197, #200 |
| `db/` | indexes | #177 (7 missing indexes) |

Total: 14 in-territory files. LOC-of-behaviour estimate ≫ 500.

## Decision

Per workflow-2 §Step 3 and §"Fast-fix vs full-pass", the workflow STOPS here.
`docs/.baseline` is NOT bumped. No fast-fix updates were applied to
`docs/current-system.md` in this pass.

Action: queue Workflow 1 (full re-baseline) against HEAD `ed45b7e`. That pass
will read every touched file in its post-change form and reconcile
`docs/current-system.md` wholesale, rather than attempting 14 fast-fixes that
would individually be correct but collectively miss cross-cutting effects (the
`request_id`-in-wallet-note convention from #197 interacts with the
`batch_id`-on-source convention from #194, which interacts with the matcher
re-enable gating in #189, which interacts with the ON_HOLD callback redesign
tracked in PR #202 — none of these read cleanly in isolation).

## Collateral observations captured in this pass

- Issues **#181 (status comments contradict 1=Active)** and **#182 (swagger
  missing 8+ route groups)** filed 2026-04-16 from the Workflow-4 run are
  **still OPEN** at HEAD — no dev fix has landed. Both drift learnings
  (`2026-04-15_drift-status-convention-comments`, `2026-04-15_drift-swagger-stale`)
  remain valid references; no supersede needed.
- The MarkFailed double-callback race that put PR #179/#180 ON_HOLD is still
  present at HEAD — see sibling learning
  `2026-04-17_fact-markfailed-callback-race-still-at-head-ed45b7e`.

## Next step

Owner: `pg-writer-oracle`. Expected follow-up: a Workflow-1 session of ≥90 min
against `ed45b7e`, producing a fresh `docs/.baseline` + updated
`docs/current-system.md` §3 (API surface), §5 (schedulers — revamp report
scheduler), §6 (services — document auto-reconcile gating, batch_id flow), §9
(known drift — close or refresh each from 2026-04-15).
