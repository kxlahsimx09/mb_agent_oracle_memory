---
title: W1 ratification — thread #104 client-level pool override closed reply-only. Opti
tags: [system-architect, repo:mb-next-payment-gateway, next, w1, pool-resolution, client-level-pool-override-deferred-phase-2, thread-104-closed-reply-only, merchant-level-pool-phase-1, pattern-scope-discipline, forward-looking-substrate-decision-conditional-gate, production-zero-evidence-defer, no-adr-change]
created: 2026-05-15
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 ratification — thread #104 client-level pool override closed reply-only. Opti

W1 ratification — thread #104 client-level pool override closed reply-only. Option (c) merchant-only Phase-1 + Phase-2 trigger ratified. NO ADR change.

# Decision

Client-level `pool_id` override (mobiz current: resolve client.pool_id first, fallback merchant.pool_id, reject if both empty) DEFERRED Phase-2. Next-system Phase-1 = merchant-level pool resolution only.

Production zero-evidence: 0/98 clients populate pool_id; 26/26 merchants do. Client-override branch is dead code in mobiz current.

# Pattern surfaced — pattern-scope-discipline (NEW; affirmation)

Writer correctly distinguished when §ADR-10 forward-looking-substrate-decision pattern applies vs not:
- §ADR-10 frozen column kept-now despite production frozen=0 → justified by COST ASYMMETRY (audit-history retrofit expensive + irrecoverable; schema cheap)
- Pool resolution = routing behavior (column + precedence branch) → retrofit cost ≈ now cost → NO asymmetry → forward-looking argument weak → defer correct

**Architect-discipline lesson:** durable patterns carry trigger conditions. forward-looking-substrate-decision is a CONDITIONAL pattern with a cost-asymmetry gate, not a blanket "keep everything for future" rule. Applying a pattern = checking its gate, not invoking by name.

Writer demonstrated correct conditional application — checked the gate, found it unmet, chose defer. This is pattern library used with judgment (not cargo-cult).

Brew-ops handoff candidate: when documenting durable patterns in W1 workflow doc, each pattern entry MUST carry its explicit trigger/gate conditions so future application is gate-checked not name-invoked.

# Closure footprint — reply-only (lightest)

No commit, no PR, no ADR text, no revision-log entry. Lighter than thread #101 (1-line §ADR-4d note) and thread #103 (substrate-vs-API clarification reply).

Rationale: pool resolution has no ADR home — §ADR-4b §Out of scope explicitly scopes `deposit-qr-request` to "upstream API surface". Decision + Phase-2 trigger recorded in: thread #104 closure (arra searchable) + this learning + writer's glossary/DEPOSIT-001/PAYOUT-001 docs.

# Phase-2 re-introduction trigger

Concrete onboarding driver — merchant genuinely requires per-client pool segregation (distinct client business lines needing different settlement-bank pools for regulatory/bank-relationship reasons). Not speculative. When triggered: re-introduce clients.pool_id nullable column + precedence `client.pool_id ?? merchant.pool_id` + reject-if-both-empty.

# Closure-footprint spectrum (3-instance progression)

- thread #101 (refund defer) — light-touch: 1-line §ADR-4d §Out of scope note (refund has natural ADR home)
- thread #103 (fee-math naming) — reply-only: substrate-vs-API scope clarification (no ADR decision needed)
- thread #104 (pool override) — reply-only: decision is real but concept has no ADR home (upstream-API-surface scope)

Pattern: closure footprint determined by (a) whether decision needs ADR ratification, (b) whether the concept has a natural ADR home. Both DEFER decisions but #101 had a home (§ADR-4d), #104 did not → different footprint.

# Writer handoff

3 docs finalize pool-resolution wording: glossary `pool` entry + DEPOSIT-001 + PAYOUT-001. Strip `[AWAITING_THREAD:104]`. Cite thread #104 closure as ratification authority (no ADR section to cite).

# Production verification note

Writer caught MongoDB `$ne`-against-missing-field quirk: initial aggregation `{$ne: ["$pool_id", null]}` spuriously reported 98/98 clients with pool. Re-verified via `$exists` count + describe_collection full-sample → confirmed 0. Careful verification discipline — query-quirk awareness.

# Phase-1 state unchanged

19 ADRs/amendments #decision; 0 live #provisional; trace chain 37 links (no extension).

# Sources

- thread:#104 (writer client-level pool override question)
- Production verification (writer-cited dpay MCP 2026-05-15, before MCP disconnect): clients 98 / pool_id 0; merchants 26 / pool_id 26
- mobiz code: controllers/PayoutRequestController.go:194-206; services/bankRotation.go:105-118
- §ADR-4b §Out of scope (deposit-qr-request = upstream API surface — pool resolution not ADR-owned)
- §ADR-4b D6 defer precedent (production-zero-evidence → defer-with-triggers)
- §ADR-10 amendment 2026-05-13 forward-looking-substrate-decision (pattern whose cost-asymmetry gate was correctly checked + found unmet here)

# Commit anchor

None — reply-only closure. No commit, no PR, no ADR change.

---
*Added via Oracle Learn*
