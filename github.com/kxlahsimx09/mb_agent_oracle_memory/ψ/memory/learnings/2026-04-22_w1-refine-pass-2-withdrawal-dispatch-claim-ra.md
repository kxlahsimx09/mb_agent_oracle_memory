---
title: W1 refine pass 2 — withdrawal dispatch & claim (ratified `#decision`).
tags: [system-architect, repo:mb-next-payment-gateway, repo:cross, next, adr, refinement, w1, withdrawal-queue, dispatcher, decision, ratified, pool, defense-in-depth, physical-constraint, source-type-modes, data-model, migration-map]
created: 2026-04-22
source: docs/adr.md@c57f1a6 + threads #41 + #42 (both closed 2026-04-22); evidence bundle cited in §Revision log pass-2 entry
project: github.com/kxlahsimx09/mb_agent_oracle_memory
---

# W1 refine pass 2 — withdrawal dispatch & claim (ratified `#decision`).

W1 refine pass 2 — withdrawal dispatch & claim (ratified `#decision`).

Supersedes `learning_2026-04-22_w1-refine-pass-1-withdrawal-queue-dispatch-cla` (pass 1 provisional draft). Integrates user-ratified answers to Oracle threads #41 (preserve single-batch invariant — reframed as physical constraint) and #42 (claim-side batch assembly), plus two supplementary design contributions from the user during ratification (pool-aware broadcast filter; defense-in-depth authorization model).

`docs/adr.md` §ADR-4a at commit `c57f1a6` on branch `claude/cool-snyder-6effcf` (PR `kxlahsimx09/mb-next-payment-gateway#1`, open, not merged). Section tag promoted `#provisional` → `#decision`. Pass-1 `[AWAITING_THREAD:41|42]` and `[RATIFICATION_PENDING:41,42]` markers stripped.

## Load-bearing ratifications

- **Thread #41 (resolved)** — Single-batch-per-`bank_account` invariant preserved and **reframed** from "permanent design intent" (mobiz thread #29) to **physical constraint**: 1 bank_account = 1 bank-portal login credential = 1 live browser session. Alternative E ("relax for higher throughput") is now rejected structurally, not by policy. Revisit trigger for this invariant tightened to: "only reopen if a bank portal introduces native multi-session-per-credential capability." Evidence grounding: KTB session-death production incidents 0170681475 / 0170679675 / 0170689786 (2026-04-11/13) — two sessions on one credential produces observable session corruption.

- **Thread #42 (resolved)** — Batch assembly lives on the claim side. `batch_id = gen_random_uuid()` inside `claim_withdrawal_items` at claim time (not at enqueue). Source flows INSERT with `batch_id = NULL`; RPC assigns + mirrors onto source docs (payout/settlement/pullout/direct_transfer) atomically in the same transaction. `N` (tier cap) computed by an Edge Function wrapper (`compute-claim-size`) and passed into the RPC — policy in TypeScript (Jest-testable), atomic boundary in PL/pgSQL (pgTAP-testable). Consistent with ADR-3.

## Supplementary ratifications (user-added during thread #42)

- **Pool abstraction is first-class and shared across methods.** Direct code read confirmed pool is shared between deposit and payout in the current system (one `selectBank()` helper for both). Data model inherits: `pool` + `pool_bank_account` (flat membership) + `bank_account_method` (live junction — fixes the 2026-04-11 frozen-snapshot drift at the schema level, not just at the filter level). Client → Pool resolution chain: `client.pool_id` → fallback `merchant.pool_id` → error.

- **Defense-in-depth authorization.** Realtime broadcast filter is Layer 1 (performance — reduces bot wake-up noise); the `claim_withdrawal_items` RPC is Layer 2 (security boundary — re-derives the bot's pool from `bank_account_id`, which is bound to the bot's service-role JWT and unforgeable). A bot that misconfigures subscription, bypasses Realtime entirely, or receives a leaky broadcast still cannot claim an item outside its pool — the RPC's pool-membership check inside the transaction rejects it. This closes the current-system gap flagged in Oracle thread #43 (mobiz dispatcher's `AssignBankToItems` has no `pool_id` filter), regardless of how pg-writer classifies the current-system behaviour.

## Two-mode source-type schema (verified against current code)

Single `withdrawal_queue` table with CHECK constraint encoding the source_type → shape rule:

- **Mode 1 — Pool-broadcast** (Payout, Settlement): `pool_id NOT NULL`, `required_method NOT NULL`, `required_bank_account_id NULL`. Broadcast fans out to all pool members with matching method; they race to claim.
- **Mode 2 — Direct-address** (Pullout, Direct Transfer): `required_bank_account_id NOT NULL`, `pool_id NULL`, `required_method NULL` (method check bypassed, matching current-system `BankSupportsSource` semantics for admin-driven internal transfers). Broadcast fans out to exactly one bot; no competition.

