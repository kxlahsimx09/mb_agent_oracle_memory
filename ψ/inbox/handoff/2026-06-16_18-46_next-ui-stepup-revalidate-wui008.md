# next-ui — WUI-008 + CORS re-validation

**Slug:** `next-ui-stepup-revalidate-wui008` · **Date:** 2026-06-16 (GMT+7) · **Repo:** `kxlahsimx09/mb-next-admin-portal` (main) · **Stack:** sinuw staging (`sinuwgsqqyqzlpaavimf`)
**Source of truth followed:** `docs/handoff-next-ui.md` + `docs/gap-analysis-wui.md` + Oracle handoff `2026-06-16_17-19_next-ui-wui-013-…-pr36-retro`.

## TL;DR
WUI-008 is **backend-blocked** (no provisioning write EF) — filed a `[for next-dev]` handoff, built **no** UI (no dead UI). Re-validated the shipped browser flows on staging: **WUI-013 step-up is GREEN end-to-end in the real browser** (CORS deployed + verified by a 200 network response). **WUI-130 bankbot-logs is still blocked — the `admin-bankbot-log` EF does not exist** (404, not merely CORS). Tally unchanged: **15/34 DONE · 4 PARTIAL · 15 MISSING (+Bankbot)**.

## Task A — WUI-008 create-user → BACKEND-BLOCKED (no UI built; correct per mission)
Checked the §ADR-18 / PROV entity-provisioning WRITE surface before building. **It is not exposed to the portal:**
- Gateway `supabase/functions/` has AUTH *lifecycle* EFs (`admin-users-set-role/disable/enable/unlock/reset-2fa`) + key-lifecycle EFs — but **NO create/provision/invite EF** for any entity.
- Portal `src/lib/entities-api.ts` is **read-only** (`v_merchants`/`v_clients`/`v_partners`).
- PROV-001..008 (§ADR-18) is S2-ratified but **unbuilt as a deployed EF**: `auth-010-…slice.md:26` ("first-key issuance is provisioning — not here"), `FLAGS.md` F-auth-012-1 (`app_user.status` "OPEN — ratified-but-unbuilt"), `live-test-journey.md` 781/821 (PROV provisioned only as `service_role` SQL fixtures, "not graded as a live action").
- **Action taken:** filed `[for next-dev]` handoff `2026-06-16_18-45_for-next-dev-prov-write-ef-and-missing-bankbot-log-ef.md` with the exact EF needed (PROV-007 write contract: §ADR-13 3-layer + audit + created-by triple, §ADR-2 identity mint, §ADR-7 key shown-once, b1 flags-off, b4 admin-only sub-client, + `app_user.status` migration, + `withCors`). Built **no** create UI. Created branch `feat/wui-008-create-user`, made zero changes, deleted it. **No PR** (nothing to ship).

## Task B — CORS re-validation (no `[for next-ui]` CORS handoff arrived; I verified directly)
No new `[for next-ui] step-up + bankbot CORS deployed` handoff was in the inbox (bounded wait). The state was knowable from source + live probes, so I verified directly against staging.

**WUI-013 step-up → GREEN (fully unblocked, browser-proven):**
- Gateway main: `auth-step-up-verify` + `auth-step-up-posture` both `withCors`-wrapped; deployed on sinuw (PR #534/#536).
- OPTIONS preflight (warmed) → **204 + `Access-Control-Allow-Origin` echo** for both `https://mb-next-admin-portal.vercel.app` and `http://localhost:3000`. (A cold-start gives a transient 405/no-ACAO — warm it before judging.)
- **Substrate check** (real AAL2 admin via password + RFC6238 TOTP from `UI_ADMIN_TOTP_SECRET`): `auth-step-up-verify` wrong-code→**401** `invalid_step_up_code`, valid→**200** `verified+grant_id+expires_at`, carved-out `admin_payout`→**400** `invalid_purpose`. `auth-step-up-posture`→400 `missing_fail_open` (alive/reachable; needs the `fail_open` arg the escape-hatch UI sends).
- **Real-UI Playwright** (local prod build w/ live `.env.local`, `PORT=3000 npm run start`, cached chrome-headless-shell): real-form login→MFA→**aal2 (`/dashboard`)** → `/settlement` (3 `อนุมัติ` buttons) → approve → confirm → **step-up modal → TOTP → `auth-step-up-verify` fired → 200**. Confirmed by the captured network response, NOT "no Playwright error". **WUI-013 browser flow completes end-to-end.**

**WUI-130 bankbot-logs → STILL BLOCKED, reclassified (EF missing, not CORS):**
- `admin-bankbot-log` (all 3 modes `fleet_now`/`stream`/`resolve_proof`) → **404 `Requested function was not found`** under AAL2 admin. The EF **does not exist** in the gateway functions tree (or bank-bot repo). Portal calls it from `src/lib/monitoring-api.ts`. Routed in the same `[for next-dev]` handoff (build + deploy the EF with `withCors`).

## Cleanup
Live-test ran in the `mb-next-admin-portal.wt-1-uidev` worktree (it has node_modules + playwright-core + a Next build). Removed `.env.local` + both temp scripts; killed the prod server; port 3000 free; worktree is secret-free (only `docs/handoff-next-ui.md`'s recipe *mentions* the secret key names, no values).

## Updated tally + next ordered action
- **Tally:** 15/34 DONE · 4 PARTIAL · 15 MISSING (+Bankbot) — **unchanged** (no buildable-now UI remained; WUI-008 is backend-blocked).
- **WUI-013 should be re-marked validated-on-staging (browser-proven), not just "CORS-pending".** WUI-130 should be downgraded from DONE → blocked (missing EF), in `docs/gap-analysis-wui.md`.
- **Next ordered action:** all remaining stories are backend-blocked. Highest-leverage next-dev items: (1) the `admin-bankbot-log` EF (unblocks already-built WUI-130 UI immediately), (2) the PROV-001 entity-provisioning write EF + `app_user.status` migration (unblocks WUI-008). Both routed in the `[for next-dev]` handoff. The only portal-side buildable-now work left is the P2P epic (WUI-115..122, excluded by request).
