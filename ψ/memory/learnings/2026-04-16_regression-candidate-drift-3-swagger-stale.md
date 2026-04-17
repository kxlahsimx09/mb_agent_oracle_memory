---
title: regression-candidate — swagger_simple.json missing 8+ route groups at HEAD (DRIFT-3 follow-up)
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - swagger
  - regression-candidate
source: swagger_simple.json + CLAUDE.md §"API Documentation" + ls routes/*.go @ a4d806f
related:
  - 2026-04-15_drift-swagger-stale
  - https://github.com/kokarat/mobiz-payment-gateway/issues/182
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# Regression candidate — swagger stale

## What

`swagger_simple.json` at HEAD has 141 path keys. Missing entire route groups: `/api/v1/2fa/*`, `/api/v1/bank-accounts/*`, `/api/v1/direct-transfer/*`, `/api/v1/activity-log/*`, `/api/v1/callback-log/*`, `/api/v1/telegram/*`, `/api/v1/app-settings/*`, `/api/v1/otp-logs/*`. Also missing the `PUT /api/v1/payouts/:id/confirm-completed` endpoint added on 2026-04-16 (PR #172).

CLAUDE.md claims swagger covers "95+ API endpoints." Numerically that is still true (141 > 95), but completeness-of-surface is not; integrators relying on swagger will not discover the missing groups.

Partial progress since the original drift (filed at `379e984` on 2026-04-15): `/api/v1/mdr-shared/*` (4 paths) and `/api/v1/pullout-logs/*` (4 paths) **are** now in swagger. The gap above has not closed.

## Why this is (B) not (A)

`swagger_simple.json` is a generated/hand-extended artifact, not a writer-authored doc. The writer does not regenerate it — that is devops/backend territory (see deployment notes in CLAUDE.md about `swag init`). Rewriting CLAUDE.md's "95+" claim to hide the gap would be the exact "silent rewrite" anti-pattern Workflow 4 pitfalls warn against.

## Issue

Filed at `https://github.com/kokarat/mobiz-payment-gateway/issues/182` on 2026-04-16 by `pg-writer-oracle` during Workflow 4 first-live-run.

## Next step

Backend / devops regenerates or hand-extends swagger to cover the missing routes. When the gap is closed, `technical_writer` re-verifies and writes a follow-up `#resolution` that supersedes both the original drift and this regression-candidate. Until then, the original DRIFT-3 learning stays open and is kept in `docs/current-system.md` §9 with status `ESCALATED: #182`.

## Handoff

This learning is the handoff. There is no in-repo `backend_developer` or `devops_engineer` AI for the current system (per `.agent/AGENTS.md` §5). The GitHub issue is the durable pointer.
