---
title: #seal-withheld #reopen — AUTH-RBAC EPIC-SEAL WITHHELD by next-investigator, 2026
tags: [seal-withheld, reopen, auth-rbac, epic-seal, auth-001, auth-002, auth-003, auth-004, auth-007, aal2, live-gate-precondition, substrate-gap, stale-deploy, independent-verification, nextteam]
created: 2026-06-10
source: next-investigator (campaign simlive)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# #seal-withheld #reopen — AUTH-RBAC EPIC-SEAL WITHHELD by next-investigator, 2026

#seal-withheld #reopen — AUTH-RBAC EPIC-SEAL WITHHELD by next-investigator, 2026-06-10 (HEAD origin/main 9e69725). Envelope: next-pm.

VERDICT: WITHHELD (not sealed). In-scope stories AUTH-001/002/003/004/007 + AAL2-EF-enforcement could NOT be independently re-derived on live substrate. Per SKILL V1/V5, refused to seal on simlive's 8/8 or on code-review alone.

ROOT BLOCKER (substrate, not a disproven code claim): the artifact under seal is NOT hosted where I have creds, and I have NO creds where it is hosted.
- My investigator creds are ref-bound to Supabase project qnccphgykzdydebmdwdf; the dispatch's recompute target / config.toml staging is sinuwgsqqyqzlpaavimf (different project; my keys don't authenticate there).
- On qnccphgykzdydebmdwdf the auth-rbac slice is NOT deployed: migrations 20260609000001 (auth/lockout/step-up) + 20260609000010 (RLS) NOT applied (admin/client/merchant/partner_profiles, step_up_grants/replay_guard/lockout/posture_config, auth_lockout_config all ABSENT; auth_is_admin/auth_effective_client_id/custom_access_token_hook RPC 404). EFs auth-login, auth-2fa-verify, auth-step-up-verify, auth-step-up-posture, admin-users-reset-2fa, tenant-read all 404; only admin-deposit{,-resolve,-verify-now} deployed. 0 gotrue users; hook unregistered; native TOTP MFA disabled.
- The deployed admin-deposit returns "malformed_token" for a bad bearer — a string that exists ONLY in the machine/GW4 gateway-assertion.ts at HEAD, NOT in the human-auth path (HEAD returns "invalid_token"). => deployed build PREDATES the gotrue cutover, != 9e69725.
- On sinuwgsqqyqzlpaavimf the artifact IS live (auth-login → 400 missing_credentials) but I have no anon/service keys for it.

FOUR REQUIRED GROUND-TRUTHS: [1] RLS cross-tenant=0 UNVERIFIABLE (no RLS tables/hook/tenant-read EF/users; service-role bypasses RLS so a user-scoped JWT is required, which I can't mint). [2] RBAC out-of-grant deny UNVERIFIABLE (0 users, stale admin EF). [3] AAL2 aal1->401/aal2->200 UNVERIFIABLE (login/2FA EFs 404, MFA off, 0 users). [4] gotrue verify accept/reject INSUFFICIENT — reject path only, against a STALE pre-cutover build; accept path impossible (no mintable session).

CODE AT HEAD reads correct (alg-pinned verify rejecting none/HS-confusion + iss/aud/exp; authoritative RLS with admin bypass, anon-reads-all hole dropped, predicate indexes; DB-fresh RBAC; fail-closed step-up). Two hand-offs to next-dev (hardening, not seal-enabling): (a) adminAuth AAL gate `if (claims.aal && claims.aal!=="aal2")` lets a token with NO aal claim bypass AAL2 — align to require aal==="aal2" like gotrueAuth; (b) AUTH-007 scope mismatch — STEP_UP_PURPOSES = {deposit_refund, direct_transfer_create, settlement_create, settlement_approve, pullout_config_write}; the deposit approve/resolve/verify-now EFs do NOT consume a step-up grant (gated by session-AAL2+RBAC only), so the dispatch's "fresh step-up on deposit approve/resolve/verify-now" is NOT implemented — next-pm reconcile the AC. Naming nit: AUTH-003 is requirePermission/ROLE_PERMISSIONS, not a `check_permission` fn.

ROUTING (brew-ops/owner owns cross-stack deploy; investigator must NOT self-provision): unblock by EITHER (A) apply both migrations + `supabase config push` (register hook + enable TOTP MFA) + deploy the AUTH/step-up/tenant-read EFs and redeploy admin-deposit* at 9e69725 to qnccphgykzdydebmdwdf + seed 2 tenants/admin/no-grant-partner; OR (B) provision investigator read+mint creds for sinuwgsqqyqzlpaavimf. Then re-dispatch; I recompute all four and seal-or-withhold on live evidence. Until then the deposit+auth LIVE gate (§ADR-21 build-workflow Step 3a) stays BLOCKED. Full report: /tmp/simlive/investigator-authseal-report.txt

---
*Added via Oracle Learn*
