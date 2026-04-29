---
title: W1 ADR-8 pass-2 **completeness sub-amendment** — X4 NOTIFY coalescing + heartbea
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-8, pass-2, sub-amendment, completeness-fix, provisional, fair-router, x4-coalescing, heartbeat-filter, base-dependency, ratification-ready]
created: 2026-04-24
source: docs/adr.md@8228c05 + 3 pre-ratification spec-completeness fixes (thread #46 discussion 2026-04-24 GMT+7)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 ADR-8 pass-2 **completeness sub-amendment** — X4 NOTIFY coalescing + heartbea

W1 ADR-8 pass-2 **completeness sub-amendment** — X4 NOTIFY coalescing + heartbeat filter + base write-path dependency.

## Supersedes

`learning_2026-04-24_w1-adr-8-pass-2-amendment-correction-pack-w` — adds three specification-completeness fixes on top. No decision changes. Core Option F intact.

## What this sub-amendment adds to ADR-8 text

### 1. X4 NOTIFY coalescing (§Decision step 1)

AFTER-INSERT trigger uses `pg_try_advisory_lock` as a probe to test if router is running:
```sql
IF pg_try_advisory_lock(hashtext(NEW.pool_id::text)::bigint) THEN
  PERFORM pg_advisory_unlock(hashtext(NEW.pool_id::text)::bigint);
  PERFORM pg_notify('pool_events', NEW.pool_id::text);
END IF;
-- lock held = router drain-looping → skip notify
```

**Effect:** burst N-INSERTs → N' ≈ 1-5 EF invocations (not N). Router's drain-loop re-queries `pending_routing` each iteration, so skipped INSERTs are picked up naturally. Race at drain-loop-end (INSERT between empty-check and commit) covered by sweep 1-min case 1.

### 2. Heartbeat + idle + MaxDailyTransactions filters made explicit (§Decision step 2 filter stack)

Previously the filter stack said "method / balance / MaximumOutstandingWithdrawal / tier cap / pool membership" — implicit "port current but enumerate later." Now enumerated:
- **Method support** (`bank.methods @> source_type_method`)
- **Heartbeat fresh** (`bank.heartbeat_at > now() - 60s`) — port of `findIdleBanks` stale-bot skip from PR #206 @ `f7f43bc`
- **Bank idle** (no in-flight batch — enforces one-batch invariant at routing time)
- **Remaining balance**
- **`MaximumOutstandingWithdrawal`** ceiling
- **`MaxDailyTransactions`** hard cap
- **Tier cap** (per-invocation `assignedCount < perBankCap`)
- **Pool membership** (NOT NULL CHECK)

### 3. Cross-cutting `bankDailyUsage.base` write-path dependency

`base = bank.daily_transactions` requires two subsystems to write correctly:
- **`mark_success` lifecycle RPC** — `$inc daily_transactions: 1` on every withdrawal success
- **`syncBankTransactionCounts` Edge Function** — `$max daily_transactions = outCount` from `bank_statements` scrape

Fair-router depends on both but owns neither. Dependency made explicit in ADR text so implementation agents know to wire all three subsystems together. If either write-path fails persistently, LRU metric skews → unfair distribution.

## What this sub-amendment does NOT change

- Core decision (Option F — push via fair-router EF) — intact
- Trigger A + Trigger B model — intact
- Claim RPC (`claim_withdrawal_items`) unchanged
- Sweep belt-and-suspenders semantics — intact
- Thread #46 ratification scope — 5 sub-questions unchanged

## Why sub-amendment vs pass-3

Pass 2 still `#provisional` pending thread #46. Adding specification detail BEFORE ratification is cheaper than ratifying incomplete text then adding detail post-#decision. Same pattern as earlier sub-amendments (Trigger B, correction pack). Keeps pass-2 chain clean: single ratification target, full spec.

## Cumulative commit chain for pass 2

- `36628c3` — reframe body (Option F adopted)
- `2518e72` — pass-2 id backfill
- `b87fc1a` — Trigger B + sweep-reframe + early-bail
- `665d209` — amendment id backfill
- `9fe73c8` — withdrawal-only metric correction (§Decision step 2)
- `eeaab31` — correction id backfill
- `330c116` — correction cleanup (§Context, §Prior art, §Sources)
- `8228c05` — completeness sub-amendment (THIS) — X4 + heartbeat + base deps

Branch `claude/relaxed-brown-12cebb`, PR [#2](https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/2).

## Ratification readiness

Design meets all 3 user criteria (verified in thread #46 pre-ratification review 2026-04-24 ~15:00):
1. **Fast, no unnecessary wait** — ~300ms typical vs current 30-60s; sweep 1-min only in edge cases
2. **Fair by bank load equivalent to current** — LRU + queueLoad + caps verbatim ported; speed adaptation via queueLoad
3. **No transaction loss** — 12 failure modes enumerated with recovery paths; no new loss scenarios introduced

Phase-2 opportunities flagged (not blockers):
- Unified-metric LRU (withdrawal + deposit) — anti-detect blind spot closure
- Trigger B rate under extreme load — materialized view mitigation
- DRIFT-12 (per-bank-independent cap) resolution opportunity

## Threads

- #44 closed (pass-1 superseded by #46)
- #45 pending (fleet-control substrate, unchanged)
- #46 pending (pass-2 ratification, 5 sub-questions + implicit Phase-2 metric question)

## Cross-references

- `learning_2026-04-24_correction-to-findbestbankforitem-prior-art-ban` — fairness mechanism finding (withdrawal-only)
- `learning_2026-04-24_current-system-prior-art-deposit-routing-via-se` — deposit side (separate rotation, sets context for unified-metric Phase-2)
- `learning_2026-04-24_drift-selectbankforpayout-is-dead-code-sort` — related drift
- `learning_2026-04-22_w1-refine-pass-2-withdrawal-dispatch-claim-ra` — §ADR-4a pass-2 ratified (Mode 1 semantic change tracked via pass-7 update note)

---
*Added via Oracle Learn*
