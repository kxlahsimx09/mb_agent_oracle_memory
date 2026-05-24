---
title: W9 OVER-THRESHOLD ESCALATION (2026-05-24, range 9aebabb..02ea1f6). The range aff
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, deferral, w9-over-threshold, pointer-staleness-backlog, escalation]
created: 2026-05-23
source: docs/flows/.baseline (stays 9aebabb); W9 trace 97597640-9131-4c7d-9eea-b83edc13c337
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 OVER-THRESHOLD ESCALATION (2026-05-24, range 9aebabb..02ea1f6). The range aff

W9 OVER-THRESHOLD ESCALATION (2026-05-24, range 9aebabb..02ea1f6). The range affects 9 flow docs, well over the 5-flow fast-fix cap, so the pass SPLIT: fast-fixed only topup-approve-mdr-distribution (clean +36) and DEFERRED 8 flows. flows-baseline NOT bumped — stays 9aebabb for the SECOND consecutive pass (prior W9 trace 7c72c093 also did not bump it). This is a compounding flow-pointer-staleness backlog that needs a dedicated split or W8-coordinated catch-up campaign. Two deferral categories: (A) PRE-EXISTING ARCHAEOLOGY — pointers pinned to commits OLDER than the baseline with multiple unrefreshed intervening commits, so they are not a clean line-shift: PayoutController.go pointers @d2a2738 in payout-admin-cancel / payout-confirm-completed / payout-request drifted across #404 (cancel reason+audit, touches CancelPayout region), #395, 2caec4c, #372; transactionMatcher.go pointers @44f8634 in deposit-auto-match-from-statement / deposit-qr-request / payout-auto-reconcile-from-statement drifted across #384 (which REWROTE linkCheckingDeposit), #372, #375; my #476 (PayoutController) and #477 (transactionMatcher) add one more shift on top. (B) PRIOR-PASS DEFERRALS still outstanding: callbackService.go @f16d602/@153a4f6 (deposit-auto-expire-pending, payout-auto-cancel-pending-timeout, + callbackService bits in matcher/payout flows) and main.go @2f35356 — the "5 callbackService-cosmetic flows + main.go Class-A from #461 brand-env" the prior W9 named. Recommended fix: a focused W9 split campaign that re-derives the PayoutController + transactionMatcher pointers against current HEAD (not a blind +N shift — symbols moved), processes ≤5 flows per pass, and bumps the baseline incrementally. No [DRIFT] markers added to the deferred flows (this is stale-pointer/line-relocation backlog, not Class-C semantic drift).

---
*Added via Oracle Learn*
