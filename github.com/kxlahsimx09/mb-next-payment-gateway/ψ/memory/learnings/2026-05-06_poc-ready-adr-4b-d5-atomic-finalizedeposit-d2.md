---
title: poc-ready: §ADR-4b D5 atomic finalize_deposit + D2 matcher cascade — Pass-1 PoC 
tags: [implementation-architect, repo:mb-next-payment-gateway, next, 4b, poc, spec-test, pgtap, supabase-local, deposit-auto-match, wallet-ledger, matcher-cascade, decision, poc-ready, fixture-source:vault-learning, fixture-source:repo-flow-doc, fixture-incident:q4a-paid-uncredited]
created: 2026-05-06
source: poc/4b/{README.md, src/*.sql, tests/*.spec.sql, mutation-tests.ts} + evidence/{production-shape-summary.md, q4c-multi-candidate-sample.md, callback-retry-shape.md}
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# poc-ready: §ADR-4b D5 atomic finalize_deposit + D2 matcher cascade — Pass-1 PoC 

poc-ready: §ADR-4b D5 atomic finalize_deposit + D2 matcher cascade — Pass-1 PoC at `poc/4b/` (Postgres-only-floor; local Supabase + pgTAP).

10 spec tests across 3 groups: A (atomicity D5), B (cascade D2), C (sweep retry D4). 49 assertions all green. 6 mutations, all flip ≥1 expected red — 0 escapees, no W1 Step 5(e) rewrites needed. Outcome: ADR claims hold under execution; no drift to file.

Evidence-cited from `#current` mining (mcp__dpay__* read-only, 2026-05-06):
- 351,991 paid deposits in production; 96.84% matched + MDR-distributed
- bank_statements match_status: matched 87.4%, fee 11.7%, unmatched 5.6%, review+pending 0.65%
- 1,872 review + 1,531 pending_review = Q4c parking is real (sample: last4 collisions @500 amount)
- callback_logs n=412k vs deposits n=352k → ~1.17 attempts/deposit; 30s timeout, attempt=3 cap observed

Notable signals:
1. Current production does NOT write `wallets_change_logs` on deposit credit (filter `reference_type=deposit` returns refunds only). §ADR-4b D5 step (iv) introduces this audit row — tightening, not regression. Flagged `[POC_GAP:ADR-4b:wallets_change_logs-current-absence]`.
2. ADR text says "deposit.completed event"; production actually emits `deposit.paid`. Minor wording divergence; PoC follows production.
3. Mutation iteration surfaced: poison trigger must be surgical (fire on `OLD.owner_type='client'` only) to faithfully reproduce mobiz Q4a; broad trigger fails everywhere → unrelated rollback. Captured as Honest Feedback in retro.

Schema: `ts_deposits, wallet (single-discriminated per §ADR-10), wallets_change_logs, transactions, mdr_shared, mdr_profile_partners, callback_queue, bank_statements`. RPCs: `finalize_deposit, link_statement_to_deposit, match_deposits_cascade, sweep_unmatched_statements`.

Promotion candidate: `[POC_PROMOTED:<commit-hash>]` deferred to next-dev consumption per W1 §3 future workflow.

Next §ADR-4b PoC pass candidates (Pass 2): concurrent deadlock test (would require dblink or 2-conn harness) for claim 5; Q4c multi-candidate parking explicit spec test; bot-side I-derived/I-no-retry/I-dedup contract PoC (separate scope, §ADR-4b amendment B1/B2).

Recommended next implement-architect lane: §ADR-4a (withdrawal dispatch + claim RPC) — same Postgres-only-floor pattern; §ADR-4c (auto-expire) — pg_cron timing; §ADR-3 (withdrawal lane full) — adds EF + bankbot simulator.

---
*Added via Oracle Learn*
