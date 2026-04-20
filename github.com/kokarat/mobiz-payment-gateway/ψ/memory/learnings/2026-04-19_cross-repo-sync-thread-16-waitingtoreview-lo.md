---
title: Cross-repo sync — thread #16 (waiting_to_review lost in bank-bot single-transfer
tags: [technical-writer, repo:cross, current, cross-repo-sync, waiting-to-review, withdrawal-queue, bank-bot, thread-16, payout, ktb]
created: 2026-04-19
source: mobiz W2 trace a0a103d2 (1ffafc1..59515bc) + bank-bot W2 traces 8c7bdad1 + 7f6dd065; Oracle thread #16
project: github.com/kokarat/mobiz-payment-gateway
---

# Cross-repo sync — thread #16 (waiting_to_review lost in bank-bot single-transfer

Cross-repo sync — thread #16 (waiting_to_review lost in bank-bot single-transfer app-layer dispatch) drove co-ordinated work across both repos on 2026-04-19. Bank-bot side: W2 trace 8c7bdad1 (19:36 UTC) covered "KTB waiting_to_review after submit" (5 commits); earlier same-day bank-bot W2 7f6dd065 (17:35 UTC) covered "SCB approver no-Select-All + maker/app waiting_to_review on uncertain submit". Mobiz side: W2 trace a0a103d2 (20:21 UTC) — the current pass — covered tester integration-tests anchoring thread #16 (forward-looking `test-payout-ktb-post-otp-waiting-to-review.sh` asserting end-state `withdrawal_queue.status=='waiting_to_review'`, wallet debited-not-refunded, `payout.status=='waiting_to_review'`; expected initial runtime = RED until bank-bot dispatcher fix lands). Shared concept: bot-layer `r.status === 'waiting_to_review'` must route to `safeMarkWaitingToReview`, not collapse to `safeMarkFailed`. Cross-repo `arra_trace_link` could not be created directly because both repos' W2 traces for this day were already chained within-repo (horizontal evolution takes precedence over sibling link in the current tool semantics); this learning is the authoritative semantic bridge.

---
*Added via Oracle Learn*
