---
title: W1 pass 4 — Remove `required_method` column from `withdrawal_queue` (schema hygi
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, pass-4, withdrawal-queue, schema-hygiene, data-model, source-type, single-source-of-truth]
created: 2026-04-22
source: docs/adr.md@a7fb131 + user dialogue 2026-04-22 (required_method redundancy question)
project: github.com/kxlahsimx09/mb_agent_oracle_memory
---

# W1 pass 4 — Remove `required_method` column from `withdrawal_queue` (schema hygi

W1 pass 4 — Remove `required_method` column from `withdrawal_queue` (schema hygiene).

## Context

User reading the pass-2 `withdrawal_queue` schema asked: "`required_method` คือ field อะไรนะ" and then "มันซ้ำจริงๆ แหละ แต่มันควรเอาออกไหม" (it's truly redundant, should we remove it?).

Pass-2 schema had:
```sql
CREATE TABLE withdrawal_queue (
    ...
    source_type source_type_enum NOT NULL,
    ...
    required_method method_enum,     -- ← 1:1 redundant with source_type
    ...
    CHECK (... required_method IS (NOT) NULL ...)
);
```

## Analysis

`required_method` is 1:1 determined by `source_type`:

| source_type | required_method (pass-2) | used for |
|---|---|---|
| `payout` | `'payout'` | Mode 1 method filter |
| `settlement` | `'settlement'` | Mode 1 method filter |
| `pullout` | `NULL` | Mode 2 (method check bypassed) |
| `direct_transfer` | `NULL` | Mode 2 (method check bypassed) |

Two options to remove the redundancy:
1. **GENERATED ALWAYS AS ... STORED** — auto-derive in DB. Removes the mismatch-bug class but keeps the concept + column.
2. **Remove entirely, use IMMUTABLE helper function** — `source_type_to_method(source_type)` called in RPC filter and conceptually in the Realtime subscription filter.

Chose option 2 because:
- Aligns with current-system pattern (`supportedSourcesForBank()` in `services/withdrawalQueue.go:659-674` derives live from `bank.Method` at query time — no snapshot column).
- Single source of truth — `source_type` is the primary concept; method is always a derivation.
- Matches the "no embedded snapshot" principle that we adopted in pass 2 for `bank_account_method` (live junction table, not snapshot, to fix the 2026-04-11 drift).
- Cleanest CHECK constraint.

## Change

`docs/adr.md` §ADR-4a at commit `a7fb131` on branch `claude/cool-snyder-6effcf` (PR `kxlahsimx09/mb-next-payment-gateway#1`, open).

- Removed `required_method method_enum` from `withdrawal_queue`.
- Simplified CHECK constraint:
  ```sql
  CHECK (
    (source_type IN ('pullout','direct_transfer')
     AND required_bank_account_id IS NOT NULL
     AND pool_id IS NULL)
    OR
    (source_type IN ('payout','settlement')
     AND pool_id IS NOT NULL
     AND required_bank_account_id IS NULL)
  )
  ```
- Added helper:
  ```sql
  CREATE FUNCTION source_type_to_method(st source_type_enum)
  RETURNS method_enum LANGUAGE sql IMMUTABLE AS $$
      SELECT CASE st
          WHEN 'payout'     THEN 'payout'::method_enum
          WHEN 'settlement' THEN 'settlement'::method_enum
      END
  $$;
  ```
- RPC filter updated:
  ```sql
  -- Mode 1: pool-broadcast
  (required_bank_account_id IS NULL
   AND pool_id = v_pool_id
   AND source_type_to_method(source_type) = ANY (v_bot_methods))
  ```
- Realtime subscribe filter example updated to `source_type = in.(…bot's supported source_types…)` where `bot_source_types` is computed at connect time from the bot's bank methods.

## Why this is a refine-pass, not supersede

The design's *shape* is unchanged:
- Mode 1 (pool-broadcast) + Mode 2 (direct-address) — still present
- Layer 1 / 2 defense-in-depth — still present
- Physical-constraint invariant — still present
- Claim-side batch assembly — still present
- RPC is still the only path `pending → claimed` — still present

Only the internal schema redundancy is cleaned up. Pass-2 learning (`learning_2026-04-22_w1-refine-pass-2-withdrawal-dispatch-claim-ra`) remains the primary decision record; `arra_supersede` not applied.

## Process note

Two user-surfaced refinements in a row (pass 3 fact-correction from pg-writer, pass 4 schema-hygiene from user reading the pass-2 doc) validate the "ADR-4a as a living document reviewed by peers before any code lands" approach. Pass 1 → pass 4 dropped mass per pass (1: baseline draft, 2: ratification + new concepts, 3: fact correction, 4: schema cleanup). The trajectory is quality-converging. Worth noting for future architect sessions: *expect at least 2-3 refine passes on any non-trivial subsystem before the decision is stable*.

## Tags

system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, pass-4, withdrawal-queue, schema-hygiene, data-model, source-type, source_type_to_method, single-source-of-truth, user-surfaced

---
*Added via Oracle Learn*
