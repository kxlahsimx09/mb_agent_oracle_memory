---
title: W9 flow-track pass 3b629e9..5ce4596: deposit-auto-match-from-statement.md — 4 Cl
tags: [flow-track, deposit, bank-statement, W9, pointer-relocation]
created: 2026-04-27
source: W9 pass 3b629e9..5ce4596
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 flow-track pass 3b629e9..5ce4596: deposit-auto-match-from-statement.md — 4 Cl

W9 flow-track pass 3b629e9..5ce4596: deposit-auto-match-from-statement.md — 4 Class B pointer relocations, all in BotConfigController.go (+12 line shift from UpdateBankBalance expansion in 5ce4596). Affected steps: Step 3 (SaveBankStatements func header 532→544), Step 4 (dedup+insert loop 567→579, goroutine kick 671→683), Step 5 (SaveBankStatements entry 544→556). Pre-existing pointer bug noted on Step 5: description says "early HTTP response" but line 556 is `}` closing BodyParser check — predates current range baseline, deferred to W4. #flow-track

---
*Added via Oracle Learn*
