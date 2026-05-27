---
title: epic authored — admin-audit — 4 stories, all S2.
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, epic, admin-audit, audit-log, s2-ratified, campaign-228, thread-230]
created: 2026-05-26
source: docs/requirements/epic-admin-audit.md@writer/admin-audit-adr13
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# epic authored — admin-audit — 4 stories, all S2.

epic authored — admin-audit — 4 stories, all S2.

Subsystem: admin-audit (Admin-API & Audit — cross-cutting admin-write + audit substrate)
Net-new epic from campaign #228 / sub-thread #230 (P1, first of remaining queue, authored after #245/#247/#248 all merged). Translates §ADR-13 (Admin-API Surface, #decision core thread #61 + actor-tier amendment thread #82) into human-readable stories. Grounded vs current production (dpay MCP 2026-05-26, prior-verified this campaign).

Stories (all S2):
- ADMIN-001 3-layer admin write invariant (D1): Layer1 sync-validate-all-before-write / Layer2 sync-execute load-bearing (queue+wallet+status+audit, one txn, rollback on fail) / Layer3 async notifications. Verify-slip-now = Layer2 special case (verdict is deliverable). Generalises the DTR incident fix to ALL admin writes (cross-ref DTR-001).
- ADMIN-002 canonical audit_log + trigger-denormalized 4-field hot-read cache (last_admin_action_*) + §ADR-10 wallet cross-link (D2). State-timestamps stay on row, identity cached from trail. Constant-4-fields divergence from mobiz ~15-20-per-row bloat; no separate admin_actions table.
- ADMIN-003 create-time actor triple (F2): created_by_id/username/type on every business row; 'system' for automated; distinct from D2 action-time identity; production settlements already carry it.
- ADMIN-004 RBAC resource-split discipline (D3): granularity via splitting resources not overloading actions (pull-out → pull-out-tasks/pull-out-logs PR #175); cross-ref AUTH-003.

SCOPING: deliberately did NOT duplicate RBAC (F3→AUTH-003) or tenant-scope (F4→AUTH-004) — those are owned by epic-auth-rbac. Individual admin actions (PAYOUT-005 cancel, DEPOSIT-008 verify-now, DEPOSIT-012/PAYOUT-007 resend, WALLET-004 adjust, TOPUP-001 record, source-flows admin paths) live in their own epics — this epic owns only the SHARED invariants. Fleet-control admin imperatives (force-logout/halt-pool/maintenance-override) = §ADR-14, separate epic (next pass).

Production grounding: activity_logs (~1,507 admin-action rows = the REAL audit surface) vs audit_trail (~6.6M = misleadingly-named HTTP request log, NOT the action audit) — captured as ADMIN-002 edge case so next-impl doesn't build on the wrong collection. settlements created_by triple = the F2 pattern generalised.

Files: docs/requirements/epic-admin-audit.md (new) + glossary.md (+audit log) + INDEX.md (+Admin-API & Audit section) + README.md (+row after Auth & RBAC). Mermaid 2/2 PASS; MDX clean.

PROCESS: branched off LATEST merged main (b026634, has all 3 P0/P1-core epics) per orchestrator "prefer sequential to avoid re-compounding glossary/INDEX conflicts" — so glossary/INDEX/README appends are clean (no conflict with merged content). One PR per pass; pausing for merge before next (Fleet-Control §ADR-14).

---
*Added via Oracle Learn*
