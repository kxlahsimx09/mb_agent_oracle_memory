# next-ui — WUI-211..213 /otp-logs UI built (pending §ADR-23 v_otp_logs)

**Agent:** next-ui (slug `next-ui-otp-logs-ui`), 2026-06-17 GMT+7.
**Repo:** `mb-next-admin-portal` · **Branch:** `feat/wui-211-213-otp-logs-ui` (fresh off TRUE `origin/main` tip 906786a — has PR #45 /bank-accounts + PR #46 epic).
**PR:** https://github.com/kxlahsimx09/mb-next-admin-portal/pull/47 — **OPEN, NOT MERGED** (awaiting owner review; goes live only after §ADR-23 substrate deploys).
**Scope:** UI LAYER ONLY (owner-confirmed). NO gateway/substrate work.

## Per-story result
- **WUI-211 ✅** Operator console — admin read-only list + filters (bank account / source sms·email / reference / free-text) + read-only detail, via `from('v_otp_logs')`. Super-admin gate is the view's SERVER-SIDE WHERE; UI shows a deny panel for non-admin (never an empty table). New `src/lib/otp-logs-api.ts` (`readOtpLogs`, `otpLogsAccess`, `VOtpLog`).
- **WUI-212 ✅ (HARD CONSTRAINT MET)** The OTP code is NEVER shown. Mock's click-to-reveal `otp` column + `shown` reveal state + Eye/EyeOff toggle **DELETED** (not masked). `VOtpLog` has **no code field**; no reveal / partial-mask / copy / export of a code anywhere; no code field is ever bound. ALSO removed the orphaned mock `makeOtpLogs`/`otpLogs` (`src/lib/mock.ts`) + `OtpLog` type (`src/lib/types.ts`) — the last place the portal fabricated an `otp` code. Metadata-only.
- **WUI-213 ✅** Read-only (NO create/edit/delete/resend control); graceful loading/empty/retention-aware/error/deny states; **STAYS in `PREVIEW_ROUTES`** (`src/lib/roles.ts:235`, untouched).

## §ADR-23 contract names bound
- read view → `public.v_otp_logs` (P1) — projects metadata only: `id`, `bank_account_id`, `system_bank_code`, `account_name`, `acc_number` (FULL — parity, no mask), `reference_code`, `source` (`sms|email|unknown`), `otp_expires_at`, `created_at`, `last_read_at`, derived `is_expired` (`otp_expires_at <= app_now()`, §ADR-20 T1). **`otp` NEVER projected (P2).**
- RBAC → `otp-log:view` (P3/P4 — super-admin-seeded, already F3-catalogued; only `:view` wired, read-only).
- retention → BBOT-010 24h-post-expiry (empty state reads as retention window, not failure).

## Redaction confirmation (owner non-negotiable)
The OTP code column is DELETED and NEVER bound — `VOtpLog` carries no code field, the live page/columns/detail never reference one, `select('*')` on `v_otp_logs` cannot return a code the view doesn't project, and the mock that fabricated one is gone. No reveal/mask/copy/export affordance exists. This is the OTP analogue of the v_users no-secret-column rule.

## Preview + degrade-gracefully
`/otp-logs` STAYS in `PREVIEW_ROUTES` (NOT de-previewed). §ADR-23 is ratified DOCUMENTS-ONLY; `v_otp_logs` + `otp-log:view` are NOT deployed, so data calls 404 at runtime today — the page degrades to a clean unavailable/empty/deny state (no white-screen). Not live-smoked (would 404). **Goes live only once the §ADR-23 `v_otp_logs` substrate deploys** (then de-preview is the follow-up step).

## Gates (all green)
`tsc --noEmit` ✅ · `eslint` (no new debt) ✅ · `impeccable detect` (changed UI files) ✅ · `next build` ✅ (39/39 pages incl `/otp-logs` prerender clean with env). CI `ui-gate` (merge-blocking) = PASS on PR #47. All new files ≤250 lines (api 114, page 162, columns 89, detail 58).

## Files
new: `src/lib/otp-logs-api.ts`, `src/app/(portal)/otp-logs/otp-log-columns.tsx`, `.../otp-log-detail-modal.tsx`; replaced: `.../otp-logs/page.tsx`; removed mock+type: `src/lib/mock.ts`, `src/lib/types.ts`; i18n: `src/lib/i18n.ts` (EN+TH `otp_*` + `accountName`).

## OPEN QUESTIONS carried (UI did not guess — surfaced in spec)
OQ-2 `from_email` not on next substrate → column dropped. OQ-3 method badges (D/T/P/S) not relay-row fields → dropped (not bound). OQ-1/(c1) 24h metadata-retention window `[RATIFICATION_PENDING:owner]`. OQ-4 parse-failure visibility = net-new (not built).
