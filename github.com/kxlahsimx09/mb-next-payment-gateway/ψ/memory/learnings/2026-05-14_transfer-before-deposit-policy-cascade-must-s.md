---
title: 
tags: [transfer-before-deposit, cascade-temporal-safety, race-policy, admin-attribution, production-data-grounding]
created: 2026-05-14
source: next-impl session 2026-05-13/14 retro
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# 


# Transfer-before-deposit policy — cascade must stay-unmatched, admin attributes

User-clarified scenario (2026-05-13): customer holds an OLD QR from a prior deposit, transfers via mobile banking, then later POSTs a new deposit-create. Bank statement arrives FIRST for an unrelated deposit context — the new deposit must NOT auto-link to it even if (receiver, amount, last-4) coincidentally align. Statement remains `unmatched`; admin attributes manually via §ADR-4d D5 force-approve.

## Production grounding
#current bank_statements audit (546,975 matched, direction=in): **99.9985% carry sender identity** (source_account_no field / `x\d{4}` last-4 in description / `BBB-NNNNNNNNNN` full account). Only 8 / 546,975 (0.0015%) matched without identity — inspection showed those were admin-manual re-matches via deposit-detail UI, NOT auto-linked by cascade.

Conclusion: spec line 73 ("identity-optional terminal-side fallback") was misleading. Production effectively has hard identity requirement. PoC's prior Step 2b allowed identity-optional auto-link = a real safety hazard ("อันตรายอาจจะผิดคนได้") under same-amount-multi-deposit scenarios.

## Two defenses (defense-in-depth)
1. **Identity-required cascade** (Step 1 + 2a + 2b): refuse `v_src.score = 0` early-return. Migration 022.
2. **Temporal-safety guard** (Step 1 / FA1): refuse Step 1 finalize when `v_dep.created_at > v_stmt.created_at + INTERVAL '10 seconds'`. Soft cross-ref only (matched_request_id set, match_status='unmatched'). Migration 024.

## Threshold = 10 wall-sec rationale
- Legitimate concurrent race (stmt arrives within 1-2s of deposit POST due to commit ordering jitter) → < 10s → ALLOW auto-link.
- Stale-statement (transfer-before-deposit typically minutes-to-hours old) → >> 10s → REFUSE.

## Multi-bank routing as natural defense
Cross-bank scenario: customer's old QR pointed at bank A; fair-router rotated new deposit to bank B. Cascade scope filter `system_bank_account_id = v_stmt.system_bank_id` naturally excludes the deposit. PoC fixture DEP-RACE-CROSSBANK seeds the mock_bank_feed at BANK_IDS[1] while deposit goes to BANK_IDS[0] via deterministic picker.

## Test fixture
DEP-RACE-TEMPORAL (same bank, stmt + 15s wall before deposit) + DEP-RACE-CROSSBANK (different bank). Both expected: deposit expires, statement unmatched (with or without soft xref). Tests both defenses independently.


---
*Added via Oracle Learn*
