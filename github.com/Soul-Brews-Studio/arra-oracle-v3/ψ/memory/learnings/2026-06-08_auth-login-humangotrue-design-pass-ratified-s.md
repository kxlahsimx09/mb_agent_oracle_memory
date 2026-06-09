---
title: auth-login (human/gotrue) DESIGN PASS — RATIFIED S2, owner GO 2026-06-08. Closes
tags: [auth-login, gotrue, human-login, jwt-flip, ef-side-verify, verify-jwt-false, no-shim-cutover, sealed-slice-remint, design-pass, authdesign, S2-ratified, sim-live-deposit, stagingprov, auth-005, auth-007, phase1-rls-jwt-claim, asymmetric-jwt-jwks]
created: 2026-06-08
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# auth-login (human/gotrue) DESIGN PASS — RATIFIED S2, owner GO 2026-06-08. Closes

auth-login (human/gotrue) DESIGN PASS — RATIFIED S2, owner GO 2026-06-08. Closes the 2026-06-08 auth-design handoff gap (real human auth blocks the §ADR-21 SIM-LIVE deposit test). Design PR #352 (docs/design/auth-login/, 7 files). next-impl authored; SPECs (deliverable #2) follow on campaign authspec.

CONTEXT: epic-auth-rbac was 4-lens-reviewed this week (now AUTH-001..012 on main) + the requirement is ratified, but there was NO login EF (auth = stub: _shared/admin-auth.ts base64url bearer, verify_jwt=false) and NO design doc. Layer-1 machine auth (client-api-gateway CF Worker) was already design-complete; Layer-2 human login (gotrue) was the gap.

THE LOAD-BEARING DECISION — the JWT flip (stub bearer → real gotrue JWT): chose (b) EF-SIDE verify of the gotrue JWT in _shared/auth.ts (verifyGotrueJwt; platform verify_jwt STAYS false), REJECTED (a) platform verify_jwt=true as primary. Grounding (not invented): §ADR-2 G5-D names the chain literally (gotrue JWT verify → IP-allowlist → RBAC → handler); §ADR-2 §Amд 2026-06-08 EA4 (the gotrue JWT IS the issuer-signed assertion, no GW4 on the auth path); (a) 401s pre-EF → strands the G4-D one-row audit + G5-D per-account IP-allowlist + instantly reds the sealed deposit slices. The change is surgical: swap decodeStubToken → verifyGotrueJwt, Actor/RBAC/tenant-scope/DB-fresh byte-identical downstream.

CUTOVER — NO SHIM (owner ruling 2026-06-08): owner REJECTED the proposed dual-accept AUTH_STUB_COMPAT compat shim (a temporary auth-bypass surface). Instead: SINGLE CLEAN CUTOVER — land verifyGotrueJwt, DELETE decodeStubToken, and re-mint EVERY sealed deposit slice's probe onto REAL gotrue JWTs (seed gotrue user via admin API + signInWithPassword in the harness) in the SAME change. Zero bypass surface ever. Sealed slices (DEPOSIT-004/007/008/009/010) get re-tested — owner accepts the re-test cost for no-bypass. verify_jwt=false throughout (EF owns verify). Optional later: platform verify_jwt=true as pure pre-EF defense-in-depth, only after cutover, never fronting the audited login-failure modes (those keep verify_jwt=false in the login EF for the G4-D audit).

ALSO covered: signing mode = migrate project to ASYMMETRIC JWT signing keys (EF holds verify-only public key via JWKS, like GW4) else fall back to SUPABASE_JWT_SECRET (HS256); AUTH-005 (audit + IP-allowlist + two-tier rate-limit [gotrue/EF audited + EA coarse edge] + two-regime lockout LK1-4 on banned_until, Postgres counter no Redis); AUTH-007 step-up (DB step_up_grants row, fail-closed + super-admin toggle); Phase-1 RLS (effective_client_id via a gotrue access-token hook; sub-client→parent SECURITY DEFINER). 10 deferred Qs A-1..A-10 all with Phase-1 recs (none block). Build-lanes mapped: next-dev (login EFs + verifyGotrueJwt + sealed-probe re-mint), data-model (RLS policies + access-token hook + pgTAP), gateway-infra (CF WAF/DDoS + EA per-IP login rate-limit), frontend (login UI + MOCK-ONLY role-switcher), next-writer (AUTH-002/005 epic touches).

NEXT: AUTH SPECs (campaign authspec, next-writer — probes mint REAL gotrue JWTs per no-shim) → hand design+SPECs to build team on the stagingprov stack (fresh Supabase mb-next-staging + CF Worker + AWS egress + mock-merchant) → builds login + JWT-flip cutover + sealed re-mint → SIM-LIVE deposit test through the admin portal (deposit read-API DEPOSIT-013 #348 + epic-deposit-ui #3 already enabled the UI/requirements side).

---
*Added via Oracle Learn*
