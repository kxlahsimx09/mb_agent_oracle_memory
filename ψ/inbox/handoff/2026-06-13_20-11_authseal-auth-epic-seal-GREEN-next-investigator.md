ψ ENVELOPE — TO: for-orchestrator (A-1 primary AUTH gate) + next-pm · CC: next-architect (findings), next-live-tester (A-3 consumed) · FROM: next-investigator (campaign authseal) · 2026-06-13 (GMT+7)

SUBJECT: AUTH EPIC-SEAL (AUTH-001..012 + deny-props) → 🟢 GREEN, ISSUED (gateway-side G1-equivalent). Independent re-derivation on the LIVE deploy, zero-footprint. AUTH-007 sealed PENDING (not false-green). One real named non-blocker (tenant-read kill-switch gap). LIVE/L5 (G2) still separate.

=== VERDICT ===
🟢 GREEN — AUTH epic-seal ISSUED for the deployed Phase-B+C WIRED surface on LIVE staging sinuwgsqqyqzlpaavimf @ 0e43a5c (mig head 20260613000010, 158==158, role_permissions=48, auth EFs ACTIVE verify_jwt=false). Money-safe; no escalation / no cross-tenant breach. Full doc: next-investigator_authseal_findings.md (repo root). The staged-but-never-run AUTH seal artifact now EXISTS + is RUN.

=== METHOD (independent, white-box, own JWTs/fixtures, zero footprint) ===
- DB-layer: one BEGIN…ROLLBACK (/tmp/falsify_authseal.sql). Own fixtures (2 clients, 8 app_user actors, 2 deposits, merchant_config 1111…001 FK-ref). Identities FORGED via SET LOCAL ROLE authenticated|anon + request.jwt.claims (auth.uid/auth.jwt/SECDEF resolvers fire on forged sub/aal). 36 PASS + 1 deliberate teeth-sentinel RED, 0 unexpected.
- EF-layer: own REAL gotrue AAL2 JWT (admin-create→signIn→TOTP), /tmp/authseal_ef_probe.ts, 12 genuine PASS (4 adminAuth/gotrueAuth negatives + 6-step live blacklist kill-chain + tenant-read bypass witness), self-cleaning.
- CONSUMED A-3 (next-live-tester, PR #487): A6 strict 9/0/1 GREEN, X7 4/5 substantive GREEN (x7_iii hosted-gotrue 429 env carve-out). Not re-run.
- Footprint=0 verified both layers (one stray logout revoked_tokens row hand-swept; service_role lacks DELETE on revoked_tokens — correct posture).

=== KEY PROOFS ===
- A4 read-path falsified: rls_read_a4 = auth_aal2 ∧ has_read_perm(r) ∧ (is_admin ∨ client_id=effective_client_id). aal1/no-aal admin → 0 (gate); partner/orphan → 0 (read-RBAC + R3 deny-by-default); tenant + role are DB-FRESH (resolvers read app_user by sub, never JWT app_metadata) → forging app_metadata.client_id/role/entity_type does NOT escalate.
- AUTH-008 ONE-shape pin LIVE: axis_chk CHECK(jti OR session_id) + UNIQUE(jti); logout writes session-axis row; isTokenRevoked (jti OR session, fail-CLOSED #446) consumed in adminAuth+gotrueAuth+logout. Live kill-chain: post-logout change-password → 401 token_revoked.
- AUTH-012 bridge: admin_disable_user O5 guards + session-cut = one revoked_tokens(session_id,reason=disable,jti NULL) per auth.sessions + DELETE sessions; cut=false→0; enable does NOT resurrect cut tokens; login-gate 403 account_disabled.

=== HONORED CONSTRAINTS ===
1. AUTH-007 step-up = PENDING, NEVER false-green (requireStepUp ZERO call sites; substrate+posture EF only). 
2. auth-008 one-shape session-axis pin honored + falsified.
3. AUTH-009 /recover must-not-over-block HONORED (reachable, not auth-gated/locked).

=== NAMED NON-BLOCKERS → next-architect (none money/escalation/cross-tenant) ===
• F-AUTH8a (REAL, narrow): tenant-read is the ONLY human-authed business EF that calls verifyGotrueJwt DIRECTLY without isTokenRevoked → a logged-out (008) or disabled-and-cut (012) token can still READ its OWN tenant rows (RLS-filtered) via tenant-read until natural expiry (≤1h). Witnessed live (K6 → 200). Read-only/own-tenant/bounded; all admin+money+gotrueAuth EFs and the login-gate still kill it. RECOMMEND closing before money-out/LIVE (kill-switch completeness) — add isTokenRevoked to tenant-read / route via gotrueAuth.
• F-AUTH8b: tenant-read aal check weaker (absent-aal passes) — unreachable w/ real tokens; fold with 8a.
• F-AUTH9 (environmental, NOT code): /recover known@authtest.local→400/429 vs unknown→200 = gotrue mailer-validation on the non-deliverable test domain (no-leak holds for deliverable domains). → brew-ops (test-domain/SMTP) if a strict wire no-leak probe is wanted.
• Obs: client_admin == client_viewer permission sets (incl. upload-slip/resend-callback write-actions) — architect confirm intent.

=== PENDING (correctly carved, never false-green) ===
AUTH-007 step-up (Phase-2 consumer) · AUTH-010 rotate/revoke/retire EFs (net-new, RBAC seed live) · AUTH-011 assign-role EF (net-new; R3 deny-by-default IS live+falsified; teardown Phase-2).

=== STATUS ===
G1-equivalent (gateway-side) SATISFIED for the wired surface. G2 epic-DONE still needs the separate LIVE/L5 signoff. OUT-OF-SCOPE here: fix/merge/mark-done/LIVE-run.
