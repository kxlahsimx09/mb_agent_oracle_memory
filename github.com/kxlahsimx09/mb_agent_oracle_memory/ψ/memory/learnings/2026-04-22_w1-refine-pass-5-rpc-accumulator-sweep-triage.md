---
title: W1 refine pass 5 — RPC accumulator + sweep triage + lifecycle RPCs.
tags: [system-architect, repo:mb-next-payment-gateway, repo:cross, repo:mobiz-payment-gateway, next, current, adr, refinement, w1, pass-5, withdrawal-queue, rpc, sweep, triage, lifecycle, bank-transaction-id, waiting-to-review, over-commit-fix, balance-snapshot, drift-analysis, pr-249, user-surfaced]
created: 2026-04-22
source: docs/adr.md@667d4d2 + user dialogue 2026-04-22 (3 correction rounds on pass-4 output)
project: github.com/kxlahsimx09/mb_agent_oracle_memory
---

# W1 refine pass 5 — RPC accumulator + sweep triage + lifecycle RPCs.

W1 refine pass 5 — RPC accumulator + sweep triage + lifecycle RPCs.

Three bug classes caught by user peer-review of pass-4 output. None shift the design shape (Mode 1/2, defense-in-depth, invariant, batching, RPC-as-sole-path all identical); all are implementation-detail fixes + one missing subsystem (lifecycle RPCs).

`docs/adr.md` §ADR-4a at commit `667d4d2` on branch `claude/cool-snyder-6effcf` (PR `kxlahsimx09/mb-next-payment-gateway#1`, open).

## Bug class 1 — Per-row balance filter over-commits

Pass 2's RPC: `AND amount <= v_bank_balance` — per-row check. Fails when N rows individually fit but sum overflows budget. Example: 5 rows × 3000 THB with v_bank_balance = 10000 → all pass per-row → claim all 5 = 15000 → over-commit 5000.

Fix: replace with procedural FOR loop + accumulator, matching current `services/withdrawalQueue.go:361-366`:

```sql
FOR r IN
    SELECT id, amount FROM withdrawal_queue
     WHERE status = 'pending' AND (<filter>) ORDER BY priority, created_at
     FOR UPDATE SKIP LOCKED LIMIT p_max_items
LOOP
    EXIT WHEN v_running_total + r.amount > v_bank_balance;  -- strict budget
    v_running_total := v_running_total + r.amount;
    v_item_ids := array_append(v_item_ids, r.id);
END LOOP;
```

Stricter than current (current uses `totalAssigned >= balance` BEFORE claim → allows one row over-commit at end; pass 5 uses `>` → never over-commits). FOR UPDATE SKIP LOCKED inside cursor locks lazily — rows past EXIT are never locked, no wastage.

## Bug class 2 — `v_bank_balance` described as trustworthy

Pass 2 §Consequences implied the one-batch-per-bank invariant made `v_bank_balance` authoritative. Incomplete: invariant serializes WITHDRAWAL-side decrements but NOT other balance-affecting paths (deposit credits, topup-in, bank fees, bot reconciliation, admin adjustments).

Under typical operational shape (bank-per-method): drift-free because decrement path ownership is clean.

Under shared-use shape (bank serves deposit + payout): drift possible:
- *Real > tracked (deposit lag)*: RPC conservative → under-utilize budget → benign
- *Real < tracked (fee ~30 THB, adjustment)*: RPC may over-book marginally → last-row portal-fail → `mark_failed` refunds that row via 4-step lifecycle → loss = ~1 row per drift event, no corruption

Documented honestly in pass-5 §Consequences (vi) with three Phase-2-candidate mitigations considered and rejected (row-lock too contentious; reservation counter requires rewrite; per-row re-read complex for marginal benefit). Added revisit trigger (g): "shared-use shape common AND drift-induced portal-failures cross ~0.1%-per-batch → reopen for reservation-counter design."

## Bug class 3 — Sweep "revert to pending" recreates double-spend bug

Pass 2 §Decision step 5 proposed: "stale claimed rows → revert to pending, append incident log." Unsafe — if bot had reached the pre-submit checkpoint at bank portal, the transfer MAY have completed. Reverting lets another bot re-claim → potential double-spend.

