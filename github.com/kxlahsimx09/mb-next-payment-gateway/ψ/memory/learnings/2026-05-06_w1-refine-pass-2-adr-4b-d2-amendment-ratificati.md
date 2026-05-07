---
title: W1 refine pass 2 — §ADR-4b D2 amendment ratification (Matcher cascade, 3-step or
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-4b, adr-4b-d2-amendment, matcher-cascade, ratification, pass-2, decision, thread-78-closed, failure-handling-spec-inline, deliberate-divergence-from-mobiz-current-instance-6, substrate-convergence-6th-port, user-pushback-instance-22, implementation-contract-spec-vs-re-ratification-cycle, deposit-lane-fraud-detection-complete, zero-live-provisional]
created: 2026-05-06
source: docs/adr.md@30171f9 §ADR-4b D2 amendment + docs/design/deposit-lane/matcher-cascade.md@30171f9 §3.5; thread:#78 messages 187-189; evidence bundle in §Revision log pass-2 entry
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine pass 2 — §ADR-4b D2 amendment ratification (Matcher cascade, 3-step or

W1 refine pass 2 — §ADR-4b D2 amendment ratification (Matcher cascade, 3-step ordering); thread #78 closed; D1-D5 resolved; amendment promotes `#provisional` → `#decision`.

All 5 sub-questions D1-D5 ratified by user 2026-05-06 GMT+7 via thread #78. §ADR-4b D2 amendment promotes from `#provisional` (pass-1 baseline 2026-05-06 commit `6879a36`) to `#decision` (pass-2 ratify commit `30171f9`). 11 ADRs ratified `#decision` overall (§ADR-1 through §ADR-13 + §ADR-4b/4d amendments + §ADR-4b D2 amendment). **0 live `#provisional` sections remain** — deposit-lane fraud detection loop architecturally complete.

Verdicts:
- D1 cascade as one EF body — (a) ratified WITH user-flagged failure-handling concern. Addressed inline as implementation contract (no D6 thread opened; mechanical implication of §ADR-4b D5 atomicity + §ADR-4b D4 sweep retry).
- D2 Step 2b filter scope — (b) `paid OR expired` ratified. Deliberate divergence from mobiz current `paid` only. Pattern instance #6 of "deliberate divergence from mobiz current" (already-durable rule per W1 §Port-from-mobiz protocol; instance #5 promoted 2026-05-05).
- D3 refuse Step 2a on missing source identity — (a) ratified. Port verbatim from mobiz `services/transactionMatcher.go::matchDeposit@20b6fa3` (PR #384).
- D4 link write via thin RPC vs direct UPDATE — (a) ratified. `link_statement_to_deposit(p_statement_id uuid, p_deposit_id uuid, p_link_step text)` SECURITY DEFINER. Substrate convergence 6th port (after `claim_withdrawal_items` / `finalize_deposit` / `expire_deposit` / `submit_statements_batch` / etc.).
- D5 source-identity priority + score tie-break — (a) ratified. Port verbatim.

Failure-handling spec authored inline (D1's user-flagged concern):

The cascade is orchestration of three independently-atomic RPCs. Failure handling distinguishes race-guard rejection (expected; cascade flow continues per design — Step 1 race → fall to Step 2a; Step 2a/2b race → exit cascade as already-linked terminal success) from RPC exception (unexpected; abort cascade for current statement; sweep retry picks up via §ADR-4b D4 within 1-min). RPC exception MUST re-throw — naive try/catch + continue-on-exception falsely converts `finalize_deposit` rollback into "no match" verdict and removes statement from sweep retry radar. Atomicity invariants relied upon: (1) `finalize_deposit` one tx, full §ADR-4b D5 bundle commits or rolls back; (2) `link_statement_to_deposit` one UPDATE in one tx, idempotent under retry via `WHERE matched_request_id IS NULL` race-guard; (3) cascade is orchestration not transaction — no outer wrapper across steps. Retry-via-sweep convergence proof: at retry time `T₀+60s`, deposit may be in any of 4 states (`pending` / `checking` / `paid` / `expired`); all 4 converge to correct terminal state via cascade self-healing. EF runtime failure (Deno panic / OOM / timeout) handled via post-INSERT default `match_status='pending'` + sweep retry. 

Pattern: when user-flagged concern is mechanical implication of already-ratified primitives, surface as implementation contract (design doc §3.5 + ADR body 2-line note) rather than re-ratification cycle (D6 + pass-1.5 + pass-2). Saves a revise pass cycle. **Candidate for W1 workflow doc heuristic update** — current workflow allows pre-ratification revise (§ADR-12 / §ADR-13 pass 1.5/1.6 precedent) for user-pushback that surfaces architectural gap; this pass establishes the symmetric heuristic for user-pushback that surfaces implementation-contract-shaped concern (no architectural decision change; mechanical derivation from ratified primitives).

User-pushback-as-design-force pattern instance #22 (D1 failure-handling concern). Cumulative pattern continues durable trend.

Pre-Input-5 instance count: 15 → 15 (no new code-read this pass; failure-handling derived from ratified atomicity invariants + sweep-retry primitive).

Architecture-decision phase post-pass:
- 11 ADRs `#decision` ratified
- 0 live `#provisional` sections
- Deposit-lane fraud detection loop architecturally complete: §ADR-4b core + Bot↔Gateway Statement Push Contract amendment + D2 Matcher cascade amendment + §ADR-4c expire + §ADR-4d core + Slip-Bearing Fraud Detection amendment all `#decision`
- Substrate convergence: 6 thin RPCs ratified across deposit-lane + withdrawal-lane (all state-transition writes route through SECURITY DEFINER thin RPC for uniform audit)

Remaining named architectural gaps:
1. §ADR-14 fleet-control (thread #45 long-pending; user-blocked on substrate choice)
2. §ADR-15 monitoring/alerting (B3+B5 deferral target from §ADR-4b amendment 2026-05-05; user-blocked on substrate choice)
3. Revision-log archival pass 2 (`docs/adr.md` ~2,650 lines; eligible entries 2026-04-30 → 2026-05-02 stable ≥3 days)

Threads closed: #78. Threads opened: none. Commit: `30171f9`. PR #17 (3 commits total). Next pass candidate: revision-log archival pass 2 (mechanical work; ~30-45 min) OR await user direction on §ADR-14 / §ADR-15.

---
*Added via Oracle Learn*
