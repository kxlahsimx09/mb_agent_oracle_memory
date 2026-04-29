---
title: flow-track pass 909d5a3..3b629e9: payout-auto-reconcile-from-statement.md pointe
tags: [flow-track, pointer-refresh, payout-auto-reconcile-from-statement, BotConfigController, transactionMatcher]
created: 2026-04-27
source: #flow-track W9 pass 909d5a3..3b629e9
project: github.com/kokarat/mobiz-payment-gateway
---

# flow-track pass 909d5a3..3b629e9: payout-auto-reconcile-from-statement.md pointe

flow-track pass 909d5a3..3b629e9: payout-auto-reconcile-from-statement.md pointer refresh

Two file shifts applied:
1. BotConfigController.go +38 (commit 2c611cc); @4aaec2c → @2c611cc
   - :494-509 → :532-547, :529-632 → :567-670, :633-636 → :671-674
   - :641-645 → :679-683 (payout-reconcile kick)
2. transactionMatcher.go +16 for lines ≥ 587 (commit b31866f); @4aaec2c → @b31866f
   - matchPayout: :840-936 → :856-952
     :854-866 → :870-882, :868-903 → :884-919, :905-933 → :921-949
     FIFO block: :940-964 → :956-980
   - finalizePayout: :967-1039 → :983-1055
     :971-985 → :987-1001, :994 → :1010, :997-1027 → :1013-1043
     :1018-1024 → :1034-1040, :1030-1036 → :1046-1052
   - payoutReconciliation.go unchanged, kept @4aaec2c
   - :1299-1342 → :1315-1358 (shared fetchStatement block)
   - callback/SSE: :1012-1017 → :1028-1033

---
*Added via Oracle Learn*
