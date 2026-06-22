# brew-ops-wf7-redeploy-systembank — START

**Mission:** Redeploy admin portal to Vercel (`mb-next-admin-portal.vercel.app`) at `mb-next-admin-portal main@HEAD = 9eb8fa9` so owner sees `/system-bank` LIVE with NO preview banner. Live site stale at prior deploy `dpl_GYvwADZWkQw9t7T4DBUyj2Tg2c2r` (built at `2dd460f`, before #42 + #44).

**Substrate scope:** admin-UI (substrate d) of workflow-7 ONLY. No DB/EF/worker/prod touched.

## Pre-deploy verification (DONE)
- Checked out `mb-next-admin-portal` `main`, fast-forwarded to `9eb8fa9a4a330dcfdb404c1ed610ee741044ecd7`.
- Last 5 commits confirm #44 (`9eb8fa9` drop /system-bank from PREVIEW_ROUTES) + #42 (`e6dd439` wire /system-bank → v_system_banks) both present; prior deploy was at `2dd460f` (#41).
- Source audit at HEAD:
  - `src/lib/roles.ts:226` — `/system-bank` commented OUT of PREVIEW_ROUTES (now live). `isPreviewRoute("/system-bank") === false`.
  - `src/lib/system-bank-api.ts:55` reads `.from("v_system_banks")`.
  - `src/app/(portal)/system-bank/page.tsx` renders the live mapped rows.
  - Preview banner = `src/components/shell/preview-notice.tsx` `PreviewNotice` (role="status", text "Preview screen"/"ตัวอย่างหน้าจอ"), rendered in `layout.tsx:60` only when `isPreviewRoute(pathname)`.

## Plan
1. source staging.env (VERCEL_TOKEN); validate `vercel whoami`.
2. git-less re-stage of `mb-next-admin-portal@9eb8fa9` (exclude .git + docs-site, carry .vercel/project.json).
3. `vercel deploy --prod --yes` with two Supabase --build-env vars (from next-ui.env). Alias to mb-next-admin-portal.vercel.app. PATCH ssoProtection=null only if 401.
4. VERIFY with Playwright using portal-test-cast.env U_SA super-admin (live TOTP): captured v_system_banks 200 + rendered rows + ABSENCE of PreviewNotice (role=status "Preview screen").

Status: pre-deploy verified, proceeding to stage + deploy.
