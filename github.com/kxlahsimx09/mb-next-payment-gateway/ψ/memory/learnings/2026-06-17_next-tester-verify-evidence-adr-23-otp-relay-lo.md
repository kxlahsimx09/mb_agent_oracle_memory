---
title: next-tester VERIFY evidence — §ADR-23 OTP-Relay Log read surface (v_otp_logs), P
tags: [next-tester, repo:mb-next-payment-gateway, next, otp, evidence, v_otp_logs, leak-safe-view, rbac, security-barrier, teeth, harness-self-validation, fixture-source:repo-flow-doc, otplog-001]
created: 2026-06-17
source: tests/integration/run-otplog.ts@f2c01cd; evidence/integration-otplog-1781699850536-f2c01cd9.json
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# next-tester VERIFY evidence — §ADR-23 OTP-Relay Log read surface (v_otp_logs), P

next-tester VERIFY evidence — §ADR-23 OTP-Relay Log read surface (v_otp_logs), PR #566, campaign otplogsbuildt. Verdict GREEN 25/25 PASS, 0 FAIL, V4-stable (3 consecutive green), harness self-validated to have teeth. Run on tester stack yupsevcrubgprsbujbpu; probe-code git-sha f2c01cd.

TEETH (headline) — the OTP code value is NEVER present in v_otp_logs — confirmed 3 independent ways + negative-access matrix:
- ABSENCE (schema): information_schema column set = exactly the 11 SPEC §3 cols; 0 forbidden (code/otp/passcode/pin/secret) columns.
- ABSENCE (wire): select=<forbidden> → PostgREST 400 col-not-exist for all 13 forbidden names; control select=acc_number → 200.
- BEHAVIORAL: seed a unique OTP code marker into base otp_logs.otp → read view as gated super-admin (aal2+super_admin+admin) → cast whole row to text (PostgREST select=* AND raw v_otp_logs::text) → code marker ABSENT in every projected column; positive-control acc_number marker present (proves rows really are the seeded ones).
- MATRIX: N0 anon→401 denied; N1 aal1 super_admin→0 rows (isolates aal2 leg); N2 aal2 non-perm partner_user + admin tier→0 (isolates perm leg); N3 aal2 super_admin role + client tier→0 (isolates admin leg); N4 aal2 no-claim→0; N5 aal2 partner→0; POS aal2 super_admin/admin→2 rows (== seeded; proves negatives' 0 is a GATE, not an empty table). security_barrier=true held — caller-supplied reference_code filter never became a row-content oracle for any negative caller.
- SV7b INTACT: base otp_logs denied to anon (401) AND to the gated super-admin who CAN read the view (403) — GRANT is on the view ONLY.
- §4 RBAC: otp-log:view seeded to super_admin ONLY. §3 is_expired derived via app_now() (fresh→false, expired→true).

KEY HARNESS TECHNIQUE (reusable for leak-safe read-view slices like v_users/v_system_banks): the two teeth predicates are PURE exported functions (forbiddenColumnsPresent, codeMarkerLeaks) shared by the live suite AND an offline self-check (harness-selfcheck-otplog.ts) that proves they FLIP to a violation on a leaky control (a view shape carrying otp/otp_code/code; a row-as-text containing the code marker) BEFORE trusting any green. In-suite selfcheck:* rows additionally run the live predicates against the base otp_logs (which has the otp column + seeded code) as a negative control — detector must fire there. De-bias preserved: SPEC + DB ground-truth only; next-dev supabase/ code never read.

Artifacts: tests/integration/probes/otplog/otplog-probes.ts, tests/integration/run-otplog.ts, tests/integration/harness-selfcheck-otplog.ts, evidence/integration-otplog-*.json, next-tester_otplogsbuildt_findings.md. JWT minting reused tests/integration/probes/auth/_authctx.ts (real gotrue aal1/aal2 mint). Seed via service-role PostgREST; introspection + raw row::text via Management-API database/query (read-only channel).

---
*Added via Oracle Learn*
