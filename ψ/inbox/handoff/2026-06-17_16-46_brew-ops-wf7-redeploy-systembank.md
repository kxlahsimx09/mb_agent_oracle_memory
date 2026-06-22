# brew-ops-wf7-redeploy-systembank — DONE ✓

**Mission accomplished.** Admin portal redeployed to `mb-next-admin-portal.vercel.app` at `9eb8fa9` (main@HEAD). The owner's "still preview" report is CLOSED — `/system-bank` is LIVE with real rows and NO preview banner.

## Deploy (workflow-7 substrate d, git-less recipe)
- Source: `mb-next-admin-portal main@9eb8fa9a4a330dcfdb404c1ed610ee741044ecd7` (fast-forwarded from 2dd460f; includes #42 wire→v_system_banks + #44 drop from PREVIEW_ROUTES).
- git-less stage: rsync excluding `.git/`, `docs-site/`, `.agent` (symlink), `node_modules/`, `.next/`, `.env.local`; carried `.vercel/project.json` (prj_ZIwsqrarjYCYgIgxMUgNAocANSCH / team_NcQL9QEsv53GkO7pBqyiyMFC).
- `vercel deploy --prod --yes` with `--build-env NEXT_PUBLIC_SUPABASE_URL` + `NEXT_PUBLIC_SUPABASE_ANON_KEY` (from next-ui.env). Token from staging.env (whoami=midasgoteam-ops).
- **NEW deployment: `dpl_BmwyAsmFfdfeftt4LHYTJSMMSxX4`** (state READY, target production). ≠ prior `dpl_GYvwADZWkQw9t7T4DBUyj2Tg2c2r`.
- Auto-aliased to `https://mb-next-admin-portal.vercel.app`. `vercel inspect` confirms alias → new dpl.
- ssoProtection PATCH NOT needed — alias served 200 directly.

## Verify (acceptance)
- HTTP: root 200, /system-bank 200, /users 200.
- Bundle is new code: live chunk `/_next/static/chunks/3_b7uly1wg4jm.js` contains `v_system_banks` (#42 symbol) — proves 9eb8fa9, not stale 2dd460f.
- Playwright real-form login as **U_SA super-admin** (portal-test-cast.env, password + live RFC6238 TOTP from U_SA_TOTP_SECRET; NOT next-ui.env). Logged in → /dashboard as `olive-u-sa+hk32qr` (role admin).
- On /system-bank, captured network: `GET sinuwgsqqyqzlpaavimf.supabase.co/rest/v1/v_system_banks?select=*&order=created_at.desc` → **200**.
- **Preview banner ABSENT**: 0 by text ("Preview screen"/"ตัวอย่างหน้าจอ"); the lone role=status element is LiveIndicator, not PreviewNotice.
- **7 real rows rendered** (footer "7 บัญชี · Σ 403,000,000.00 THB"): OLIVE ktb/kbank/scb + M&K Property Real Estate Co. accounts (real account nos, pools olive-P3-ktb/olive-P1/olive-P2/main_pool, balances, working=พร้อม, bot=ออนไลน์). No deny panel, no load-error.
- Screenshot visually confirmed before cleanup. **VERDICT: PASS.**

## Hygiene
- Cleaned: stage dir, prior stale /tmp/portal-deploy-staged (had leftover .env.local), verify driver, screenshots, deploy log. No leftover chrome/bun procs.
- Worktree clean at 9eb8fa9, secret-free (no .env.local, no token shapes in tracked files).

## Note (not in mission scope)
This run did NOT emit the workflow-7 STAGING-DEPLOY-MANIFEST update (mission was a targeted admin-UI redeploy, not a full wf7 run). If a manifest re-stamp is wanted, record: admin-ui | 9eb8fa9 | main | deployed | dpl_BmwyAsmFfdfeftt4LHYTJSMMSxX4.
