---
title: Partner self-service revenue analytics endpoint added: GET /api/v1/partner/auth/
tags: [technical-writer, repo:mobiz-payment-gateway, current, partner, mdr, rbac, permission-migration, jwt-identity-gate, cross-partner-enumeration, read-replica]
created: 2026-05-05
source: controllers/PartnerController.go:1481-1691@6e10032, routes/partner.go:24-32@6e10032, scripts/add_partner_revenue_permission.go:1-120@6e10032
project: github.com/kokarat/mobiz-payment-gateway
---

# Partner self-service revenue analytics endpoint added: GET /api/v1/partner/auth/

Partner self-service revenue analytics endpoint added: GET /api/v1/partner/auth/revenue/by-client (commit 6e10032 #408, 2026-05-06). Aggregates mdr_shared into per-client MDR earnings broken down by transaction_type (deposit/topup/payout/settlement) with date-range + type filters.

Identity gate is JWT-only — handler reads c.Locals("user_type") (must equal "partner"; admin/client/sub-client/merchant all 403) and c.Locals("user_id") for the partner_id filter. Any caller-supplied ?partner_id=X query param is silently ignored, making cross-partner enumeration impossible by construction. Pre-unwind $match adds status: 1 so cancelled/reversed MDR rows do not inflate earnings. Date window capped at ~1 year (e - s > 10000 in YYYYMMDD form → 400). Pipeline reads from db.GetReadCollection("mdr_shared") (read replica) and targets the existing {distributions.partner_id + created_date_bkk} index.

Permission gate is a new dedicated action partner-revenue:view (NOT overloaded onto an existing partner permission). The seed file seed/roles_seed.go is intentionally NOT modified — it is insert-only/skip-on-duplicate, so editing it would be a no-op in production. Source of truth is the idempotent migration script scripts/add_partner_revenue_permission.go (build-tag–ignored), which uses $addToSet / conditional $push so it never overwrites other permissions on the partner role, then flushes Redis permissions:* + role:* + menu:* caches so live partner sessions pick up the new action without re-login.

Source: routes/partner.go:24-32@6e10032, controllers/PartnerController.go:1481-1691@6e10032, scripts/add_partner_revenue_permission.go:1-120@6e10032.

---
*Added via Oracle Learn*
