---
title: Redis TLS is now opt-in via `REDIS_TLS=true` env flag (`db/redis.go:131-136@f2f7
tags: [technical-writer, repo:mobiz-payment-gateway, current, redis, config, stack]
created: 2026-04-22
source: db/redis.go:131-136@f2f7e26
project: github.com/kokarat/mobiz-payment-gateway
---

# Redis TLS is now opt-in via `REDIS_TLS=true` env flag (`db/redis.go:131-136@f2f7

Redis TLS is now opt-in via `REDIS_TLS=true` env flag (`db/redis.go:131-136@f2f7e26`, PR #264, 2026-04-22). Prior code unconditionally wrapped the client in `tls.Config{InsecureSkipVerify: true}`, which timed out against plain `redis:7-alpine` used by docker-compose integration tests ("context deadline exceeded" on every SET/GET). Observable regression: `test-deposit-idempotency.sh` — with Redis unreachable, `CheckIdempotencyKey` treated every lookup as a cache miss, so the second request with the same idempotency key created a duplicate deposit with a different txnId, breaking the idempotency contract. The chosen opt-in direction (default plain; prod sets `REDIS_TLS=true`) makes prod mis-config fail loud at startup instead of silently downgrading security, and matches the norm that local/CI Redis runs plaintext. Pairs with `21cd87f` PR #268 which sets `REDIS_TLS=true` on `k8s/deployment.yaml` for DO App Platform.

---
*Added via Oracle Learn*
