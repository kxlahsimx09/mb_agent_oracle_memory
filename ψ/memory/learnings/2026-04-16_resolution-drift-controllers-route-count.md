---
title: resolution — controller/route count drift closed (DRIFT-6)
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - resolution
source: CLAUDE.md:119-129 (new "Additional controllers and routes" block) + controllers/*.go + routes/*.go @ a4d806f
supersedes:
  - 2026-04-15_drift-controllers-route-count
related:
  - 2026-04-15_drift-controllers-route-count
  - 2026-04-15_drift-undocumented-features
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# Resolution — DRIFT-6 controller/route count divergence

## Drift class (original)

CLAUDE.md §"Project Structure" listed ~26 controllers and ~24 routes in its hand-curated tree. At HEAD the repo has **41 controllers** and **39 route files**. The difference — 17 controllers and 15 route files — was never added to the tree.

## Resolution path (taken)

(A) fix-doc — via a compact append rather than a tree rewrite.

## What changed

- Doc: CLAUDE.md §"Project Structure" — appended a new "Additional controllers and routes (not in the tree above)" block listing the 17 added controllers and 15 added route files, grouped into the feature surfaces they implement (activity log, app settings, bank accounts, banks master list, callback log, client API log, direct transfers, MDR shared, pools, pull-out logs + tasks, RBAC resource/action registry, Telegram webhook + config + broadcast, 2FA, wallet change log).
- Doc: same block ends with "`ls controllers/*.go routes/*.go` is authoritative" — a disclaimer pointer so future agents stop relying on the tree as the source of truth.
- Code: unchanged.

## Why compact-append and not a tree rewrite

A full rewrite of the ASCII tree would produce a ~50-line diff that is hard to review for correctness (description text would need re-verification against every controller). The append keeps the historical tree intact (P-001: nothing deleted), resolves the counting drift, and flags the tree as non-authoritative going forward. A future Workflow 1 pass may choose to replace the tree entirely — that is a separate decision.

## How I verified

`ls controllers/*.go` → 41 files; `ls routes/*.go` → 39 files. Cross-referenced each added name against the appended block. Re-read CLAUDE.md §"Project Structure" post-edit.

## Residual

The appended block is intentionally terse — it names each controller with a one-liner but does not describe the HTTP surface. That belongs in dedicated CLAUDE.md sections, which is the scope of the still-open DRIFT-9.
