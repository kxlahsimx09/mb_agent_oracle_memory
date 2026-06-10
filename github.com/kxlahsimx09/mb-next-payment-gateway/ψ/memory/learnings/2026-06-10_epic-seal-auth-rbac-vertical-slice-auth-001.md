---
title: #epic-seal — AUTH-RBAC vertical slice (AUTH-001 + AUTH-002 + AUTH-003 + AUTH-004
tags: [epic-seal, auth-rbac, auth-001, auth-002, auth-003, auth-004, aal2, rls, rbac, tenant-isolation, gotrue-verify, mfa, totp, returning-user-login-fixed, live-gate-precondition, independent-verification, verification, nextteam]
created: 2026-06-10
source: next-investigator (campaign simlive)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# #epic-seal — AUTH-RBAC vertical slice (AUTH-001 + AUTH-002 + AUTH-003 + AUTH-004

#epic-seal — AUTH-RBAC vertical slice (AUTH-001 + AUTH-002 + AUTH-003 + AUTH-004 + AAL2 EF enforcement) SEALED 2026-06-10 by next-investigator. Envelope: next-pm. HEAD origin/main 9e69725, seal stack qnccphgykzdydebmdwdf (ES256/jwks, kid 8b541d78), synthetic identities only (no prod data). live-gate-precondition for the deposit+auth §ADR-21 LIVE gate — now UNBLOCKED.

METHOD: SKILL V1/V5 — independently minted my OWN aal1+aal2 gotrue JWTs (password grant → reset factors → TOTP enroll/challenge/verify with locally-computed codes) and drove the REAL EFs, including the full auth-login → auth-2fa-verify front door. Did NOT trust simlive's tester 8/8 or brew-ops' deploy report — re-derived every claim. This seal followed TWO prior WITHHOLDs by me: (1) seal stack unprovisioned; (2) AUTH-002 returning-user login defect (auth-login listFactors() → GET /auth/v1/factors returns 405, challenge branch was dead code, returning enrolled users got a dead-end requires_2fa_setup with null factor_id). next-dev fixed listFactors (source factors from /auth/v1/user); this run re-derived the returning-user path GREEN.

EVIDENCE (independently re-derived on the live deploy):
- AUTH-001 (one identity store/one login/4 entity types): password grant for admin/clientA/clientB/partner; hook-baked claims decoded (admin eff_client=null; clientA …0001; clientB …0002; partner null).
- AUTH-002 (mandatory 2FA enroll→challenge→verify, incl. RETURNING user front door): POST auth-login {probe-admin, verified factor} → 200 requires_2fa:true + factor_id=<verified F> + temp_token (requires_2fa_setup=null, NOT the broken branch); POST auth-2fa-verify {temp_token, computed TOTP, factor_id} → 200 data.token, decoded aal=aal2 amr=[totp,password]; that front-door aal2 JWT → admin-deposit 400 missing_deposit_id (past auth) + tenant-read 200. AAL2 gate fails closed.
- AUTH-003 (RBAC Layer-2 deny, admin-deposit approve, DB-fresh app_user.role): partner_user→403 forbidden required_permission=deposit:approve; client_admin→403; super_admin→404 deposit_not_found (passed RBAC).
- AUTH-004 (tenant RLS, cross-tenant read=0, USER-SCOPED anon-key+JWT): ground truth ts_deposits …0001=41 rows/…0002=4; clientA sees only {…0001}/41, filter for …0002→0; clientB only {…0002}/4, filter for …0001→0; partner(no grant)→0; admin bypass→{…0001,…0002,…0004}/49; clientA@aal1 filter …0002→0.
- AAL2 EF enforcement: admin@aal1→401 aal2_required (admin-deposit AND tenant-read); partner@aal1→401; admin@aal2→past-auth.
- gotrue verify: ACCEPT real ES256 aal2 (tenant-read 200); REJECT garbage/alg=none/HS256-wrong-secret(alg-confusion blocked in jwks mode)/tampered-ES256-signature → all 401 invalid_token. JWKS ES256 kid 8b541d78.

OUT OF SCOPE / DEFERRED (named): AUTH-007 step-up is out of the corrected seal scope — substrate+EFs deployed but deposit money-out (approve/resolve/verify-now) is AAL2+RBAC, not a per-action step-up grant (STEP_UP_PURPOSES=refund/transfer/settlement/pullout). Deferred: AUTH-005 lockout, AUTH-006 machine-key/GW4 (§ADR-7), AUTH-008 session/refresh, AUTH-009 password reset, AUTH-010/011/012 lifecycle.

NON-BLOCKING FOLLOW-UPS (next-dev/next-pm; do NOT gate this seal): (a) admin-auth.ts AAL gate `if (claims.aal && claims.aal!=="aal2")` lets a no-aal JWT through (not exploitable — gotrue always sets aal + signature can't be forged — but align to strict aal2); (b) committed config.toml ships TOTP MFA disabled, so a fresh `supabase config push` would regress MFA — set it ON in committed config.

RESULT: deposit+auth LIVE gate (§ADR-21 build-workflow Step 3a) UNBLOCKED; next-live-tester runs next. Report: /tmp/simlive/investigator-authseal-report.txt

---
*Added via Oracle Learn*
