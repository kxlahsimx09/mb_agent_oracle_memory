---
title: flow cross-repo breadcrumb — payout-request crosses into bank-bot territory at s
tags: [technical-writer, repo:mobiz-payment-gateway, repo:cross, current, flow, payout-request, cross-repo-sync, bank-bot]
created: 2026-04-18
source: docs/flows/payout-request.md@4e84ad5 + routes/bot.go:25-33@4e84ad5
project: github.com/kokarat/mobiz-payment-gateway
---

# flow cross-repo breadcrumb — payout-request crosses into bank-bot territory at s

flow cross-repo breadcrumb — payout-request crosses into bank-bot territory at steps 7+8 (Playwright login + bank confirmation parsing) and reads back via /api/v1/bot/queue/{claim,success,failed,waiting-to-review} at steps 6 and 9.

Expected counterpart: bank-bot/docs/flows/payout-request.md (bot-writer W8 not yet implemented in the bank-bot repo). When bot-writer adopts W8 and runs it on this slug, the sibling pass should:

1. arra_trace_link(prevTraceId="ba99f3b3-6e59-4348-8878-f180a1fee17e", nextTraceId=&lt;bot W8 trace&gt;) to chain the two passes for `arra_trace_chain` traversal.
2. Mirror the [RATIFICATION_PENDING] anchor for the bot-side ratification thread into the bot's flow doc.
3. Cite the same step numbering (1–10) as this doc so cross-doc reasoning lines up — specifically step 6 (claim cadence/batch-size choice) and steps 7–8 (Playwright login + popup parsing) are bot-owned; steps 1–5, 9, 10 are mobiz-owned.

Source: docs/flows/payout-request.md@4e84ad5 (mobiz side) + routes/bot.go:25-33@4e84ad5 (claim/success/failed/waiting-to-review endpoints) + services/withdrawalQueue.go:780-1118@4e84ad5 (MarkSuccess/MarkFailed/MarkWaitingToReview).

Related to: 2026-04-17_flow-cross-repo-breadcrumb-deposit-qr-request-cr (the earlier deposit-side breadcrumb that established this pattern).

---
*Added via Oracle Learn*
