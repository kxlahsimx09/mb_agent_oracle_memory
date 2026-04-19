---
title: flow — withdrawal-queue-single-bot-transfer — ratified revision (S4 → S2 via Ora
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, withdrawal-queue-single-bot-transfer, ratified, revision, withdrawal-queue, ktb, single-transfer, cross-repo, sibling-flow, s2]
created: 2026-04-18
source: docs/flows/withdrawal-queue-single-bot-transfer.md@252849e (mobiz) + bbd1616 (bank-bot) + thread #13 closed 2026-04-18
project: github.com/kokarat/mobiz-payment-gateway
---

# flow — withdrawal-queue-single-bot-transfer — ratified revision (S4 → S2 via Ora

flow — withdrawal-queue-single-bot-transfer — ratified revision (S4 → S2 via Oracle thread #13).

Supersedes `2026-04-18_flow-withdrawal-queue-single-bot-transfer-sing` (the pending-state learning). Thread #13 ratified the spec on 2026-04-18 GMT+7 with human classifications as follows:

**Design Q1 — sibling-not-child decision:** KEEP. Separate doc (`withdrawal-queue-single-bot-transfer.md`) rather than monolithic with mode branches inside the dispatch-and-claim doc. Shared gateway machinery is cross-referenced to sibling, not duplicated. Matches the pattern bot-writer's future W8 will likely use (per-bank-mode flow docs on bank-bot side), enabling clean `arra_trace_link` pairing across the two repos.

**Design Q2 — generic naming:** KEEP. Slug `withdrawal-queue-single-bot-transfer` and actor name `BankBotSingle` stay generic/future-proof. KTB is currently the only implementer (`bank-bot/banks/ktb/index.js:33-34` returns `getSupportedFlows() = ['transfer']`) but the flow describes the pattern for any single-session bot deployment. Avoids premature specialization.

**Design Q3 — Bank as two edges in diagram:** KEEP. Step 5 (`BB->>BK: ext-bank-bot login + add recipients + submit + OTP`) + Step 6 (`BK-->>BB: ext-bank-bot success page with bankRef (or failure or post-OTP ambiguity)`) retained as distinct request/response edges. Deviates from sibling's convention (single outbound edge with response described inline) but faithfully shows the request-response nature of bot↔bank interaction here.

**Drift (I) — `bankRef` in wrong positional slot at `bank-bot/app.js:1629,1695`:** Moved to **Oracle thread #15** (bot-writer-owned) per human instruction. pg-writer opened the anchor + filed the canonical drift learning (`2026-04-18_drift-bank-bot-bankref-in-wrong-positional-slo.md`, supersedes earlier `…appjs1244-single-transfer-suc` with corrected framing); bot-writer closes the thread when the fix lands. Doc §Error paths carries `[AWAITING_THREAD:15]` until resolution.

**Drift (II) — `waiting_to_review` status lost in single-transfer dispatch at `bank-bot/app.js:1628-1635,1694-1700`:** Moved to **Oracle thread #16** (bot-writer-owned). pg-writer opened the anchor + filed the canonical drift learning (`2026-04-18_drift-bank-bot-waitingtoreview-lost-in-singl.md` — new finding from this authoring pass); bot-writer closes the thread when the fix lands. Doc §Error paths carries `[AWAITING_THREAD:16]` until resolution.

**Transition.** Claim strength **S4 → S2**. Doc header carries `// ratified-via-thread:13`. Thread #13 closed 2026-04-18 GMT+7. W8 root trace `6afbf4f9-e19e-4b63-8a9e-26e23f941154` (child of sibling W8 `383d3a2d-…`) gains a child trace for the resolution.

**Deferred drift-resolution loop (cross-repo pattern, per AGENTS.md §7):**
- pg-writer opens thread + anchors marker in own doc → bot-writer owns the fix → bot-writer closes thread when code lands → pg-writer's next W9 / thread-resolve sweep sees closed thread → strips marker + updates §Error paths with resolution note (per P-001 historical record stays).
- For both #15 and #16, the resolution loop is kept async — pg-writer does not block on bot-writer's triage timing, and the single-transfer flow doc is already authoritative-at-HEAD even while the underlying bank-bot code still carries the drifts.

**Related:**
- Learning (superseded): `2026-04-18_flow-withdrawal-queue-single-bot-transfer-sing.md`
- Sibling flow (ratified separately via thread #12): `2026-04-18_flow-withdrawal-queue-dispatch-and-claim-ratif.md`
- Cross-repo-sync (validated earlier): `2026-04-18_cross-repo-sync-wq-dispatch-and-claim-validate.md` — also describes the single-transfer + dual-control split operationally for bot-writer reference.
- Drift anchors (bot-writer territory):
  - `2026-04-18_drift-bank-bot-bankref-in-wrong-positional-slo.md` (thread #15)
  - `2026-04-18_drift-bank-bot-waitingtoreview-lost-in-singl.md` (thread #16)

---
*Added via Oracle Learn*
