---
title: drift — swagger_simple.json is a month stale and misses ~7 route groups
name: drift — swagger_simple.json is a month stale and misses ~7 route groups
description: Swagger last modified 2026-03-16; no paths for telegram, 2fa, bank-accounts, direct-transfer, activity-log, callback-log, app-settings/maintenance. HEAD has 39 route files; swagger has 141 path keys.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - swagger
  - drift
source: swagger_simple.json (mtime 2026-03-16) + routes/ @ 379e984
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-15
---

# DRIFT — swagger_simple.json is a snapshot, not a live spec

## Fact

`jq -r '.paths | keys[]' swagger_simple.json` returns 141 paths. The file was last modified 2026-03-16 per `ls -la swagger_simple.json`. Since then, 19 commits have landed on `main` (see `docs/current-system.md` Appendix A).

Swagger has no paths whose prefix matches any of: `telegram`, `2fa`, `bank-accounts`, `direct-transfer`, `activity-log`, `callback-log`, `app-settings`, `maintenance`. All of these are live route groups — see `routes/{telegram,2fa,bankaccount,directTransfer,activitylog,callbacklog,appsettings}.go`.

## Why it matters

- Swagger UI is the primary client onboarding surface. Missing routes look "not supported" rather than "not documented."
- Integration tests and SDK generators that regenerate from swagger will silently drop new routes.

## How to apply

- Never answer "what endpoints exist?" from swagger alone. Routes directory is authoritative.
- Doc sections that cite swagger must also cross-reference the route file:line.
- A follow-up job — probably a `qa_engineer` or a dedicated `swagger-regenerate` script — should refresh `swagger_simple.json` before any public SDK release.

## Trace

commit `379e984` → docs/current-system.md §3 + §9 DRIFT-3 → resolution PR (this PR documents gap; regen tracked separately)
