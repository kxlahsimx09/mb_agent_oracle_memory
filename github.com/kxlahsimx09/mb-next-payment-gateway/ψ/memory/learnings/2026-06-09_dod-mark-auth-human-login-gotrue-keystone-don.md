---
title: DoD-MARK — AUTH human-login (gotrue) KEYSTONE: DONE (EF-side gotrue NO-SHIM cuto
tags: [dod-mark, auth, auth-login, gotrue, no-shim-cutover, nextteam]
created: 2026-06-09
source: next-pm (campaign authpm)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# DoD-MARK — AUTH human-login (gotrue) KEYSTONE: DONE (EF-side gotrue NO-SHIM cuto

DoD-MARK — AUTH human-login (gotrue) KEYSTONE: DONE (EF-side gotrue NO-SHIM cutover). next-pm campaign authpm, 2026-06-09. Scope = the login keystone (EF-side gotrue JWT flip); NOT epic-done — epic-auth-rbac has follow-on lanes remaining.

VERDICT: DoD-MET. All 5 gates re-verified from ARTIFACTS ONLY, each re-checked gate-to-artifact.

GATE BOARD (gate -> artifact -> re-verify result):

1. SPEC/DESIGN -> PASS.
   docs/design/auth-login/ = 7 files on origin/main (README + 01-login-ef, 02-jwt-flip, 03-auth-005-mechanics, 04-step-up, 05-rls-claim-tie-in, 06-deferred-and-ratification). Ratification doc 06 confirms S2 + owner GO 2026-06-08, NO-SHIM clean cutover ratified (the stub-shim migration was rejected by owner). 4 AC slice specs present: auth-001-002-login-2fa, auth-003-004-rbac-tenant-scope, auth-005-login-security (9 ACs), auth-007-step-up. Build seam present: docs/spec/auth-login-build-slice.md (status published, single binding rule = every authed probe mints REAL gotrue AAL2 JWT, verify_jwt stays false on every authed EF).

2. BUILD -> PASS.
   PR #357 squash bfbcfd5 git merge-base --is-ancestor bfbcfd5 origin/main = TRUE (landed on main). Commit subject = the auth-login lane EF-side gotrue JWT flip (NO-SHIM cutover). Delta re-confirmed by git show: 6 new EFs (auth-login, auth-2fa-verify, auth-step-up-posture, auth-step-up-verify, admin-users-reset-2fa, admin-users-unlock) + _shared/login-support.ts + _shared/step-up.ts; _shared/auth.ts adds verifyGotrueJwt (jose@5.9.6, createRemoteJWKSet, ASYM_ALGS=[ES256,RS256,RS512,EdDSA], iss/exp/aud pins, alg-confusion blocked); _shared/admin-auth.ts flipped to import verifyGotrueJwt; decodeStubToken DELETED (git diff shows -export function decodeStubToken + -const claims=decodeStubToken -> +verifyGotrueJwt; NO fallback) = NO-SHIM cutover. Migration 20260609000001_auth_login_profiles_lockout_stepup.sql ADDED (status A vs parent) with allowed_ips inet[] on 4 profile tables, app_user lockout cols (is_locked/failed_login_attempts/locked_at/banned_until/email), step_up_grants/step_up_replay_guard/step_up_lockout, auth_lockout_config + step_up_posture_config singletons. config.toml carries 13 verify_jwt blocks.

3. REVIEW -> PASS.
   next-code-reviewer_authreview_findings.md VERDICT: APPROVE (one non-blocking NOTE on cross-branch re-mint; minor nits). Cutover-completeness gate PASS: (a) decodeStubToken DELETED (node:buffer import + JwtClaims type + body all removed); alg PINNED two ways + alg-confusion BLOCKED (HS* never in jwks mode); token-source swap only, per design 02 sec 2.2; NO half-cutover within the branch; verify_jwt false on all 6 EFs so EF owns verify. None blocking.

4. VERIFY -> PASS.
   next-tester /tmp/authtest-report.txt (run 7adec90, staging sinuwgsqqyqzlpaavimf): 37-AC auth bijection = 26 GREEN / 11 boundary-FAIL. Headline core ALL GREEN: JWT-1 real AAL2 accepted, JWT-2 legacy-stub/alg:none/bad-sig/expired all 401 (no decodeStubToken fallback), JWT-3 AAL1 cannot reach authed EF; RBAC two-layer (required_permission echo, 0 writes), DB-fresh role change on same JWT, hard-lock no-TTL + super-admin unlock, audit one-row-per-attempt, step-up verify/replay-409/cross-purpose/path-lockout-423. The 11 fails triaged as env/deploy/seam boundaries, not product defects. NO-SHIM cutover CLOSED via sealed-deposit re-green /tmp/deposit-regreen-v2.txt: 91/93 deposit ACs GREEN on REAL gotrue JWTs (DEPOSIT-007 47/47, DEPOSIT-003/004 26/27, DEPOSIT-012 18/19), was 13/87 pre-GW4. Deploy verified /tmp/authdeploy-report.txt + /tmp/staging-gw4-report.txt: migration applied (9 tables + 5 app_user cols via to_regclass), 6 new + 13 redeploy EFs, JWKS ES256 (kid d0160159) in-use, AUTH_JWT_MODE=jwks pinned, REAL-JWT verification PASS (no-bearer 401 / garbage 401 / aal1 401 aal2_required / aal2 400 business). GW4 assertion substrate closed (signed deposits-create 201).

5. SEAL -> PASS.
   next-investigator /tmp/authseal-report.txt + next-investigator_authseal_findings.md VERDICT: SEALED. Fully independent: minted its OWN 6 fresh gotrue users (not tester 8888 rows), real ES256/AAL2 via admin-create + signInWithPassword + real TOTP enroll/challenge/verify, every claim re-derived from staging truth DB (Mgmt API SQL) + live EF responses, all artifacts cleaned. All 5 load-bearing claim groups PASS: (1) NO-SHIM cutover + alg-pin, (2) RBAC two-layer DB-fresh, (3) step-up AUTH-007, (4) hard-lock+unlock+audit, (5) DEPOSIT-007 re-green spot-check. Independently confirmed the 2 deposit fails are ENV/STATE/TIMING, not defects, independent of the cutover.

SCOPED FOLLOW-UPS (NOT defects — named owners; these are out-of-keystone-scope work, do not block the DoD-mark):
 - AUTH-004 RLS policy bodies + client-facing tenant-read EF (AC1/AC3/AC4/AC5 + cross-tenant leg; lane provisioned claims with RLS keys OFF per BUILD-SLICE sec 7) -> data-model lane.
 - AUTH-007 gated deposit-refund money-out EF slug (admin-deposit-refund 404; likely an action inside admin-deposit-resolve; step-up VERIFY engine itself fully GREEN) -> next-dev to name the gated-refund EF slug + purpose.
 - rate-limit audited-tier threshold (no 429 in 30 attempts on staging) + IP-allowlist synthetic-source injection / allowed_ips seeding key + LK2 soft-lock auto-expiry (gotrue banned_until is WALL-CLOCK, not ADR-20 virtual-clock advanceable) -> config / gateway.
 - 2FA-enroll via the EF two-step (auth-login -> auth-2fa-verify) so the EF-side enrolled flag flips (AUTH-002 AC2; AC1/AC3/AC4 GREEN) -> harness.
 - the 2 deposit fails: d004_ac9 (admin x-client upload-slip 409 vs 200) = STATE-residue; d012_ac06 (in-flight 202 vs 409) = dispatch-TIMING race -> deposit lane / quiesced-stack confirm.
 - DEPOSIT-008/009/010 deposit-probe-suite re-run (no probe suites in this fork; skipped per orchestrator) -> coverage follow-up.
 - config.toml missing verify_jwt=false blocks for ~12 EFs (deploy without --no-verify-jwt silently re-enables the platform gate) -> source hardening.

CUTOVER PROPERTY SEALED: no base64url(JSON) stub bearer, no env bypass flag, no decodeStubToken fallback anywhere in the tree; every authed EF owns verification of a REAL gotrue ES256/JWKS AAL2 JWT. The login keystone (EF-side gotrue cutover) is DONE. Epic-auth-rbac remains open on the follow-on lanes above.

---
*Added via Oracle Learn*
