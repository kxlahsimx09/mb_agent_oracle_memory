---
title: p2p-hub §E5/§C9 — matching was ONE-DIRECTIONAL (deposit-only); symmetric is the 
tags: [system-architect, repo:p2p-hub, symmetric-matching, bidirectional, fifo, propose_match, try_match, deposit, payout, skip-locked, concurrent-race, sweep-tick, driver, match-engine, C9, E5, E11, thread-8, pr-23, impl-gap, p-001, p-004, cross-db-caveat]
created: 2026-06-02
source: system-architect — thread #8 + PR #23 (P-004 vs migrations 007/009)
project: github.com/kxlahsimx09/p2p-hub
---

# p2p-hub §E5/§C9 — matching was ONE-DIRECTIONAL (deposit-only); symmetric is the 

p2p-hub §E5/§C9 — matching was ONE-DIRECTIONAL (deposit-only); symmetric is the intended model (impl gap, not a reversal). [RATIFICATION_PENDING: Oracle thread #8, PR #23]

## The gap (P-004, confirmed vs migrations 007/009)
`propose_match(p_deposit_intent_id)` (migration `009_formation_rpcs.sql`) locks the arriving item `WHERE side='deposit'` (L60-61) and scans the counterparty `WHERE side='payout' ORDER BY created_at ASC LIMIT 1 FOR UPDATE SKIP LOCKED` (L87-94). So ONLY "deposit arrives → fill oldest waiting payout" is built. A **deposit pooled first + payout arriving later NEVER matches** (nothing fires on payout-arrival). Human-spotted bug.

## Why it's a gap, not a design reversal
The design already INTENDS symmetric:
- §C9 (design L1016-1018): "a deposit intent with no compatible waiting withdrawal waits in turn until one appears" — only meaningful if payout-arrival matches waiting deposits.
- Migration `007_pool_items.sql` L46-47 created `pool_items_deposit_open_idx ON (amount, created_at ASC) WHERE side='deposit' AND status='POOLED'` — an index to SCAN WAITING DEPOSITS, with **NO consumer today**. It only makes sense for a payout-arrival scan. Substrate built for symmetric; RPC half missing. (Pattern: an unused partial index is a tell that an intended code-path was never wired.)

## The recommendations (for ratify on thread #8)
1. **Symmetric model** — arriving item on EITHER side fills the oldest compatible (equal-amount, provider ACTIVE+serves) waiting counterparty on the OTHER side, `created_at ASC` (symmetric FIFO). Extends §C9/CQ5 fairness to both directions; no starvation change.
2. **RPC shape (B) RECOMMENDED:** unified `try_match(p_pool_item_id)` — detects arriving `side`, scans the opposite side, normalizes to `(dep,pay)`, runs the ONE existing 009 formation body (already side-symmetric: payout reserves M+F_p, deposit reserves F_d). `propose_match` kept as a thin wrapper (P-001: evolve, don't delete the ratified signature). Reject (A) parallel `propose_match_from_payout` — duplicates the money-touching §D3 reserve/rollback/B2.1 logic.
3. **⚠️ Concurrent-both-arrive race (the subtle one):** compatible D+P arrive near-simultaneously → each `try_match` `SKIP LOCKED`-skips the other's still-locked arriving row → both find no counterparty → both sit POOLED → MISSED PAIR. It's a LIVENESS miss only (B2.1 + §D3 still forbid double-match/money error; safe fallback = "match later" never "match wrong"). **Mitigation: periodic SWEEP TICK** re-runs try_match over POOLED oldest-first (primary safety net) + accept/document the bounded live miss (≤ one sweep interval). Reject "drop SKIP LOCKED" (reintroduces the FIFO-scan contention §E9 added it to prevent).
4. **Driver (was §E11/§G9 'operational/deferred'; symmetric FORCES it):** inline best-effort `try_match` at tail of `submit_pool_item` (must NOT roll back a valid submit) + the sweep tick. Reject AFTER-INSERT trigger as primary (hidden control flow in a money path).

## Cross-DB caveat
This is the **same same-amount-FIFO matching class as mobiz `transactionMatcher.go`** (see learning `2026-05-23_same-amount-fifo-matching-gap`), but mobiz's is a KNOWN-WONTFIX single-DB Go matcher; p2p-hub's is greenfield Postgres RPC with FOR UPDATE SKIP LOCKED concurrency — the race + sweep analysis here is p2p-hub-specific and must NOT be conflated with the mobiz wontfix. Different DB, different concurrency model.

## Status
DESIGN-ONLY. Impl follow-up (next-impl): unified `try_match` migration + propose_match rewrap (CREATE OR REPLACE, P-001) + driver wiring + sweep tick + regression assertions (deposit-pooled-first→payout-arrives→matches; concurrent→sweep closes). No merge until human ratifies thread #8.

---
*Added via Oracle Learn*
