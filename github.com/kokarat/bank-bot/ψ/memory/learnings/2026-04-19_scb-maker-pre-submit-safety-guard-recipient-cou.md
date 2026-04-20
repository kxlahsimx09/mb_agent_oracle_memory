---
title: SCB maker — pre-submit safety guard (recipient count + amount match) is the mini
tags: [technical-writer, repo:bank-bot, current, scb, maker, safety, ibft-merge, pre-submit-guard, waiting_to_review]
created: 2026-04-19
source: banks/scb/maker.js:357-405@0ea0e80 (PR #77 / 8f68dae, 2026-04-19)
project: github.com/kokarat/bank-bot
---

# SCB maker — pre-submit safety guard (recipient count + amount match) is the mini

SCB maker — pre-submit safety guard (recipient count + amount match) is the minimal surviving form of the 2026-04-19 IBFT-merge iteration. The maker's per-job loop already adds exactly one recipient per call and relies on dispatcher to cap batch at 1, but SCB's transfer page will silently merge a stale recipient into the current submit if the page state carries over from a failed previous batch. Before clicking Submit, makerFlow re-reads `ผู้รับเงินที่เลือก (N)` and the single amount on the recipients table. If N>1 or the parsed `[\d,]+\.\d{2} บาท` value differs from `jobs[0].amount` by more than 0.01 (or multiple amounts are parsed), the whole batch is aborted as `waiting_to_review` — Submit is never clicked, so SCB has no record of the attempt and admin can reconcile safely. Four earlier same-day commits tried post-submit navigation fixes (navigate to dashboard, click ทำรายการอื่น, broader clearStaleRecipients fallbacks) and were reverted in 8f68dae after they broke recipient adding; the pre-submit block is the only piece that survived because it adds a hard stop without changing the happy path. Key strength: guard runs after DRY_RUN short-circuit, so dry runs are unaffected.

---
*Added via Oracle Learn*
