---
title: cross-repo-sync — mobiz b23a903 (#336 Pullout DestCap pre-credit + settled-unsyn
tags: [technical-writer, repo:cross, cross-repo-sync, current, pullout, destcap, bot-writer-handoff]
created: 2026-04-30
source: pg-writer W2 a8fb64e..59bc640 (PR pending)
project: github.com/kokarat/mobiz-payment-gateway
---

# cross-repo-sync — mobiz b23a903 (#336 Pullout DestCap pre-credit + settled-unsyn

cross-repo-sync — mobiz b23a903 (#336 Pullout DestCap pre-credit + settled-unsynced) modifies controllers/BotConfigController.go inside UpdateBankBalance (~lines 468-490 of pre-change file). The file is cited from three bank-bot flow docs: docs/flows/bot-bootstrap-and-status-reporting.md (cites GetBotConfig at line 119-165), docs/flows/bot-otp-relay.md (cites GetOTP at line 119-165 / 134-141 / 140-145 / 284-286), docs/flows/deposit-auto-match-from-statement.md (cites bank-statement ingest at line 494-640). The change is semantically internal to the auto-pullout-trigger inside UpdateBankBalance (adds settled-unsynced reservation alongside pending reservation in the headroom check) — none of the cited regions changed behavior. However the +8 line addition inside UpdateBankBalance shifts the deposit-auto-match citation from 494-640 down by ~8 lines. Bot-writer's next W9 pass (when bank-bot itself has commits) will detect the line-shift via grep, but per workflow-2-track-commit.md §Sibling-flow-doc citation case (no defer) the pg-writer side still files a handoff so the bot-writer doesn't have to wait on their own commit cycle. Trace pair: pg-writer W2 d525a840-17a1-4ec7-aece-f60cd3cd54c4; latest bank-bot W2 ed040637-36ba-4e67-ad2d-6dd481029235 (2026-04-28, older than 24h so no temporal sibling — handoff is the linkage instead).

---
*Added via Oracle Learn*
