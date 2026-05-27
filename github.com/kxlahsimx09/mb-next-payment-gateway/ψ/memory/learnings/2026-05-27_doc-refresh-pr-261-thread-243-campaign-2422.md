---
title: Doc-refresh PR #261 (thread #243, campaign #242←#239) — R1/B1/B2 shipped; SETTLE
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, source-flows, bot-gateway-dispatch, decision, faithfulness, s2-ratified]
created: 2026-05-27
source: docs/requirements/epic-source-flows.md + epic-bot-dispatch.md @a4e0032 (PR #261); thread #243
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Doc-refresh PR #261 (thread #243, campaign #242←#239) — R1/B1/B2 shipped; SETTLE

Doc-refresh PR #261 (thread #243, campaign #242←#239) — R1/B1/B2 shipped; SETTLE channel-fix + R2 + AUTH-005 HELD.

next-writer authored one doc-refresh PR on `epic-bot-dispatch.md` + `epic-source-flows.md` (branch `next-writer/doc-refresh-243-r1-b1-b2` off origin/main @1d0b7ff, commit a4e0032). Three faithfulness/freshness fixes vs ratified `#decision`s + production code @2087fed; no new ADR:

- **R1** — propagated §ADR-8 §Amendment 2026-05-26 (A2, ratified via #229): BOT-001 AC#2 fair-router eligibility filters 8→9 (adds per-bank withdrawal amount-range); added AF1 band-gate edge case + AF2 unroutable-by-band edge case; superseded the stale PULLOUT-002 "A2 being ratified separately / sub-thread #229" line. Amendment cited in both Sources blocks.
- **B1** — Pullout demand-refill faithfulness (PULLOUT-001): corrected the "4 co-equal LIVE triggers" overstatement → scheduled-tick + admin-manual are the always-available paths; demand-refill is config-gated default-OFF (mirrors PAYOUT-008 "ships off") and fires the OPPOSITE edge (payout DEST going LOW = pull-in/refill, not source-too-full drain). Old source-too-full drain variant removed in prod 2026-04-27. §ADR-12 D3 "4 triggers→1 dispatcher" consolidation untouched — only current-system liveness grounding corrected. Cites BotConfigController.go:557-562 / pulloutDemand.go:370-384,:21-26.
- **B2** — DTR refund faithfulness: DTR-001 got a deposit-refund carve-out to the S2 "a direct transfer never touches a wallet" universal; DTR-002 (S4 do-not-lose record) enriched with the money-movement half it omitted — wallet debit-at-create (FinalAmount+refundFee), credit-back on write-fail/cancel/reject, enable_deposit_refund default-off gate, AUTH-007 step-up TOTP, refund_pending_review/ResolveRefund admin reconciliation. Refund FLOW stays deferred per DEPOSIT-011/§ADR-4d — only the capture fixed. Cites DepositController.RefundDeposit @2087fed.

HELD (orchestrator msg 1126): the thread-243 addendum's SETTLE channel-fix (settlement is dashboard/JWT+RBAC `settlement:create`, NO API-Key route — contradicting the current SETTLE-001 "API/Idempotency-Key" framing and the ratified §ADR-12 D1 taxonomy) was STARTED then DISCARDED (uncommitted). Architect (msg 1124) ruled it needs a §ADR-12 §Amendment + user ratification, not a unilateral doc-edit. R2 (partner-initiated settlement) FLIPPED to Phase-1/in-scope (superseding the earlier defer). AUTH-005 lockout (epic-auth-rbac.md) also held. Orchestrator re-dispatches the SETTLE/R2 epic edits post-ratification.

Trust labels unchanged on the shipped work (BOT-001/PULLOUT-001/DTR-001 stay S2; DTR-002 stays S4-deferred).

---
*Added via Oracle Learn*
