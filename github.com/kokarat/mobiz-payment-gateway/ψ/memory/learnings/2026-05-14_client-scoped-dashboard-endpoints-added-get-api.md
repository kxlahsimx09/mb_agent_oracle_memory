---
title: Client-scoped dashboard endpoints added: `GET /api/v1/client/dashboard/stats` an
tags: [technical-writer, repo:mobiz-payment-gateway, current, dashboard, api-surface, client-scope, rbac, tenant-guard]
created: 2026-05-14
source: routes/dashboard.go:33-49@c8588a1, controllers/DashboardController.go:1316-1379@c8588a1
project: github.com/kokarat/mobiz-payment-gateway
---

# Client-scoped dashboard endpoints added: `GET /api/v1/client/dashboard/stats` an

Client-scoped dashboard endpoints added: `GET /api/v1/client/dashboard/stats` and `GET /api/v1/client/dashboard/charts` (`c8588a1` #433, 2026-05-13). Same payload as the admin `/api/v1/dashboard/*` routes, but the new handler `requireClientUserAndScopeQuery` (a) rejects callers whose JWT `user_type != "client"` with 403, (b) returns 400 on a malformed `user_id` ObjectID, then (c) **overwrites the `clientIds` query arg in the underlying fasthttp request** with the JWT's own `user_id` before delegating to `GetDashboardStats` / `GetChartData`. Crucially, the route group has **no `RequirePermission` gate** — JWT verification + the in-handler `user_type=="client"` assertion is the gate. The rationale (in route file comment): the seeded `client` role intentionally does NOT carry `dashboard:view`, because granting it would also unlock the admin `/api/v1/dashboard/*` endpoints (which accept arbitrary `clientIds` and would let one client see another client's aggregates). Sibling-pattern of `/api/v1/partner/auth/revenue/by-client` (PartnerController `6e10032` #408) which uses the same JWT-only identity gate to prevent cross-tenant enumeration.

---
*Added via Oracle Learn*
