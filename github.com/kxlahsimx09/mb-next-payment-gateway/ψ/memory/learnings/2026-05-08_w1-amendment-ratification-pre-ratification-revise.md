---
title: W1 amendment ratification (pre-ratification revised pass 1.5 + pass 2 combined) 
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, amendment, w1, adr-13-amendment, ratification, pass-15, pass-2, combined-pass-instance-5-durable, decision, thread-82-closed, f3-revised-prefix-to-flat-mobiz-parity, production-db-mcp-verification-at-ratify-time-instance-1-new-sub-pattern, verify-divergence-via-production-mcp-before-propose-instance-1-new-sub-pattern, f2-per-action-actor-triple-pattern-durable-threshold-5-instances, user-pushback-instance-28, 14-adrs-decision-phase-2-provisional-remaining]
created: 2026-05-08
source: docs/adr.md@5c2128a §ADR-13 amendment block (post pass-1.5 revise); thread:#82 messages 196-198; dpay MCP roles collection verification (33 resources flat namespace 2026-05-08)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 amendment ratification (pre-ratification revised pass 1.5 + pass 2 combined) 

W1 amendment ratification (pre-ratification revised pass 1.5 + pass 2 combined) — §ADR-13 amendment thread #82 closed; F1-F4 resolved; amendment promotes `#provisional` → `#decision`. Architecture-decision phase: 14 ADRs/amendments `#decision`; 2 live `#provisional` remain.

User direction *"F1-F4 รับ; F2 + F3 แก้ตามที่เสนอ F3 port มาให้หมดเลย"* + question *"ตัว current ได้ทำ f4 ไหม"*. F1 + F4 straight-ratified. F2 scope clarified pre-ratification. **F3 revised pass 1.5 from prefix proposal to mobiz-parity flat namespace** per dpay MCP verification of production roles collection.

Verdicts:
- F1 Actor tier model (4 JWT actors + 2 machine actors) — straight ratified
- F2 Create-time actor triple — scope clarified pass 1.5: 4-mode tracking table (F2 create-time / D2 admin action-time / per-flow transition-specific / audit_log generic update-time); pattern "per-action actor triple as universal forensic primitive" reaches durable threshold at 5 instances
- F3 RBAC permission namespace — REVISED pass 1.5 from `<actor-tier>:<resource>:<action>` to mobiz-parity flat `<resource>:<action>` per dpay MCP production roles collection verification (33 resources flat-namespace; tier separation via route + user_type + tenant scope, NOT permission prefix); architect's initial prefix proposal would have created divergence; revise restored parity. Port verbatim all 33 production resources + 4 §ADR-14 fleet-control sub-resources.
- F4 Layer 1 sync-validate tenant scope check — straight ratified after deep-dive (per-actor scoping rules + 3-layer enforcement Middleware/Controller/RLS-deferred + 4 concrete endpoint examples + edge cases + mobiz current implementation status)

dpay MCP verification (production roles collection 2026-05-08):
- super_admin role: 33 distinct resources × per-resource action enums
- merchant role: subset (view-only on most resources)
- client role: subset (CREATE on topup + bank-account + sub-client + settlement; UPDATE on deposit + payout)
- Aggregate query confirmed flat namespace (no actor-tier prefix); same permission `deposit:view` exists in admin role + client role + merchant role with different action sets per role

F3 ratified architectural rule:
- Permission strings = flat `<resource>:<action>` (port mobiz current verbatim)
- Same permission can be granted to multiple roles; scope differs by tier via routing + tenant scope check
- Tier separation enforced at 3 layers: route prefix + JWT user_type + Layer 1 tenant scope (per F4)
- Resource-split discipline (D3 ratified) still applies — split when granular control needed
- 33 production resources ported verbatim; 4 §ADR-14 fleet-control sub-resources added per D3 sub-resource discipline

next-impl verification responsibility (per user direction "ไปดูใน rbac ของตัว current ว่า ที่เราออกแบบ ไม่ทำให้เคสไหนตกหล่นใช่ไหม"): cross-reference roles collection schema vs §ADR-13 amendment F3 resource list; ensure (a) all resources ported; (b) all action enums per resource ported; (c) no resource/action drift; (d) backward-compat roles work (e.g. legacy `pull-out` resource still grants intended access).

