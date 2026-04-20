---
title: drift — flow:payout-confirm-completed (c) MDR distribution is duplicated inline 
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow, payout-confirm-completed, mdr-inline-vs-helper, refactor-candidate, mdr, payout, thread-22-resolved]
created: 2026-04-19
source: controllers/PayoutController.go:1907-1970@0d968fa + services/withdrawalQueue.go distributeMDRFees@0d968fa + controllers/TopupController.go (topup MDR fan-out)@0d968fa + docs/flows/payout-confirm-completed.md + thread #22 full resolution 2026-04-19
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — flow:payout-confirm-completed (c) MDR distribution is duplicated inline 

drift — flow:payout-confirm-completed (c) MDR distribution is duplicated inline instead of reusing `services.distributeMDRFees` helper. `controllers/PayoutController.go:1907-1970` (inside `session.WithTransaction`) loops over `mdrProfile.Partners`, computes share via `helpers.CalculateFee(amount, percentage)`, `FindOneAndUpdate` on partner wallet, inserts `mdr_distribution` change-log, appends to `distributions` slice — substantively the same logic as `services/withdrawalQueue.go` `distributeMDRFees` used on the happy-path success flow. Inline comment at L1907-1909 justifies: *"cannot reuse the non-transactional services.distributeMDRFees helper here"* — the helper does not accept a session context so it cannot participate in the confirm-completed transaction. Net: two MDR fan-out code paths exist with small differences. Same family as `topup-approve-mdr-distribution` §Resolved questions (b) (asymmetric abort-vs-skip across MDR paths); combined with this finding, **three MDR call sites** exist in production today: (A) helper `distributeMDRFees` used by `services/withdrawalQueue.go` happy path, (B) inline transactional copy in `controllers/PayoutController.go ConfirmPayoutCompleted`, (C) inline topup copy in `controllers/TopupController.go` (topup approval). Human ruling 2026-04-19 (thread #22): drift, fix later. Recommended refactor: make `distributeMDRFees` accept an optional `sessCtx *mongo.SessionContext` so both transactional and non-transactional callers can share the primitive. When W4 picks up (c), should also audit the topup path (C) to keep the refactor coherent — collapse all three call sites into one primitive. Low urgency (MDR logic changes rarely in practice) but compounds with every future MDR-related business logic change (referral fees, audit fields, formula tweaks) — each requires touching three places until collapsed.

---
*Added via Oracle Learn*
