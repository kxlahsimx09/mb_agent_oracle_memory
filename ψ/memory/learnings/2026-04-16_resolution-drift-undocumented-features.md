---
title: resolution — undocumented-features drift parked as (C) scope-exceeds (DRIFT-9)
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - resolution
  - next-task
source: CLAUDE.md (no sections for 2FA, Telegram, Bank Accounts, Direct Transfers, Pools, Activity Logs, App Settings, Callback Logs, MDR Shared, maintenance window, ConfirmPayoutCompleted, auto-reconcile) @ a4d806f
supersedes:
  - 2026-04-15_drift-undocumented-features
related:
  - 2026-04-15_drift-undocumented-features
  - 2026-04-16_resolution-drift-controllers-route-count
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

# Resolution — DRIFT-9 undocumented features (parked as scope-exceed)

## Drift class (original)

CLAUDE.md has no sections for entire feature areas that ship in production: 2FA, Telegram (webhook + config + broadcast), Bank Accounts (approval workflow), Direct Transfers, Pools, Activity Logs, Audit Trail middleware, App Settings, Callback Logs, MDR Shared logs, Banks master list, Maintenance window. Additions from the 2026-04-16 baseline also unwritten: `ConfirmPayoutCompleted`, auto-reconcile (`services.ReconcileFailedPayoutToCompleted`), KTB deposit-routing exclude, multi-client list filter, Bangkok-local MDR date parsing, wallet-change-log `reference_id`.

## Resolution path (taken)

(C) with a pragmatic reason: **scope-exceeds-reconcile**. This is closed on the drift side of the ledger and re-opened as a `#next-task` for a focused Workflow 1 (or multiple Workflow 2 passes) over the gaps.

## Why this is not (A) in this pass

Workflow 4 is a cleanup pass whose unit cost is ~5–10 min per drift. Writing ~12 new CLAUDE.md feature sections is authoring work at ~30–60 min per section — three orders of magnitude more effort, a review-burden mismatch with the other drift closures in this PR, and a different failure mode (needs domain questions to the user for each feature's invariants). Bundling it into this PR would make every other drift resolution harder to review.

## What changed

- Doc: nothing in CLAUDE.md. §9 of `docs/current-system.md` notes the closure with a parked-scope annotation. The DRIFT-6 resolution's "Additional controllers and routes" block is a partial bridge — it names the missing surfaces without describing them.
- Code: unchanged.

## Next task

A dedicated writer session (likely triggered by one of the Workflow 1 re-baseline conditions in `docs/current-system.md` §11) should author one section per missing feature. Suggested order by audit risk:

1. **2FA** (`controllers/TwoFactorController.go`, `routes/2fa.go`) — security surface, should be documented before the next `security_auditor` pass.
2. **BankAccount approval workflow** (`controllers/BankAccountController.go`, `routes/bankaccount.go`) — production incident risk if approvers do not know the state machine.
3. **Telegram** (webhook + report triggers + broadcast) — the `ReportScheduler` is disabled in-process and reports run via the `/telegram/report/*` endpoints, which are not in CLAUDE.md. See the superseded DRIFT-10 learning for the code fact.
4. **DirectTransfer** — callback and wallet-effect behavior is non-obvious and will generate bug reports until described.
5. **App Settings / Maintenance window / CallbackLog / ActivityLog / MDRShared / Pool / WalletChangeLog API / ClientAPI log** — lower-urgency, straightforward listings.
6. Additions from the 2026-04-16 baseline (`ConfirmPayoutCompleted`, auto-reconcile, KTB exclude, multi-client filter, Bangkok-local date, wallet-change-log reference_id) — small deltas, can piggy-back on any of the above.

## How I verified

Grepped CLAUDE.md for each feature name; none appear as section headings. Spot-checked that code exists at HEAD for each via `ls controllers/*.go routes/*.go`.

## Residual

The superseding `arra_supersede` is called to move the original drift into `superseded_by` status, but the follow-up work is **open**. This is the deviation from strict workflow-4 outcome (C) semantics — I am using (C) with a non-standard reason `scope-exceeds-reconcile` instead of `obsolete | duplicate | feature-removed`. The deviation is documented here so the pattern is searchable if other drifts need the same treatment.