The CHECK constraint elevates the rule from runtime convention (current system) to a database invariant — bug writes in the wrong shape are rejected by the engine.

## Claim RPC shape (full body in `docs/adr.md`)

```sql
CREATE FUNCTION claim_withdrawal_items(p_bank_account_id uuid, p_max_items int)
RETURNS SETOF withdrawal_queue
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE v_pool_id uuid; v_bot_methods method_enum[]; v_bank_balance numeric; v_batch_id uuid;
BEGIN
    -- Layer 2a: pool resolution (DB-authoritative)
    SELECT pba.pool_id, ba.available_balance INTO v_pool_id, v_bank_balance
    FROM pool_bank_account pba JOIN bank_account ba ON ba.id = pba.bank_account_id
    WHERE pba.bank_account_id = p_bank_account_id;
    IF v_pool_id IS NULL THEN RAISE EXCEPTION '...' USING ERRCODE = 'P0003'; END IF;

    -- Layer 2b: live method resolution
    SELECT array_agg(method) INTO v_bot_methods FROM bank_account_method WHERE bank_account_id = p_bank_account_id;

    -- Layer 3: one-batch-per-bank (physical invariant)
    IF EXISTS (SELECT 1 FROM withdrawal_queue
               WHERE bank_account_id = p_bank_account_id
                 AND status NOT IN ('completed','failed','waiting_to_review'))
    THEN RAISE EXCEPTION 'batch_in_progress' USING ERRCODE = 'P0001'; END IF;

    v_batch_id := gen_random_uuid();

    -- Atomic claim: pool-isolated, method-matched, balance-capped, FIFO, SKIP LOCKED
    RETURN QUERY UPDATE withdrawal_queue wq
    SET bank_account_id = p_bank_account_id, batch_id = v_batch_id,
        status = 'claimed', claimed_at = now(), claimed_by = p_bank_account_id
    WHERE wq.id IN (
        SELECT id FROM withdrawal_queue WHERE status = 'pending'
          AND ((required_bank_account_id IS NULL AND pool_id = v_pool_id
                AND required_method = ANY (v_bot_methods))
               OR (required_bank_account_id = p_bank_account_id))
          AND amount <= v_bank_balance
        ORDER BY priority, created_at FOR UPDATE SKIP LOCKED LIMIT p_max_items
    ) RETURNING *;

    -- batch_id mirror onto source docs (same transaction, per-source-type dispatch)
END $$;
```

Key invariants in one place: P-001 (pool isolation via re-derived `v_pool_id`), P-002 (live methods via runtime query not snapshot), P-003 (one-batch invariant), P-004 (FIFO ordering), P-005 (balance cap), P-006 (SKIP LOCKED for racing bots in the same pool).

## Threads resolved this pass

- #41 — closed with citation to commit c57f1a6
- #42 — closed with citation to commit c57f1a6

## Threads opened this pass

None (pass 2 is a ratification + integration pass).

## Threads still pending (non-blocking)

- #43 — cross-role handoff to pg-writer re: current-system dispatcher pool-filter drift classification. Non-blocking for this ADR; next system closes the gap regardless of classification.
- mobiz#14 — `waiting_to_review` admin resolution mechanism. Deferred to a future admin-review refine pass.

## Revisit triggers for this ADR

(a) > 50 bots; (b) > 100 withdrawals/s sustained; (c) Supabase Realtime Postgres-Changes pricing/limits shift; (d) a new bank portal whose latency dwarfs the `pg_cron` 1-min sweep; (e) bot-side pre-claim session-death class of failure redesigned away; (f) **a bank portal introduces native multi-session-per-credential capability — only then can the one-batch-per-bank invariant be reopened for design review.** Trigger (f) is new in pass 2 (follows from the physical-constraint reframe).

## Next pass candidate

Thread #43 resolution (when pg-writer answers) → file cross-link learning.  
Then: deep-dive on the deposit auto-match lane of ADR-4 (the other half of the parent ADR). Current-system prior art `flow:deposit-auto-match-from-statement` is available (ratified S2 via thread #17, mobiz `212f36c` + bank-bot `5755b9a`). ~60 min pass.

## Change from pass 1

- Tag: `#provisional` → `#decision`.
- RPC body: referenced → fully written (40 lines PL/pgSQL in the ADR).
- Data model: implicit → explicit (full Postgres schema in the ADR, with CHECK constraint).
- Broadcast filter: `bank_code`-level (incorrect) → pool + bank_account_id, two-mode (correct per user ratification + code verification).
- Security framing: implicit → explicit (§Security boundary subsection).
- Invariant rationale: "permanent design intent" → "physical constraint."
- Alternative E: "rejected by policy" → "rejected structurally."
- Prior art: +2 new learnings from pass-2 Input 5 direct code reads; +Oracle thread #43 citation.

---
*Added via Oracle Learn*
