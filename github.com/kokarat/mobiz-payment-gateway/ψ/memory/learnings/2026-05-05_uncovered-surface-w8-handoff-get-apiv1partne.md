---
title: Uncovered surface (W8 handoff): GET /api/v1/partner/auth/revenue/by-client (comm
tags: [technical-writer, repo:mobiz-payment-gateway, current, w8-handoff, uncovered-surface, flow:partner-revenue-self-service-analytics-proposed, partner, mdr]
created: 2026-05-05
source: controllers/PartnerController.go:1481-1691@6e10032, routes/partner.go:24-32@6e10032
project: github.com/kokarat/mobiz-payment-gateway
---

# Uncovered surface (W8 handoff): GET /api/v1/partner/auth/revenue/by-client (comm

Uncovered surface (W8 handoff): GET /api/v1/partner/auth/revenue/by-client (commit 6e10032 #408, 2026-05-06). New partner-only self-service MDR revenue analytics endpoint — no docs/flows/*.md doc currently covers it. Not a class-D step-within-flow because it sits outside any existing flow's pointer territory.

Whether this warrants a dedicated flow doc is a W8 author judgment call, NOT a W9 mechanical decision. Arguments for a flow doc: (a) actor-crossing exists (partner JWT → mobiz aggregation → mdr_shared read replica → response); (b) defense-in-depth identity gate is non-trivial (handler ignores caller-supplied partner_id, uses JWT user_type+user_id only); (c) permission-migration-not-seed-file pattern is the kind of nuance flow docs usually capture better than current-system.md. Arguments against: (a) it is purely read-only — no state mutation, no callback, no SSE event, no bot hop; (b) existing flow portfolio is dominated by state-changing flows (payout/deposit/topup/settlement); (c) the §3.2 partner row in current-system.md (updated by today's W2) already captures the same security/aggregation/permission notes.

Recommendation: skip the flow doc unless future requirements add cross-actor or async behavior (e.g., scheduled revenue digest emails, webhook-based revenue notifications) that would naturally pull this into flow territory.

Source: routes/partner.go:24-32@6e10032, controllers/PartnerController.go:1481-1691@6e10032, scripts/add_partner_revenue_permission.go:1-120@6e10032.

---
*Added via Oracle Learn*
