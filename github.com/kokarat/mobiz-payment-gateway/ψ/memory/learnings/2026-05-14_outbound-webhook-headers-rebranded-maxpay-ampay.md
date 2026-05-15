---
title: Outbound webhook headers rebranded MAXPAY → Ampay (`4ea0de2` #320, 2026-05-14) w
tags: [technical-writer, repo:mobiz-payment-gateway, current, callback, headers, ampay-rebrand, cloudflare-evasion]
created: 2026-05-14
source: services/callbackService.go:62-103@4ea0de2
project: github.com/kokarat/mobiz-payment-gateway
---

# Outbound webhook headers rebranded MAXPAY → Ampay (`4ea0de2` #320, 2026-05-14) w

Outbound webhook headers rebranded MAXPAY → Ampay (`4ea0de2` #320, 2026-05-14) with a deliberate browser-like negotiation block to evade Cloudflare bot-detection. `User-Agent` is now hybrid: `Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 Ampay-Webhook/1.0` — real Chrome prefix + `Ampay-Webhook/1.0` suffix so clients can still substring-filter. New `Accept`, `Accept-Encoding`, `Accept-Language`, `Connection: keep-alive` headers populated by a single `buildCallbackHeaders()` helper that is also persisted into `callback_logs.request_headers` so the audit trail matches the wire. `X-Webhook-Source: ampay-gateway`, `X-Webhook-Version: 1.0`. Motivation per file comment: the 2026-05-13 30 s-timeout incident showed 96% of failed callbacks hit Cloudflare-protected hosts where the only differentiator vs. a normal browser was the UA and the missing Accept-* block. Payload shape unchanged; clients filtering inbound by `User-Agent` need to allowlist the new value.

---
*Added via Oracle Learn*
