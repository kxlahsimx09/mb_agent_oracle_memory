---
title: flow-drift — deposit-slip-upload-admin-approve: #528/#529 add 4th fraud-block + persisted slip-dest; #521/#522 defer Thunder on client path
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - drift
  - flow-drift
  - flow-track
  - flow:deposit-slip-upload-admin-approve
  - deposit
  - fraud
created: 2026-06-17
source: docs/flows/deposit-slip-upload-admin-approve.md ; controllers/DepositController.go:994-1009,896-918 + services/slipFraudCheck.go:190-217 + controllers/DepositRequestController.go @ 03d6383
related:
  - 2026-06-17_drift-19-slip-fraud-late-autoconfirm
  - 2026-06-17_telegram-report-fixes-and-thunder-client-upload-defer
project: github.com/kokarat/mobiz-payment-gateway
---

# Flow drift — deposit-slip-upload-admin-approve (Class C)

W9 pass 2026-06-17 over `9aebabb..03d6383`. Flow `deposit-slip-upload-admin-approve` touched by `8f29c29` #528, `b88eccb` #529, `7bfad9b` #521, `d921419` #522. Outcome: **Class-C drift** compounding on the existing #460/#361/#362 [DRIFT] markers (no A/B refresh — baseline held).

**Drifts (all marked `[DRIFT]` in §Implementation pointers; pointers held at prior `@short` per W9 Class C):**
1. **#528** — NEW 4th pre-paid fraud-block layer: approve→paid returns `409 DUPLICATE_SLIP` (original deposit id in body) when `slip_duplicate_of` is set, overridable only via the same `[force-approve]` token in `notes` (`controllers/DepositController.go:994-1009@03d6383`).
2. **#529** — layer (ii) receiver-mismatch is **superseded** by a persisted-field check: new deposit fields `slip_dest_status` (`ok`/`mismatch`/`unverified`) + `slip_dest_account`, written at verify time by `services/slipFraudCheck.go:190-217 EvaluateSlipDestination`; approve→paid hard-blocks on `slip_dest_status="mismatch"` (`controllers/DepositController.go:896-918@03d6383`). Persisted (survives every view) vs the old live-recompute.
3. **#521/#522** — the doc's "client path (`DepositRequestController.UploadSlip`) unchanged by #460" claim is now stale: Thunder is **fully deferred/async on the client path too** — upload no longer flips to `checking`, deposit stays `pending`, matcher keeps its full `slip_review_timeout_minutes` window before escalation queues Thunder. §Sequence Steps 3/4 (sync Thunder) + Step 6 response (`{transRef, verifyResult}`) no longer hold for the client path. Extends `current-system.md` DRIFT-15.

§Error paths / §Sequence describe none of these. The W8 revision scope for this flow is now **four+ fraud layers + the override-contract evolution + persisted slip-dest model fields + the client-path Thunder deferral**. Fraud/financial — W8 revision should CC `security_auditor` + `code_reviewer`.

W9 child trace: `8702e11b-0c66-45b5-b679-165f3384c6a1` (parent `38558e51`).
