---
title: brew-ops (thread #18, 2026-06-12) — provisioning a synthetic MFA-capable admin l
tags: [brew-ops, repo:mb-next-payment-gateway, next, auth, rbac, mfa, totp, aal2, provisioning, gotrue, next-ui, finding, decision]
created: 2026-06-12
source: thread #18 2026-06-12; provisioned next-ui.env on sinuw; mintGotrueBearer reuse + live AAL2/RBAC proof
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# brew-ops (thread #18, 2026-06-12) — provisioning a synthetic MFA-capable admin l

brew-ops (thread #18, 2026-06-12) — provisioning a synthetic MFA-capable admin login slot on a stack (next-ui browser pass), + the admin-tier-read-only gap.

## Recipe — reuse the canonical mintGotrueBearer (do NOT hand-roll gotrue calls)
`tests/integration/probes/_auth-gotrue.ts` exports `mintGotrueBearer(ctx, seed)` and `totp(secret)`. It is the same path that mints the qnccph seal-stack synthetic identities. Given `ctx = {supabaseUrl, anonKey, serviceRoleKey, fnBase, botSecret}` (build from the stack slot) and `seed = {user_type:"admin", role:"super_admin", username, email?, password?}` it: (1) creates/refreshes the gotrue user via `POST /auth/v1/admin/users` (`email_confirm:true`, stamps `app_metadata.entity_type/role`), (2) upserts the `app_user` row on `on_conflict=username` repointing `id` onto the gotrue sub (so `adminAuth`'s DB-fresh lookup resolves), (3) resets factors then enrolls + **verifies** a fresh TOTP factor, returns `{bearer, userId, email, secret, factorId}`. Idempotent (sign-in-first). Run it once via a tiny Bun runner that imports the module; pass a fixed username+email+password so the identity is storable/repeatable. On a SHARED live stack use a DISTINCT username (e.g. `next-ui-admin`, NOT the pre-seeded `probe-admin`) so you don't repoint a probe identity.

## What persists / what next-ui needs
After one run the stack holds: a gotrue user (email+password), an `app_user` row (role drives RBAC), and ONE verified TOTP factor (secret known). next-ui then drives the REAL portal front door: `POST /functions/v1/auth-login {email,password}` → 200 `{requires_2fa, temp_token, factor_id}` (challenge branch, because the factor is verified) → `POST /functions/v1/auth-2fa-verify {code: totp(secret), temp_token, factor_id}` → 200 `{data:{token: <AAL2>, role, mfa_required:false}}`. So the slot needs only: public `SUPABASE_URL` + anon key + `UI_ADMIN_EMAIL/PASSWORD/TOTP_SECRET` — NO service-role key, NO DB password (minimal privilege). A missing `admin_profiles` row is GRACEFUL (auth-login uses `maybeSingle` → null → IP gate passes), so you need not create one. To force the ENROL/setup screen instead of challenge, reset 2FA first (admin-users-reset-2fa) → `requires_2fa_setup`.

## RBAC mapping (verified on sinuw)
`role='super_admin'` holds EXACTLY 13 `:view` permissions = the "13 admin read screens", 1:1: activity-log, bank-transactions, client, deposit-log, deposit, mdr-shared, merchant, partner, payout, transaction, wallet-log, wallet, withdrawal-queue (merchant/client/partner = the CA8 entity-views). Proof of authorization: an `admin-deposit` read with the AAL2 token returns 400 (bad body) NOT 401/403 → auth+RBAC passed the gate.

## FINDING — no admin-tier read-only role (over-privilege for read-only passes)
`super_admin` is the ONLY admin-tier role carrying the 13 `:view` perms, and it ALSO carries write/money-out perms (`deposit:approve`, `payout:cancel`, `user:reset-2fa`, `security-config:update`). The §ADR-13 catalogue has no admin `*_viewer` tier (only client_viewer on the client axis). So any synthetic identity that needs to SEE all 13 admin read screens is necessarily over-privileged. A least-privilege `admin_viewer` would be a catalogue add (architect decision), not a brew-ops posture fix. Routed to secres/architect.

Slot recorded in README-slots.md as `next-ui.env` (login-only, sinuw). Verified factor secret stays in `auth.mfa_factors` (native gotrue MFA; no app table stores AAL — `aal` is a JWT claim read by `adminAuth`/RLS `auth_aal2()`).

---
*Added via Oracle Learn*
