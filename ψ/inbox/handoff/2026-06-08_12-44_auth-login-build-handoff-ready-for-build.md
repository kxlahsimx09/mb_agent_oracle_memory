---
to: build team (orchestrator-build / nextteam — next-dev, next-tester, data-model, gateway-infra, frontend)
from: orchestrator (auth design+review session) 2026-06-08
priority: P1
topic: BUILD the HUMAN-LOGIN (gotrue) lane — design + SPECs RATIFIED (S2), ready to build; unblocks the §ADR-21 SIM-LIVE deposit test
project: github.com/kxlahsimx09/mb-next-payment-gateway
tags: [orchestrator, auth, gotrue, build-handoff, auth-login, jwt-flip, no-shim, sim-live, epic-auth-rbac]
---

# BUILD ORDER — human-login (gotrue) lane

The auth design pass (handoff 2026-06-08_11-20) is COMPLETE + owner-RATIFIED. Everything you need to build is pinned. This closes the gap that blocks the SIM-LIVE deposit test (deposit flow through the admin portal needs a real authenticated operator).

## STATE (all ratified)
- **Design (S2):** PR #352 — `docs/design/auth-login/` (7 files: README + 01 login-ef · 02 jwt-flip · 03 auth-005-mechanics · 04 step-up · 05 rls-claim-tie-in · 06 deferred+ratification). READ THIS FIRST — it is the build spec.
- **Test-facing SPECs:** PR #353 — `docs/spec/auth-001-002-login-2fa-slice.md` · `auth-003-004-rbac-tenant-scope-slice.md` · `auth-005-login-security-slice.md` · `auth-007-step-up-slice.md`. Bind your probes off these (AC-bijection, like the deposit SPECs).
- **Requirement:** epic-auth-rbac AUTH-001..012 (merged, incl. AUTH-008 logout/session · 009 password · 010 key rotate/revoke · 011 role assign/delete · 012 disable). UI: admin-portal epic-auth-ui (PR #2; role-switcher is MOCK-ONLY — real login has NO role picker).
- **ADRs (merged):** §ADR-2 + Amд 2026-05-07 (G1-D 2FA, G3-D latency, G4-D audit, G5-D IP-allowlist) + Amд 2026-05-26 (AUTH-007 step-up) + Amд 2026-05-28 (GW machine edge) + Amд 2026-06-07 (Two-Regime Lockout LK1-4) + §ADR-13-F4 Amд 2026-06-07 (Phase-1 Postgres RLS A1-3) + §ADR-2 Amд 2026-06-08 (EA edge shell for human auth). §ADR-13 F1-F4/D1/D2. §ADR-7 (machine — layer 1, separate).

## THE TWO BINDING DECISIONS (do NOT re-litigate)
1. **JWT-flip = (b) EF-SIDE verify.** `verifyGotrueJwt` in `_shared/auth.ts`; platform `verify_jwt` STAYS false. The EF verifies the gotrue JWT signature itself (grounded G5-D chain + §Amд 2026-06-08 EA4 "gotrue JWT IS the assertion, no GW4 on auth path"). Reading: swap `decodeStubToken` → `verifyGotrueJwt`; Actor / RBAC / tenant-scope / DB-fresh downstream are BYTE-IDENTICAL — preserve them. (design 02-jwt-flip §2.2-2.3.)
2. **NO SHIM — clean cutover (owner GO 2026-06-08; the AUTH_STUB_COMPAT dual-accept shim was REJECTED).** In ONE change: land `verifyGotrueJwt`, DELETE `decodeStubToken`, and RE-MINT EVERY sealed deposit slice's probe fixtures onto REAL gotrue JWTs (seed a gotrue user via the admin API + `signInWithPassword` in the harness setup), then re-test. Zero bypass surface, ever. Do NOT half-cutover (flipping verify without re-minting reds the sealed slices). The sealed slices DEPOSIT-004/007/008/009/010 get re-tested — that re-test is accepted + is also the SIM-LIVE login leg.

## BUILD-LANE BREAKDOWN (design 06 §D)
- **next-dev:**
  - `POST /auth/login` (gotrue `signInWithPassword` → compose session + entity-profile + 2FA flags; role from JWT app_metadata, NOT a picker; G1-D two-step 2FA shape VERBATIM) · `POST /auth/2fa/verify` · `POST /admin/users/:id/reset-2fa`.
  - `_shared/auth.ts` `gotrueAuth` + `verifyGotrueJwt` (jose; pin alg, reject none/alg-confusion, check iss/exp/aud) + the `admin-auth.ts` flip (delete `decodeStubToken`) + **re-mint sealed deposit slice probes onto real gotrue JWTs in the SAME change** (the cutover).
  - Migrations: `allowed_ips inet[]` on the profile tables (G5-D) · lockout failed-attempt counter + config tables (Postgres, NO Redis per §ADR-1; LK figures 5-attempt / ~15-min as Phase-1 baseline) · `step_up_grants` (AUTH-007).
  - Update the four `config.toml` `verify_jwt=false` rationale comments: stub → "EF-side gotrue verify (G5-D/EA4); platform gate off so the EF writes the G4-D audit + runs G5-D IP-allowlist before any 401."
- **data-model pass:** per-tenant-scoped-table RLS policies (one isolation predicate/table, Phase-1 authoritative per §ADR-13-F4 A1) + the `effective_client_id` gotrue ACCESS-TOKEN HOOK (sub-client→parent via SECURITY DEFINER; design 05) + pgTAP coverage.
- **gateway/infra:** CF zone WAF/DDoS/Bot config + the EA2 coarse source-IP login rate-limit rule (fail-open; flood backstop, NOT the audited limit). Login EF sits behind the same CF zone (EA1).
- **frontend (admin-portal):** the login UI (entity-aware, all failure states per epic-auth-ui WUI) + the MOCK-ONLY role-switcher.
- **next-writer:** AUTH-002/005 epic touches (pin lockout figures as Phase-1 baseline; the auth-edge two-tier rate-limit note already landed via #350).
- **next-tester:** probes off PR #353 SPECs — REAL gotrue JWTs (admin-seed + signInWithPassword), never a stub bearer.

## SUGGESTED BUILD ORDER
1. Merge prereq PRs to main: #352 (design) + #353 (SPECs) + #348 (deposit epic incl. DEPOSIT-013 read-API) + admin #2/#3 (auth-ui/deposit-ui). (#344/#345/#347/#349/#350 already merged.)
2. Confirm/finish the `stagingprov` stack (brew-ops): fresh Supabase `mb-next-staging` (org lsgheeuhvfqhmombfqsl, ap-southeast-1) + CF Worker + shared AWS egress + mock-merchant.
3. Set the staging project's JWT signing mode → ASYMMETRIC JWT signing keys (design A-2) so the EF is verify-only (JWKS); else fall back to `SUPABASE_JWT_SECRET` (HS256).
4. Build login EFs + `verifyGotrueJwt` + THE CUTOVER (flip + delete stub + re-mint sealed probes, one change) → re-run the full sealed-slice + auth probe suite GREEN.
5. RLS policies + access-token hook (data-model) + the lockout/IP-allowlist/step-up migrations.
6. CF edge config (gateway-infra) + admin-portal login UI (frontend).
7. **SIM-LIVE deposit test (§ADR-21 L1 golden journey, M1 mode):** real operator logs in via the admin portal → drives deposit slip-upload/approve/reject through the admin EFs (now verifying real JWTs) → terminal state. The deposit read-API (DEPOSIT-013) + epic-deposit-ui WUI already cover the read/UI half.

## DEFERRED REGISTER (design 06 §A — none block build; carry into impl)
A-1 always-warm keepalive · A-2 JWKS signing mode · A-3 IP source header (`CF-Connecting-IP`) · A-4 lockout `action_type` enum names · A-5 lockout figures/counter/config · A-6 step-up wiring (DB `step_up_grants`) · A-7 fail-open toggle (per-request DB config-row) · A-8 RLS bodies + access-token hook · A-9 enrollment-race (future ADR) · A-10 onboarding/account-creation.

## GOTCHAS
- **git identity fixed globally** (`117012903+kxlahsimx09@users.noreply.github.com`) so fleet commits now match GitHub. NOTE the docs-site Vercel git-author block on the EXISTING admin-portal commits is the OWNER's one-time fix (relax the Vercel git-author gate / point the docs-site project at `main`) — future commits are clean.
- Machine path (client-API CF Worker, §ADR-7/GW4) is SEPARATE + already design-complete (`docs/design/client-api-gateway/`) — do not entangle with the human-login flip; two verifiers coexist in `_shared/` (one per caller class).
- The 4-lens review of epic-auth-rbac is DONE (#344/#345) — do not redo it.
