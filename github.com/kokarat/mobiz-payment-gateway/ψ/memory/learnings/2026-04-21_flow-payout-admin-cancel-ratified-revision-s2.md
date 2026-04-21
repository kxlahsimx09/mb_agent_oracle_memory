---
title: Flow: payout-admin-cancel (ratified revision, S2). Admin-discretion cancel termi
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, payout-admin-cancel, workflow-8, ratified, revision, s2, payout, admin-cancel, wallet-refund, withdrawal-queue, callback]
created: 2026-04-21
source: docs/flows/payout-admin-cancel.md@ratified + thread #34 closed 2026-04-21
project: github.com/kokarat/mobiz-payment-gateway
---

# Flow: payout-admin-cancel (ratified revision, S2). Admin-discretion cancel termi

Flow: payout-admin-cancel (ratified revision, S2). Admin-discretion cancel terminal for pending payouts via `PUT /api/v1/payouts/:id/cancel`. W8 doc `docs/flows/payout-admin-cancel.md` was reverse-engineered 2026-04-21 from `controllers/PayoutController.go:913-1079@aff85e1` and ratified same-day via Oracle thread #34 — claim strength promoted S4 → S2.

**Three load-bearing framings confirmed as-is by human:** (1) bot-excluded-by-step-4-gate — the handler hard-rejects with 400 when the queue row is `processing`; admin cannot preempt in-flight bank transfers through this endpoint (must wait and use `confirm-completed` / `override` instead). (2) Dedicated-endpoint invariant — only `CancelPayout` drives `pending → cancelled`; PR #228 explicitly removed `cancelled` from `UpdatePayoutStatus`'s validator to close the earlier double-refund hazard. (3) Terminal cancellation — at HEAD `aff85e1`, no admin endpoint reverses the `cancelled` state; only a new `payout-request` with a new `RequestID` can start fresh.

**Four folded questions ruled:** (a) non-transactional write sequence → drift, PR needed, **separate PR cross-linked** to sibling `payout-auto-cancel-pending-timeout` (a) (not folded — human preferred independent refactor PRs); (b) queue-cancelled-but-payout-not-pending race window → drift (upgraded from my proposed "narrow, not drift") — fix is the transaction from (a) OR explicit compensation write; (c) blind wallet `$inc` with silent failure → drift, PR needed, shape paired with sibling #31 (b), fold into (a)'s transactional wrapper; (d) callback not resend-safe on goroutine-kill → regression-candidate, **separate per-flow learning** cross-linked to the unified callback-resend-with-idempotency learning (not scope-extended — human preferred per-flow entries with cross-links over a three-rail unified learning that becomes a dependency hairball).

Four follow-up learnings filed for W4 pickup: `2026-04-21_drift-payout-admin-cancel-a-non-transactional.md`, `2026-04-21_drift-payout-admin-cancel-b-queue-cancelled-bu.md`, `2026-04-21_drift-payout-admin-cancel-c-blind-wallet-inc.md`, `2026-04-21_regression-candidate-payout-admin-cancel-d-cal.md`. Thread #34 closed. W8 root trace `8002ff0a-6c83-4f35-a495-7077286da7a4` gets a ratification child trace. Supersedes the initial pending-state learning `learning_2026-04-21_flow-payout-admin-cancel-admin-discretion-cance`.

PR #263 carries the ratified doc (branch `docs/flow-payout-admin-cancel`). PR stays unmerged pending human merge — pg-writer's workflow default is "I do not merge my own docs PRs". Cross-references: sibling `docs/flows/payout-auto-cancel-pending-timeout.md` (thread #31), mutually exclusive `docs/flows/payout-confirm-completed.md` (thread #22), parent `docs/flows/payout-request.md` (thread #8), `docs/flows/withdrawal-queue-dispatch-and-claim.md` (thread #12).

---
*Added via Oracle Learn*
