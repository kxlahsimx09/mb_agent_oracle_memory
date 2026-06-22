---
title: §ADR-13 SV8 `execute_or_no_grants` allowlist amendment — `_otp_log_app_now()` ra
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, decision, rbac, sv8, otp-log, execute_or_no_grants, security-definer]
created: 2026-06-17
source: docs/adr.md §ADR-13 Revision log @ ad85919 (PR #574)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# §ADR-13 SV8 `execute_or_no_grants` allowlist amendment — `_otp_log_app_now()` ra

§ADR-13 SV8 `execute_or_no_grants` allowlist amendment — `_otp_log_app_now()` ratified (the 7th member; #456 precedent realized a 2nd time).

Decision: the gated SECURITY DEFINER reader `_otp_log_app_now()` is a legitimate member of the SV8 `execute_or_no_grants` allowlist — it legitimately holds `authenticated` EXECUTE. Ratified as a §ADR-13 §Amendment 2026-06-11 SV8 Revision-log entry (docs/adr.md, append-only), within architect authority — no new owner decision (owner said proceed / "ทำเลย"). PR #574 (docs), MERGED 2026-06-17 (commit ad85919).

The load-bearing rationale (caller-vs-owner FUNCTION EXECUTE): a PostgreSQL view does NOT substitute the view-owner for FUNCTION EXECUTE — the rewrite owner-substitutes only RTE/table access; a function called inside the view body is permission-checked against the CALLER. `app_now()` (§ADR-20 T1 virtual clock) is SV8-locked to proacl {postgres, service_role}, so an `authenticated` reader of an owner-context/security_invoker view that calls it hits "permission denied for function app_now". The fix: a gated SECDEF reader that runs `app_now()` AS OWNER and carries the SAME admin-tier gate as the view in its body (aal2 ∧ has_read_perm('otp-log') ∧ auth_db_is_admin()) — a non-gated/non-admin call returns NULL (no clock-probing oracle). This is the IDENTICAL class + standing rule as the #456 `_deposit_system_bank(uuid)` amendment: "a function added to a view's read path joins the SV8 allowlist."

Concrete: `_otp_log_app_now()` was added by MERGED PR #566 (migration supabase/migrations/20260617000140_v_otp_logs_read_surface.sql) to derive `v_otp_logs.is_expired = otp_expires_at <= app_now()` (§ADR-23 P1/P2). supabase/tests/sv8_execute_or_no_grants_test.sql adds `('_otp_log_app_now()')` to rls_helper_fns + bumps the integrity assertion is(6)→is(7); the plan(...+3) and per-function sweep are unchanged. PG17 identity key is `_otp_log_app_now()` (zero params → no `has_read_perm(p_resource text)` identity-args gotcha).

Reusable pattern: when a new owner-context OR security_invoker view's read path needs a function that authenticated cannot EXECUTE directly under SV8 (because the function is itself SV8-locked, e.g. app_now()), introduce a gated SECDEF wrapper, GRANT it authenticated EXECUTE, add it to the SV8 allowlist + bump the integrity count — a same-migration code change + an append-only §ADR-13 SV8 Revision-log ratification. Architect authority, reviewer-gated self-merge; NOT owner-bearing (the allowlist grows ONLY by amendment, the #456/SV7c-allowlist precedent).

---
*Added via Oracle Learn*
