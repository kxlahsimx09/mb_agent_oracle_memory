---
title: KTB navigateToTransfer fast-path now requires list-view markers in addition to t
tags: [technical-writer, repo:bank-bot, current, ktb, transfer, navigate, fast-path, list-view, batch]
created: 2026-04-27
source: banks/ktb/transfer.js:215-234@b74e745
project: github.com/kokarat/bank-bot
---

# KTB navigateToTransfer fast-path now requires list-view markers in addition to t

KTB navigateToTransfer fast-path now requires list-view markers in addition to the transfer page header. The "รายละเอียดการโอนเงิน" header is rendered on both the recipient-list view (correct starting state for a new batch) and any leftover recipient-detail/review/result views from the previous batch. Trusting only the header caused openRecipientForm to run against a detail view where the plus icon and add-payee button are absent — 3 retries failed, batch aborted pre-submit. Fix (PR #106 / b74e745): if the header is visible, a Promise.race checks for .plus-icon > svg or the add-payee button (2s each); if neither is visible, falls through to the full dashboard → account card → transfer page navigation. Trade-off: ~2s extra visibility check per batch when the optimisation wins; clean ~5s re-navigation when it would have misfired. No change to the failure path — items that fail at navigateToTransfer fail before any bank call, so safeMarkFailed remains correct.

---
*Added via Oracle Learn*
