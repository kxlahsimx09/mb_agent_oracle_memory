---
title: cross-repo-sync — bank-bot deposit-auto-match-from-statement.md cites `services/
tags: [technical-writer, repo:mobiz-payment-gateway, current, cross-repo-sync, matcher, deposit, linkCheckingDeposit, bot-writer-handoff]
created: 2026-05-02
source: services/transactionMatcher.go:108-130@20b6fa3 + bank-bot/docs/flows/deposit-auto-match-from-statement.md:105
project: github.com/kokarat/mobiz-payment-gateway
---

# cross-repo-sync — bank-bot deposit-auto-match-from-statement.md cites `services/

cross-repo-sync — bank-bot deposit-auto-match-from-statement.md cites `services/transactionMatcher.go:1126` (the `MatchNewStatements` entry point) as the synchronous-after-POST hook. mobiz commit `20b6fa3` (#384, 2026-05-03) inserts `linkCheckingDeposit` between `matchDepositKTB/SCB` and `linkPaidDeposit` in the matcher cascade. The actor-visible contract bank-bot's flow doc cares about (synchronous after POST → pending deposit may flip to paid within seconds) is unchanged — the new step is statement-linking only and writes no callback/wallet. However bot-writer should still review whether bank-bot's flow doc should mention the new "checking → linked but not paid" intermediate outcome for slip-uploaded deposits, so operators reading the bot-side flow understand why a statement may match but not auto-credit. Sibling flow doc path: `bank-bot/docs/flows/deposit-auto-match-from-statement.md`. Mobiz fix commit: `20b6fa3` #384. Mobiz W2 trace: `c93d0c25-e494-43fb-87bb-a039ff14cea4`. Companion handoff filed at `ψ/inbox/handoff/2026-05-03_03-30_bot-writer_matcher-link-checking-deposit-cross-repo-cite.md`.

---
*Added via Oracle Learn*
