---
title: OTP-relay log admin read surface (§ADR-23) — parity findings + the redaction TEE
tags: [system-architect, repo:mb-next-payment-gateway, repo:cross, next, otp-log, otp, adr, decision, read-view, redaction, rbac, parity, migration-map]
created: 2026-06-17
source: docs/adr.md §ADR-23 + docs/requirements/epic-otp-relay-log.md (PR #563); mb-next-admin-portal epic-otp-logs-ui.md (PR #46)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# OTP-relay log admin read surface (§ADR-23) — parity findings + the redaction TEE

OTP-relay log admin read surface (§ADR-23) — parity findings + the redaction TEETH rule (campaign otplogsspec, 2026-06-17)

Authored the missing requirement stack for the portal `/otp-logs` page (bank-OTP relay log viewer), sibling to the just-merged `/bank-accounts` (§ADR-22/BENE) stack. Gateway PR #563 (§ADR-23 + epic-otp-relay-log.md OTPLOG-001..003), portal PR #46 (epic-otp-logs-ui.md WUI-211..213). DOCUMENTS ONLY, owner-gated (do not merge).

GROUND-TRUTH PARITY FINDINGS (mobiz Go @ 03d6383 + live dpay otp_logs ~51,190 docs; 2 independent sub-agents cross-corroborated):
- Current production DOES have a dedicated OTP-relay-log OPERATOR screen: GET /api/v1/otp-logs + /:id + /account/:acc_number (routes/otplog.go:11-20, main.go:464, controllers/OTPLogController.go:121-137), RBAC `otp-log:view`, seeded ONLY to super_admin (insert-roles.js:43, insert-resources.js:403-408). So "who-reads = parity" = super-admin-only.
- 🔴 Current RETURNS THE RAW OTP UNMASKED (models/otp_logs.go:11 `otp` json:"otp"); no redaction. The next-system REDACTS it — a deliberate, owner-mandated divergence from parity (the HARD CONSTRAINT). Same divergence shape as §ADR-2 S4 fail-closed; the OTP analogue of the v_users no-secret-column TEETH rule.
- 🔴 Current has NO retention/TTL/purge in code (db/indexes.go:255-258 plain index; 0 delete jobs) → unbounded raw-OTP PII window. Live dpay shows ~7-day window (out-of-code TTL). The next BBOT-010 substrate (20260614000010:322-333) already purges 24h-post-expiry — TIGHTER. Retention is a substrate (§ADR-6 OR1-OR5) decision, NOT re-litigated in §ADR-23.

KEY CORRECTION (P-004): the brief said "introduce a NEW §ADR-13 RBAC resource otp-log". GROUND TRUTH: `otp-log` is ALREADY a ratified §ADR-13 F3 catalogue member — rbac_seed_vs_catalogue_test.sql:90 block A `('otp-log','view create update delete')` (verbatim mobiz-parity port). So NO catalogue-add; the read rides existing `otp-log:view`, exactly the user:view / system-bank:view precedent. Always check the catalogue test before minting an RBAC resource.

§ADR-23 DESIGN: leak-safe `v_otp_logs` = owner-context PROJECTION (security_invoker=false, security_barrier=true) over the SV7b zero-grant otp_logs base table, admin-tier WHERE gate (auth_aal2 ∧ has_read_perm('otp-log') ∧ auth_db_is_admin) — the v_users/v_system_banks pattern (NOT the v_deposits security_invoker+RLS, because otp_logs has no user_id/owner → admin-only, no owner-self read). Projects metadata ONLY: id, bank_account_id, system_bank_code+account_name (join bank_account), acc_number (full, admin-tier — v_system_banks precedent), reference_code, source, otp_expires_at, created_at, last_read_at, derived is_expired (otp_expires_at <= app_now(), §ADR-20 T1, NOT now() — avoids read-view-family wall-clock DRIFT-V). NEVER projects `otp`. Seed ('super_admin','otp-log:view'). Base table untouched.

SUBSTRATE PARITY GAPS flagged as OPEN QUESTIONS: (a) the next BBOT-010 otp_logs table OMITS `from_email` (current dpay has it) — UI can't show fromEmail unless substrate adds the col; (b) no parse-status column anywhere — a parse failure never lands a row (save_bot_otp RAISES otp_parse_failed → EF 400), so the operator view shows only SUCCESSFUL saves; a parse-failure viewer is net-new; (c) the mock portal page renders a click-to-reveal `otp` column (shown[id] ? o.otp : "••••••") — a defect; the next UI DELETES the column entirely (nothing to reveal). Material escalation: (c1) metadata-retention window 24h vs longer redacted archive [RATIFICATION_PENDING:owner].

---
*Added via Oracle Learn*
