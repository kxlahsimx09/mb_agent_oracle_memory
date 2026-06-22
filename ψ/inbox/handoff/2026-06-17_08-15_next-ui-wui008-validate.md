# next-ui — WUI-008 validated + staging cleaned

**Agent:** next-ui-wui008-validate (fresh dispatch). **Repo:** kxlahsimx09/mb-next-admin-portal, branch `feat/wui-008-create-client`, PR #41 (commit `245169a`, NOT merged). **Target:** staging sinuw (`sinuwgsqqyqzlpaavimf`).

## Outcome: WUI-008 PARTIAL → **DONE** (validated end-to-end on staging)

## 1. Leftover throwaway-client cleanup (staging hygiene) — DONE
Found **2** leaked `zz-wui008-smoke%` clients from the prior build agent's interrupted validation; **0** `zz-prov001-smoke%` stragglers. Each had exactly: 1 `client` row + 1 `app_user` row (id = gotrue user id) + 1 gotrue user (`...@clients.local`); `wallet` + callback-endpoint tables empty (never transacted). Deleted via sinuw service-role (from `slots/staging.env`) in FK-safe order — gotrue user (cascades auth.users/identities) → app_user → client. `audit_log` left append-only (untouched).
- `zz-wui008-smoke-8b5db3` (client `75919ee8-…a22d`) — removed
- `zz-wui008-smoke-b9c7a5` (client `d4db545f-…45c28`) — removed
- Post-delete verify: **0 remaining** for both patterns.

## 2. CI gate (PR #41) — GREEN
`ui-gate` = **pass** (1m12s — tsc/eslint/build). The only red is the "Vercel" check, which is a commit-author-email mismatch ("No GitHub account was found matching the commit author email"), NOT a code/build failure; PR is `MERGEABLE`. No branch fix needed.

## 3. Browser UI-smoke (the deferred validation) — PASS, all green
Local prod build (`next build`, BUILD_ID `y33iJ5UEnMlpZoOfoKs2B`) + `PORT=3000 next start`; Playwright (playwright-core + cached chromium-1223) drove the real UI:
- **aal2 login**: real-form email/password + TOTP step-up (slot `UI_ADMIN_*`) → reached `/dashboard`.
- **Create-client modal** opened from /users; merchant picker populated from live `v_merchants` read surface.
- **201 happy path** (CAPTURED, not "no error"): network `POST functions/v1/admin-clients-create → 201`, `client_id 79ca13f0-…ff34`; the once-shown secret panel rendered in DOM — `api_key` = `pk_147b228d8…`, `api_key_secret` = `sk_…` (both `<code>`); success state "I've saved the keys — close" visible.
- **4xx path** (duplicate username): network `→ 409`, honest error surfaced, **modal stayed open** (no optimistic done) — confirms the no-done-on-4xx behavior.

## 4. My own throwaway cleanup — DONE
The 201 minted `zz-wui008-smoke-09dd71` (client `79ca13f0-…ff34`, gotrue `fce48b0e-…b1b5`); deleted (gotrue + app_user + client). The 409 dup path created nothing. Post-verify: **0 remaining** `zz-wui008-smoke%`.

## Secret-free confirmation
`.env.local` (NEXT_PUBLIC_* only, gitignored) removed; all `/tmp` temp scripts + screenshots removed; chromium + next-server killed by PID; nothing on :3000; `git status` clean; HEAD still `245169a`. No secrets in the tree.

## Tally
WUI-008 create-client: **DONE** (code committed+pushed+PR'd #41, ui-gate green, UI-smoke 201 + once-shown secret + 4xx-keeps-modal-open all verified live on sinuw). Awaiting user merge of PR #41 (do not self-merge).
