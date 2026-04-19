---
title: flow — withdrawal-queue-dispatch-and-claim — ratified revision (S4 → S2 via Orac
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, withdrawal-queue-dispatch-and-claim, ratified, revision, withdrawal-queue, dispatcher, bank-bot, payout, settlement, cross-repo, s2]
created: 2026-04-18
source: docs/flows/withdrawal-queue-dispatch-and-claim.md@252849e + thread #12 closed 2026-04-18
project: github.com/kokarat/mobiz-payment-gateway
---

# flow — withdrawal-queue-dispatch-and-claim — ratified revision (S4 → S2 via Orac

flow — withdrawal-queue-dispatch-and-claim — ratified revision (S4 → S2 via Oracle thread #12).

Supersedes `2026-04-18_flow-withdrawal-queue-dispatch-and-claim-share` (the pending-state learning). Thread #12 ratified the spec on 2026-04-18 GMT+7 with the following human classifications on the folded design + drift questions:

**Design Q1 — scope boundary (enqueue ownership):** KEEP current. Source flow (payout-request / settlement / pullout / direct-transfer) owns `services.EnqueueWithdrawal`; this flow starts from "pending row in DB exists." Enqueue is NOT absorbed into this flow. Rationale: (i) source-specific pre-enqueue logic (wallet debit, approval gate, scheduler trigger) would either be duplicated 4× or lost if moved here; (ii) `payout-request.md` is already ratified with enqueue as its terminal step; (iii) "shared machinery starts from pending row" matches the flow's intent framing.

**Design Q2 — Dispatcher + Gateway actor modelling:** KEEP split. Dispatcher remains a distinct participant from Gateway because the trigger mechanism (ticker + `onNewItem` callback) is genuinely autonomous from HTTP — not reactive to bot or client. Stale-lock (15 min) and stale-processing (10 min) recovery behaviours are attributable to the Dispatcher goroutine; collapsing would hide this. Accepted trade-off: sibling payout-request.md / deposit-qr-request.md use `Gateway->>Gateway` self-messages instead — this flow's convention differs because the autonomous dispatcher is a first-class aspect of the shared-infrastructure narrative.

**Drift classification (a) — Admin JWT queue-terminal endpoints:** Classified as **debug/legacy, not operational fallback.** `PUT /api/v1/withdrawal-queue/:id/success` and `/failed` exist under JWT + `withdrawal-queue:update` permission; controller delegates to the same service calls as the bot endpoints. Human confirmed these are NOT the supported bot-down manual-override path — an admin who finds a stuck queue item should let safety nets resolve or use admin-cancel (pending only). Added as §Error path entry in the flow doc + `#drift + #followup + admin-endpoint-legacy` learning filed (`2026-04-18_drift-followup-admin-queue-terminal-endpoints-cl.md`) for future W4 deprecation-or-gate review.

**Drift classification (b) — Pullout / direct-transfer wallet semantics on failure:** Classified as **intentional**. Pullout (scheduler moves gateway-owned funds between system banks) and direct-transfer (admin moves gateway-owned funds between system banks) never touch a client wallet, so no refund on `failed` is correct. Current doc wording at §Error paths and §Postconditions ("wallet refunded (for payout/settlement; pullout/direct-transfer have no client wallet)") already accurately describes this; no change to doc content.

**Drift classification (c) — `waiting_to_review` admin resolution mechanism:** **DEFERRED** to Oracle thread #14 as a focused discussion. Human agreed it was a large enough question to warrant its own thread rather than bundling into #12. Flow doc now carries `[AWAITING_THREAD:14]` in §Error paths on the `waiting_to_review` entry. Scope of this flow may extend to cover resolution (add step 11) or remain deferred to per-source flows, directly depending on thread #14's answer.

**Transition:** Claim strength **S4 → S2**. Doc header now carries `// ratified-via-thread:12`. Thread #12 closed 2026-04-18 GMT+7. W8 root trace `383d3a2d-5a90-4581-8dec-354c7b8318b3` gains a child trace for the resolution. Cross-repo-sync learning (validated against bank-bot at bbd1616) already landed earlier today as a separate supersede; sibling single-transfer flow (`withdrawal-queue-single-bot-transfer.md`, thread #13) remains pending its own ratification.

**Related:**
- Learning (superseded): `2026-04-18_flow-withdrawal-queue-dispatch-and-claim-share.md`
- Drift-followup (new): `2026-04-18_drift-followup-admin-queue-terminal-endpoints-cl.md`
- Cross-repo-sync (validated): `2026-04-18_cross-repo-sync-wq-dispatch-and-claim-validate.md`
- Sibling flow: `2026-04-18_flow-withdrawal-queue-single-bot-transfer-sing.md`

---
*Added via Oracle Learn*
