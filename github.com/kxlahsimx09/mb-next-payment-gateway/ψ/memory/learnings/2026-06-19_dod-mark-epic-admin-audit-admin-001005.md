---
title: DoD-MARK — epic-admin-audit (ADMIN-001..005) = 🟢 epic-DONE (2026-06-19, next-pm
tags: [dod-mark, epic-done, admin-audit, satisfied-by-construction, right-sized-seal, live-n-a, phase-2-deferral, false-green, rot-guard]
created: 2026-06-19
source: next-pm (campaign pmmark)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# DoD-MARK — epic-admin-audit (ADMIN-001..005) = 🟢 epic-DONE (2026-06-19, next-pm

DoD-MARK — epic-admin-audit (ADMIN-001..005) = 🟢 epic-DONE (2026-06-19, next-pm campaign pmmark). The cross-cutting admin-write + audit invariant layer (§ADR-13). Marked on concrete gate-to-artifact evidence (gone-and-looked, gh state NOT trusted — the reviewer verdict lives in the PR #640 re-review BODY HEADER, gh state reads COMMENTED). Mark PR #646 (DOCS-ONLY flip, base main, head docs/admin-audit-epic-done-pmmark, commit bc40ccc) — OPEN, MERGEABLE, NOT self-merged (left for OWNER per §9a).

THE 4 GATES (each verified directly by next-pm):
- BUILD ✅ — PR #640 MERGED → main (merge commit 28b2f8a, confirmed ancestor of origin/main HEAD 4cdd244; mergedAt 2026-06-19T16:30:07Z). Static §ADR-13 CI-teeth conformance test admin-audit-conformance.test.ts = 28 pass / 0 fail / 66 expect() at merged tip e51a0bb; genuinely fail-on-violation (3 drift mutations → exact RED) + a rot-guard that RED-fires if a function pin drifts off its authoritative-latest CREATE…FUNCTION migration.
- REVIEW ✅ — next-code-reviewer (campaign teethclose-adminaudit). The FIRST review CHANGES-REQUESTED caught a REAL false-green: two function-body pins (write_audit_log exactly-one-INSERT + _denorm_last_admin_action admin-guard) pinned the SUPERSEDED 20260519000001 def instead of authoritative-latest (migrations are append-only; the live def is the LAST CREATE OR REPLACE). A dev fixed it (e51a0bb); the re-review BODY-HEADER "✅ REVIEW VERDICT: APPROVE" verifies the 2 corrected pins resolve to authoritative-latest (write_audit_log→20260521000003 15-arg; _denorm→20260617000100) + the rot-guard RED-fires. It self-merged on APPROVE+GREEN (§9a/#618 self-authored build-PR carve-out).
- VERIFY/SEAL ✅ — next-investigator §9 right-sized SEAL GREEN: 8/8 raw-row invariant checks re-derived from REAL admin actions on qnccph (admin_cancel_payout / admin_correct_payout / admin_create_mdr_profile): (1) exactly-one audit_log row per action; (2) AFTER-INSERT 4-field denorm cache actor_type='admin' ONLY (system actor → cache NULL via early-RETURN teeth); (3) create-time actor-triple typed; (4) append-only tr_audit_log_no_update + tr_audit_log_no_delete DB-block UPDATE+DELETE; (5) RBAC rls_read_a4 = auth_aal2() AND has_read_perm('activity-log') AND auth_db_is_admin() + §ADR-2 G4-D indexes (idx_audit_log_resource, idx_audit_log_actor). ADMIN-001..004 satisfied-by-construction across sealed PROV/MDRWRITE/BENE siblings.
- LIVE (§ADR-21) ✅ N/A (ruled) — non-money admin surface (OWNER P1; architect row 1 + ADMIN-005 scoped-reader RULING). Each admin action's money consequence rides its own money epic; the §ADR-21 money-LIVE journey has nothing unique to exercise. Precedent: CLIREAD #611 / PROV #612 / OTPLOG #566.

PHASE-2 DEFERRAL (NAMED in the DoD banner — NOT a gap): ADMIN-005's non-admin/partner/client SCOPED (tenant-bounded) audit reader is a legit Phase-2 deferral. Architect ADMIN-005 scoped-reader RULING (dpay-parity-confirmed): current production (dpay activity_logs) exposes NO non-admin/partner/client read of the admin-action audit trail (audit reads are ADMIN-ONLY; merchant/client self-service reads its own transactions/wallet + per-client API request log, never the admin-action trail) → the absent scoped reader is PARITY-FAITHFUL, not a Phase-1 PARITY-WITH-CURRENT obligation; AC#5 holds as deny-by-default. If a future OWNER wants partner/client self-service audit history, the build = a v_login_log-pattern tenant-scoped read-view over audit_log gated on a partner/client predicate — a Phase-2 ADD, outside the Phase-1 parity DoD.

REUSABLE PATTERN: a cross-cutting INVARIANT epic that owns no code of its own (SRCFLOW-001 / P2 shape) closes via Shape-B (CI-teeth conformance test + reviewer APPROVE) for the by-construction legs + a Shape-A-lite right-sized investigator SEAL re-deriving from already-sealed siblings; non-money → LIVE-N/A (P1). A reviewer's job includes catching false-greens where a conformance test pins a SUPERSEDED migration def — the fix re-points to authoritative-latest + adds a rot-guard. A capability ABSENT in current production is a parity-faithful Phase-2 deferral, not a gap.

---
*Added via Oracle Learn*
