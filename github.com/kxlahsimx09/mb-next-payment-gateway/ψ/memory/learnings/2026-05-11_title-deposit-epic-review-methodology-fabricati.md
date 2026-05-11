---
title: title: DEPOSIT epic review methodology — fabrication detection + AWAITING_THREAD
tags: [next-product-writer, repo:mb-next-payment-gateway, next, epic-deposit, fabrication-detection, verify-divergence-via-production-mcp-instance-3, awaiting-thread-inventory, deliberate-divergence-from-mobiz-current, writer-discipline, story-review-methodology]
created: 2026-05-11
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: DEPOSIT epic review methodology — fabrication detection + AWAITING_THREAD

title: DEPOSIT epic review methodology — fabrication detection + AWAITING_THREAD inventory (2026-05-10 to 2026-05-11)

## Context

2-day session (2026-05-10 → 2026-05-11) reviewing the existing DEPOSIT-001..004 stories and authoring DEPOSIT-005. User-led review caught **9 fabricated/wrong claims** that had no source in §ADR, vault learnings, or production data. Surfaced **6+ architectural decisions** that need formal next-architect ratification.

## Fabrication-detection methodology (durable)

Verify every claim in next-system requirements against three independent sources:

1. **ADR** (`docs/adr.md`) — grep for the claim term/field name; check both decisions and amendments
2. **Vault learning** (`arra_search`) — search by claim keywords; filter to `#current` for current-system facts and `#next` for next-system decisions
3. **Production data** (`mcp__dpay__*`) — query Mongo collections directly to verify field existence, value ranges, status distributions, schema reality

A claim is **fabricated** if it appears in none of the three. A claim is **drift** if ADR + learning support it but production diverges (or vice versa). A claim is **load-bearing** if removing it would change a contract that future code depends on.

**Pattern instance #3** of `verify-divergence-via-production-mcp-before-propose` (after thread #82 §ADR-13 amendment + 2026-05-09 actor terminology fix thread #90).

## Fabrications caught this session (9)

| Story | Fabricated claim | What's true |
|---|---|---|
| DEPOSIT-001 | "Gateway adds a fingerprint to the amount (1,000.00 → 1,000.07)" | `paid_amount = amount` exactly; integer THB; no fingerprint. Matcher disambiguates via sender source-identity from bank statement |
| DEPOSIT-001 | "`expires_at` default 15 minutes" + "at least 5 minutes in the future" | Server-derived per-client: `expires_at = createdAt + clients.expired_deposit_time` (5–15 min in sample); not client-supplied |
| DEPOSIT-001 | "outstanding-deposit caps respected" in pool rotation | No `maximum_outstanding_deposits` field exists on `system_banks`; only daily-count cap |
| DEPOSIT-001 | AC using `daily_transactions`/`max_daily_transactions` | These are **withdrawal** counters; deposit AC should use `deposit_count`/`maximum_number_of_deposits` |
| DEPOSIT-002 | "exact-amount + fingerprint, then time-window heuristics" | §ADR-4b D2 amendment ratified 3-step cascade (parse-and-finalize / linkCheckingDeposit / linkPaidDeposit) |
| DEPOSIT-003 | "the gateway frees the system bank's capacity for the next deposit" on expire | `deposit_count` increments at creation, midnight-BKK blanket-zero only; no decrement on expire/match |
| DEPOSIT-004 | "deposit's TTL is extended per §ADR-4d D3 (15 minutes from upload)" | 15-min is the **Thunder-verify sweep threshold** (separate timer from `created_at`); deposit's own `expires_at` unchanged |
| DEPOSIT-004 | "same as DEPOSIT-001, but typically with a longer window" | Same `expires_at` derivation; no slip-specific longer window |
| DEPOSIT-004 | `custom_bank_*` as "destination override bypassing pool" | `custom_bank_*` is the **customer's source bank** (audit metadata); destination remains pool-selected. Field name is current-system misnomer |

## AWAITING_THREAD inventory (architectural ratifications pending)

Each of these is flagged inline in `docs/requirements/epic-deposit.md` as `[AWAITING_THREAD: ...]` and needs formal next-architect ratification (open arra thread, similar to thread #90 actor terminology fix pattern):

1. **Intra-bank fallback policy** (DEPOSIT-001) — next-system refuses pool-exclusion-empties with `NO_BANK_AVAILABLE_AFTER_EXCLUSION` instead of current's silent unfiltered fallback (which produces unreconcilable intra-bank deposits)
2. **Terminal-state taxonomy split** (DEPOSIT-004) — `rejected` (deliberate refusal) vs `failed` (unintentional system error); current overloads `failed`
3. **`expired_deposit_time` rename + scope** (DEPOSIT-001) — rename to `deposit_expiry_minutes` AND decide scope (per-client vs per-merchant vs system-wide vs drop)
4. **`custom_bank_*` → `customer_bank_*` rename + table location** (DEPOSIT-001) — field is misnomer; also decide on-row vs separate customer-payment-source table; fraud-loop integration
5. **Status-name canonicalization for multi-candidate parking** (DEPOSIT-005) — §ADR-4b D2 + production = `review`; D3 = `review_required`; lock canonical value
6. **Degenerate-multi-candidate FIFO carve-out** (DEPOSIT-005) — when ≥2 candidates share same source-account, auto-pick FIFO instead of parking (deliberate divergence from current; §ADR-4b D3 minor amendment)
7. **`pending_review` semantics** (DEPOSIT-005) — 1,774 production rows; separate flow from multi-candidate parking; semantics undocumented
8. **Custom-bank epic / customer-source-bank epic** — separate epic needed (DEPOSIT-001 edge case `[AWAITING_THREAD: TBD on first customer-source-bank epic pass]`)
9. **Specific paths that produce `failed` in next-system** (DEPOSIT-004) — not yet enumerated; design pass

## New patterns surfaced

- **"Deliberate divergence ratification at requirements time"** — instance #3 (after intra-bank fallback divergence + terminal-state taxonomy). Writer flags + recommends ADR minor amendment + uses `[AWAITING_THREAD]` placeholder; user provides explicit decision; arra thread formalizes later.
- **"Skill consultation gap"** — writer forgot to read SKILL.md + workflow-1 before authoring; user surfaced the rule (`Principle 4: no code in body`) mid-session; pattern: always grep + read skill files first when entering a writer-territory task.
- **"Greenfield framing discipline"** — `project_no_data_migration` memory; doc must not imply legacy backfill / migration scope; "12,497 records" cited as **current-system drift evidence only**, not as next-system backfill scope.
- **"Orphan commit pattern"** — recurring 5+ times across PRs #45/#46/#48/#53. User merges fast; commits pushed after-merge get orphaned. Mitigation: bundle all changes in 1 push BEFORE PR opens, accept re-apply pattern for genuine post-merge follow-ups.

## How to apply (next session)

1. Before reviewing any requirements doc, run `arra_search` for prior corrections on that story/term to avoid re-litigating settled issues.
2. For each claim in a story body, verify against ADR + learning + production data triple. Flag fabrications immediately.
3. For each `[AWAITING_THREAD]` inventory item above, open arra thread to next-architect with the proposed amendment shape — analogous to thread #90 actor terminology pattern.
4. Use Principle 4: prose stays plain-English; engineering identifiers (field names, status enums, error codes) appear only in ACs, Sources, mermaid, or edge case grounding.
5. Greenfield: never write "migration plan" / "legacy backfill" / "carry over data" in next-system requirements — only "fresh design from day one".


---
*Added via Oracle Learn*
