---
title: Admin read API for client_request_logs added (7909917 #472; GitHub squash bundle
tags: [technical-writer, repo:mobiz-payment-gateway, current, api-surface, client-request-logs, admin, rbac, observability]
created: 2026-05-23
source: controllers/ClientRequestLogController.go:37-282@7909917, routes/clientRequestLog.go:17-31@7909917, main.go:427@7909917
project: github.com/kokarat/mobiz-payment-gateway
---

# Admin read API for client_request_logs added (7909917 #472; GitHub squash bundle

Admin read API for client_request_logs added (7909917 #472; GitHub squash bundled PR #471's content into this commit — the standalone #471 commit b7040eb is file-empty). Two endpoints: GET /api/v1/client-request-logs (paginated list, default sort created_at DESC, filters request_type[deposit|payout]/action[create|cancel]/status[success|rejected]/status_code/client_id/client_username/search[regex $or over error_message+request_body]/start_date+end_date[YYYYMMDD on created_date_bkk]) and GET /api/v1/client-request-logs/reject-stats (aggregate grouped by (request_type, status_code, error_message): count, first_at, last_at, up to 5 distinct sample_usernames, sample_request_id/sample_body/sample_ip; sorted count DESC, cap 200 groups; defaults status=rejected, ?include_success=1 for full). Both gated JWTAuthMiddleware + RequirePermission(PermView("client-request-log")) and read the replica (db.GetReadCollection) — seed a "client-request-log" resource via the role API to grant view (follows the /otp-logs PermView pattern, no new RBAC scaffolding). The client_request_logs collection is populated async by helpers.LogClientRequest on every client-facing /deposit/create + /payout/create + cancel, INCLUDING rejects, so this surface backs the BO request-log timeline and a reject dashboard (before it, "why are N create calls returning 400 in the last 30m" required poking MongoDB directly). Documented in current-system.md §3.2.

---
*Added via Oracle Learn*
