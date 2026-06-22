---
title: orchestrator decision-authority — UI parity build program (campaign o-ui-gap, 20
tags: [orchestrator, decision-authority, user-override, team-dispatch, ui-parity-build, accepted, #repo:cross, #next, #decision]
created: 2026-06-21
source: campaign o-ui-gap (orchestrator, 2026-06-21)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator decision-authority — UI parity build program (campaign o-ui-gap, 20

orchestrator decision-authority — UI parity build program (campaign o-ui-gap, 2026-06-21): user authorized "ลุยทั้งหมดอัตโนมัติ" = DRIVE THE ENTIRE UI-gap parity build program AUTONOMOUSLY. Run the full mb-next build pipeline (architect→dev→deploy→test→review→merge) for the whole backlog tracked in mb-next-admin-portal docs/ui-gap-tracking.md (D4 config-page backends, D2 write-CRUD parity across ~9 pages, D3 terms-conditions rebuild, P1/P2/P3), phase by phase. AUTO-MERGE code PRs after reviewer (next-code-reviewer) APPROVE without pinging (consistent with [[build-pr-auto-merge-authorized]]). Doc/tracker merges by next-pm authorized. Ping the user ONLY for a genuine blocker or a real design/business decision the architect cannot rule. Scale reality: our stack had NO config backend at all (prod used a separate Node REST API; ours is Supabase-only PostgREST views + admin-* EFs), so parity = building a new backend layer, not just frontend. Backend (migrations/EFs/ADRs) lives in kxlahsimx09/mb-next-payment-gateway; frontend in kxlahsimx09/mb-next-admin-portal. dev slots: dev-1=mb-next-dev1 (qvmjywljrgqzyxshexhx, often held by other campaigns), dev-2 provisioned 2026-06-21 (free). ADR-32 (config-pages persistence backend) ratified: Q1 bot_token→Vault, Q2 single-default in RPC, Q3 broadcast CRUD-only Phase-1 (send deferred), Q4 full prod field-set parity, Q5 RBAC tokens dual-write.

---
*Added via Oracle Learn*
