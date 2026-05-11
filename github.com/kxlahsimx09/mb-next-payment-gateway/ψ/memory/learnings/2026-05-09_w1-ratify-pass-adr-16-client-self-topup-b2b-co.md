---
title: W1 ratify pass — §ADR-16 Client Self-Topup B2B (combined baseline + pass-2 ratif
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-16, client-self-topup, b2b, client-topups-table, apply-client-topup-rpc, ratify, pass-2, decision, thread-83-closed, track-3-closed, combined-baseline-ratify-landing-instance-1-NEW, append-only-forensic-pattern-instance-5, create-time-actor-triple-pattern-instance-2, substrate-convergence-7, production-db-mcp-grounding, p2p-orthogonality-confirmed, phase-1-admin-only, pr:40]
created: 2026-05-09
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 ratify pass — §ADR-16 Client Self-Topup B2B (combined baseline + pass-2 ratif

# W1 ratify pass — §ADR-16 Client Self-Topup B2B (combined baseline + pass-2 ratify; thread #83 closed)

# Pass shape

Combined-landing pass (NEW pattern instance #1): baseline filed 2026-05-07 + pass-2 ratify 2026-05-09 consolidated into single `#decision` landing on clean-from-main branch. Distinct from prior "combined pass 1.5+2" pattern (same-session pre-ratification revise + ratify); this is "baseline + ratify span session boundary + wholesale ratify + branch has rebase debt → consolidate into one commit on clean branch."

Trigger conditions for combined-landing:
1. Baseline filed in earlier session; ratification crosses session boundary
2. User ratifies wholesale (no revise scope)
3. Baseline branch has rebase debt (auto-merge artifacts re-introducing already-stripped markers from upstream merges that landed mid-rebase)

When all 3 hold, single-commit landing on clean-from-main branch is right call. Saves rebase choreography + clean diff for reviewer.

# G1-G7 ratification

All 7 sub-questions wholesale-ratified per *"Thread #83 ok ตามที่แนะนำทั้งหมด"*:

- G1 — Topup as distinct entity (separate `client_topups` table; no flag-based discrimination in `ts_deposits`)
- G2 — Phase-1 admin-only path; client/sub-client deferred Phase-2 (production: 22 records 100% admin-approved; no driver for self-service Phase-1)
- G3 — Atomic apply via `apply_client_topup` thin PL/pgSQL RPC (substrate convergence #7)
- G4 — `client_topups` append-only-spirit schema (pattern instance #5)
- G5 — MDR distribution preserved verbatim from mobiz current
- G6 — No external callback (explicit non-decision)
- G7 — Create-time actor triple per §ADR-13 amendment F2 (mandatory; Phase-1 always admin)

# P2P-matching forward-compatibility check (orthogonality verified)

User asked at thread #84 H1 walk-through whether the §ADR-16 design supports the future P2P-matching PoC (`learning_2026-05-09_poc-feasibility-p2p-withdrawdeposit-matching-p`, PR #41). Architect confirmed orthogonality:

- §ADR-16 = topup-side feature (B2B lane: client business → mobiz lump-sum)
- P2P matching = deposit-side feature (B2B2C lane: customer → withdrawer-customer direct route, bypassing system bank)
- Different entities, different actors, different routing logic — no interaction
- Phase-2 P2P amendment (when ratified) lands on §ADR-4 lane (e.g. §ADR-17 NEW or §ADR-4 amendment), not §ADR-16

Pattern: *"forward-compatibility check before ratify"* — when ratifying ADR-X with adjacent feature ADR-Y in flight (or pre-ADR PoC stage), verify orthogonality explicitly. If orthogonal → ratify ADR-X cleanly. If interaction → consider amendment scope or defer.

# Pattern accumulation post-pass

- **Combined baseline + ratify landing — instance #1 NEW.** Brew-ops handoff candidate at instance #2.
- **Append-only forensic table — instance #5.** Continuing-confirmation; durable rule unchanged.
- **Create-time actor triple — instance #2 (within §ADR-16 specifically; durable rule confirmed at instance #5 per session-close 2026-05-08 retro tally counting all ADRs together).**
- **Substrate convergence (thin RPC) — #7.** Continuing-confirmation; durable rule unchanged.
- **Front-load design-dir at baseline — instance #3.** Authored 2026-05-07; ratify pass found design dir adequate — no revise needed.
- **Production-DB MCP grounding** continues durable per session-close retro.

# Trace chain — extends 28 → 29 links

`bffd971f` (§ADR-13 amendment ratify pass 1.5+2, 2026-05-08) → `[backfill]-§ADR-16-ratify` (this pass, 2026-05-09).

Next link reserved for §ADR-4d D1 amendment ratify (Track 2 close, planned same-session as this).

# Architecture-decision phase status post-pass

18 ADRs/amendments ratified `#decision`:
- §ADR-1 / §ADR-2 (+ Auth Surface Completion amendment) / §ADR-3 / §ADR-4 / §ADR-4a / §ADR-4b (+ Bot↔Gateway Statement Push Contract amendment + D2 Matcher Cascade amendment) / §ADR-4c / §ADR-4d (+ Slip-Bearing Fraud Detection amendment) / §ADR-5 / §ADR-6 / §ADR-7 / §ADR-8 / §ADR-9 / §ADR-10 / §ADR-11 / §ADR-12 / §ADR-13 (+ Client Web User Actor amendment) / §ADR-14 / §ADR-15 / **§ADR-16 NEW (this pass)**.

1 live `#provisional` remaining: §ADR-4d D1 amendment thread #84 (Track 2). Planned ratify same-session.

After thread #84 ratify: **0 live `#provisional`; full Phase-1 architectural surface complete; `next-dev` activation per thread #66 fully unblocked.**

# Threads

- **Closed:** #83 (with closing message + commit citation 7811cfa).
- **Opened:** none.

# Sources

- thread:#83 messages 197 (G1-G7 baseline questions; full architect rec)
- thread:#81 (closed bridge from baseline pass; closure context preserved)
- baseline learning superseded: `learning_2026-05-07_w1-baseline-pass-adr-16-new-client-self-topup`
- 4 mobiz learnings (topup flow doc + 2 drifts + settlements F2 precedent)
- dpay MCP production verification (22 records 100% Tiger-approved)
- session-close retro `ψ/memory/retrospectives/2026-05/08/15.28_session-close-3-day-architecture-sprint-2026-05-06-to-08.md` (resume context + priority-1 task)
- p2p-matching PoC learning `learning_2026-05-09_poc-feasibility-p2p-withdrawdeposit-matching-p` (orthogonality verified)

# Commit anchor

`7811cfa` (§ADR-16 ratify combined-landing) on branch `architect/w1-baseline-adr-16-client-self-topup-2026-05-07` (force-pushed clean from main). PR #40.

---
*Added via Oracle Learn*
