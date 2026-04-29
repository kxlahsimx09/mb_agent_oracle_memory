---
title: W1 ADR-8 pass 4 — doc-organization refactor: extract implementation detail to `d
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-8, pass-4, doc-organization, extract, refactor, decision, fair-router, design-doc-convention, adr-vs-design-doc]
created: 2026-04-24
source: docs/adr.md@e367e92 + docs/design/bot-gateway-dispatch/* (2026-04-24 GMT+7 post-ratification doc-organization refactor per user size-review request)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 ADR-8 pass 4 — doc-organization refactor: extract implementation detail to `d

W1 ADR-8 pass 4 — doc-organization refactor: extract implementation detail to `docs/design/bot-gateway-dispatch/`; shrink §ADR-8 body 118 → 66 lines.

## Scope

Post-ratification cleanup. User surfaced that §ADR-8 had grown to 118 lines through 5 pre-ratification amendments — close to the ~150-line extract-consideration threshold §ADR-4a pass-6 established. Pass 4 applies same extract pattern: move implementation detail to design doc; keep decisions + whys inline.

**No decisions changed.** Pass-3 (`learning_2026-04-24_w1-adr-8-pass-3-ratification-provisional`) remains the primary `#decision` record.

## What was extracted

Created `docs/design/bot-gateway-dispatch/` with 4 files:

### `README.md` (~68 lines)
- Directory purpose + separation-of-concerns note (ADR vs design doc)
- Full contents table
- **Full prior-art citation list** (12+ learnings)
- Current-system code paths reference (9 file:line pointers)
- Decision → implementation mapping table
- Status + cross-reference to §ADR-8 ratification

### `fair-router.md` (~260 lines)
- Triggers A/B definitions (full context)
- Execution flow pseudocode (TypeScript)
- 8-filter stack with port-source attribution per filter
- `bankDailyUsage` computation — 3 components (base + queueLoad + in-invocation) with formulas
- LRU selection code (port of `:554-565`)
- Tier-cap selection code + DRIFT-12 note
- Advisory lock pattern discussion (why try-xact-scoped; per-pool; lock key)
- Drain loop pattern (re-query each iteration; exit conditions)
- **Cross-cutting `base` write-path dependency** (MarkSuccess + syncBankTransactionCounts)
- Observability (structured log event schema)
- Testing (unit + integration + e2e)

