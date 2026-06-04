---
title: p2p-hub §E5/§C9 symmetric (bidirectional) matching — built in migration 014 (PR 
tags: [p2p-hub, symmetric-matching, try_match, sweep, postgres, supabase, E5, C9, thread-8]
created: 2026-06-02
source: next-impl symmetric matching (thread #8, PR #24)
project: github.com/kxlahsimx09/p2p-hub
---

# p2p-hub §E5/§C9 symmetric (bidirectional) matching — built in migration 014 (PR 

p2p-hub §E5/§C9 symmetric (bidirectional) matching — built in migration 014 (PR #24, ref Oracle thread #8 #decision 2026-06-02). Ground truth P-004 on origin/main.

WHAT shipped:
- try_match(p_pool_item_id uuid): arrival-side-agnostic generalization of the 009 propose_match body. Lock arriving POOLED item, detect side, scan the OPPOSITE side's oldest equal-amount POOLED counterparty (ORDER BY created_at ASC LIMIT 1 FOR UPDATE SKIP LOCKED, provider ACTIVE+serves-that-side), normalize to (dep,pay), run the SAME §D3 combined reserve (payout M+F_p / deposit F_d, both-must-reserve-or-rollback, POOLED→MATCHED single-shot B2.1, 3 change_logs, 2 MatchProposed). Returns match_id or NULL. Payout-arrival scan finally consumes the previously-unwired pool_items_deposit_open_idx (migration 007 L46) — that index existing was the tell that bidirectional was always intended.
- propose_match(p_deposit_intent_id) rewrapped CREATE OR REPLACE as a thin wrapper over try_match (P-001 — ratified signature + 009 error messages preserved).
- Inline driver: submit_pool_item calls try_match(new_id) best-effort at its tail on BOTH sides, wrapped in plpgsql BEGIN…EXCEPTION WHEN OTHERS so a match-attempt failure NEVER rolls back the valid submit.
- sweep_matches(p_limit default 500): iterates POOLED oldest-first calling try_match best-effort; closes the concurrent-both-arrive SKIP-LOCKED miss + crash-between-submit-and-inline miss.

KEY GOTCHA (cost a hosted-test cycle): adding the inline driver to submit_pool_item BROKE the pre-existing e1–e7 + driveToSent + G1–G6 hosted assertions, because they used submit_pool_item for BOTH legs then called propose_match explicitly — the second submit's inline driver now auto-forms the match, so the later explicit propose_match sees the item already MATCHED. Fix: switch those tests to direct-insert pooling (INSERT into pool_items POOLED, bypassing the driver) so they keep driving the match explicitly. Any test that wants to control match timing must NOT use submit_pool_item once the inline driver exists.

Sweep cadence (impl-param, §E11): primary = Supabase pg_cron every 1 min (create extension pg_cron; cron.schedule('p2p-sweep-matches','* * * * *', $$select sweep_matches(500)$$)). Could NOT positively confirm pg_cron enabled on the project — PostgREST only exposes public schema, so a cron.job probe is inconclusive (don't assert PRESENT from that). Fallback shipped: src/sweep/worker.ts Bun worker.

Hosted verify on gkgacoskpocntboxzkyy (ap-southeast-1): 33/33 PASS incl M1–M5. Migration pushed via aws-1 session pooler (aws-1-ap-southeast-1.pooler.supabase.com:5432; aws-0 fails tenant/user not found). Generalizing the 009 body to side-agnostic did NOT conflict with §D3/§E9 — §E5 explicitly says steps 2–8 are already side-symmetric.

---
*Added via Oracle Learn*
