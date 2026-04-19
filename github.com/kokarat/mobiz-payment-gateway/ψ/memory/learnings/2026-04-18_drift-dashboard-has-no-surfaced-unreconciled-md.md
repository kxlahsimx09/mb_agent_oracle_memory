---
title: drift — Dashboard has no surfaced "Unreconciled MDR" indicator for residual gaps
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow:topup-approve-mdr-distribution, dashboard, mdr, reconciliation]
created: 2026-04-18
source: controllers/DashboardController.go:30-50,390-489@252849e
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — Dashboard has no surfaced "Unreconciled MDR" indicator for residual gaps

drift — Dashboard has no surfaced "Unreconciled MDR" indicator for residual gaps.

`controllers/DashboardController.go:390-489@252849e` computes `MDRAmount` (Σ total_fee), `MDROwner` (owner's partner share), `MDRPartner` (total_distributed - MDROwner). If admin misconfigured an MDR profile so `Σ partners[].TopupPercentage < profile.TopupFee` (i.e. forgot to add owner as a partner, or owner's percentage is stale), the residual becomes invisible:

- `MDRAmount` = 150 (what clients were charged)
- `MDROwner` = 0 (owner never appeared in distributions[])
- `MDRPartner` = 100 (what partners actually got)
- **Unreconciled** = 50 (stays in system bank, no wallet row)

Dashboard today does NOT expose this gap. Ops must manually compute `MDRAmount - MDROwner - MDRPartner` per period to catch miscofigurations.

**Recommended fix:** add a computed field `DashboardStats.MDRUnreconciled = max(0, MDRAmount - MDROwner - MDRPartner)` and highlight in UI when > 0 (threshold configurable). Pairs with (a2) invariant check — (a2) prevents new miscofigurations, (a3) catches historical ones.

Ratified via Oracle thread #11 (2026-04-18 GMT+7) during W8 flow topup-approve-mdr-distribution. Queued for W4 pickup.

---
*Added via Oracle Learn*
