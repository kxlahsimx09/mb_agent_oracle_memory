---
title: mobiz #492 (a011daf, 2026-05-28) adds a custom Fiber ErrorHandler + AWS region d
tags: [technical-writer, repo:mobiz-payment-gateway, current, bot-ops, cors]
created: 2026-05-27
source: docs/current-system.md §1,§6.7 @a011daf
project: github.com/kokarat/mobiz-payment-gateway
---

# mobiz #492 (a011daf, 2026-05-28) adds a custom Fiber ErrorHandler + AWS region d

mobiz #492 (a011daf, 2026-05-28) adds a custom Fiber ErrorHandler + AWS region default change. (1) CORS-on-error: Fiber's default ErrorHandler bypasses the app.Use(cors.New(...)) middleware, so 5xx responses reached browsers as "blocked by CORS policy" instead of the real error (this was the surface symptom behind the AWS Restart-Bot "Failed to fetch" diagnosis). main.go now sets a custom ErrorHandler in fiber.Config that re-attaches Access-Control-Allow-Origin using the same allowlist logic as the CORS middleware (echo request Origin when in CORS_ORIGINS, adding Vary: Origin + Access-Control-Allow-Credentials: true; "*" only when the allowlist itself is "*") and renders errors as {success:false, message:<err.Error()>} JSON at the underlying *fiber.Error status code (else 500). So ALL error responses now carry a structured JSON body + CORS headers. (2) services/botOpsService.go AWS_REGION fallback default changed ap-southeast-1 → ap-southeast-7 (Bangkok, where the AWS bank-bots run). (3) k8s/base/deployment.yaml + envs/{ampay,goodpay,maxpayplus}/{secrets,configmap}.yaml add AWS_ACCESS_KEY_ID/SECRET/REGION (all optional:true) — devops territory, out of §scope. Context: #492 re-lands a commit (823828a) dropped by the #491 squash-merge and extends the AWS creds to goodpay + maxpayplus. Documented at current-system.md §1 (global middleware chain, CORS item) + §6.7 botOpsService.go region.

---
*Added via Oracle Learn*
