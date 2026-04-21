---
title: Cross-repo-sync breadcrumb (bot W9 → mobiz W9/W4): bot-side drifts from 2026-04-
tags: [technical-writer, repo:cross, cross-repo-sync, flow-drift, flow-track, flow:scb-dual-control-withdrawal, flow:ktb-single-transfer-withdrawal]
created: 2026-04-20
source: docs/flows/scb-dual-control-withdrawal.md + docs/flows/ktb-single-transfer-withdrawal.md
project: github.com/kokarat/bank-bot
---

# Cross-repo-sync breadcrumb (bot W9 → mobiz W9/W4): bot-side drifts from 2026-04-

Cross-repo-sync breadcrumb (bot W9 → mobiz W9/W4): bot-side drifts from 2026-04-20 W9 pass on commits 1cf5e14..5665f79 affect two bot flows whose boundaries cross into mobiz territory. Neither drift is detectable from the mobiz side because mobiz's sibling flows only carry a single `// ext: kokarat/bank-bot` marker at the relevant step.

Flow: `scb-dual-control-withdrawal` (bot W9 trace `0b29f60b-f4d3-4c3c-8f0f-affbf415c627`), sibling: `mobiz-payment-gateway/docs/flows/withdrawal-queue-dispatch-and-claim` (mobiz W2 trace `9e30baaf-ae7f-48a7-95cb-c8d005502319`). Drifted bot steps 2 / 3 / 4 / 8 all live inside the mobiz step-5 `// ext: kokarat/bank-bot` marker — mobiz W9 cannot see these without this breadcrumb. Specific drifts: (1) SCB maker `clearStaleRecipients` row-count fallback removed (`8f68dae`); (2) SCB maker pre-submit IBFT-merge guard + amount-match guard consolidated at top of `makerFlow` with `waiting_to_review` abort (`8f68dae`); (3) maker post-submit cleanup + no-bankTxnId fallback both promoted from `failed` to `waiting_to_review` (`dd5966b`, `6ebee00`, `9525cff`); (4) SCB Approver Phase 2 never uses Select All — ABORTs whole batch to `waiting_to_review` when zero items match, never blind-approves (`0815737`).

Flow: `ktb-single-transfer-withdrawal` (bot W9 trace same as above), sibling: `mobiz-payment-gateway/docs/flows/withdrawal-queue-single-bot-transfer`. Bot Step 8 post-submit dispatch now handles `waiting_to_review` status via a new `else if` branch in `processSingleTransfer` (`3359d08`). This RESOLVES the drift recorded in thread #16 (closed) — the `waiting_to_review` status emitted by `batchTransferFlow` after `submitted=true` or `KTB_POST_OTP` no longer falls through to `safeMarkFailed` and trigger an incorrect wallet refund when money may have left the bank. DRIFT-15 (bankRef slot-swap, thread #15 still pending) is NOT fixed by this commit range.

Impact on mobiz W4 queue: the SCB drifts have no direct mobiz-side code change — they are behavior shifts in the bot's interpretation of ambiguous submit/approve outcomes, now biased toward `waiting_to_review` over `failed`. This means mobiz will see fewer `MarkFailed` calls and more `MarkWaitingToReview` calls in steady-state, reducing the work of `tryReconcileAfterMarkFailed` but increasing admin review load. Mobiz's `withdrawal-queue-dispatch-and-claim` flow doc §Error paths should note this terminal-status distribution shift at its next W2/W9 pass.

---
*Added via Oracle Learn*
