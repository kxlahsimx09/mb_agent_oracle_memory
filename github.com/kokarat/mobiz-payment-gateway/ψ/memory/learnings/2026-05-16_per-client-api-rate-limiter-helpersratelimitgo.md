---
title: Per-client API rate limiter (`helpers/ratelimit.go`) is now scoped per endpoint.
tags: [technical-writer, repo:mobiz-payment-gateway, current, rate-limit, deposit, payout]
created: 2026-05-16
source: helpers/ratelimit.go:36-242@33664cd
project: github.com/kokarat/mobiz-payment-gateway
---

# Per-client API rate limiter (`helpers/ratelimit.go`) is now scoped per endpoint.

Per-client API rate limiter (`helpers/ratelimit.go`) is now scoped per endpoint. Commit `33664cd` (#443, 2026-05-16) added a `scope` argument to `getRateLimitKeys` / `CheckClientRateLimit` / `IncrementClientRequest` / `GetClientRateLimitInfo` / `RateLimitMiddlewareCheck`, changing the Redis counter key from `ratelimit:{clientID}:{minute|day}:{window}` to `ratelimit:{clientID}:{scope}:{minute|day}:{window}`. `POST /api/v1/deposit/create` passes scope `"deposit"`, `POST /api/v1/payout/create` passes scope `"payout"` — so the two endpoints now keep independent daily/minute counters. Before the fix they shared one counter while being checked against different caps; a high-volume deposit client pushed the shared daily counter past the lower payout cap and got every payout rejected with "daily limit exceeded". The fix also unified the daily caps to 300,000 for both endpoints (previously deposit 100,000 / payout 10,000); per-minute caps unchanged (deposit 1000, payout 60). Old un-scoped keys age out on their existing 25h TTL. `ResetClientRateLimit` still works via the SCAN pattern `ratelimit:{clientID}:*` (scope sits between clientID and minute/day). This is the per-client application-level limiter called inline by the controllers — distinct from the three IP-based middleware limiters in `middlewares/rateLimiter.go` (`DISABLE_RATE_LIMIT` bypasses only those, not this one). Documented in `docs/current-system.md` §7.2.

---
*Added via Oracle Learn*
