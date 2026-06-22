---
title: flow-drift — deposit-slip-upload-admin-approve drift extends (#528 4th fraud layer, #529 persisted slip_dest_status, #521/#522 client-path Thunder defer)
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - flow-track
  - flow-drift
  - drift
  - deposit
  - flow:deposit-slip-upload-admin-approve
created: 2026-06-18
source: controllers/DepositController.go:896-918,994-1009@03d6383 + services/slipFraudCheck.go:190-217 + controllers/DepositRequestController.go UploadSlip@03d6383 + docs/flows/deposit-slip-upload-admin-approve.md
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 Class-C flow drift — slip-upload-admin-approve drift extends (post-bb02f02)

The `deposit-slip-upload-admin-approve` flow already carried `[DRIFT]` markers (Step 5 #460 Thunder-defer on the admin path; Step 7 three pre-paid fraud layers #360/#361/#362/#364/#366/#369 + override-contract evolution) queued for a W8 revision. This pass extends those markers with the post-`bb02f02` commits:

- **#528 `8f29c29` — NEW 4th fraud layer (duplicate-slip block):** approve→`paid` hard-blocked with **`409 DUPLICATE_SLIP`** when the deposit carries `slip_duplicate_of`, unless admin `notes` contains literal `[force-approve]` (`controllers/DepositController.go:994-1009@03d6383`).
- **#529 `b88eccb` — layer (ii) reworked to persisted fields:** receiver-mismatch is no longer live-recompute-only — `services/slipFraudCheck.go:190-217 EvaluateSlipDestination` persists `slip_dest_status` (`ok`/`mismatch`/`unverified`) + `slip_dest_account`; approve→`paid` hard-blocks on `slip_dest_status=="mismatch"` (`controllers/DepositController.go:896-918@03d6383`).
- **#521 `7bfad9b` / #522 `d921419` — client upload path also Thunder-deferred:** the existing Step-5 NB "client path (`DepositRequestController.UploadSlip`) unchanged by #460" **no longer holds** — Thunder is now fully deferred/async on the client path too; deposit stays `pending` after upload (no flip to `checking`, `slip_verify_status` empty); `#521` recreates a fresh context after a slow Thunder call (fixes the context-deadline 500). Steps 3/4/6 of §Sequence no longer apply to the client path either.

W9 action: extended the existing Step 5 + Step 7 `[DRIFT]` markers (pointer-section only). The W8 revision scope is now **five** axes (4 defense layers + override-contract evolution) plus the client-path Thunder-defer. Class C; flows-baseline held at `9aebabb`. First surfaced (unlanded) by W9 trace `38558e51`; this pass lands the markers on main.
