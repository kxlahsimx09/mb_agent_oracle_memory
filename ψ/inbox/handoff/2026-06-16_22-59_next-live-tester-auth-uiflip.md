# [post-merge] AUTH UI-flip smoke — /users + /clients

**Agent:** next-live-tester-auth-uiflip (fresh)
**Repo/build:** kxlahsimx09/mb-next-admin-portal @ merged `main` (#37 wiring + #39 /users list, commit 2c58fda). Local prod build (`next build`/`next start`) on PORT=3000, env from fleet slot `mb-next-payment-gateway/slots/next-ui.env` → sinuw / mb-next-staging (ref sinuwgsqqyqzlpaavimf).
**Mode:** REAL UI-driven (headless chromium → rendered page → click → live EF). Verified by CAPTURED EF network status + DOM, not "no Playwright error".

## Headline
Browser EGRESS is NOT blocked in this sandbox. The pre-flight (`timeout 30` Playwright nav to `${SUPABASE_URL}/auth/v1/health`) returned a live 401 GoTrue body — DNS+TLS+HTTP all reach sinuw. The prior `next-ui-finish-userslist` agent's ERR_NAME_NOT_RESOLVED did NOT recur. So the UI-render leg was attempted CLEANLY and PASSED; no fallback/deferral needed.

## Per-leg result (all UI-driven, captured EF 200)
- **Login**: real-form password → MFA challenge (RFC6238 TOTP from UI_ADMIN_TOTP_SECRET, computed via node crypto HMAC-SHA1) → AAL2 → landed `/dashboard`.
- **/users list**: `/rest/v1/v_users` network **200**, **327 rendered `<tr>`s** (live directory, matches substrate-proven count).
- **AUTH-012 disable** (`admin-users-disable`): clicked rendered Disable on `probe-client-user` → confirm → **200**. ✅ UI-drivable.
- **AUTH-012/005 enable** (`admin-users-enable`): clicked Enable on now-inactive row → **200** (state RESTORED). ✅ UI-drivable.
- **AUTH-011 set-role** (`admin-users-set-role`): Assign-role → picked `client_viewer` → Save → **200**; then flipped back to `client_admin` → **200** (RESTORED). ✅ UI-drivable (two clean 200s, self-restoring).
- **AUTH-005 unlock** (`admin-users-unlock`): NOT fired — the unlock button only renders for `status==locked` rows and none are locked; I refused to hard-lock a real user just to unlock. Same proven `efPost` Bearer path as the others; super-admin permission substrate-confirmed (self-row = next-ui-admin / super_admin). Treat as **wired, EF-unexercised-this-round** (low risk).
- **/clients (AUTH-010)**: **read-only confirmation** — 10 client rows, **10 rotate + 10 revoke** buttons render for the admin; rotate modal opens with its Rotate/Confirm button present (wired). Did **NOT** fire rotate/revoke (destructive on a shared staging client; rotate demotes the active key, revoke kills both slots irreversibly). Cancelled out. **UI present + wired confirmed; live EF fire DEFERRED (shared-client safety), not env.**

## Are AUTH-010/011/012 now confirmed UI-drivable?
- **AUTH-011 (set-role)**: YES — UI-driven 200 ×2, self-restoring.
- **AUTH-012 (disable/enable)**: YES — UI-driven 200 each, self-restoring.
- **AUTH-005 (unlock)**: UI control wired; EF not fired (no locked row to act on safely).
- **AUTH-010 (client key rotate/revoke)**: action UI present + wired in the rendered page; live EF fire withheld for shared-client safety, NOT an environment block.

## State integrity
`probe-client-user` (88888888-…-000000000002) substrate-re-read post-run: status=active, role=client_admin, is_locked=false — exact pre-test state. No residual mutation.

## Note to liverun
- **Flip `via=ui` now**: AUTH-011 set-role, AUTH-012 disable/enable — proven UI-driven (rendered click → captured EF 200) against sinuw this round.
- **AUTH-005 unlock**: needs a deliberately locked fixture to exercise the UI unlock click; harness should seed one locked test user then drive unlock for the `via=ui` flip.
- **AUTH-010 rotate/revoke**: harness with real egress should drive these against a DEDICATED throwaway client (not a shared key) to flip `via=ui` — the UI is confirmed present + wired here, only the destructive fire was withheld.
- Sandbox chromium DOES have egress to sinuw (contra the earlier ERR_NAME_NOT_RESOLVED note) — UI-driven runs are viable from here, not only the liverun harness.

## Cleanup (secret-free, verified)
`.env.local` removed; all temp scripts (uiflip-preflight/substrate/driver/restore-check.mjs) removed; spawned `next start` + chromium killed; `git status` empty/clean on `main`; no sinuw host or admin-cred leak in tracked source.
