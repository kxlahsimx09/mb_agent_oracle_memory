---
title: drift — topup flow (a1) DashboardController MDROwner field comment contradicts c
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow:topup-approve-mdr-distribution, dashboard, mdr, wallet]
created: 2026-04-18
source: controllers/DashboardController.go:37,461-489@252849e
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — topup flow (a1) DashboardController MDROwner field comment contradicts c

drift — topup flow (a1) DashboardController MDROwner field comment contradicts code.

`controllers/DashboardController.go:37@252849e` declares:
```
MDROwner  float64 `json:"mdrOwner"`  // MDR Owner (total_fee - total_distributed)
```

But the actual computation at `:461-489@252849e` calculates `MDROwner` as the owner's partner share from `mdr_shared.distributions[]` (looked up via wallet with `is_owner=true`), NOT as `total_fee - total_distributed`. Comment at `:487-488` is correct: "distributions[] contains the owner as one of the partners, so the raw total_distributed double-counts owner."

**Impact:** documentation drift. A new dev reading the field comment would assume residual/gap detection; actual semantics require owner to be explicitly configured as a partner entry in each MDR profile.

**Recommended fix:** update the field comment to match code — e.g., `// MDR Owner (owner's share from distributions[] where wallets.is_owner=true)`. Alternatively rename the field if the original intent was genuinely "residual" and the implementation drifted.

Ratified via Oracle thread #11 (2026-04-18 GMT+7) during W8 flow topup-approve-mdr-distribution. Queued for W4 pickup.

---
*Added via Oracle Learn*
