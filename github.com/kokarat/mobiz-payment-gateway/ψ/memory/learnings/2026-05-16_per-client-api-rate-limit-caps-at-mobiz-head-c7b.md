---
title: Per-client API rate-limit caps at mobiz HEAD (`c7b2232` #444, 2026-05-16): depos
tags: [technical-writer, repo:mobiz-payment-gateway, current, rate-limit, deposit, payout]
created: 2026-05-16
source: controllers/DepositRequestController.go:161-167@c7b2232; controllers/PayoutRequestController.go:170-176@c7b2232
project: github.com/kokarat/mobiz-payment-gateway
---

# Per-client API rate-limit caps at mobiz HEAD (`c7b2232` #444, 2026-05-16): depos

Per-client API rate-limit caps at mobiz HEAD (`c7b2232` #444, 2026-05-16): deposit-request `1000/min` + `600,000/day`, payout-request `1000/min` + `300,000/day`. The caps are set inline in the two client-facing create handlers — `controllers/DepositRequestController.go:161-167` and `controllers/PayoutRequestController.go:170-176` — passed to `helpers.RateLimitMiddlewareCheck(clientID, scope, limits)`.

Evolution worth recording so a future reader is not misled: commit `33664cd` (#443) had briefly UNIFIED both daily caps at `300,000` (previously deposit `100,000`, payout `10,000`); `c7b2232` (#444) then split them again — the deposit daily cap was raised to `600,000` to give transaction-heavy clients headroom, and the payout per-minute cap was lifted `60` → `1000` to match deposit. Rationale for the payout per-minute change: production logs showed one client bursting ~91 payout requests in a single minute (~31 rejected with HTTP 429), while the `300,000/day` cap remained the intended effective limit — the old `60/min` could only reach ≈86k/day, making it an artificial bottleneck. The per-endpoint Redis counter scope mechanism from #443 (`ratelimit:{clientID}:{scope}:{minute|day}:{window}`) is unchanged by #444. Related learning: 2026-05-16_per-client-api-rate-limiter-helpersratelimitgo (the #443 scope fix). Documented in docs/current-system.md §7.2.

---
*Added via Oracle Learn*
