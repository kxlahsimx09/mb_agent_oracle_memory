---
title: resolution — payout bson camelCase drift closed as obsolete premise (DRIFT-8)
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - payout
  - data-model
  - resolution
source: models/payout.go:99-101 + models/deposit.go:118-120 + models/wallets.go (any CreatedAt) + CLAUDE.md (no bson-convention claim) @ a4d806f
supersedes:
  - 2026-04-15_drift-payout-bson-camelcase
related:
  - 2026-04-15_drift-payout-bson-camelcase
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# Resolution — DRIFT-8 payout bson camelCase (obsolete premise)

## Drift class (original)

`models/payout.go:89-91` uses `bson:"createdAt"` / `bson:"updatedAt"` (camelCase) — the drift claimed this was an outlier among models that otherwise use snake_case, and cited a prior production bug (`scheduler/payout_expiry.go:126-132`) caused by writing a snake_case filter against the camelCase field.

## Resolution path (taken)

(C) obsolete — premise mis-stated.

## Why this resolves as (C)

Re-verification at HEAD `a4d806f` found `models/deposit.go:118-120` **also** uses `bson:"createdAt"` / `bson:"updatedAt"`. The "outlier" framing in the original drift was already false at `379e984`. There is no doc anywhere in the repo that currently asserts a cross-model bson convention — CLAUDE.md has no section on it, `docs/current-system.md` has no section on it. Therefore there is no stale doc claim for the writer to fix.

The underlying code-style inconsistency (mixed camelCase/snake_case across models) is real and is a code-cleanup candidate, but it is owned by the backend team, not the writer. The Mongo-filter gotcha — that `ts_payouts.createdAt` (and likely `ts_deposits.createdAt`) must be filtered with the camelCase bson tag — is a durable `#fact` that the drift learning captures. That fact stays valuable; only the drift framing ("this is a stale doc") is closed.

## What changed

- Doc: nothing. Row removed from `docs/current-system.md` §9 per workflow-4 Step 6.
- Code: unchanged. No backend handoff — this is a pre-existing code-style pattern, not a regression.

## How I verified

Read `models/payout.go:80-103` and `models/deposit.go:108-127`. Both use identical camelCase bson tags for `CreatedAt` / `UpdatedAt`. No CLAUDE.md or docs/current-system.md section asserts a convention that conflicts with either.

## Residual

Future agents writing MongoDB filters against `ts_payouts` or `ts_deposits` must still use camelCase bson field names. The durable fact lives in the superseded drift learning (`How to apply` section).
