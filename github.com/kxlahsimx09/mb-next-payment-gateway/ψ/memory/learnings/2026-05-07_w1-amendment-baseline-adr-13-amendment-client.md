---
title: W1 amendment baseline — §ADR-13 amendment (Client Web User Actor Tier + Create-T
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, amendment, w1, adr-13, client-web-user-actor-tier, created-by-triple-pattern-instance-2, rbac-namespace, tenant-scope-layer-1, coordination-rule-instance-5, production-db-mcp-verification-pre-input-5-instance-1-new-pattern, user-pushback-instance-26, user-clarification-surfaces-adr-silent-production-tier-instance-1-new-pattern, thread-82-opened, thread-81-closed-bridge, baseline, pass-1, provisional, ratification-pending]
created: 2026-05-07
source: docs/adr.md@3a17aec §ADR-13 amendment block; thread:#82 + thread:#81 (closed); dpay MCP verification queries 2026-05-07; learning:2026-05-02_settlement-model-gained-createdby-triple + learning:2026-04-19_sub-client-tenant-scoping-pr-235
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 amendment baseline — §ADR-13 amendment (Client Web User Actor Tier + Create-T

W1 amendment baseline — §ADR-13 amendment (Client Web User Actor Tier + Create-Time Actor Triple + RBAC Namespace + Tenant Scope Layer-1) (`#provisional`, thread #82 opened).

Closes 2 ADR-silent gaps surfaced via thread #81 dpay MCP verification (2026-05-07 GMT+7):

1. Actor tier model gap — §ADR-13 D1 3-layer rule covers admin/bot/customer; lacks `client_web_user` tier. Mobiz current has `c.Locals("user_type") ∈ {admin, client, sub-client, partner}` enum + sub-client tenant scoping (PR #235 cb78ef7); ADR-silent.

2. Audit pattern gap — §ADR-13 D2 has `last_admin_action_*` (action-time admin) but lacks create-time actor triple. Mobiz settlements PR #374 ec9d0d7 introduced `(CreatedBy, CreatedByUsername, CreatedByType)`; pattern durable but ADR-silent. Discriminator surface needed for thread #81 deposit/topup forensic distinction.

4 decisions in amendment (F1-F4):

- F1 — Actor tier model: 4 JWT actors (admin/client/sub-client/partner) + 2 machine actors (client API-Key / bot tier API-Key); tenant scoping invariant (sub-client → parent_client_id; client → own; partner → own; admin → no scope); architectural commitment that every business-row read/write checks tenant scope at Layer 1 when actor is non-admin
- F2 — Create-time actor triple `(created_by_id, created_by_username, created_by_type)`; pattern instance #2 of "create-time actor triple" (after settlements PR #374); created_by_type enum `{admin, client, sub-client, partner, system}`; mandatory on ts_deposits / ts_payouts / settlements / client_topups (§ADR-16) / future create-time-actor-relevant tables; application-time write (NOT trigger-populated; distinct from D2 trigger-denorm); discriminator role solves thread #81 forensic distinction
- F3 — RBAC permission namespace `<actor-tier>:<resource>:<action>` (e.g. `admin:topup:create`, `client:deposit:upload-slip`); single-endpoint-serving-multiple-tiers REJECTED (route prefix matches actor: `/admin/*`, `/clients/:id/*`); permission strings static
- F4 — Layer 1 sync-validate extension: tenant scope check; non-admin actor's request MUST validate tenant scope at Layer 1 before any Layer 2 mutation; coordination-rule pattern instance #5 (after Decision #1 + §ADR-4c D10 + §ADR-13 D2 + §ADR-9 D6 + §ADR-4b amendment B2); architecturally extends PR #235 mobiz fix from per-controller-helper to architectural invariant; IDOR class structurally prevented

Production-DB MCP verification at baseline pass — dpay MCP enabled by user mid-session 2026-05-07; allowed verification of next-impl's thread #81 claim against production reality:
- topups collection = 22 records (not 100k+ as next-impl claimed); 100% admin-approved by "Tiger" with notes="Approved by admin"; B2B-only (no callback_url field; no customer_* / deposit_id reference); amounts 10k-100k THB
- ts_deposits = 421k records; 100% channel=QR for slip-bearing deposits; 100% approved_by_type=admin (no client/sub-client/partner values in production today despite mobiz code allowing); 12,497 records with slip_uploaded_at + 0 with slip_uploaded_by → drift confirmed (current does not track slip-uploader; next-system fix per future §ADR-4d D1 amendment Track 2)

next-impl thread #81 claim was wrong on 2 dimensions (volume + use case): no "admin-create-from-scratch deposit" path exists in production; offline customer transfers flow through normal QR deposit + slip-fallback path (`channel=QR` always created; QR generated but not used by customer transferring offline).

Patterns surfaced this pass:
- User-pushback-as-design-force instance #26 — user clarified production actor model (`client_web_user` tier exists in mobiz code via JWT enum but never ratified) at architect-recommendation level pre-baseline
- Pre-Input-5 instance #18 — extends to production-DB MCP verification (new pattern after Oracle-memory-sweep instance #17). When ADR-baseline claims involve production data shape, verify via production-DB MCP at architect baseline time, not retro time. Pattern: Input 5 surfaces extends 3rd time: code-read → Oracle-memory → production-DB MCP. Brew-ops handoff candidate for W1 §Inputs heuristic update.
- Coordination-rule pattern instance #5 (F4 tenant scope at Layer 1) — already-durable pattern continues; instance count tally only
- Create-time actor triple — pattern instance #2 (after settlements PR #374). At instance #3 reaches durable threshold per W1 §Port-from-mobiz protocol rule 2; instance #2 = candidate-durable
- "User clarification surfaces ADR-silent production tier" — instance #1 (NEW pattern). When ADR specifies abstract structure without enumerating concrete tiers, code can drift to add tiers without re-ratifying. Mitigation: ADRs specify enums explicitly when they exist in current.

Pre-Input-5 instance count: 17 → 18. User-pushback-as-design-force: 25 → 26.

3-track derivative plan from thread #81 correction:
- Track 1 (this amendment) = §ADR-13 amendment baseline → ratify thread #82
- Track 2 = §ADR-4d D1 amendment baseline (depends on F1+F2 ratifying); slip upload actor matrix + slip_uploaded_by audit field
- Track 3 = §ADR-16 NEW (parallel-able); Client Self-Topup B2B; admin-only Phase-1; client_topups table

Migration map (small):
- Current ts_deposits (~421k records) — backfill created_by_* from request_logs best-effort OR 'system' fallback; new rows mandatory triple
- Current topups (22 records) — migrate to §ADR-16 client_topups; backfill created_by_type='admin'
- Current settlements — already has triple per PR #374; port verbatim
- audit_log per D2 — append-only; no migration; applies forward

Threads opened: #82. Threads closed: #81 (bridge to this amendment via correction message_id 194). Commit: `3a17aec`. PR: #24 (stacked on PR #19 branch).

Architecture-decision phase post-amendment (when thread #82 ratifies + thread #80 ratifies §ADR-14 + §ADR-15 already ratified): 0 live `#provisional` ADRs; full Phase-1 architectural surface ready for implementation kickoff per §11k orchestrator + thread #66 next-dev developer agent.

---
*Added via Oracle Learn*