F4 mobiz current implementation status (per dpay + PR #235 verification):
- Has primitive: resolveEffectiveClientIDFromJWT helper (PR #235 cb78ef7, 2026-04-20)
- Applied: 4 controllers fixed (TopupController + SettlementController + BankAccountController via PR #235)
- Architectural enforcement: per-controller helper, can be missed
- Other controllers (Deposit, Payout, etc.) may still have IDOR drift class
- F4 elevates pattern from "code helper" → "ADR rule" — every non-admin endpoint MUST enforce at Layer 1; structural drift prevention via PR review checklist

Patterns surfaced this pass:

1. **Combined pass 1.5 + pass 2 lifecycle — instance #5** (after §ADR-9 / §ADR-13 D2 / §ADR-15 D6 / §ADR-14 E6 / this F2+F3). Now durable rule (3-instance threshold reached at instance #3; this is instance #5 — continuing-confirmation).

2. **Pre-Input-5 production-DB MCP verification at RATIFY time — instance #1 (NEW sub-pattern)**. Earlier instance #18 (§ADR-13 amendment baseline) verified production data SHAPE (collections); this pass verified production data CONFIGURATION (roles collection) at ratify time. Pattern: when ADR amendment touches existing production-data structure (collection schema OR role config OR enum values), verify via production-DB MCP at BOTH baseline + ratify time — caught architect-rec divergence that initial baseline review missed. Brew-ops handoff candidate for W1 §Inputs heuristic update at instance #2.

3. **Verify-divergence-via-production-MCP before propose — instance #1 (NEW sub-pattern)**. When architect proposes divergence from mobiz current pattern, MUST verify via production-data first (not just code structure). Architect's F3 prefix proposal would have created divergence; user's "ไปดูใน rbac ของ current" prompt + dpay verification refuted proposal. Brew-ops handoff candidate at instance #2.

4. **User-pushback-as-design-force instance #28** — operational-concern at ratify time (F2 scope ambiguity) + production-divergence-flag at ratify time (F3 prefix). Pattern: ratify time is **second forensic checkpoint** after baseline; user-pushback at ratify can catch issues that baseline missed.

5. **F2 pattern "per-action actor triple as universal forensic primitive" reaches durable threshold** — 5 instances confirmed (settlements create-time PR #374 + this F2 + slip-upload-time §ADR-4d D1 amend H2 + slip-verify-time §ADR-4d D9 + topup-approve-time §ADR-16). Brew-ops handoff: add to W1 workflow doc as architectural rule. Pattern at 5 instances (durable threshold = 3) firmly established.

User-pushback-as-design-force instance count: 27 → 28. Pre-Input-5: 18 → 19.

Architecture-decision phase post-amendment-ratify:
- 14 ADRs/amendments `#decision` (§ADR-1 through §ADR-13 + §ADR-13 amendment + §ADR-4b/4d amendments + §ADR-4b D2 amendment + §ADR-15 + §ADR-14)
- **2 live `#provisional` remain** — §ADR-16 thread #83 + §ADR-4d D1 amendment thread #84 (Track 3 + Track 2 of 3-track derivative plan from thread #81)
- After both ratify: 0 live `#provisional`; full Phase-1 architectural surface complete; Phase-1 implementation kickoff fully unblocked

Same-day ratify cycle: §ADR-13 amendment ~1 day cycle (baseline 2026-05-07 → ratify 2026-05-08); within typical W1 cadence; faster than §ADR-14 (2-day cycle from 2026-05-06 → 2026-05-08) because less complex revise.

Threads closed: #82. Threads opened: none. Commit: `5c2128a`. PR #24 (3 commits total: amendment baseline + baseline-backfill + ratify pass 1.5+2 combined).

Next pass candidate: ratify thread #83 (§ADR-16 Client Self-Topup) + ratify thread #84 (§ADR-4d D1 amendment slip upload actor matrix; depends on §ADR-13 amendment F1+F2 ratify which JUST happened — Track 2 unblocked).

---
*Added via Oracle Learn*
