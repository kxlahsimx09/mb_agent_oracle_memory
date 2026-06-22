---
title: drift — DRIFT-21 dangling mdr_profile guard (delete-block 409 + deposit/payout 422) undocumented
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - mdr
  - deposit
  - payout
  - drift
created: 2026-06-17
source: controllers/MDRProfileController.go:907-919 + controllers/DepositRequestController.go:329-334 + controllers/PayoutRequestController.go:305-310 @ 0897541
related:
  - 2026-06-17_drift-18-bank-fee-ledger-wallet
  - 2026-06-17_decision-range-a011daf-03d6383-w1-sized-escalate
project: github.com/kokarat/mobiz-payment-gateway
---

# DRIFT-21 — Dangling-mdr_profile guard, undocumented (financial-behavior)

`0897541` #542 "fix(mdr): guard against dangling mdr_profile references" (2026-06-17). Recorded as deferred drift in the 2026-06-17 W2 amend pass (current-system.md §9 DRIFT-21, folded into the W1-sized backlog beside DRIFT-18). **Financial-behavior — CC `code_reviewer` on the W1 PR that documents it.**

Root cause (issue #541): an `mdr_profiles` doc could be deleted while `clients`/`merchants` still carried its id in `mdr_profile_id`. The deposit/payout fee lookup then hit `mongo.ErrNoDocuments`, fell into the generic warn-and-continue branch, and **silently charged fee=0 with no `mdr_shared` partner distribution** — money lost quietly, no error surfaced.

Two guards (post-change @ 0897541):
- **Delete-block** — `MDRProfileController.DeleteMDRProfile` (`controllers/MDRProfileController.go:907-919`) now `CountDocuments` on `clients` + `merchants` where `mdr_profile_id == <hex id>`; if either count > 0 it returns **`409 Conflict`** with a message naming both counts ("still referenced by N client(s) and M merchant(s). Reassign them to another profile first."). The check runs before the existing partner-unlink/delete logic.
- **Fail-loud at create** — `DepositRequestController.CreateDeposit` (`controllers/DepositRequestController.go:329-334`) and `PayoutRequestController.CreatePayout` (`controllers/PayoutRequestController.go:305-310`): the assigned-profile branch now explicitly handles `err == mongo.ErrNoDocuments` by calling `rejectDeposit` / `rejectPayout` with **`422 Unprocessable Entity`** ("Configured MDR profile not found — deposits/payouts are blocked until an admin assigns a valid MDR profile to this client"). Previously this case fell into `else if err != nil` → log warning → continue at fee=0.

Scope note: a client with **no** `mdr_profile_id` assigned is unaffected — the profile lookup only runs when a profile id is present, so the 422 fires on *dangling* (assigned-but-deleted) references only, not on unassigned clients.

Doc impact: new client-facing API error contract (`409` on MDR delete, `422` on deposit/payout create) on the MDR + deposit/payout surface; no current-system.md §3/§6 prose coverage yet. Folds into the W1-sized backlog; baseline held at `a011daf`.
