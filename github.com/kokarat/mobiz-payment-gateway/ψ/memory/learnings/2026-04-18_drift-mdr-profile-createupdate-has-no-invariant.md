---
title: drift — MDR profile create/update has no invariant check on Σ partners percentag
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, followup, flow:topup-approve-mdr-distribution, mdr, invariant, validation]
created: 2026-04-18
source: controllers/MDRProfileController.go@252849e (no invariant check site), models/mdr_profile.go:15-27@252849e
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — MDR profile create/update has no invariant check on Σ partners percentag

drift — MDR profile create/update has no invariant check on Σ partners percentage vs profile fee.

When admins configure an MDR profile with e.g. `TopupFee = 1.5%` and partners `[P1: 0.5%, P2: 0.5%]` (sum = 1.0%), nothing in the MDR profile CRUD code warns that 0.5% of residual will leak into the system bank account as an unrecorded book entry. The "owner-as-partner" design (owner's wallet has `is_owner=true`, owner must be listed in `mdr_profile.partners[]` with the residual percentage) is an **operational contract** — not enforced in code.

**Impact:** silent accounting gap. Admin reconfigures MDR partners, forgets to update owner's percentage, residual disappears. Only visible on Dashboard by computing `MDRAmount - MDROwner - MDRPartner` manually.

**Recommended fix:** add a soft warning (or hard validation if risk tolerance is low) in MDR profile create/update controllers (`controllers/MDRProfileController.go`) that checks `Σ partners[].TopupPercentage == profile.TopupFee` (and same for Deposit/Payout/Settlement). Warning: log + return payload flag. Hard: reject with 400 if sum ≠ profile fee.

Ratified via Oracle thread #11 (2026-04-18 GMT+7) during W8 flow topup-approve-mdr-distribution. Queued for W4 pickup.

---
*Added via Oracle Learn*
