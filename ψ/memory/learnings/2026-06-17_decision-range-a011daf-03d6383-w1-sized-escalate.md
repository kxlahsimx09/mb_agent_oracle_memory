---
title: decision — W2 range a011daf..03d6383 is W1-sized; baseline held, W1 re-baseline escalated
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - decision
  - drift
created: 2026-06-17
source: git log a011daf..03d6383 + docs/current-system.md §9/§11 @ 03d6383
related:
  - 2026-06-01_drift-16-finance-api-deferred-to-w1
  - 2026-06-17_drift-17-terms-conditions-new-feature
  - 2026-06-17_drift-18-bank-fee-ledger-wallet
  - 2026-06-17_drift-19-slip-fraud-late-autoconfirm
  - 2026-06-17_drift-20-settlement-window-list-export-bounding
project: github.com/kokarat/mobiz-payment-gateway
---

# Decision — the 2026-06-17 W2 range is W1-sized; defer all, hold baseline, escalate to W1

The 2026-06-17 daily W2 pass covered the new delta `ae09c34..03d6383` (16 production commits, 2026-06-09…06-15; cumulative since held baseline = `a011daf..03d6383`). Per the W2 workflow's own escalation rule (">50% of in-territory files over fast-fix threshold" + "a new top-level feature area → run Workflow 1"), the correct outcome is **escalate to W1**, not fast-fix. The pass recorded everything as deferred drift, held the baseline hash at `a011daf`, bumped `last-verified-at` to 2026-06-17, and opened a W2 PR carrying the §9/§11 doc updates.

Full classification of `ae09c34..03d6383`:
- **OUT of territory (devops):** `54a64c7` #524 (k8s AWS-key rotation).
- **INTERNAL-PERF-ONLY (no doc change):** `afc3097` #525 (dashboard covering indexes + drop dead $or), `2988b73` #523 (two indexes). Index-only portions of #526/#527/#536 also neutral.
- **NEW top-level feature → W1:** `ba8d63a` #514 Terms & Conditions (DRIFT-17).
- **NEW behavior, in-territory, deferred (folded into W1 backlog):** `03d6383` #538 bank-fee ledger wallet (DRIFT-18, financial); `8f29c29` #528 + `b88eccb` #529 + `e1964b8` #530 slip-fraud + late auto-confirm (DRIFT-19, fraud/financial); `52c8b75` #535 settlement window + `5cf693d` #534 list-count cap + `82734df` #536 CSV export cap + `c7e616f` #527 masked-account search (DRIFT-20); `c98e174` #526 + `32224a9` #537 telegram-report fixes (DRIFT-10 update); `7bfad9b` #521 + `d921419` #522 Thunder client-upload defer (DRIFT-15 update).

This is the SECOND new top-level feature (T&C) on top of the still-outstanding Finance deferral (DRIFT-16, since 2026-05-28). **A Workflow 1 re-baseline is now the clearly-owed action** and should not be deferred again — the deferral now spans two feature areas plus financial/fraud-sensitive wallet & matcher behavior. Next W2 pass: if no W1 has run, keep holding `a011daf` and keep recording new deltas as drift; flag the W1 debt in the retro.

No cross-repo signal except the matcher↔bank-bot flow-doc citation handled separately (see `2026-06-17_cross-repo-sync-matcher-late-autoconfirm-bankbot-deposit-flow`).
