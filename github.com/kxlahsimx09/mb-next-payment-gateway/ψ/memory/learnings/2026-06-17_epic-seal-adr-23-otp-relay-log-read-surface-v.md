---
title: EPIC SEAL — §ADR-23 OTP-Relay Log read surface (v_otp_logs), epic OTPLOG (OTPLOG
tags: [next-investigator, repo:mb-next-payment-gateway, next, epic-seal, seal, otp, v_otp_logs, otplog, verify, v5, security-barrier, adr-23]
created: 2026-06-17
source: next-investigator_otplogsseal_findings.md@f2c01cd
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# EPIC SEAL — §ADR-23 OTP-Relay Log read surface (v_otp_logs), epic OTPLOG (OTPLOG

EPIC SEAL — §ADR-23 OTP-Relay Log read surface (v_otp_logs), epic OTPLOG (OTPLOG-001..003), PR #566. Verdict: SEALED.

Independently falsified from RAW seal-DB ground truth on my own isolated stack (qnccphgykzdydebmdwdf — distinct from tester yupsevcrubgprsbujbpu); seal-env git-sha f2c01cd = merged HEAD. Did NOT trust the tester's 25/25 green, the harness flags, or next-dev's source.

THE TEETH (OTP code NEVER in any v_otp_logs row) — confirmed 4 ways:
1. Deployed viewdef (pg_get_viewdef): o.otp referenced NOWHERE (not SELECT/WHERE/JOIN) — excluded by construction for every caller.
2. information_schema: exactly 11 cols, 0 forbidden-name matches.
3. Behavioral NON-VACUOUS: seeded unique marker into base otp_logs.otp (base::text ~ marker = true control), read view as gated super-admin via request.jwt.claims GUC → 2 rows projected, string_agg(v::text) ~ marker = FALSE (code absent), acc_number positive control present, returned keys = exactly 11 (no forbidden key).
4. Wire: service_role select=otp on view → HTTP 400 "column does not exist"; control acc_number → 200.

Negative matrix (raw GUC predicate legs + wire): N0 anon → 401 (no grant); N1 aal1 → 0 (isolates aal2 leg); N2 perm-leg isolated (admin=T,perm=F) → 0; N3 admin-leg isolated (perm=T,admin=F) → 0; N4 no-uid → 0; POS gated (all 3 true) → rows. Deployed gate = literal AND of auth_aal2() AND has_read_perm('otp-log') AND auth_db_is_admin().

security_barrier=true holds: negative caller (partner) WITH exact reference_code filter on a real row → 0 rows; gated admin with same filter → 1 row. Caller qual is NOT a content oracle.

SV7b intact: base otp_logs grants = {postgres, service_role} ONLY (no anon/authenticated) → gated super-admin denied on base (grant on VIEW only); anon wire → 401. RBAC: otp-log:view → ["super_admin"] only. is_expired derived via _otp_log_app_now()→app_now() virtual clock (not now()); expired→true, fresh→false. Cleanup: zero residue.

PROBE-RIGOR NOTE (non-blocking, not a reopen): the tester raw-cast leg (otplog-probes.ts:233-237) runs as postgres with no JWT → view gate false → 0 rows → marker vacuously absent. Proves nothing alone; headline carried by the other legs. I closed it by setting the gated-admin JWT GUC so the view actually projects rows (still code-free). Hardening suggestion for next-tester/next-code-reviewer; correctness unaffected.

---
*Added via Oracle Learn*
