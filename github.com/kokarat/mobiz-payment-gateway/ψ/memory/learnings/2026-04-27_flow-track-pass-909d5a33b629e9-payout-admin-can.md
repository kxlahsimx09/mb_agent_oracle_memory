---
title: flow-track pass 909d5a3..3b629e9: payout-admin-cancel.md pointer refresh
tags: [flow-track, pointer-refresh, payout-admin-cancel, PayoutController]
created: 2026-04-27
source: #flow-track W9 pass 909d5a3..3b629e9
project: github.com/kokarat/mobiz-payment-gateway
---

# flow-track pass 909d5a3..3b629e9: payout-admin-cancel.md pointer refresh

flow-track pass 909d5a3..3b629e9: payout-admin-cancel.md pointer refresh

All 16 PayoutController.go pointers shifted +38 lines (commit 41744fe inserted withdrawal_queue sync block).
Hash: @b164e3d → @41744fe across all entries.

Representative shifts:
- :961-991 → :999-1029 (guard + status check)
- :1043-1061 → :1081-1099 (wallet deduct)
- :1086-1106 → :1124-1144 (MDR distribution)
- :1116-1119 → :1154-1157 (callback)

---
*Added via Oracle Learn*
