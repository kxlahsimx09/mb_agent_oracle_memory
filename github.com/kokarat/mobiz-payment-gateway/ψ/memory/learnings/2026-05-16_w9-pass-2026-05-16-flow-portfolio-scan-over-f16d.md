---
title: W9 pass 2026-05-16: flow portfolio scan over `f16d602..33664cd` (3 code commits 
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, no-drift-found, flow:deposit-qr-request, flow:payout-request, flow:deposit-slip-upload-admin-approve]
created: 2026-05-16
source: docs/flows/deposit-qr-request.md, docs/flows/payout-request.md, docs/flows/deposit-slip-upload-admin-approve.md
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 pass 2026-05-16: flow portfolio scan over `f16d602..33664cd` (3 code commits 

W9 pass 2026-05-16: flow portfolio scan over `f16d602..33664cd` (3 code commits — `33664cd` rate-limit scope #443, `cf3e02f` per-service maintenance window #442, `e356670` ops scripts #441). Three flows affected, all Class A (pure hash refresh, zero drift): `deposit-qr-request` (5 pointers), `payout-request` (4 pointers), `deposit-slip-upload-admin-approve` (4 pointers) — 13 pointers total. Only `33664cd` touched flow-cited files (`controllers/DepositRequestController.go`, `controllers/PayoutRequestController.go`); every `33664cd` diff hunk is an equal-line-count in-place replacement (gofmt struct/map field alignment + the rate-limit block), so no pointer line number shifted — Class A across the board, refreshed `@ed45b7e`/`@c5270b3`/`@4e84ad5` → `@33664cd`. The rate-limit cap/scope change (#443) is NOT flow-step drift: `payout-request` Step 2's `// impl:` annotation lists "rate limit" as one item in the validation chain, and the chain still runs a rate-limit check — the changed cap value (10k→300k) and counter key scope are internal details the flow doc never asserted at step granularity. `cf3e02f` (`helpers/maintenance.go`) and `e356670` (`scripts/*.go`) cited by no flow pointer; `helpers/maintenance.go` is a pure helper called inside the create-controller validation chains covered by `payout-request`/`deposit-qr-request` Step 2 — caller-expansion check confirms the flow-step claim "validation chain incl. maintenance mode" still holds, no drift. No B/C/D/E/F. `docs/flows/.baseline` bumped f16d602 → 33664cd. Outcome: A=13 refreshed, B=0, C=0, D=0, E=0, F=0.

---
*Added via Oracle Learn*
