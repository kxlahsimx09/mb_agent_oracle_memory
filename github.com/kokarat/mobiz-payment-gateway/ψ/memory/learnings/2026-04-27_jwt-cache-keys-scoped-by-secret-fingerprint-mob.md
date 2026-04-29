---
title: **JWT cache keys scoped by secret fingerprint (mobiz-payment-gateway, 2026-04-27
tags: [jwt, cache, security, redis, secret-rotation]
created: 2026-04-27
source: W2 backlog repair 2026-04-27, commit c0f9c6f #315
project: github.com/kokarat/mobiz-payment-gateway
---

# **JWT cache keys scoped by secret fingerprint (mobiz-payment-gateway, 2026-04-27

**JWT cache keys scoped by secret fingerprint (mobiz-payment-gateway, 2026-04-27)**

Commit `c0f9c6f` #315. `helpers/jwt.go` now includes a short fingerprint of `JWT_PRIVATE_KEY` in every Redis cache key for token validation and token blacklisting.

**Why it matters:** before this change, rotating `JWT_PRIVATE_KEY` (commit `b42915f` #313 rotated the secret) left stale cache entries valid — an old token could still pass the cache-hit path even after the key changed. With the fingerprint in the key, a secret rotation automatically misses the cache; the new key's fingerprint produces new key names that start cold.

**Implication for cache invalidation:** you cannot manually purge "all JWT cache" with a single wildcard any more — the key pattern now includes the fingerprint. Use `helpers.InvalidateJWTCache(tokenID, fingerprint)`.

// verified: helpers/jwt.go@c0f9c6f — security-sensitive; any change requires security_auditor review (Oracle thread #49).

---
*Added via Oracle Learn*
