---
title: pattern — bot reserves "failed" for cases where it is 100% certain no transfer l
tags: [technical-writer, repo:bank-bot, current, scb, maker, safety, waiting_to_review, wallet-refund]
created: 2026-04-19
source: banks/scb/maker.js:657-690@6ebee00, app.js:485-493@6ebee00 (PR #82 / dd5966b + 9525cff + 6ebee00)
project: github.com/kokarat/bank-bot
---

# pattern — bot reserves "failed" for cases where it is 100% certain no transfer l

pattern — bot reserves "failed" for cases where it is 100% certain no transfer left the browser.

Before 2026-04-19 the SCB maker/app.js would mark a payout "failed" in three paths where the submit had actually reached SCB: (1) Skip-to-review or Submit timed out AND cleanup reported clean (clearStaleRecipients can report count=0 while the recipients are still staged — false-clean), (2) Submit succeeded but the TRANSFER ID scrape path timed out (`'Maker completed without transaction ID (partial scrape)'`), (3) the app.js maker-loop branch where `makerFlow` returned `status:'success'` with no `bankTransactionId`.

PR #82 (commits dd5966b + 9525cff + 6ebee00) switched all three to `waiting_to_review`. Cleanup is still attempted best-effort after the demotion (to prepare the transfer page for the next batch), but its outcome no longer gates the demotion target — everything past the Submit click is `waiting_to_review`.

The design rule: `failed` on the bot side triggers a wallet refund in mobiz. Issuing a wallet refund for a transfer that SCB actually processed = double-pay. `waiting_to_review` holds the item in that state until admin verifies against bank statement and either marks success or uses the mobiz admin-cancel-payout endpoint (#228) to issue the refund deliberately. Only paths that are unambiguous-did-not-reach-SCB — e.g. `addRecipient` failing before Submit, or the pre-submit safety guard firing (§3.1.3) — still mark `failed` directly.

Error messages to grep for: `'needs manual verification'`, `'Maker submitted but no transaction ID scraped'`.

---
*Added via Oracle Learn*
