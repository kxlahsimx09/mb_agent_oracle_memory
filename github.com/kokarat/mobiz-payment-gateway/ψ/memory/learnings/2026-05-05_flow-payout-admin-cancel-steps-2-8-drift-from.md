---
title: Flow `payout-admin-cancel` Steps 2 + 8 drift from `cd48052` #404 (2026-05-05). W
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, flow-drift, flow:payout-admin-cancel, step:2, step:8, w4-queue]
created: 2026-05-05
source: docs/flows/payout-admin-cancel.md
project: github.com/kokarat/mobiz-payment-gateway
---

# Flow `payout-admin-cancel` Steps 2 + 8 drift from `cd48052` #404 (2026-05-05). W

Flow `payout-admin-cancel` Steps 2 + 8 drift from `cd48052` #404 (2026-05-05). W9 pass over `f89e235..7c8033b` flagged two flow-level drifts in `docs/flows/payout-admin-cancel.md`: (a) Step 2 pointer `controllers/PayoutController.go:999-1029@d2a2738` — body validation switched from silent `c.BodyParser` to strict (malformed JSON → 400 `Invalid JSON body`; trimmed notes < 5 chars → 400 + `code:"CANCEL_REASON_REQUIRED"`; > 500 chars truncated). §Preconditions paragraph "Parse failures are silently ignored" is factually wrong at HEAD. (b) Step 8 pointer `controllers/PayoutController.go:1124-1144@d2a2738` — wallet_change_logs row gained a `Reason: "Payout cancelled — <admin reason>"` field write + the `Note` template now embeds `| reason: <admin reason>`. Class B line shift (+21 from the validation block above) compounded with Class C structural change to the inserted row. §Postconditions line 109 carries a stale `Note` template claim. Both `[DRIFT]` markers added inline in §Implementation pointers per W9 minimal-edit discipline; prose rewrite (§Preconditions L41 + §Postconditions L106 + L109) deferred to W4 queue. Pairs with sibling W2 learning `2026-05-05_payout-admin-cancel-reason-validation-tightened.md` which captures the underlying code change. W9 trace: `4079588d-737c-4d8a-90d5-db9c2a6df46f`. No `Claim strength` downgrade (well below 50% step threshold — only 2 of 14 numbered pointer steps drifted).

---
*Added via Oracle Learn*
