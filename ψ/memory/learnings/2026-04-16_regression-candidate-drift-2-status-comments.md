---
title: regression-candidate — status-convention comments in models/ contradict CLAUDE.md invariant (DRIFT-2 follow-up)
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - rbac
  - data-model
  - regression-candidate
source: models/wallets.go:18 + models/clients.go:33 + models/mdr_profile.go:24 + middlewares/apiKeyCheck.go:58 + CLAUDE.md §"Status Codes Convention" @ a4d806f
related:
  - 2026-04-15_drift-status-convention-comments
  - https://github.com/kokarat/mobiz-payment-gateway/issues/181
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# Regression candidate — status-convention comments

## What

CLAUDE.md §"Status Codes Convention" states the documented invariant: `1 = Active, 0 = Inactive, 2 = Suspended` across all entities (users, merchants, clients, partners, wallets, MDR profiles, system banks, pools, roles, resources). Runtime code honors this invariant — `middlewares/apiKeyCheck.go:58` guards `if client.Status != 1 { 401 }`, `services/bankRotation.go:66` uses the same pattern, `services/withdrawalQueue.go:70` ditto.

Three model-file struct-field comments state the opposite:

- `models/wallets.go:18` — `// 0=active, 1=inactive, 2=suspended (default: 0)`
- `models/clients.go:33` — same
- `models/mdr_profile.go:24` — `// 0=active, 1=inactive (default: 0)`

Runtime is unaffected. The risk is a contributor who trusts the struct-field comment and writes new business-logic against the wrong interpretation of `Status`.

## Why this is (B) not (A)

Doc encodes a stated invariant (CLAUDE.md's universal status convention). Code artifacts (the struct-field comments) contradict it. Per workflow-4 outcome (B) the writer does not silently "fix" the model comments — that is code work — and does not rewrite CLAUDE.md to match the wrong comments. Instead we open an issue and leave the drift open until the comments are corrected.

## Issue

Filed at `https://github.com/kokarat/mobiz-payment-gateway/issues/181` on 2026-04-16 by `pg-writer-oracle` during Workflow 4 first-live-run.

## Next step

Backend team picks up the issue. When the model comments are corrected, `technical_writer` re-verifies and writes a follow-up `#resolution` that supersedes both the original drift and this regression-candidate. Until then, the original DRIFT-2 learning stays open and is kept in `docs/current-system.md` §9 with status `ESCALATED: #181`.

## Handoff

This learning is the handoff. There is no in-repo `backend_developer` AI (per `.agent/AGENTS.md` §5 — backend work on the current repo is owned by humans outside the AI team). The GitHub issue is the durable pointer.
