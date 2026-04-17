---
title: Pullout RBAC resource renamed — pull-out → pull-out-tasks / pull-out-logs (#175)
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - rbac
  - pullout
  - breaking
source: routes/pullout_task.go@ed45b7e, routes/pullout_logs.go@ed45b7e
created: 2026-04-17
project: github.com/kokarat/mobiz-payment-gateway
---

# Pullout RBAC resource renamed — pull-out → pull-out-tasks / pull-out-logs (#175)

## Pattern

Before PR #175 both `routes/pullout_task.go` and `routes/pullout_logs.go` gated on `RequirePermission(PermView|PermCreate|…("pull-out"))`. At HEAD:

- `routes/pullout_task.go`: every CRUD + `/toggle`, `/preview`, `/execute-now` route gates on resource `"pull-out-tasks"`. The `/:id/logs` sub-route gates on `"pull-out-logs"`.
- `routes/pullout_logs.go`: all routes gate on `"pull-out-logs"`.

## Why

The RBAC UI shows one row per resource when building role permissions. A single `pull-out` resource couldn't let an operator grant "view logs" without also granting "edit tasks". Splitting the resource gives roles the granularity they need.

## How to apply

- **Breaking for roles defined before 2026-04-16.** Roles with `{resource: "pull-out", actions: […]}` no longer reach either endpoint group — the middleware looks for `pull-out-tasks` or `pull-out-logs`.
- Fix path: re-issue the role with the new resource names. The Role CRUD API (`POST /api/v1/roles`) accepts the new resource strings; `GET /api/v1/roles/available-resources` surfaces them.
- If a team reports "Customer Support can't see pullouts anymore after 2026-04-16", this is the cause — not a permission bug, a resource rename that their role didn't follow.
