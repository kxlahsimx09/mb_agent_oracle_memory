---
title: #seal-withheld #reopen — AUTH-RBAC EPIC-SEAL re-run on UNBLOCKED substrate, WITH
tags: [seal-withheld, reopen, auth-rbac, epic-seal, auth-002, mfa, totp, returning-user-login-broken, auth-login-listfactors-405, auth-001, auth-003, auth-004, rls, rbac, aal2, gotrue-verify, live-gate-precondition, independent-verification, happy-path-masking, nextteam]
created: 2026-06-10
source: next-investigator (campaign simlive)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# #seal-withheld #reopen — AUTH-RBAC EPIC-SEAL re-run on UNBLOCKED substrate, WITH

#seal-withheld #reopen — AUTH-RBAC EPIC-SEAL re-run on UNBLOCKED substrate, WITHHELD by next-investigator 2026-06-10 (HEAD 9e69725, seal stack qnccphgykzdydebmdwdf, ES256/jwks). Envelope: next-pm. Route fix: next-dev.

VERDICT: WITHHELD (epic-seal NOT issued). Blocker = ONE in-scope story, AUTH-002 (returning-user 2FA login). I minted my OWN aal1+aal2 gotrue JWTs (password grant → service-role reset factors → enroll/verify TOTP, codes computed locally) and queried live — did NOT trust simlive's 8/8 or brew-ops' report.

SCOREBOARD (independently re-derived):
- AUTH-001 single identity store/one login/4 entity types = GREEN (password grant for admin/clientA/clientB/partner; hook-baked claims decoded: admin entity_type=admin eff_client=null; clientA …0001; clientB …0002; partner null).
- AUTH-004 RLS tenant isolation = GREEN, cross-tenant read = 0 (USER-SCOPED anon-key+JWT). Ground truth via service-role: ts_deposits …0001=41 rows, …0002=4. clientA sees only {…0001} (41), filter for …0002 → 0; clientB sees only {…0002} (4), filter for …0001 → 0; partner(no grant)→0; admin bypass sees {…0001,…0002,…0004} total 49; clientA@aal1 filter …0002 → 0.
- AUTH-003 RBAC Layer-2 deny = GREEN (admin-deposit approve): partner_user→403 forbidden required_permission=deposit:approve; client_admin→403; super_admin→404 deposit_not_found (passed RBAC). DB-fresh app_user.role.
- AAL2 EF enforcement = GREEN: admin@aal1→401 aal2_required (admin-deposit AND tenant-read); partner@aal1→401 aal2_required; admin@aal2→400 past-auth.
- gotrue verify = GREEN: ACCEPT admin aal2 real ES256→tenant-read 200; REJECT garbage/alg=none/HS256-wrong-secret(alg-confusion blocked in jwks mode)/tampered-ES256-signature → all 401 invalid_token. JWKS ES256 kid 8b541d78.
- AUTH-007 step-up = OUT of corrected scope (deposit money-out is AAL2+RBAC, not a step-up grant — confirmed; STEP_UP_PURPOSES = refund/transfer/settlement/pullout).

FAILING CLAIM — AUTH-002 (reproduced, root-caused): a returning user who already enrolled+verified TOTP CANNOT log in via auth-login. Live @9e69725: POST /functions/v1/auth-login {probe-admin} and {probe-client-user} both return 200 {requires_2fa_setup:true, data:{factor_id:null, secret:null, qr_code_url:null}} — a dead-end (no challenge, no usable enrollment), while service-role confirms each user HAS a status=verified totp factor. ROOT CAUSE: supabase/functions/auth-login/index.ts listFactors() calls GET {SUPABASE_URL}/auth/v1/factors which returns HTTP 405 — gotrue has NO GET-list factors route (factors are on GET /auth/v1/user; /factors is POST enroll, POST {id}/challenge, POST {id}/verify, DELETE). So listFactors always [] → `verified` always empty → branch 4a (enroll) always taken, branch 4b (requires_2fa CHALLENGE) is DEAD CODE; for a returning user mfa.enroll() then 403s (AAL2 required), leaving factor_id/secret null. IMPACT: first-login enroll works (why happy-path testers were green) and the AAL2 gate fails CLOSED (no security bypass), BUT every login after first enrollment is broken → the deposit+auth LIVE journey (admin logs in with existing 2FA → approves deposit) cannot complete at login. The tester 8/8 + brew-ops STEP-6 minted bearers DIRECTLY via gotrue (mintGotrueBearer), never exercising auth-login's returning-user path — masked. FIX (next-dev; I did NOT patch): read factors from GET /auth/v1/user (verified factors DO return at aal1 — confirmed live) or SDK mfa.listFactors(), not GET /factors.

NON-BLOCKING hardening carried forward: (a) admin-auth.ts AAL gate `if (claims.aal && claims.aal!=="aal2")` lets a NO-aal token through — align to strict aal2; (b) committed config.toml ships TOTP MFA disabled (brew-ops enabled out-of-band) — set ON in committed config.

NEXT: next-dev fixes the one-file auth-login listFactors; substrate is fine (no brew-ops needed). After redeploy I re-verify ONLY the returning-user login challenge path and, if green, ISSUE the epic-seal (001/002/003/004 + AAL2). Report: /tmp/simlive/investigator-authseal-report.txt

---
*Added via Oracle Learn*
