---
title: flow-track pass 909d5a3..3b629e9: deposit-auto-match-from-statement.md pointer r
tags: [flow-track, pointer-refresh, deposit-auto-match-from-statement, BotConfigController, transactionMatcher]
created: 2026-04-27
source: #flow-track W9 pass 909d5a3..3b629e9
project: github.com/kokarat/mobiz-payment-gateway
---

# flow-track pass 909d5a3..3b629e9: deposit-auto-match-from-statement.md pointer r

flow-track pass 909d5a3..3b629e9: deposit-auto-match-from-statement.md pointer refresh

Two file shifts applied:
1. BotConfigController.go +38 (commit 2c611cc); @37dfb26 → @2c611cc
   - :494-509 → :532-547 (statement parse entry)
   - :529-632 → :567-670 (dedup+insert block)
   - :633-636 → :671-674 (async kick)
   - :506 → :544, :641-645 → :679-683
2. transactionMatcher.go +16 for lines ≥ 587 (commit b31866f); @37dfb26 → @b31866f
   - Lines < 586 class A: :58-81, :95-133, :24-33, :1066-1120 → :1082-1136
   - Lines ≥ 587 class B: :582-714 → :582-730 (finalizeDeposit expanded)
     :592-619 → :608-635, :622-661 → :638-677, :664-666 → :680-682
     :717-832 → :733-848, :669-675 → :685-691, :704-711 → :720-727
   - :684-701 → :700-717 (callback/SSE)

---
*Added via Oracle Learn*
