---
title: cross-repo-sync — bot "waiting_to_review" posture meets mobiz admin-cancel walle
tags: [technical-writer, repo:cross, current, cross-repo-sync, scb, waiting_to_review, wallet-refund]
created: 2026-04-19
source: W2 2026-04-20 bank-bot (0ea0e80..6ebee00) + W2 2026-04-19 mobiz (37dfb26..1ffafc1)
project: github.com/kokarat/bank-bot
---

# cross-repo-sync — bot "waiting_to_review" posture meets mobiz admin-cancel walle

cross-repo-sync — bot "waiting_to_review" posture meets mobiz admin-cancel wallet-refund endpoint.

On 2026-04-19, mobiz-payment-gateway shipped PR #228 (admin cancel payout with explicit wallet refund). Bank-bot on the same day shipped PR #82 (commits 0815737 + dd5966b + 9525cff + 6ebee00) which stopped the bot from auto-returning status "failed" for transfers whose submit outcome is uncertain (no TRANSFER ID scraped, Skip/Submit timed out, no approver match data, approver selection step threw). Those paths now return "waiting_to_review" so the wallet is NOT refunded automatically — admin must verify via bank statement and, if needed, issue the refund via the new mobiz admin-cancel endpoint.

Bot W2 trace: 7f6dd065-c59c-407a-98cb-eb5824e2e7e0 (prev 3b3ba210 in bot chain).
Mobiz W2 trace: 65b549a4-9026-4839-8082-b56229cdfc31 (admin cancel payout + wallet refund).

Shared concept: wallet refund authority boundary. Before 2026-04-19 the bot could unilaterally trigger a wallet refund by marking a payout "failed" — even when money may have been staged on the bank side. After these two passes, the bot's job is to avoid `failed` whenever outcome is uncertain, and the operator uses mobiz's admin-cancel path to issue the refund deliberately when they've confirmed against bank statement.

Note: `arra_trace_link` for sibling relationship failed here (trace 7f6dd065 already has a prev in the bot chain). This learning is the authoritative cross-repo link; next W2 on either side should be able to find it by `arra_search query="#cross-repo-sync wallet refund"`.

---
*Added via Oracle Learn*
