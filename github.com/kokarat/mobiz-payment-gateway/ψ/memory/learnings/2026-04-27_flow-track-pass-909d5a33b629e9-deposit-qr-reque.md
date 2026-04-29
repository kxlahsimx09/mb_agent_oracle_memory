---
title: flow-track pass 909d5a3..3b629e9: deposit-qr-request.md pointer refresh
tags: [flow-track, pointer-refresh, deposit-qr-request, BotConfigController, transactionMatcher]
created: 2026-04-27
source: #flow-track W9 pass 909d5a3..3b629e9
project: github.com/kokarat/mobiz-payment-gateway
---

# flow-track pass 909d5a3..3b629e9: deposit-qr-request.md pointer refresh

flow-track pass 909d5a3..3b629e9: deposit-qr-request.md pointer refresh

Two file shifts applied:
1. BotConfigController.go +38 (commit 2c611cc: Pullout DestCap added ~38 lines)
   - @ed45b7e → @2c611cc; :496 → :534, :635 → :673
2. transactionMatcher.go shift boundary at line 586 (commit b31866f: transaction_date from statement)
   - Lines < 586: class A (hash bump only, @ed45b7e → @b31866f)
   - Lines ≥ 587: class B (+16, @ed45b7e → @b31866f)
   - :627-660 → :643-676 (wallet credit, +16)
   - :664-666 → :680-682, :717 → :733 (MDR distribution, +16)
   - :684-701 → :700-717 (callback/SSE, +16)

---
*Added via Oracle Learn*
