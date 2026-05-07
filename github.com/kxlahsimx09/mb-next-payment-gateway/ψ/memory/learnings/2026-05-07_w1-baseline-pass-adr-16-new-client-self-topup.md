---
title: W1 baseline pass — §ADR-16 NEW: Client Self-Topup B2B (`client_topups` append-on
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-16, client-self-topup, b2b, client-topups-table, apply-client-topup-rpc, substrate-convergence-7, append-only-forensic-pattern-instance-5, create-time-actor-triple-pattern-instance-2, front-load-design-dir-baseline-pattern-instance-3, production-db-mcp-grounding-continues, thread-83-opened, track-3-of-3-derivative-plan, phase-1-admin-only, baseline, pass-1, provisional, ratification-pending]
created: 2026-05-07
source: docs/adr.md@2d0a3a2 §ADR-16 + docs/design/topup/{README,schema}.md@2d0a3a2; thread:#83 + thread:#81 (closed bridge); 4 mobiz topup-related learnings; dpay MCP verification 2026-05-07
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 baseline pass — §ADR-16 NEW: Client Self-Topup B2B (`client_topups` append-on

W1 baseline pass — §ADR-16 NEW: Client Self-Topup B2B (`client_topups` append-only + `apply_client_topup` RPC; admin-only Phase-1) (`#provisional`, thread #83 opened).

Track 3 of 3-track derivative plan from thread #81 correction. Closes architectural gap surfaced via dpay MCP verification: mobiz current `topups` collection is B2B-only entity distinct from deposit (B2B2C; customer-facing). Distinct entity warrants own ADR; new `client_topups` table (NOT discriminator flag in `ts_deposits`).

Production verification (dpay MCP 2026-05-07):
- 22 records total
- 100% admin-approved by "Tiger" with notes="Approved by admin"
- Amounts 10k-100k THB (B2B-large)
- MDR distribution present
- NO callback_url field in schema
- NO customer_* / deposit_id fields → confirms B2B-only entity

7 decisions in baseline (G1-G7):
- G1 Topup as distinct entity (separate `client_topups` table; flag-based discrimination rejected; B2B vs B2B2C are different semantic axes)
- G2 Phase-1 admin-only path; client/sub-client self-service deferred Phase-2 (no production driver)
- G3 Atomic apply via thin PL/pgSQL RPC `apply_client_topup` (substrate convergence #7)
- G4 `client_topups` append-only-spirit schema (pattern instance #5 of "append-only forensic table"; durable rule continues)
- G5 MDR distribution preserved verbatim from mobiz current (`topup_percentage × gross amount`)
- G6 No external callback (explicit non-decision; admin-only flow per mobiz parity)
- G7 Create-time actor triple per §ADR-13 amendment F2 (Phase-1 always `created_by_type='admin'`)

`apply_client_topup` RPC (9-step atomic transaction):
1. CAS-flip status pending → approved with belt-and-suspenders processed=true guard
2. UPDATE client wallet (+net_amount)
3. INSERT wallets_change_logs (operation='topup' — distinct audit op tag from deposit)
4. UPDATE partner wallets (MDR fan-out per §ADR-10 D4; lock-ordering wallet.id ASC per §ADR-10 D5)
5. INSERT wallets_change_logs (operation='mdr_distribution') for each partner
6. INSERT mdr_shared row (if ≥1 partner credited)
7. INSERT transactions row (uniform shape across deposit/payout/topup per §ADR-12)
8. INSERT audit_log row (action_type='topup_approve' per §ADR-13 D2; trigger auto-populates last_admin_action_*)
9. NO callback_queue INSERT (explicit difference from §ADR-4b D5 finalize_deposit; admin-only flow)

Migration map (small): 22 records 1:1 transform; 100% `created_by_type='admin'` (production-verified). Validate post-migration: financial parity check on `total_distributed` sum.

3-track derivative plan from thread #81 correction:
- Track 1 (§ADR-13 amendment thread #82, opened earlier this session) — actor model + create-time triple + RBAC namespace + tenant scope Layer-1
- Track 2 (§ADR-4d D1 amendment future thread #84-or-later) — slip upload actor matrix; depends on Track 1 F1+F2 ratifying
- Track 3 (this baseline thread #83) — Client Self-Topup B2B; parallel-able with Track 1

Patterns surfaced this pass:
- Pattern instance #5 of "append-only forensic table" — `client_topups` joins `audit_log` / `callback_attempts` / `slip_verify_attempts` / `fleet_command_log`. Already-durable rule (per §ADR-14 baseline established at #4); instance #5 = continuing-confirmation.
- Pattern instance #2 of "create-time actor triple" — `client_topups.created_by_*` follows §ADR-13 amendment F2 + settlements PR #374 precedent. At instance #3 reaches durable threshold; instance #2 = candidate-durable.
- Substrate convergence #7 — `apply_client_topup` joins thin-RPC pattern. Already-durable rule (per §ADR-14 baseline established at #6); instance #7 = continuing-confirmation. Pattern: "every state-transition write goes through SECURITY DEFINER thin RPC for uniform audit."
- Front-load design-dir at baseline pattern instance #3 (after §ADR-15 + §ADR-14). Crisp scope at baseline → co-author design dir alongside ADR body. Saves pass-3 extraction cycle. Pattern continues durable.
- Production-DB MCP grounding continues durable (Pre-Input-5 instance #18 confirmed across 2 ADR baselines this session: §ADR-13 amendment + §ADR-16).

Architecture-decision phase status post-this-baseline: 12 ADRs ratified `#decision` + 3 live `#provisional` (§ADR-14 thread #80, §ADR-13 amendment thread #82, §ADR-16 this thread #83). After all 3 ratify: 0 live `#provisional`; full Phase-1 architectural surface ready for implementation kickoff per §11k orchestrator + thread #66 next-dev developer agent.

Threads opened: #83. Threads closed: none (Track 3 doesn't close anything; Track 1 already closed thread #81 via correction). Commit: `2d0a3a2`. PR: #25 (stacked on PR #20 → PR #19 → main).

Next pass candidate: ratify thread #82 (§ADR-13 amendment) + thread #80 (§ADR-14) + thread #83 (§ADR-16 this) — combined ratification possible; or sequential. After all 3 ratify, Track 2 (§ADR-4d D1 amendment) can baseline since F1+F2 enables slip_uploaded_by_type field specification.

---
*Added via Oracle Learn*
