---
title: W8 revision — flow:withdrawal-queue-dispatch-and-claim dispatcher semantics (thread #29)
name: w8-revision-flow-withdrawal-queue-dispatch-and-claim-dispatcher-semantics
description: W8 revision pass on docs/flows/withdrawal-queue-dispatch-and-claim.md (originally ratified S2 via thread #12 @ 252849e). Spec's Purpose paragraph 2 claim "dispatcher can operate every tick without waiting for the bot" was invalidated by PR #239 (4313ef2 — findIdleBanks now filters working_status != busy). Step 3 Implementation pointer's tier-randomised cap description was replaced by the tier-tiered cap algorithm from PRs #237 + #242. Both revisions anchored under new ratification thread #29 [AWAITING_THREAD:29]. Claim strength stays S2 (code-to-doc transcription).
type: project
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - flow
  - w8-revision
  - flow:withdrawal-queue-dispatch-and-claim
source: docs/flows/withdrawal-queue-dispatch-and-claim.md
project: github.com/kokarat/mobiz-payment-gateway
---

W8 revision pass 2026-04-20 on `withdrawal-queue-dispatch-and-claim.md`. Triggered by W9 pass `68ec92a6-1834-4b8a-8a2a-76fd306d35d3` detecting 7 affected flows in `b886cc4..68accc6` — over the ≤5 fast-fix cap. This flow selected first because dispatcher commits introduced behavioral changes, not just line shifts.

**Why:** the 2026-04-18 ratified spec made two claims that no longer match HEAD:

1. **§Purpose para 2**: "dispatcher can operate every tick without waiting for the bot" — PR #239 (`4313ef2`) added `working_status != busy` to the `findIdleBanks` filter, so the dispatcher now waits for each bank to finish its current batch before assigning more. One batch per bank at a time, no pipelining.
2. **§Implementation pointers Step 3**: "tier-randomised cap 1–5 / fixed 5 if ≥100 pending" — PR #237 (`12ad0d5`) replaced this with a tier-tiered cap (`>=100: 5 fixed`, `>=20: 4-5`, `>=5: 3-5`, else `1-5`) and removed the bot's separate batchSize=5 limit. PR #242 (`386f0a7`) adjusted the middle tiers.

**How to apply:** revisions committed with `[AWAITING_THREAD:29]` markers anchored inline next to both changed claims. The thread asks (Q1) whether the coupling is permanent intent or transitional safety fix, (Q2) whether the old framing should be superseded in §Change log or silently rewritten, and (3) whether the tier-tiered cap is canonical vs transitional. Claim strength stayed **S2** — this is transcribing new code behavior, not ratifying reverse-engineered intent, so no `[RATIFICATION_PENDING]` header downgrade.

**Related:**
- Prior W8 trace: `383d3a2d-5a90-4581-8dec-354c7b8318b3` (original authoring + thread #12 ratification)
- W8 revision trace: `b27c8d35-f7f3-46b5-8cf4-51e48f4ba7ec` (chained from prior via `arra_trace_link`)
- W9 threshold-breach trace: `68ec92a6-1834-4b8a-8a2a-76fd306d35d3` (the pass that halted and escalated)
- Sibling learning: `2026-04-20_drift-dispatcher-comment-code-mismatch-1-3-vs-1-5.md` (filed separately for W4 code-reviewer pickup)
- Deferred flows from the W9 breach: payout-request, payout-confirm-completed, topup-approve-mdr-distribution, deposit-slip-upload-admin-approve, withdrawal-queue-single-bot-transfer, deposit-qr-request — require their own W8 revisions or W9 class-B refresh passes.
