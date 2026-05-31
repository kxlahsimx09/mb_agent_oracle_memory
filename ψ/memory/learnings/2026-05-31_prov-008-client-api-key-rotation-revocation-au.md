---
title: PROV-008 (client API-key rotation + revocation) authored 2026-05-31 on writer/ke
tags: [api-key-lifecycle, rotation, revocation, ADR-2-GW6, step-up-scope, PROV-008, requirements-authoring, next-writer]
created: 2026-05-31
source: next-writer (keylife campaign, PROV-008)
---

# PROV-008 (client API-key rotation + revocation) authored 2026-05-31 on writer/ke

PROV-008 (client API-key rotation + revocation) authored 2026-05-31 on writer/keylife — gap-sweep auth-g1, doc-only, NO new ADR. The key-lifecycle gap was fully covered by ratified substrate; only the rotation/revocation ADMIN ACTION story was missing. Substrate map for any future key-lifecycle work:
- ISSUANCE: PROV-001 (api_key pk_ + api_key_secret sk_ minted at client create, secret shown ONCE).
- VERIFICATION (request-time, key + HMAC): AUTH-006 / §ADR-7 — now relocated to the Cloudflare edge gateway tier (§ADR-2 §Amendment 2026-05-28).
- PROPAGATION of a key change: §ADR-2 §Amendment 2026-05-28 GW6 — Supabase Database Webhook on `clients` fires on api_key/api_key_secret column change → POST /internal/invalidate → Workers-KV DELETE of BOTH old+new key entries; push-invalidate primary (sub-second typical), KV TTL ~300s backstop. RATIFIED eventual-consistency trade-off: a revoked/rotated key may still be honored at some PoP up to ~60s; zero-tolerance instant-revoke considered and NOT adopted. In-flight already-authenticated requests are NOT retroactively killed.
- ADMIN-WRITE + AUDIT: §ADR-13 D1 (3-layer write) / D2 (canonical audit_log + actor triple) via PROV-007.

KEY DETERMINATION: key rotation/revocation does NOT require step-up 2FA. §ADR-2 §Amendment 2026-05-26 S2 scopes step-up to admin MONEY-OUT actions only and explicitly excludes machine/client API flows. Key lifecycle is credential management, not money-out → no step-up. Asserted as a determination against ratified scope, not flagged as open.

GOTCHA: the SCOPE-LOCK brief claimed "PROV-001 already says 'Rotation and revocation are an admin action covered by the client-management surface'" — that text does NOT exist in epic-entity-provisioning.md at HEAD (e41e20b). PROV-001 instead mentions a settable key EXPIRY and "expired key → call rejected". Re-verify brief premises against HEAD.

Home choice: folded into epic-entity-provisioning.md as PROV-008 (not AUTH-008) because it reuses the PROV-007 write contract and extends PROV-001 issuance on the same admin client-management surface. The provisioning epic had NO revision log (only deposit + payout do) → created epic-entity-provisioning-revision-log.md.

3 genuinely-undecided surfaces flagged to architect/user (NOT invented in the story): (a) rotation grace/overlap window — Phase-1 single key pair per client so rotation replaces in place with a brief client auth gap; zero-downtime overlap undecided; (b) client self-service (client-initiated) rotation — authored admin-only (parallels PROV-001 b4 self-serve-deferred); (c) key-expiry ↔ KV-cache interaction — GW6 invalidates on column change only, so time-based expiry enforcement at the edge is unspecified.

---
*Added via Oracle Learn*
