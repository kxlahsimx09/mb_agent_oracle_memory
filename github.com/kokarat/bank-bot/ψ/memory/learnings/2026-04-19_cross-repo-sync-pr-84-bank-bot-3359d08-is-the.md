---
title: cross-repo-sync: PR #84 (bank-bot, 3359d08) is the bot-side partner of mobiz PR 
tags: [technical-writer, repo:bank-bot, repo:cross, repo:mobiz-payment-gateway, current, ktb, waiting-to-review, wallet-refund, cross-repo-sync]
created: 2026-04-19
source: W2 track-commit 6ebee00..b5ed22c @ 2026-04-20
project: github.com/kokarat/bank-bot
---

# cross-repo-sync: PR #84 (bank-bot, 3359d08) is the bot-side partner of mobiz PR 

cross-repo-sync: PR #84 (bank-bot, 3359d08) is the bot-side partner of mobiz PR #228 (admin-cancel-payout with wallet refund). The mobiz side added a refund-wallet endpoint triggered when a payout is marked `failed`. The bot side's invariant is now "never mark failed after the ถัดไป → ยืนยัน submit click" because marking failed would cause mobiz to refund the wallet on a transfer that KTB may have actually completed — a double-credit for the customer and a real-money loss for the operator. The contract surface is: bot queue item status transitions `pending → processing → success | waiting_to_review | failed`; `waiting_to_review` is the "uncertain, admin verify via bank statement" bucket that does NOT trigger wallet refund on mobiz side. Both halves of the invariant landed 2026-04-20 on bank-bot: SCB approver (PR #82 / 0815737) + SCB maker (PR #82 / dd5966b + 6ebee00) earlier, KTB transfer (PR #84 / 3359d08) today. CLAUDE.md safety section codified the rule ("NEVER mark failed after submit — would cause incorrect wallet refund") same day (cefddae). Sibling-link direction: mobiz pg-writer W2 65b549a4 (2026-04-19) → bank-bot W2 8c7bdad1 (2026-04-20) — both sides ratify the waiting_to_review posture at the same commit epoch. `arra_trace_link` call skipped this pass: my trace 8c7bdad1 already has prev=7f6dd065 (bank-bot W2 chain) and the single-prev invariant blocks a second prev (same failure the prior W2 hit). This learning is the authoritative cross-repo record; the bank-bot writer chain is the navigation record.

---
*Added via Oracle Learn*