Current system (mobiz PR #249, commit `8bf3a52`, 2026-04-20, `scheduler/withdrawal_dispatcher.go:728-799`) uses `bank_transaction_id` as discriminator:
- `bank_transaction_id IS NOT NULL` → bot submitted to bank → `mark_waiting_to_review` (human verifies bank statement)
- `bank_transaction_id IS NULL` → bot crashed before submit → `mark_failed` (safe auto-refund via 4-step lifecycle)

Production incident 2026-04-12 (16 orphaned payouts from naive bulk `UpdateMany` to `failed` that skipped the lifecycle) is the cited cautionary tale.

Fix: pass-5 sweep adopts triage verbatim. Added:
- `bank_transaction_id text NULL` column on `withdrawal_queue` (set by bot via `set_bank_transaction_id()` RPC right before submitting maker form)
- §Decision step 6 (new) — `mark_failed` / `mark_waiting_to_review` / `mark_success` as SECURITY DEFINER RPCs each running the 4-step post-completion contract (source-doc → wallet refund if applicable → callback queue → bank unlock). Matches mobiz `processPostCompletion` guarantee.
- Explicit "NEVER revert to pending" statement in step 5 with PR #249 + 2026-04-12 incident citation

## No design-shape changes

Mode 1 (pool-broadcast) + Mode 2 (direct-address), CHECK constraint encoding source_type → shape, defense-in-depth Layer 1 (Realtime) + Layer 2 (RPC), physical-constraint one-batch-per-bank invariant, claim-side batch_id generation, RPC as sole `pending → claimed` path, Supabase Realtime as performance filter — all identical pre/post pass 5. Pass 2 remains the primary decision record. `arra_supersede` NOT applied — pass 5 is layered clarification/fix of implementation details within the same decision.

## Threads

Opened: none. Closed: none. The three correction rounds this pass were inline conversation between user and architect; they did not require formal ratification threads because none changed the decision shape.

Pending (carried): architect #43 (pg-writer's forthcoming `nil poolBankIDs` drift learning), mobiz #14 (`waiting_to_review` admin resolution workflow).

## Process pattern that emerged

User's peer review of pass-N output has now triggered pass-(N+1) three times in a row:
- Pass 3: user's question about a claim → pg-writer handoff → Hypothesis 3 correction
- Pass 4: user's question "มันซ้ำไหม?" → remove `required_method` column
- Pass 5: user's three questions on pass-4 (per-row filter / balance trust / sweep revert) → this pass

**Principle:** ADR as living document reviewed by experienced peers catches class-of-bug issues before implementation. Each pass's review surfaces the next pass's focus. Trajectory quality-converging: pass 5 delta (~150 lines) is larger than pass 3/4 combined because it fixes 3 issues + adds a missing subsystem (lifecycle RPCs), not because the design is drifting.

**Recommendation for future W1 runs:** When designing a subsystem that has a current-system implementation, *always read the current-system's own safety-net/sweep code first* — it encodes years of incident learnings that the naive design will otherwise miss. (Pass 5 missed PR #249 because I read `services/withdrawalQueue.go` for enqueue semantics but not `scheduler/withdrawal_dispatcher.go` for sweep semantics.)

## Cross-references

- Originating PR (current system): `kokarat/mobiz-payment-gateway#249` (commit `8bf3a52`, 2026-04-20).
- Prior incident: 2026-04-12, 16 orphaned payouts — cited in the code comment at `scheduler/withdrawal_dispatcher.go:757-760`.
- Pass-5 prior-art learning: `learning_2026-04-22_current-system-prior-art-stale-processing-triage`.
- Pass-2 ADR record (primary): `learning_2026-04-22_w1-refine-pass-2-withdrawal-dispatch-claim-ra` — unchanged, still authoritative.
- Pass-3 learning: `learning_2026-04-22_w1-pass-3-cross-link-thread-43-classification`.
- Pass-4 learning: `learning_2026-04-22_w1-pass-4-remove-requiredmethod-column-from`.

## Tags

system-architect, repo:mb-next-payment-gateway, repo:cross, repo:mobiz-payment-gateway, next, current, adr, refinement, w1, pass-5, withdrawal-queue, rpc, sweep, triage, lifecycle, bank-transaction-id, waiting-to-review, mark-failed, mark-success, processPostCompletion, over-commit-fix, balance-snapshot, drift-analysis, pr-249, 2026-04-12-incident, user-surfaced

---
*Added via Oracle Learn*
