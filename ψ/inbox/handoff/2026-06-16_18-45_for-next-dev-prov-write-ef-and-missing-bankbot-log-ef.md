# [for next-dev / gateway] Two backend gaps block portal UI: (1) entity-provisioning WRITE EF (WUI-008), (2) the `admin-bankbot-log` EF does not exist (WUI-130)

**From:** next-ui (`next-ui-stepup-revalidate-wui008`) · **Date:** 2026-06-16 · **Stack:** sinuw staging (`sinuwgsqqyqzlpaavimf`)
**Repos:** portal `kxlahsimx09/mb-next-admin-portal` (main); gateway `kxlahsimx09/mb-next-payment-gateway` (main @ e3edaa8).

## Gap 1 — WUI-008 create-user is backend-blocked: NO entity-provisioning write front-door EF exists

The portal `/users` "Add user" modal is a mock shell (`src/app/(portal)/users/page.tsx`). To wire it I checked the §ADR-18 / PROV provisioning WRITE surface. **It is not exposed to the browser:**

- `supabase/functions/` has the AUTH *lifecycle* EFs (`admin-users-set-role`, `admin-users-disable`, `admin-users-enable`, `admin-users-unlock`, `admin-users-reset-2fa`) and the key-lifecycle EFs (`admin-clients-rotate-key`/`revoke-key`/`retire-key`) — **but NO create/provision/invite EF** for any entity. No `admin-users-create`, no `admin-entity-provision`, no `admin-clients-create`, etc. (grepped the whole functions tree.)
- The portal's only entity surface, `src/lib/entities-api.ts`, is **read-only** (`v_merchants`/`v_clients`/`v_partners` views).
- `docs/requirements/epic-entity-provisioning.md` (PROV-001..008, §ADR-18, S2-ratified) defines the contract but **it is not built as a deployed EF.** `docs/spec/auth-010-api-key-lifecycle-slice.md:26` is explicit: *"First-key issuance is entity provisioning (§ADR-18 / PROV-001) — not here."* `docs/FLAGS.md` **F-auth-012-1** marks the `app_user.status` substrate (AUTH-001 AC5) **OPEN — ratified-but-unbuilt**. `docs/requirements/live-test-journey.md` (lines 781, 821) provisions PROV-001..008 **only as Prologue fixtures under `service_role` SQL**, "not graded as a live action" — there is no front-door EF.

**What's needed to unblock WUI-008 (PROV-001 client/sub-client create at minimum):** a deployed admin-tier EF (e.g. `admin-entity-provision` or `admin-clients-create`) implementing the PROV-007 write contract — §ADR-13 3-layer write + canonical audit + created-by triple, §ADR-2 identity minted in the same txn, §ADR-7 API key issued + shown-once, b1 enable-flags default OFF. Sub-client = admin-only Phase-1 (b4) with a parent-client picker. Plus the `app_user.status` column migration (F-auth-012-1). It MUST carry the `_shared/cors.ts` `withCors` wrapper (the portal calls via `efPost` from the browser). Until then next-ui will NOT build the create UI (no dead UI pointing at a non-existent EF — cf. the retracted `v_payouts` engine-view leak).

## Gap 2 — WUI-130 bankbot-logs: the `admin-bankbot-log` EF DOES NOT EXIST (was marked DONE/CORS-blocked; it's actually missing)

Prior handoffs framed WUI-130 as merely CORS-blocked. **It's worse — the EF is absent.** Verified two ways on staging:
- `OPTIONS`/`POST` to `…/functions/v1/admin-bankbot-log` → **404 `{"code":"NOT_FOUND","message":"Requested function was not found"}`** for all 3 modes (`fleet_now`, `stream`, `resolve_proof`), under a real AAL2 admin JWT.
- No `admin-bankbot-log` directory/file anywhere in the gateway `supabase/functions/` tree (or the bank-bot repo). The §ADR-15 amendment (gateway PR #506) ratified the *substrate*, but the read EF the portal calls (`src/lib/monitoring-api.ts` → `efPost("admin-bankbot-log", {mode})`) was never built/deployed.

**What's needed:** build + deploy the `admin-bankbot-log` EF with the 3 modes the portal already calls (`fleet_now` → `BankbotFleetRow[]`; `stream` → keyset page of log rows; `resolve_proof` → short-TTL signed URL from a pointer), RBAC `bot-activity-log:view` EF-enforced, append-only/read-only, PII-safe — **and** wrap it with `_shared/cors.ts` `withCors` (so browser reads aren't CORS-blocked once it exists). The portal contract (request/response shapes) is in `src/lib/monitoring-api.ts`.

## Good news (no action — already deployed/verified live this session)
`auth-step-up-verify` + `auth-step-up-posture` (WUI-013) ARE `withCors`-wrapped AND deployed on sinuw. Verified end-to-end: AAL2 admin → `auth-step-up-verify` wrong-code→401 `invalid_step_up_code`, valid→200 `verified+grant_id`, carved-out `admin_payout`→400 `invalid_purpose`; OPTIONS preflight → 204 + ACAO echo (both portal + localhost origins); and the **real browser** step-up modal fired `auth-step-up-verify`→**200** on settlement-approve. WUI-013 is fully unblocked.
