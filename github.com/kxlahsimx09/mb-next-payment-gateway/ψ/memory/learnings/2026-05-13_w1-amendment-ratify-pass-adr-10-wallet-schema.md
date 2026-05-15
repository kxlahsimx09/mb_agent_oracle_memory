---
title: W1 amendment ratify pass — §ADR-10 wallet schema {balance, frozen} + freeze-sett
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, amendment, w1, adr-10, wallet-schema-frozen-column, freeze-settle-mutation-semantic, snapshot-per-row-audit, thread-96-closed, forward-looking-substrate-decision-instance-1-NEW, snapshot-per-state-change-audit-instance-1-NEW, production-drift-cross-system-flag-instance-1-NEW, cost-asymmetry-of-timing-decision-lens-instance-1-NEW, ask-why-does-it-exist-technique-instance-1, poc-implementer-comprehensive-audit-DURABLE, combined-baseline-ratify-landing-instance-6, trace-chain-34-links, pr:82, poc-implement-handoff-schema-migration]
created: 2026-05-13
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 amendment ratify pass — §ADR-10 wallet schema {balance, frozen} + freeze-sett

W1 amendment ratify pass — §ADR-10 wallet schema {balance, frozen} + freeze-settle mutation semantic + snapshot-per-row audit (combined baseline + pass-2 ratify; thread #96 closed). 3rd of 4 same-day poc-implement audit threads closed (#94/#95/#96/#97).

# Pass shape

Combined baseline + ratify landing — instance #6 (continuing durable). Single-commit combined-landing on clean-from-main branch.

User dialogue arc: initial architect-rec (Option B defer) → user "why does it exist?" → conceptual intent surfaces predictable future drivers → architect re-thinks via cost-asymmetry lens → recommendation flips to Option C → user wholesale-ratifies. 

# Production audit grounding

dpay MCP audit revealed:
- 103 wallets total (93 client + 10 partner)
- **frozen=0 across ALL 103 wallets** — production data shows frozen vestigial
- 1.5M+ audit rows: freeze=1, unfreeze=1 (essentially never invoked in real flow)
- 4 wallets (3.9%) have available > balance - frozen — production race-condition class
- wallets_change_logs schema: single-balance snapshot (no frozen_* audit fields)

→ Production MODEL has 3-balance triple but production CODE shortcut to pre-debit pattern.

# Decision pivot

Initial architect-rec: Option (B) Document Divergence — defer adding frozen because production-data shows unused.

User instinct: "freeze ในความจริงมีไว้ทำไม" — surfaced conceptual intent question.

Architect explanation: drivers are predictable Phase-2 asks (admin UI in-flight widget / merchant API available-balance / multi-step bank 2PC / reconciliation tooling).

Architect re-think: cost-asymmetry analysis shifted recommendation:
- Schema cost (adding column): trivial both timings
- Mutation semantic cost (rewriting payout RPCs): expensive to retrofit
- Audit history cost: **irrecoverable** (rows written without frozen_* fields cannot be retroactively populated)

→ Adopt now = audit history correct from row #1 + code paths written once.

# AM1-AM8 (wholesale-ratified)

- **AM1** — Schema `{balance, frozen}` 2-column + computed `available` (not GENERATED)
- **AM2** — Freeze-settle mutation semantic (5 RPCs specified per-op)
- **AM3** — Snapshot-per-row audit (all 4 balance/frozen fields on every row)
- **AM4** — Operation enum: add `payout_freeze` / `payout_settle` / `payout_unfreeze`; existing preserved
- **AM5** — `CHECK (balance >= frozen)` table-level invariant
- **AM6** — Partner wallet uniform schema (frozen column default 0; never freezed)
- **AM7** — Phase-2 driver criteria for further substrate evolution (4 explicit triggers)
- **AM8** — Production drift forensic note (brew-ops handoff to #current team)

# NEW patterns surfaced

## Forward-looking-substrate-decision sub-pattern — instance #1 NEW (AM2)

Distinct from "premature optimization avoidance":
- Premature optimization: adopt now for hypothetical future need
- Forward-looking-substrate: adopt now when retrofit cost asymmetrically high + future driver probability moderate-to-high + current adoption cost near-zero

Trigger conditions:
1. Decision concerns substrate (schema + mutation semantic + audit shape) not feature surface
2. Retrofit cost > forward cost asymmetry demonstrable
3. Future driver probability moderate-to-high (predictable business asks)
4. Current cost of adopting forward substrate is near-zero

Brew-ops handoff candidate at instance #2.

## Snapshot-per-state-change audit pattern — instance #1 NEW (AM3)

Distinct from event-sourcing sparse pattern. Trade-off analysis:
- Snapshot: every row has full state; query simplicity; compliance-friendly; mild storage overhead
- Sparse: only-what-changed; storage lean; requires LAG window function for state reconstruction

Snapshot wins for financial audit because:
- Compliance/audit queries common (single-row reads vs window functions)
- Storage cost negligible (~$0.002/month savings ignored)
- NULL convention ambiguity avoided
- Matches existing production audit shape

Apply uniformly across all next-system audit tables (wallets_change_logs, callback_attempts, slip_verify_attempts, audit_log, fleet_command_log). Brew-ops handoff candidate at instance #2.

## Production drift cross-system flag pattern — instance #1 NEW (AM8)

Architectural-note-only documentation of #current bug class that next-system does not inherit by design. Distinct from "deliberate divergence" (architecturally chosen) — this is "we noticed production has a bug that we will not inherit because our design naturally avoids it."

Pattern: when next-system architecture audit incidentally surfaces #current bug, document the finding architecturally so brew-ops can route to #current team for observability/cleanup. No next-system action required.

## Cost-asymmetry-of-timing as decision lens — instance #1 NEW

When evaluating "adopt now vs defer Phase-2":
- Can the substrate be added cheaply later? (yes for schema; no for audit history)
- Does delay propagate cost? (yes for mutation code paths written with wrong pattern)
- Is current adoption cost truly zero or just low?

Forward-substrate adoption defensible when answers align toward adopt-now. Brew-ops handoff candidate at instance #2.

## "Ask why does it exist" as architect technique — instance #1

When production data alone disagrees with model schema, ask the conceptual-intent question before deferring. User's *"freeze ในความจริงมีไว้ทำไม"* triggered this surfacing.

Pattern: production data shows current usage; conceptual intent shows design rationale + future drivers; combine both for grounded decision. Brew-ops handoff candidate at instance #2.

## PoC-implementer comprehensive-audit pass — instance #1 DURABLE confirmed

4 drifts surfaced from single 2026-05-13 audit pass (threads #94/95/96/97). Distinct from "writer-flagged unratified surface during user-story authoring" because PoC audit reviews substrate/implementation against production behaviour rather than ratified-text/story-shape alignment.

Brew-ops handoff: add to W1 workflow doc as "implementation-pass-triggers-architect-amendments" lifecycle pattern.

# Continuing-durable

- Combined baseline + ratify landing — instance #6
- Verify-divergence-via-production-MCP at amendment time — instance #7

# Same-arc 4-thread closure progress (2026-05-13)

- #94 (matcher cascade) — closed via reply (PoC bug; ADR D3 already correct port-verbatim)
- #95 (callback wire contract) — still open pending Q1 ratification
- **#96 (wallet schema) — CLOSED via this amendment**
- #97 (admin-in-loop) — closed via reply (PoC bug; ADR D5 already correct)

# Architecture-decision phase status post-pass

**19 ADRs/amendments ratified `#decision`; 0 live `#provisional`.** Corrective amendment ratifies previously-deferred column schema + forward-looking substrate adoption without opening new provisional.

Trace chain: extends 33 → 34 links. Sequence: `bffd971f` §ADR-13 amend → `42c30ed4` §ADR-16 → `0eef3209` §ADR-4d D1 → `d5139d8e` §ADR-4b D6 → `46bc6d02` §ADR-4d D8 → `5f9b66fa` §ADR-9 → this pass.

# Handoff to poc-implement

Schema migration + RPC ports per AM1-AM6. Direct implementation steps:

```sql
ALTER TABLE wallet
  ADD COLUMN frozen numeric(18,2) NOT NULL DEFAULT 0,
  ADD CONSTRAINT wallet_frozen_nonneg CHECK (frozen >= 0),
  ADD CONSTRAINT wallet_balance_gte_frozen CHECK (balance >= frozen);

ALTER TABLE wallets_change_logs
  ADD COLUMN frozen_before numeric(18,2) NOT NULL DEFAULT 0,
  ADD COLUMN frozen_after numeric(18,2) NOT NULL DEFAULT 0;
```

RPC mutations:
- create_payout: `frozen +=`; balance untouched; check (balance - frozen) >= amount+fee
- mark_success: balance -= AND frozen -=
- mark_failed: frozen -=; balance untouched
- finalize_deposit: balance +=; frozen untouched (unchanged)
- distribute_mdr (partner): balance +=; frozen untouched (unchanged)

Recommend bundling AM5 invariant + AM3 audit columns into single migration file with #94 cascade port migration.

# Sources

- thread:#96 (poc-implement audit; 3-option architectural choice + Q2 sub-question)
- dpay MCP audit 2026-05-13: wallets collection + wallets_change_logs operation distribution + integrity check
- mobiz code: models/wallets.go (3-column model schema); PayoutController/withdrawalQueue (freeze semantic intent)
- §ADR-10 Decision #1/#2/#5 (preserved + extended)
- §ADR-4a/4b/4d (mutation call sites — unchanged in behavior, semantic clarified)
- Concurrent threads #94/#95/#97 (same poc-implement audit pass)
- session-arc memory: `project_session_arc_2026-05-10-to-11-poc-impl.md`

# Commit anchor

`0dd1835` (amendment combined-landing on branch `architect/w1-adr10-amendment-frozen-column-2026-05-13`). PR #82 merged via `9e006fb`.

---
*Added via Oracle Learn*
