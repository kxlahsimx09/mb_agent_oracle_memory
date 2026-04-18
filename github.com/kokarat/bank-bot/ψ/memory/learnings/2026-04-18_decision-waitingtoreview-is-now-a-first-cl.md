---
title: # decision — `waiting_to_review` is now a first-class terminal state for queue i
tags: [technical-writer, repo:bank-bot, current, scb, ktb, decision, queue, safety, waiting-to-review]
created: 2026-04-18
source: W1 baseline @ 7d4b50e (PR #60, commit 0789b4b)
project: github.com/kokarat/bank-bot
---

# # decision — `waiting_to_review` is now a first-class terminal state for queue i

# decision — `waiting_to_review` is now a first-class terminal state for queue items

**Tags**: technical-writer, repo:bank-bot, current, scb, ktb, decision, queue, safety

**What changed**: Queue items now have three terminal states — `success`, `failed`, and `waiting_to_review`. The third is reserved for post-OTP ambiguity: cases where the bot cannot safely assert success or failure because the bank side may have already debited. Dispatcher MUST NOT retry `waiting_to_review` items automatically — they need human triage.

**Why it matters**:
- Retrying a `failed` item is safe. Retrying a post-OTP-timeout item is NOT safe — funds may already have moved.
- Without a third state, the bot was forced to choose between false `success` (risk of double-credit bookkeeping) and false `failed` (risk of double-transfer on retry). Neither is acceptable.
- Represents a safety-over-throughput tradeoff: some items will sit in review indefinitely until a human clears them.

**Where it lives**:
- Backend endpoint: `PUT /api/v1/bot/queue/:id/waiting-to-review` (takes `{ reason }`)
- Bot wrapper: `core/api.js:markWaitingToReview(itemId, reason)` (L86-90 @ 7d4b50e)
- App-level wrapper with safeMarkFailed-style fallback: `app.js:safeMarkWaitingToReview()` (L336-351 @ 7d4b50e) — falls back to `markFailed` on endpoint error so items don't get stuck in processing
- Triggered in three surfaces: SCB maker (pre-batch recipient contamination), SCB approver (post-OTP ambiguity — three distinct paths), KTB transfer (post-OTP confirm failure via `KTB_POST_OTP` sentinel)

**How to apply**: When writing or reviewing bot flows, any operation that happens *after* OTP submission MUST consider `waiting_to_review` as a possible outcome, not fall through to `markFailed`. Same rule applies to any operation where partial bank-side state is possible (recipient list contamination, batch merging).

**Source**: docs/current-system.md §7 Safety + §2.4 + §3.1.3 + §3.1.4 + §3.2.3 @ commit `7d4b50e`. Opened PRs #58 (SCB) and #59 (KTB) landing between 95dbb70 and 7d4b50e.

---
*Added via Oracle Learn*
