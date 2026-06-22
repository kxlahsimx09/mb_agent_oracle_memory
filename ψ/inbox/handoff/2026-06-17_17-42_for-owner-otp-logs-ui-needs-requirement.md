# [for owner] `/otp-logs` UI — needs a REQUIREMENT first (owner will dispatch the spec)

**From:** orchestrator (bui session) · **2026-06-17 17:42 (GMT+7)** · **Re:** owner ask "wire `/otp-logs` to real data; if a requirement is missing, handle the spec"

> Captured per owner direction: **handoff only — the owner dispatches the spec themselves** (do NOT auto-dispatch an agent to author it). Same shape as `/bank-accounts` was.

## TL;DR
`/otp-logs` is a MOCK. Wiring it to live data is **blocked on two missing pieces** — there is **no UI requirement** and **no admin read surface** — and the OTP code is a **live secret** that must be redacted. It is NOT a wiring job; it needs (1) a requirement, (2) a leak-safe backend read view, then (3) the UI wire. Mirror the just-merged `/bank-accounts` flow (§ADR-22 + BENE epic + WUI-201..205).

## What's there today (verified on main)
- **Portal:** `src/app/(portal)/otp-logs/page.tsx` reads `otpLogs` from `@/lib/mock` (pure mock; `bankCode` field ⇒ this is the **bank-OTP relay** log, NOT user-auth 2FA). `/otp-logs` is in `PREVIEW_ROUTES` (banner shows — correct).
- **Requirement: MISSING.** The gateway `docs/requirements/INDEX.md` explicitly states the bank-OTP relay (`otp_logs`, BBOT-010) is *"bot-side, not user auth — routed to `cross-repo.md`, **not authored as an auth story**."* There is no UI/WUI story for an operator OTP-logs screen.
- **Substrate: MISSING (zero-grant).** `otp_logs` (BBOT-010, migration `20260614000010_bbot010_otp_relay.sql`) is **SV7b zero-grant**: `ALTER TABLE otp_logs ENABLE RLS` with NO policies + `REVOKE ALL ON otp_logs FROM PUBLIC, anon, authenticated` — **service-role (EF tier) only**. No `v_otp*` admin-readable view exists. (Schema: FK `bank_account_id`, NO `user_id`, `reference_code`, `otp_expires_at`, source SMS/email, single-use/expiry, timestamps; the OTP **code value** is stored here.)

## What it would take to make `/otp-logs` live (3 steps — the owner drives)
1. **Requirement** (a UI epic + the implied substrate spec / ADR, current-system parity) — model on the `/bank-accounts` stack: `epic-bank-account-ui.md` (WUI band) + gateway `§ADR-22` + `epic-beneficiary-bank-account.md` (BENE).
2. **Backend read surface** — a leak-safe admin view over `otp_logs` (mirror `v_users` / `v_system_banks`: `security_barrier`, admin-tier gate in WHERE, base table stays zero-grant) + a new RBAC resource (e.g. `otp-log:view`).
   - **🔒 HARD: redact the OTP code value.** The OTP code is a LIVE SECRET — it must NEVER be projected in the view (even to admin). Expose only metadata: bank_account, bank, `reference_code`, source, `otp_expires_at`, single-use/expiry status, `created_at`, parse-status. This is the OTP analogue of the `v_users` no-secret-column TEETH rule.
3. **UI wire** — replace the mock read with the view; per-bank-account filter + detail; read-only (it's a log). De-preview only after the view deploys.

## Open OWNER DECISIONS (resolve before/within the spec)
1. **Who reads OTP-relay logs?** admin only, or also the owning client/partner of the bank account?
2. **Retention / PII window** for the metadata?
3. **Parity scope** — does current production's `/otp-logs` show anything beyond metadata (and definitely never the raw OTP)?
4. **Surface placement** — does an OTP-relay log viewer belong in THIS admin portal, or a bot/monitoring surface (it's "bot-side" per the gateway INDEX)?

## Reference (for whoever authors the spec)
- Mock contract: `mb-next-admin-portal/src/lib/mock` `otpLogs` + `src/lib/types.ts` + `src/app/(portal)/otp-logs/page.tsx`.
- Substrate: gateway `supabase/migrations/20260614000010_bbot010_otp_relay.sql` (the `otp_logs` table) + BBOT-010 in the gateway INDEX + `docs/requirements/cross-repo.md`.
- Leak-safe view precedent: `v_users` (`20260616000040`) / `v_system_banks` (`20260617000030`).
- Spec-stack precedent the owner approved: `/bank-accounts` — §ADR-22 + `epic-beneficiary-bank-account.md` (BENE) + `epic-bank-account-ui.md` (WUI-201..205).

## Status of the related UI work (this session)
- `/system-bank` → **LIVE** (portal #42 + #44 merged, redeployed `dpl_Bmwy…`; gateway view #553 still OPEN).
- `/bank-accounts` → **UI built** (PR #45, code-complete) but stays preview until BENE-001..006 substrate is built+deployed; BENE-007 (enforced payout linkage) is an open owner decision (kept advisory).
