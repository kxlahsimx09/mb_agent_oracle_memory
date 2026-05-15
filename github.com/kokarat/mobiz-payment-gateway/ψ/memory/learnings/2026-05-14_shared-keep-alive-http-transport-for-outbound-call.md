---
title: Shared keep-alive HTTP transport for outbound callbacks (`842241d` #435, 2026-05
tags: [technical-writer, repo:mobiz-payment-gateway, current, callback, http-transport, cloudflare-evasion]
created: 2026-05-14
source: services/callbackService.go:31-41,138-178,205-212@842241d
project: github.com/kokarat/mobiz-payment-gateway
---

# Shared keep-alive HTTP transport for outbound callbacks (`842241d` #435, 2026-05

Shared keep-alive HTTP transport for outbound callbacks (`842241d` #435, 2026-05-14). A single package-level `callbackTransport` (`http.Transport`) is reused across every `CallbackService` instance: `MaxIdleConns=200`, `MaxIdleConnsPerHost=20` (default Go is 2 — which means a TCP/TLS handshake every send when more than 2 callbacks go to the same host), `MaxConnsPerHost=50` (auto-throttle and bounds goroutine fan-out if a host goes slow), `IdleConnTimeout=90s`, `ForceAttemptHTTP2=true`. Connection pool is process-wide, not per-call. Companion change: `retryBatchLimit` lowered 100 → 20 per collection per tick — a 100-deep concurrent outbound burst contributed to the Cloudflare bot-traffic pattern; 20/min still drains a 1,000-row backlog within an hour (50 ticks × 20 = 1,000). Both changes target the same root cause: at peak we sent 400+ callbacks/hour to single hosts (e.g. `dpay.medusa-gr.pro`) as a fast-handshake burst that fronting CDNs flagged.

---
*Added via Oracle Learn*
