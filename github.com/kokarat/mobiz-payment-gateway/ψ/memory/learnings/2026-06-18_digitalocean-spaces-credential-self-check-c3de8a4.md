---
title: DigitalOcean Spaces credential self-check (c3de8a4 / c777dab #553/#554, 2026-06-
tags: [technical-writer, repo:mobiz-payment-gateway, current, storage, spaces, monitoring, workflow-2]
created: 2026-06-18
source: helpers/storage.go:22-167@c3de8a4, main.go:355-376@c3de8a4
project: github.com/kokarat/mobiz-payment-gateway
---

# DigitalOcean Spaces credential self-check (c3de8a4 / c777dab #553/#554, 2026-06-

DigitalOcean Spaces credential self-check (c3de8a4 / c777dab #553/#554, 2026-06-19). helpers/storage.go: InitStorage now runs a boot-time VerifyAccess() (a lightweight HeadBucketWithContext, 5s timeout) confirming the configured key actually works against the bucket — a misconfigured/revoked key builds an S3 client fine but only fails on the first real upload. It logs a loud "[storage] CRITICAL …" (key masked to first 6 chars via maskKey) on failure, else "credential check OK". A background startHealthLoop() goroutine re-verifies every 10 min (healthCheckInterval), logging CRITICAL on failure and "… access RECOVERED" when a previously-failing key starts working; the cached {healthy,lastErr} state (sync.RWMutex) is exposed via IsHealthy() and surfaced on GET / as storage:{healthy,error} for external monitoring. Motivation: the 2026-06 maxpayplus revoked-key incident — a revoked Spaces key stayed invisible for days because slip uploads are the minority path. Fail-soft: the boot check only logs, never blocks startup or uploads. Documented current-system.md §8.3 (W2 PR #540).

---
*Added via Oracle Learn*
