---
to: orchestrator (next session — AUTH design+review pass)
from: orchestrator-build 2026-06-08
priority: P1
topic: AUTH design pass — author HUMAN-LOGIN (gotrue) design + SPECs + 4-lens review so Epic Auth can be built
project: github.com/kxlahsimx09/mb-next-payment-gateway
tags: [orchestrator, auth, gotrue, epic-auth-rbac, design-pass, 4-lens-review, handoff, live-test-prereq]
---

# AUTH design pass — HUMAN LOGIN (gotrue) is the gap

**Why now:** all DEPOSIT build slices are sealed (stub bearer). The path to §ADR-21 SIM LIVE test (deposit flow through the admin portal UI) needs REAL auth. Auth splits into two layers — one is design-complete, one is the gap THIS handoff owns.

## Split (do NOT redo layer 1)
- **Layer 1 — machine/client-API auth (CF Worker): DESIGN COMPLETE.** `docs/design/client-api-gateway/README.md` (`#decision`) pins every deferred §ADR-2-amendment question: GW4 = JWT/jose EdDSA, kid keyring, rh request-binding, rotation, GW6 KV TTL + /internal/invalidate, RL4 rate-limit cap schema. Worker scaffold = `gateway/cf-worker`. This is buildable as-is — NOT your scope (it is the build team's).
- **Layer 2 — HUMAN login (gotrue): THE GAP — your scope.** AUTH-001/002/005/007 (login, 2FA/TOTP, audit+IP-allowlist+lockout, admin step-up) + AUTH-003/004 (RBAC/tenant-scope, already exercised at EF logic level by deposit). Status: requirement ratified (epic-auth-rbac, S2) BUT no login EF exists, `supabase/functions/_shared/admin-auth.ts` is a STUB (base64url bearer, not gotrue-verified), and there is NO design doc.

## Deliverables
1. **`docs/design/auth-login/`** — impl-spec for the gotrue human-login lane, mirroring the quality bar of `docs/design/client-api-gateway/`. Must resolve:
   - login EF(s): `signInWithPassword` → entity_type→role (§ADR-2; role from JWT, NOT a picker), 2FA G1-D response shape (verbatim mobiz shape per §ADR-2 G1-D), session/refresh handled by platform.
   - **How the deposit/admin EFs flip from the stub bearer to verifying REAL gotrue JWT** — the load-bearing decision: platform `verify_jwt=true` (gotrue-signed) vs EF-side verify with gotrue public key. NOTE deposit EFs currently run `verify_jwt=false` + stub-decode (admin-auth.ts) — this design says how that becomes real without breaking the sealed slices.
   - AUTH-005 (login audit §ADR-13 D2, IP-allowlist, rate-limit, lockout two-regime), AUTH-007 (admin money-out step-up, fail-closed + super-admin toggle).
2. **Test-facing SPECs** AUTH-001/002/003/004/005/007 (like the deposit SPECs — the build team binds probes off these).
3. **4-lens pre-dev review** of epic-auth-rbac (never reviewed; SECURITY-CRITICAL — 2FA, step-up, lockout, IP-allowlist): next-architect (ADR-consistency) · pg-writer (current-mobiz parity: 4-login-flow → 1 gotrue) · next-writer (completeness) · next-ui (auth console — epic-auth-ui already authored, WUI auth stories).

## Refs
§ADR-2 + Amendment 2026-05-07 (G1-D 2FA, G2-D email-uniqueness) + Amendment 2026-05-28 (GW1-GW5 gateway-in-front) + Amendment 2026-05-26 (AUTH-007 step-up) · §ADR-13 (RBAC F1-F4, D2 audit) · §ADR-7 (HMAC — Worker/layer-1) · `docs/requirements/epic-auth-rbac.md` (AUTH-001..007) · `docs/requirements/epic-auth-ui.md` (admin-portal repo — UI login stories; role-switcher is MOCK-ONLY, real login has no role picker) · `docs/design/client-api-gateway/` (layer-1, quality bar).

## Coordination
Staging backend is being stood up IN PARALLEL by orchestrator-build (brew-ops campaign `stagingprov`): fresh Supabase `mb-next-staging` (org lsgheeuhvfqhmombfqsl, ap-southeast-1) + CF Worker + shared AWS egress + mock-merchant (proving the egress IP-allowlist). The auth BUILD (after your design) lands on that staging stack. Hand your ratified design + SPECs to the build team; do not build code in this pass — design + review only. Owner ratifies the design (S3→S2) before build, same as the deposit/payout pattern.
