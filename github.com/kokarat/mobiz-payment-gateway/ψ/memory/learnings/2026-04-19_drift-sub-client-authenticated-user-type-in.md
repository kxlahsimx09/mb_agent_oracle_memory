---
title: ## #drift: `sub-client` authenticated user type introduced across 4 files — undo
tags: [repo:mobiz-payment-gateway, technical-writer, drift, sub-client, auth, current, w4-deferred]
created: 2026-04-19
source: pg-writer-oracle W2 @ 386f0a71
project: github.com/kokarat/mobiz-payment-gateway
---

# ## #drift: `sub-client` authenticated user type introduced across 4 files — undo

## #drift: `sub-client` authenticated user type introduced across 4 files — undocumented; deferred to W4 full-pass

### Drift
Commit `cb78ef7` (mobiz-payment-gateway, landed between `1ffafc13..386f0a71`, +221 lines) introduces a `sub-client` JWT subject type and IDOR-scoping logic across:
- `controllers/BankAccountController.go`
- `controllers/SettlementController.go`
- `controllers/TopupController.go`
- `routes/settlement.go`

The sub-client user type is now recognized as a first-class authenticated subject in settlement / bank-account / topup flows, with its own scoping helpers (to prevent a sub-client from seeing or acting on a sibling sub-client's data, while still being constrained under its parent client's ownership).

### Doc state
- `CLAUDE.md` §"SubClient Management" exists but describes *managing sub-client resources as data objects* via admin JWT. It does NOT mention sub-client as a JWT subject type, does NOT describe the IDOR scoping added in cb78ef7, and does NOT list sub-client auth endpoints.
- `docs/current-system.md` has no §subsection for sub-client auth flows at `386f0a71` — only scattered mentions under existing client / topup / settlement sections.

### Why deferred (W4 full-pass, not fast-fix)
- 221-line change spanning 4 files — exceeds pg-writer W2 fast-fix threshold (which is tight edits only, single-concept).
- A proper write-up needs a §new subsection with endpoint-by-endpoint scoping matrix, which is a W4 (full-pass) deliverable, not W2.
- Filed as DRIFT-13 in `docs/current-system.md` §9 at branch `docs/track-386f0a7` for visibility; full expansion owed at next W4.

### How to apply
- **For pg-writer next W4 run:** open §"Sub-client auth + IDOR scoping" under §3 (Entities) or §4 (Auth), citing cb78ef7 line-by-line.
- **For reviewers of cb78ef7:** the scoping guards need their own test (`test-subclient-idor-scoping.sh` does not yet exist in `scripts/tests/` at `386f0a71`) — flagged for pg-tester.
- **For W2 baseline rule:** because cb78ef7 was deferred (not fast-fixed), `docs/.baseline` is NOT bumped to `386f0a71` in this pass. Baseline stays at `1ffafc13` until W4 closes DRIFT-13.

citations: `cb78ef7` across `controllers/BankAccountController.go`, `controllers/SettlementController.go`, `controllers/TopupController.go`, `routes/settlement.go`
filed under: `docs/current-system.md` §9 DRIFT-13
deferred to: W4 full-pass (pg-writer next full sweep)

---
*Added via Oracle Learn*
