# next-ui — /users list wired to v_users (AUTH-011/012 UI-flip ready)

**Agent:** next-ui (slug `next-ui-finish-userslist`) — salvage of the stalled `next-ui-wire-userslist`.
**Repo:** kxlahsimx09/mb-next-admin-portal · **Branch:** `feat/next-ui-wire-userslist` · **Commit:** `9ad246f`.
**Stacked PR:** #39 → base `feat/wui-006-009-015-livewire` (PR #37, head `bf9c5c1`). **OPEN, not merged. Must merge after #37.**

## What I finalized
The prior agent's uncommitted working tree was correct end-to-end; I reviewed, validated, committed, and PR'd it (no code rewrite needed beyond review).

`/users` now LISTS real users from the leak-safe `public.v_users` read surface via `supabase.from('v_users').select('*')` (newest first), replacing the mock seed. Each row's `id` (= gotrue `sub` / `app_user.id` = the `user_id` every lifecycle EF takes) drives the already-wired WUI-006/009 per-row actions:
- **set-role** (AUTH-011 `admin-users-set-role`)
- **disable/enable** (AUTH-012 `admin-users-disable`/`-enable`)
- **unlock** (AUTH-005 `admin-users-unlock`, super-admin display-gate; server enforces `admin:super`)

Files (all ≤250 lines): `src/lib/admin-users-api.ts` (added `AdminUserRow` contract + `listUsers()`), new `src/app/(portal)/users/users-access.ts` (read posture + `toUserRow`: `is_locked→locked` priority > active > inactive, id verbatim), new `src/app/(portal)/users/users-columns.tsx` (live columns + per-row action buttons), `src/app/(portal)/users/page.tsx` (live list w/ loading / load-error / RBAC-empty "no access" deny panel; refetch-after-action, no optimistic flip, no refetch on 4xx), `src/lib/roles.ts` (dropped `/users` from PREVIEW_ROUTES).

## Validation evidence
- **PRIMARY (substrate-proven):** `@supabase/supabase-js` script from repo root — aal2 admin login (password + RFC6238 TOTP from `UI_ADMIN_TOTP_SECRET`) → the EXACT `from('v_users').select('*').order('created_at',desc)` call `listUsers()` makes → **327 rows, all 13 contract keys present**, shape matches `AdminUserRow`. Matches brew-ops (aal2→327, aal1→0, anon→401). Data path proven without a browser.
- **Gates:** `tsc --noEmit` ✅ · `eslint` ✅ · `next build` (prod) ✅ (`/users` prerenders).
- **SECONDARY (UI smoke): DEFERRED / FLAKY.** Headless chromium could not reach the external Supabase host from the sandbox (`ERR_NAME_NOT_RESOLVED`/`Failed to fetch`), so login didn't complete and `/users` didn't render under the browser. Bounded (`timeout 120`), did not hang, killed cleanly. Non-blocking — substrate check covers the same creds + exact query.

## Note to liverun — AUTH-011/012 legs now UI-drivable
The §ADR-21 harness can flip AUTH-011 (set-role) and AUTH-012 (disable/enable), plus AUTH-005 (unlock), from `via=api → via=ui` per-row off `/users`. **Selector titles to drive (localized, TH default):**
- Page title: `ผู้ใช้งาน` (nav_users)
- Assign role button: title `กำหนดบทบาท` / EN `Assign role` (modal radiogroup `เลือกบทบาท`, canonical roles `super_admin|client_admin|client_viewer|partner_user`, primary save button)
- Disable: title `ปิดใช้งาน` / EN `Disable`
- Enable: title `เปิดใช้งาน` / EN `Enable`
- Unlock (super-admin only, shown when row status=locked): title `ปลดล็อก (super-admin)` / EN `Unlock (super-admin)`
- Lifecycle confirm modal uses the shared `confirm` button.
Note for liverun: the UI smoke couldn't run here due to sandbox browser→Supabase egress; if the live harness has real network egress this should drive fine. RBAC-empty (non-admin) shows deny panel `ไม่มีสิทธิ์ดูรายชื่อผู้ใช้`; load error shows `โหลดรายชื่อผู้ใช้ไม่สำเร็จ`.

## Cleanup
Secret-free confirmed: no `.env.local`, temp scripts (`.substrate-check.mjs`, `.ui-smoke.mjs`) removed, background `next start` + chromium killed, `/tmp` pid/log removed. `git status` shows only the 5 intended committed files; nothing untracked.
