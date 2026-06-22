## /mdr + /roles — LIVE (mock → deployed). Orchestrator campaign `o-ui`, 2026-06-18 18:50 GMT+7.

Both admin-portal menus (`/mdr` MDR fee-profile viewer + `/roles` RBAC catalog viewer) driven from MOCK+preview-gated to LIVE on the deployed portal. 3rd of the read-surface family (after v_users/v_system_banks/v_otp_logs/v_bank_accounts).

**Shipped (7 PRs, all merged):**
- Gateway: #591 (§ADR-24 + epic-mdr-profile-read MDRVIEW-001..003 + epic-roles-catalog-read ROLEVIEW-001..003) → #594 (build `v_mdr_profile`+`v_roles` leak-safe views + RBAC seeds `super_admin/{mdr:view,role:view}` + pgTAP TEETH) → #595 (migration dedupe `…300`→`…320`) → #596 (pm DONE).
- Portal: #52 (epic-mdr-roles-ui WUI-221..223) → #56 (wire + de-preview + ฿→% fix) → #57 (pm DONE).

**LIVE-verified** (real aal2 TOTP + Playwright): /mdr 200 + 7 profiles (fees %), /roles 200 + 4-role matrix, non-admin deny-gated, data from staging `sinuw`. All 9 stories DONE.

**Owner decisions:** d1 project-what-exists · d3 parity-with-current (grounded mobiz: role:view→super_admin, mdr:view→super_admin+cs, cs-residual flagged Phase-2) · d5 is_system derive-in-portal.

**Fleet:** all teammates closed; 1 leftover worktree `mb-next-payment-gateway.wt-c-mdrrolestest` (untracked tester harness, not --force-removed). Retro: `ψ/memory/retrospectives/2026-06/18/18.50_mdr-roles-live.md`.

**Friction flagged:** team-dispatch-helper shared-worktree default breaks dev↔tester de-bias (worked around via separate tester slug); same-day migration-timestamp collision recurred (`…000300`).
