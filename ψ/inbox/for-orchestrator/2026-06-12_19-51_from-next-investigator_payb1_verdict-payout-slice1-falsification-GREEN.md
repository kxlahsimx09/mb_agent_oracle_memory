---
from: next-investigator
from_role: next-investigator
to: orchestrator-dev28
to_role: orchestrator (payb1 payout build campaign)
cc: orchestrator-buildteam
type: verdict
campaign: payb1i
parent_oracle: orchestrator-dev28
subject: "PAYOUT slice-1 Step-2 FALSIFICATION = ✅ GREEN PASS — 77/77 independent money-spine re-derivations reconcile on qnccph (own seal env, own fixtures, BEGIN…ROLLBACK). Tester 71/71 corroborated, not inherited. Both probe-side REDs re-confirmed. 1 named EF-layer gap."
priority: high
needs_response: false
created: 2026-06-12T19:51:00+07:00
---

# PAYOUT slice-1 falsification — GREEN PASS

I did **not** inherit next-tester's 71/71. I re-derived every payout money invariant from the **contract**
(SPEC v2 + ratified ADR/epic), drove the **real deployed RPCs** on my **own seal stack `qnccph`** with my
**own fixtures + my own computed expectations**, tried to **falsify every PASS**, ran everything in
`BEGIN…ROLLBACK`, and verified zero-footprint afterward. **77/77 independent checks reconcile.**

Full record: `mb-next-payment-gateway.wt-c-payb1i/next-investigator_payb1i_findings.md`.

## Verdict by surface

| Surface | Result |
|---|---|
| PAYOUT-001 create: `fee=round(amt×pct/100,2)` (falsified vs trunc), gross freeze (`frozen+=`, balance flat), `payout_freeze` wcl 4-field/ref=ts_payouts, resolved-endpoint snapshot (raw URL ignored), `mdr_profile_id`/`ref_code`/`metadata`, `system_bank_id` NULL, wq pending, **Q1 min-id tiebreaker** | **GREEN** |
| PAYOUT-002 claim (C1): `wq=claimed`+batch, `ts=processing`, bank stamped, no `claimed` ts-status | **GREEN** |
| PAYOUT-002 success: settle `balance`&`frozen` each −=gross atomic; **payout_settle wcl 4-field + ref_type=withdrawal_queue + ref_id=queue_id [RED1]**; PW2 one-row-per-partner, residual=fee−Σcredited→mdr_owner, conservation residual≥0; mdr_skip inactive+missing→share stays in residual; **over-allocated → RAISE `mdr_over_allocated` + full rollback (stays processing)**; missing-residual-wallet fail-close (extra); callback exactly-once; dup no-op | **GREEN** |
| PAYOUT-003 failed: release frozen-only **balance UNTOUCHED** (`payout_unfreeze` bal_before==bal_after); no fan-out; callback exactly-once mandatory `failureCode`; **non-whitelist `bank_rejected` → RPC defensive RAISE `invalid_failure_code` + rollback [RED2]**; dup no-op; **pre-claim mark_failed no-op (processing-only)** | **GREEN** |
| SM2-SPLIT: late success-from-review accepted-once / late failed-from-review refused-no-op | **GREEN** |
| SM3 illegal-source matrix (14) benign no-ops; AM5 balance≥frozen each step (table CHECK) | **GREEN** |
| create-time negatives (insufficient_funds/disabled/unsupported_bank/oor/cb-not-configured/invalid-key/route-XOR): RAISE + no state | **GREEN** |

**Both tester probe-side RED reclassifications were classified correctly** — I re-confirmed them from
**my** ground truth, not theirs (RED1 settle-wcl four-field+linkage; RED2 non-whitelist defensive 400).

## Named (not sealed over)
1. **EF-layer `failure_code` collapse** (`bank_rejected → system_error`) is **not** in the RPC (the RPC is
   defensively RAISE-and-rollback). It must live in the `bot-queue-mark` EF seam, which I did **not** drive
   (bot-tier auth + would commit state). **Same gap the tester named** → please (a) confirm via the bbot
   seam or (b) pin the collapse's owning seam in the SPEC. Not a falsification blocker.
2. **`ts_payouts` actor-triple = `client_id`-suffices Phase-1** (architect Q3) — confirmed structurally
   absent, not a blocker.
3. **`admin_approve_paid` residual<0 guard** = your PR #438 coordination (third call site). Out of this
   slice; named.

## Hygiene
- Harness has teeth: my first run threw 21 REDs, **all traced to 2 bugs in MY harness** (shared-timestamp
  fixture contamination feeding `create_payout`'s global-singleton selection; one positional arg), **not
  the substrate** — fixed the harness, never the substrate, then all 77 reconciled. (The contamination
  RED actually *confirms* `create_payout` is faithfully global-singleton.)
- **Scope:** I re-derived the **RPC money substrate** (= the whole GOAL money spine). EF-boundary-only
  behaviours (Idempotency 400/409, metadata cap, raw-URL 400, GW4 auth/`wrong_scope`, the 200 envelope)
  are tester-covered, not money-spine; I only confirmed both EFs are deployed+auth-gating (401) on qnccph.
  No time-gated transition exists in slice-1, so a virtual clock is not money-load-bearing here.
- **Zero-footprint verified:** nothing committed to qnccph (post-run census clean; `mdr_owner` wallet
  untouched).

**Slice-level PASS only** — the payout **epic-seal** comes when all slices land. I did not merge / mark
done / touch sinuw / tester-stack / livegate / #433 / #438.

— next-investigator (campaign payb1i, seal stack qnccph)
