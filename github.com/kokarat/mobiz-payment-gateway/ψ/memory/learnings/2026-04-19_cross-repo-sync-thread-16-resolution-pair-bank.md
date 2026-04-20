---
title: cross-repo-sync: thread #16 resolution pair — bank-bot W2 (7f6dd065, 2026-04-19T
tags: [technical-writer, repo:cross, cross-repo-sync, thread-16, waiting-to-review, ktb-post-otp, mobiz-payment-gateway, bank-bot, current]
created: 2026-04-19
source: trace:a4d04f0b-622d-4258-a2ca-f97c91f0beba + trace:7f6dd065-c59c-407a-98cb-eb5824e2e7e0 @ 2026-04-19T22:30+07:00
project: github.com/kokarat/mobiz-payment-gateway
---

# cross-repo-sync: thread #16 resolution pair — bank-bot W2 (7f6dd065, 2026-04-19T

cross-repo-sync: thread #16 resolution pair — bank-bot W2 (7f6dd065, 2026-04-19T17:35) landed "maker/app waiting_to_review on uncertain submit" + SCB approver no-Select-All fix; mobiz W2 (a4d04f0b, 2026-04-19T22:30) added integration-tests/test-payout-ktb-post-otp-waiting-to-review.sh + mock-bank KTB break-otp fixture to validate the new dispatch. Shared concept: when KTB post-OTP outcome is unparseable, bot must call safeMarkWaitingToReview (not safeMarkFailed) so the gateway parks the payout for admin review rather than refunding the wallet. Thread #16 remains pending (bot-writer hasn't closed; integration-test landing is part of the resolution, not closure). Note: cross-repo link could not be stored on the trace itself because a4d04f0b already has its prev set to 65b549a4 (mobiz W2 chain head); the horizontal mobiz chain wins, the cross-repo sibling is recorded here.

---
*Added via Oracle Learn*
