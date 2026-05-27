---
title: drift - callback URL SSRF guard is create-time only and not strict HTTPS at HEAD
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - drift
  - callback
  - callback-url
  - ssrf
  - security
  - gist-review
created: 2026-05-25
source: helpers/security.go:110-165@16467ff, controllers/DepositRequestController.go:193-195@16467ff, controllers/PayoutRequestController.go:174-176@16467ff, services/callbackService.go:413-452@16467ff, https://gist.github.com/kxlahsimx09/ad77a5acfaf59bc8ee546c144e5c8442
project: github.com/kokarat/mobiz-payment-gateway
---

# drift - callback URL SSRF guard is create-time only and not strict HTTPS at HEAD

The 2026-05-25 next-architect gist/thread #223 proposes a strict Phase-1 callback URL safety contract: validate at create time before business-state writes, accept absolute HTTPS public URLs only, reject localhost/private/reserved/DNS-unsafe targets and unsafe ports, re-check DNS at dispatch time to resist rebinding, and keep retries/manual resends pinned to the stored per-request URL.

Current mobiz-payment-gateway at `16467ff` already has a create-time SSRF helper:

- `helpers.ValidateCallbackURL` parses the URL, accepts `http` or `https` when `requireHTTPS=false`, requires a host, resolves DNS with `net.LookupIP`, rejects unresolvable/private/reserved IPs, rejects localhost/internal host patterns, and blocks a small set of internal service ports.
- `DepositRequestController.CreateDeposit` and `PayoutRequestController.CreatePayout` both call `ValidateCallbackURL(req.CallbackURL, false)` before inserting `ts_deposits` / `ts_payouts`.
- The stored `callback_url` field is the only URL used by normal callbacks, scheduler retries, and manual resend; no code path found in this pass mutates `callback_url` after create.

Gaps against the strict thread #223 contract:

- HTTPS-only is not enforced: both create handlers pass `requireHTTPS=false`, so plain `http://` is accepted.
- Invalid callback URL responses are generic 400 messages from the helper; there is no stable `code=INVALID_CALLBACK_URL` response.
- Dispatch-time DNS re-check is absent: `CallbackService.sendCallbackWithLog` calls `http.NewRequest` and `httpClient.Do` directly against the stored URL without re-validating host resolution immediately before send. This leaves a DNS-rebinding gap because create-time lookup is not pinned and the default transport resolves again later.
- Redirect targets are not revalidated: Go's default `http.Client` follows redirects unless `CheckRedirect` overrides it, and this service does not install a redirect policy around callback delivery.
- Unsafe dispatch attempts are not classified as `callback_url_unsafe`; they are logged as normal HTTP/create-request errors in `callback_logs`.
- Port policy is deny-list based, not strict default-port/allowlist based.
- Embedded credentials are not rejected explicitly; `url.Parse` accepts userinfo and `ValidateCallbackURL` does not check `parsedURL.User`.
- `swagger_simple.json` still says deposit `callbackUrl` is "HTTPS required", which is stronger than current code because the actual deposit and payout create paths accept `http`.

Recommended follow-up if current system adopts the strict policy: add a dispatch-safe validator around `sendCallbackWithLog`, switch create handlers to HTTPS-only or document why current allows HTTP, return a stable `INVALID_CALLBACK_URL` code, add callback URL unsafe logging/dead-letter semantics, and cover create-time + dispatch-time rebinding cases in tests.
