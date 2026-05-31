---
title: campaign archamd1 (2026-05-30) — 3 HIGH-severity admin money-out / admin-resolve
tags: [adr, amendment, ratification-discipline, money-out, settlement, direct-transfer, deposit, confirm-review, waiting_to_review, freeze-settle, admin-api, rbac, step-up, port-fidelity, provisional, campaign-archamd1, gap-sweep]
created: 2026-05-30
source: next-architect (campaign archamd1)
---

# campaign archamd1 (2026-05-30) — 3 HIGH-severity admin money-out / admin-resolve

campaign archamd1 (2026-05-30) — 3 HIGH-severity admin money-out / admin-resolve coverage gaps (current-prod-vs-next gap-sweep) closed as ADR amendment text in mb-next-payment-gateway docs/adr.md. Architect drafts the decision record only; next-writer authors S2 stories after ratification.

1. §ADR-12 §Amendment 2026-05-30 — Settlement Confirm-Review Resolution (CR1–CR4) — `#provisional` `[RATIFICATION_PENDING:campaign-archamd1]`. Class (b) money-material / NEW admin money-out decision surface. `waiting_to_review` is a dispatcher/bot-set non-terminal holding state (single writer services.MarkWaitingToReview; settlement encodes int 3); admin `PUT /settlements/:id/confirm-review` adjudicates uncertain bank outcome: success→freeze settles out, reject→freeze released, via §ADR-10 AM2 + §ADR-12 M1 freeze-settle (mechanism divergence from prod pre-debit; merchant-observable effect identical). Load-bearing CAS-409 guard (prod has `{_id,status:3}` filter but DISCARDS MatchedCount → silent lost-update; next hardens). §ADR-13 D1 3-layer + D2 audit + §ADR-2 step-up (AUTH-007/S2) required.

2. §ADR-12 §Amendment 2026-05-30 — Direct-Transfer Admin Reconciliation Override (DTO1–DTO4) — `#provisional` `[RATIFICATION_PENDING:campaign-archamd1]`. Class (b) money-material. Allowed source `waiting_to_review` → terminal {completed, failed}; completed→settle-out, failed→release (§ADR-10 AM2; DT freeze-at-create per §ADR-12 D4); freeze resolution is load-bearing layer-2 coupled to terminal transition (no orphaned freeze). Guarded `withdrawal_queue` sync (status∈{pending,processing,waiting_to_review}) ported verbatim — correct in prod. Divergences recorded: prod `PUT /direct-transfers/:id/status` validates `oneof=processing completed failed` with `{_id}`-only DT write (NO source-state guard; admin can trample terminal state) and does NO in-handler wallet mutation (dispatcher-delegated); next tightens source + couples freeze. §ADR-13 + §ADR-2 step-up.

3. §ADR-13 §Amendment 2026-05-30 — Admin Deposit List/Read Surface (DL1–DL3) — ratified `#decision`. Class (a) port-fidelity of ratified F1/F3/F4 actor model. `GET /api/v1/deposits` governed by F1 admin actor-tier (cross-tenant) + F3 `deposit:view` + F4 tenant scope; D1 write invariant N/A (read). Filter set (status whitelist / account-number anchored prefix / client_ids $in + legacy client_id / BKK date range) + checking-count badge = port-fidelity. Verification findings (no invention): (i) NO sparse btree index on ts_deposits.custom_bank_account_number — unindexed scan (data-model-pass concern, not asserted); (ii) NO read-time fraud-preview badge — DEPOSIT-007 cascade runs ONLY at approve-time, so DL3 CARVES OUT the read badge (not prod-backed; not self-ratified) and flags next-writer to downgrade the AC to approve-time-only or raise a separate provisional.

Ratification-discipline (charter §9) lesson: money-mechanics that reuse already-ratified semantics (§ADR-10 freeze-settle, §ADR-12 M1) can be drafted within architect authority, but the admin money-out DECISION SURFACE itself (admin adjudicating settle-vs-release of frozen funds) is a NEW surface → `#provisional` `[RATIFICATION_PENDING:campaign-archamd1]` + flag user. Read surfaces governed by an already-ratified RBAC/actor model = class (a) port-fidelity → architect may ratify. When verification contradicts the gap-sweep's claimed prod behavior (no sparse index; no read-time fraud badge; DT no source guard), record the divergence faithfully rather than drafting to the claim.

Verified against mobiz current source (kokarat/mobiz-payment-gateway: SettlementController.go:1457-1558, DirectTransferController.go:710-870, DepositController.go:203-493+1551-1586, services/withdrawalQueue.go:1156-1228, scheduler/withdrawal_dispatcher.go:808-810, db/indexes.go) + dpay prod (settlements status int 3 /2; direct_transfers waiting_to_review /50). Verify-against-HEAD 0fb63c0: all 3 gaps unspecified. Branch arch/archamd1-high3; one PR vs main (not merged).

---
*Added via Oracle Learn*
