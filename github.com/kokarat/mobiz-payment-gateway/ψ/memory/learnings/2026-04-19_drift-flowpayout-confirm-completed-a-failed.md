---
title: drift — flow:payout-confirm-completed (a) `failed` entry branch is a defensive p
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow, payout-confirm-completed, invariant-violation, deprecation-candidate, payout, thread-22-partial-ratification]
created: 2026-04-19
source: controllers/PayoutController.go:1735-2039@0d968fa + docs/flows/payout-confirm-completed.md + thread #22 partial ratification 2026-04-19 + Oracle memory feedback_payout_state_invariant
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — flow:payout-confirm-completed (a) `failed` entry branch is a defensive p

drift — flow:payout-confirm-completed (a) `failed` entry branch is a defensive patch for upstream invariant violations, not a feature. Load-bearing invariant (ratified in thread #22 on 2026-04-19): `failed` on the payout rail is proof-negative-only; uncertainty belongs in `waiting_to_review`. The endpoint `PUT /api/v1/payouts/:id/confirm-completed` currently accepts `failed` as entry state (`controllers/PayoutController.go:1788`: `if payout.Status != "failed" && payout.Status != "waiting_to_review"`) with a branch at L1870 that deducts client wallet when prior status was failed (because `MarkFailed` refunded). This branch exists to accommodate two upstream drifts: (1) `bank-bot/app.js:1640-1648` flattens KTB post-OTP `waiting_to_review` to `failed` (thread #16 — bot-writer's territory); (2) `scheduler/withdrawal_dispatcher.go:788` stale-lock sweep calls `MarkFailed` with error message explicitly admitting uncertainty ("bot may have crashed. Check bank statement before retrying"). Once both upstream drifts are fixed, the `failed` entry branch of `ConfirmPayoutCompleted` should be **deprecated** and the endpoint should accept only `waiting_to_review → completed`. Human ruling 2026-04-19 (thread #22 partial ratification): deprecation on the table, deferred to future PR; current behavior stays until upstream fixes land (premature removal would strand items). Fix sketch when upstream is ready: narrow the guard to `if payout.Status != "waiting_to_review"`, remove the wallet-deduction branch at L1870-1900 entirely (waiting_to_review never touched wallet), keep only the MDR fan-out + queue cascade + callback paths. Drift class: invariant-violation + deprecation-candidate.

---
*Added via Oracle Learn*
