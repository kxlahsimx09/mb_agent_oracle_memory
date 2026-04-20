---
title: Recovered re-file (corrected project field) — bank-bot< → bank-bot.
tags: [technical-writer, repo:bank-bot, current, flow, flow:scb-dual-control-withdrawal, scb, maker, approver, otp-email, otp-api, reverse-engineered, ratification-pending, recovered-from-typo-bracket]
created: 2026-04-20
source: docs/flows/scb-dual-control-withdrawal.md@466d56e — recovered 2026-04-20 (also fixes bank-bot&lt; project typo)
project: github.com/kokarat/bank-bot
---

# Recovered re-file (corrected project field) — bank-bot< → bank-bot.

Recovered re-file (corrected project field) — bank-bot< → bank-bot.

flow — scb-dual-control-withdrawal — intent at a glance.

Purpose: After the mobiz gateway has assigned a pending withdrawal-queue item to an SCB system-bank, bank-bot's two-session maker-approver pair claims the item via POST /bot/queue/claim, submits the transfer on SCB Business Anywhere (maker session), OTP-approves it (approver session with a second SCB login), calls per-item PUT /bot/queue/:id/{success,failed,waiting-to-review} back to the gateway, and pushes a fresh bank-statement row + balance so the gateway's tryReconcileAfterMarkFailed safety net has ground truth.

Bot-side doc: docs/flows/scb-dual-control-withdrawal.md@466d56e. 9 actor-crossing messages in the mermaid diagram; actors = System:BankBot:Maker, System:BankBot:Approver, External:SCBPortal, System:Gateway, External:OTPService (plus optional viewer session not on happy path).

Load-bearing design rules: (1) maker→approver serialisation via in-memory signalApprover/waitForApprover/signalMaker/waitForBatch + bankTxnIds Map — maker blocks up to 120s for the approver to finish each batch because SCB's Select All on the approval page selects every visible todo and a second maker batch would mix with the first; (2) per-item terminal call matrix — matched AND success → markSuccess, matched AND success-popup-timeout → markWaitingToReview (gateway holds, no wallet refund), unmatched (SCB side OR demoted by /fetch-processing backend cross-check) → markFailed; Confirm-OTP click throw escalates to waiting_to_review because OTP may have submitted server-side; (3) OTP cadence — Phase 1 poll /bot/otp every 10s for SMS while the email-request button stays disabled (180s cap), Phase 2 click email button + re-scrape rotated reference code + poll every 10s for email OTP (180s cap), final fallback direct Gmail IMAP; (4) preSubmitIds snapshot + poll-until-N-ids on the TRANSFER-id scrape guards against the stale-sidebar-id bug that caused the 2026-04-16 4192118234 duplicate-TRANSFER incident; (5) clearStaleRecipients pre-batch aborts the whole batch into waiting_to_review if cleanup fails, because adding new recipients to a page with stale ones triggers an IBFT merge and all items collapse onto one TRANSFER id.

Drifts flagged in Implementation pointers (not queued for W4 this pass; ratification thread #18 asks for the W4 decision): [DRIFT-checker-vestigial] banks/scb/checker.js + SCBModule.checkerFlow are exported but app.js never invokes them at HEAD 466d56e — CLAUDE.md's "maker → approver → checker" is stale wording; [DRIFT-sse-unused] core/sse.js exists but sseClient is never instantiated, so intake is poll-only at POLL_INTERVAL (already documented as current-system.md §8 DRIFT-1).

Claim strength S4, [RATIFICATION_PENDING:18]. W8 root trace 98325f58-bb96-4823-9883-c236026991fc. Bot-first pass — no mobiz counterpart names this exact slug; closest sibling is mobiz-payment-gateway/docs/flows/withdrawal-queue-dispatch-and-claim.md (S2-ratified, W8 trace 383d3a2d-5a90-4581-8dec-354c7b8318b3) which documents the gateway-internal view of claim/set-txn-id/fetch-processing/terminal-call crossings.

Recovery note: original arra_learn call on 2026-04-19 wrote project field as `github.com/kokarat/bank-bot<` (stray `<` character — likely a shell-redirect typo or copy-paste artifact). The path-corrupted file lives at `mb_agent_oracle_memory/github.com/kokarat/bank-bot</ψ/memory/learnings/2026-04-19_flow-scb-dual-control-withdrawal-intent-at-a-g.md`. Per P-001 the original is preserved at the bad path; this entry is the corrected re-file. Use this ID for ratification thread #18.

---
*Added via Oracle Learn*
