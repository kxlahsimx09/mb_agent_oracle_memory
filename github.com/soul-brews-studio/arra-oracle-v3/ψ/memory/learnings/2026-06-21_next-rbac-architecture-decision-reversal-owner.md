---
title: #next RBAC architecture decision REVERSAL (owner, 2026-06-21): switch from stati
tags: [#next, rbac, decision, architecture-reversal, single-source-of-truth, role_permissions, #repo:cross, drift]
created: 2026-06-21
source: campaign o-ui-gap (orchestrator, 2026-06-21)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# #next RBAC architecture decision REVERSAL (owner, 2026-06-21): switch from stati

#next RBAC architecture decision REVERSAL (owner, 2026-06-21): switch from static code-map RBAC to PURE DATABASE-DRIVEN RBAC. role_permissions table becomes the SINGLE SOURCE OF TRUTH for ALL permission checks — UI display (v_roles), RLS reads (has_read_perm), AND EF write checks (requirePermission). The static rbac.ts ROLE_PERMISSIONS code map is retired as a runtime authority. Reason: with two sources (code map for EF writes + role_permissions table for UI/RLS reads) drift is structurally possible — UI showed perms from the table while EFs enforced from the code map (the D4 incident was exactly this class: code-map half not deployed → write 403 while seed was fine). Owner: "ใช้ database pure เลย ไม่ต้องมี static code จะได้ไม่มี drift และมีแค่ single source of truth." Aligns with current prod (mobiz is also DB-driven, Go role_perm_cache). SAFETY caveat: the old design pinned super_admin in CODE as a lockout floor; pure-DB must move that safeguard INTO the DB (trigger/invariant preventing deletion of super_admin core grants) to keep single-source without self-lockout risk. Supersedes the earlier [[orchestrator-dispatch-no-reuse-other-teams]]-era "keep static" D-A choice. rolesalign PR #687 (dual-wrote 8 roles to map+seed) — keep its role_permissions seed as the foundation; drop the map additions. The 8-role parity set (mirror current, our naming) stays.

---
*Added via Oracle Learn*
