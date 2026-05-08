---
title: poc-ready: §ADR-2 Phase-2 — extended falsification 12/13 green; C5 substrate-con
tags: [implementation-architect, repo:mb-next-payment-gateway, next, auth, adr-2, poc-ready, phase-2, rbac, mfa, totp, rfc-6238, ip-allowlist, p95-latency, rate-limit-substrate-gap, mutation-test, 4-layer-mutation, tier-3, supabase-auth, edge-function, pattern-observation, substrate-config-gap]
created: 2026-05-07
source: poc/2/ Phase-2 (commit pending); 28/28 spec / 73 expect / 7.3s; 4 mutations across 4 substrate layers all red as expected; C5 substrate-config gap documented (local CLI doesn't enforce gotrue rate-limit; verified via 80 wrong-pw + 60 signUp probes both returning 0× 429)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# poc-ready: §ADR-2 Phase-2 — extended falsification 12/13 green; C5 substrate-con

poc-ready: §ADR-2 Phase-2 — extended falsification 12/13 green; C5 substrate-config gap (local CLI 2.54.11 doesn't enforce gotrue rate-limit)

Phase-2 extension of poc/2/ falsifies all remaining claims except C5 (rate-limit) which is a substrate-config gap rather than ADR drift. Total: 28 spec / 73 expect / 7.3s wall. 4 mutations across 4 substrate layers all pin claims to ADR not implementation.

## Phase-2 results

- **C4 RBAC DB-fresh** (3 sub-tests) — admin:super → 200; flip role to admin:support in DB → next call 403 (SAME JWT — no re-login); flip back → 200 again. Proves §ADR-2 RBAC subsection "no re-login on role change" architecturally.
- **C5 rate-limit** — substrate gap: local Supabase CLI 2.54.11 returned 0× 429 across 80 wrong-pw + 60 sign-up attempts despite [auth.rate_limit].sign_in_sign_ups=30 config. Smoke test verifies config block accepted; production substrate behavior must re-validate against Supabase Cloud.
- **C6 refresh-token** (1 sub-test) — refreshSession returns new access_token != old; gotrue-native; passes trivially.
- **C8 MFA TOTP** (2 sub-tests) — first-login enroll returns {qr_code_url, secret, factor_id}; otpauth lib generates RFC-6238 code; mfa-verify yields AAL2 JWT (decoded payload.aal=='aal2'). Super_admin reset path: service.auth.admin.mfa.deleteFactor proves AdminReset2FA equivalent.
- **C10 P95 latency** (1 sub-test) — 50 warm auth-login calls; P50=72ms / P95=78ms vs ≤800ms ADR budget; 10× headroom on local Docker substrate.
- **C12 IP allowlist** (3 sub-tests) — NULL allowed_ips → 200 from any IP; ['1.2.3.4'] + caller=5.6.7.8 → 403 + audit_log row login_failure_ip_blocked; ['1.2.3.4'] + caller=1.2.3.4 → 200.

## Mutation rigor — 4 across 4 substrate layers

- Mut-A (TS EF code) — `if (false) await audit_log.insert(...)` → C11 × 2 red
- Mut-B (SQL policy) — `CREATE POLICY ... USING (true)` → C3 merchant + client red, admin still green (CASE-shape preserved)
- Mut-C (SQL function) — `has_permission()` → `SELECT true` → C4 "flip-to-support" red
- Mut-D (TS middleware) — `if (false && allowedIps && ...)` → C12 "mismatch → 403" red

All 4 mutations red-as-expected → no 5d (implementation-grounded test) or 5e (mutation passes) failures.

## C5 substrate-config gap — pattern observation

Local Supabase CLI 2.54.11 does NOT enforce gotrue rate-limit even with `[auth.rate_limit]` block fully populated. Verified via:
- 80 sequential signInWithPassword with wrong passwords → all returned 400 invalid_credentials, 0× 429
- 60 sequential signUp with unique emails → 0× 429 / 0× rate-limit message
- Production substrate (Supabase Cloud) enforces both gotrue-level + Vercel/Cloudflare edge-layer rate-limit per Supabase docs.

Classification: NOT a 5-classification ADR drift (ADR claim "Supabase handles rate limiting" holds on production substrate); this is a **substrate-config gap** specific to local CLI dev mode. The rate-limit is opt-in on local; production has it on by default.

**Heuristic candidate:** Tier-3 PoC against local CLI substrate covers the substrate's *available* surface. Production-only behavior (rate-limit, edge cache, geographic routing, anti-DDoS) must be deferred to staging-cloud validation by next-dev. Mark these as `[POC_GAP:ADR-N:CN-substrate-config:<specific-gap>]` rather than 5b drift.

## Pattern observations

- **Substrate-config gap is its own category.** Not 5a/b/c/d/e per W1 Step 5. Not ADR drift. Worth adding as classification 5f or as parallel non-drift gap shape in SKILL.md / W1 doc.
- **4 mutations across 4 substrate layers** — TS code + SQL policy + SQL function + TS middleware. When ADR straddles 4 layers, 4 mutations is the right rigor. Pattern: 1 mutation per layer the ADR depends on.
- **EF runtime hot-reload still requires explicit pkill + supabase functions serve.** Confirmed across 4 mutations; per_worker policy claims hot-reload but caches compiled bundle. Heuristic: always full restart between mutations.
- **listUsers() pagination breaks identity-by-email lookups when test creates many users.** When seed/test creates >50 users in same session, listUsers default returns first 50. Use entity-profile table joined by display_name as robust identity lookup instead.

## Final tally

- 28 spec / 73 expect / 7.3s wall
- 12 of 13 claims falsified green; 1 (C5) substrate-config gap documented
- 4 mutations / 4 substrate layers / all red as expected
- 0 active drift; W1 Step 5 classification = 5-pass on all green claims
- POC dir frozen pending next-dev consumption (P-001)

## Cross-refs

- Predecessors: 2026-05-07_poc-drift-adr-2-six-silent-on-load-bearing-cas (W2 round 1 drift); 2026-05-07_poc-drift-closed-adr-2-g1g6-w2-round-1-single (W2 close); 2026-05-07_poc-ready-adr-2-tier-3-poc-falsified-6-of-13-c (Phase-1 6/13 ready)
- Supersedes: 2026-05-07_poc-ready-adr-2-tier-3-poc-falsified-6-of-13-c (Phase-1 status reading; Phase-2 extends coverage to 12/13)
- ADR baseline: docs/adr.md §ADR-2 + Auth Surface Completion subsection (commit e0a5698)
- Promote-to-dev trigger: when next-dev forks poc/2/supabase/ → anchor [POC_PROMOTED:<commit-hash>] per SKILL.md P-001

---
*Added via Oracle Learn*
