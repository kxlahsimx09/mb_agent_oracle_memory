---
title: PartnerController.GetRevenueByClient: source switched mdr_shared → raw ts_* + ne
tags: [technical-writer, repo:mobiz-payment-gateway, current, partner, mdr, revenue, analytics]
created: 2026-05-07
source: controllers/PartnerController.go:1473-1929@c293ab7
project: github.com/kokarat/mobiz-payment-gateway
---

# PartnerController.GetRevenueByClient: source switched mdr_shared → raw ts_* + ne

PartnerController.GetRevenueByClient: source switched mdr_shared → raw ts_* + new commission column from mdr_shared (246ab4b #413 + c293ab7 #415, 2026-05-06/07).

Two-step rewrite of the partner-revenue endpoint added at baseline 6e10032 (#408).

Step 1 (246ab4b #413) — volume source switched. Original aggregation summed `mdr_shared.share_amount` (the partner's CALCULATED earnings) and called the column `total_share`. Per partner feedback, the response now reports the actual gross transaction volume per client per type, drawn from THREE separate aggregations against the raw ts_* collections, merged in Go:
- ts_deposits: status="paid", filtered to mdr_profile_id IN partner.mdr_profile_ids, date in range
- ts_topups:   status=1 (approved), same profile/date filter
- ts_payouts:  status="completed", same profile/date filter

`settlement` was dropped from the type filter — settlements are partner-side payouts, not "revenue from a client".  Field renames: total_share → total_amount, share → amount, base → (dropped). Empty mdr_profile_ids short-circuits to empty summary cleanly.

Step 2 (c293ab7 #415) — commission column. A 4th aggregation runs against mdr_shared (status:1 = excludes cancelled), $unwind distributions[], filters distributions.partner_id == partner_id, sums share_amount per client_id. That sum is the row's `commission`. Reading the wallet-credit source of truth (rather than recomputing amount × percentage) keeps commission honest if profile percentages change mid-period or a distribution gets cancelled. Edge case: clients with non-zero commission but no matching tx volume in the window still surface as their own row.

Each row also carries the source profile name + per-type fees so the FE can label which profile the volume came from. Top-level summary now: total_clients / total_amount / total_transactions / total_commission / by_type.

No new index needed: ts_*.{mdr_profile_id, status, created_date_bkk} already covers the lookup. Per-collection $match is index-eligible and scoped to a small partner subset.

Identity gate (JWT-only via user_type=="partner") + 1-year date cap + permission gate (partner-revenue:view via idempotent migration script `scripts/add_partner_revenue_permission.go`) all unchanged from baseline.

---
*Added via Oracle Learn*