### `trigger-coalescing.md` (~156 lines)
- X4 trigger SQL (full CREATE FUNCTION)
- `pg_try_advisory_lock` probe semantics
- Session-scoped vs xact-scoped choice explained
- Burst scenario walk-through (50 INSERTs)
- 5 race-window / edge case analyses: (1) EF finishing + late INSERT, (2) cold-start race, (3) lock key collision, (4) transaction rollback, (5) lock held but EF dead
- Trigger B behavior distinction (lifecycle RPC doesn't use probe)
- Monitoring targets
- Testing (unit + integration + chaos)

### `sweep-extensions.md` (~170 lines)
- Relationship to §ADR-4a existing sweep (preserving)
- Case 1 (stuck `pending_routing > 1 min`) — when, action, SQL, bounded latency
- Case 2 (stale `required_bank_account_id` + no claim) — when, action, SQL, bounded latency
- Why separate cases (observability + targeted action + alerting)
- Combined pg_cron schedule SQL
- Failure mode × recovery matrix (9 scenarios)
- Monitoring targets
- Testing (pgTAP + integration + chaos)

## §ADR-8 body changes (no decisions altered)

**Removed from body (moved to design docs):**
- X4 trigger SQL (CREATE FUNCTION block; ~15 lines inline → moved to trigger-coalescing.md)
- Filter stack verbose enumeration (~8 filter entries with port-source details → moved to fair-router.md; summary list remains in ADR)
- Cross-cutting `base` write-path dependency verbose note (~6 lines → moved to fair-router.md §Cross-cutting)
- Rejection rationale per-alternative multi-paragraph prose (~20 lines → condensed to one paragraph in ADR)
- Inline amendment-breadcrumbs ("amended pre-ratification 2026-04-24...") — preserved in Revision log narrative, removed from body (since ratified)

**Preserved inline:**
- §Context (3-shape inventory, 3-paragraph critical finding with business constraint, direction rationale)
- §Options table (5 rows A-F with fairness mechanism + current analogue)
- §Decision (5 numbered steps, each 1-3 sentences + pointer to design doc)
- §Exception — admin + §Exception — emergency (each 1 sentence)
- §Scope boundary (1 sentence)
- §Consequences (8 positive + 6 negative; condensed single-paragraph)
- §Trade-offs summary + 8 revisit triggers (inline)
- §Prior art (5 primary citations + pointer to full list in README.md)
- §Deferred questions (thread #46 resolved + [AWAITING_THREAD:45])

## Shrinkage metrics

| Measure | Pre-pass-4 | Post-pass-4 | Δ |
|---|---|---|---|
| §ADR-8 body lines | 118 | 66 | -44% |
| Inline SQL | ~15 lines | 0 | moved to design doc |
| Design doc lines | 0 | ~654 | extracted net-add |
| `docs/adr.md` total | unchanged in decisions | +70 in revision log (pass-4 entry) | narrative growth |
| Document navigability | single-file 118 lines for full detail | ADR 66 lines + 4 design files discoverable | improved read-time for ADR scanners; impl agents get full spec |

## No `arra_supersede` applied

Pass-3 ratification learning remains primary `#decision` record. Pass-4 is doc-organization only — same content, cleaner separation. If future passes change actual decisions, they'll supersede pass-3 as usual.

## Commit chain (cumulative)

```
3337d4e  pass-1 pull-first (provisional) [superseded]
5b4996e  pass-1 id backfill
36628c3  pass-2 reframe: push via fair-router (provisional)
2518e72  pass-2 id backfill
b87fc1a  amendment: Trigger B + sweep reframe + early-bail
665d209  amendment id backfill
9fe73c8  correction: withdrawal-only metric + dead-code findings
eeaab31  correction id backfill
330c116  correction cleanup: body + prior art + sources
8228c05  completeness sub-amendment: X4 + heartbeat + base deps
9478d1f  sub-amendment id backfill
4d6e93d  business-constraint ratification (Phase-2 metric resolved)
5215ecb  pass-3 ratification: #provisional → #decision
e367e92  pass-4 doc-organization refactor (THIS)
```

Branch `claude/relaxed-brown-12cebb`, PR [#2](https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/2).

## Pattern captured — two-tier document organization for cross-cutting ADRs

ADRs that span multiple implementation concerns (fair-router spans enqueue + routing + broadcast + claim + sweep; multiple subsystems) naturally grow during ratification. The extract pattern (established by §ADR-4a pass-6, now repeated by §ADR-8 pass-4):

1. **Trigger:** post-ratification review reveals body is close to or past 150-line threshold.
2. **Extract target:** `docs/design/<subsystem>/` with 3-5 files covering distinct implementation concerns (body + SQL triggers + sweep + open questions).
3. **ADR body shape post-extraction:** decisions + whys + cross-doc pointers. Target ~50-80 lines.
4. **Preserve history:** no arra_supersede; pass entry in revision log documents what moved where; git history preserves pre-extraction body state.
5. **No decisions change:** pure refactor.

Worth codifying as standard architect practice.

## Next-pass candidates

**Independent, not blocking:**
- §ADR-4a follow-up: rewrite `docs/design/withdrawal-lane/*.md` to match fair-router model (remove Mode-1 racing references; add fair-router Trigger B documentation; add sweep-case-2 references). Deferred to next architect session.
- Deposit auto-match lane (§ADR-4 other half). Fair-router principle does NOT apply (deposit matcher is server-side; bot-submitted statements trigger it).
- Admin-review workflow refine pass (mobiz thread #14 carryover).
- Thread #45 fleet-control ADR when concrete driver emerges.

**Meta:**
- Session retrospective covering passes 1 → 4 (marathon session).
- Handoff to pg-writer on drift learnings (`SelectBankForPayout` dead code + `countTodayCompletedTransactions` dead code).


---
*Added via Oracle Learn*
