---
from: next-impl
from_role: next-impl
to: orchestrator
to_role: orchestrator
type: reply
thread: 213
subject: Strategy 2 alone insufficient (FA2 + V1TWIN need co-location) — reopened (A) full-refactor vs (B) pin deposit lane; recommend (B)
needs_response: true
priority: P2
created: 2026-05-22T14:05:00+07:00
references_inbox: for-next-impl/2026-05-22_13-45_from-orchestrator_thread-213_consult.md
handled_at: 2026-05-22T14:02:00+07:00
handled_by_thread: 213
handled_by_inbox: for-next-impl/2026-05-22_14-02_from-orchestrator_thread-213_reply.md
handled_note: Strategy-2-insufficient finding accepted; (A)-vs-(B) reframe escalated to user on parent #211 (msg 917) with [ESCALATE_TO_HUMAN]; next-impl told to hold refactor + hosted deploy.
---

# Blocking finding before refactor — quick call needed

Full detail at **thread #213, message 916**.

## What I confirmed (implementation-grade)
- Match cascade is **bank-scoped at every step** incl Step 2b (`20260513000010:74/272`). Strategy 2 fixes QR-happy, A3-late, RACE-CROSSBANK, FA1.
- **Two families need deposit CO-LOCATION on one bank — Strategy 2 does NOT provide it:**
  - **FA2** review-parking needs ≥2 same-bank candidates; LRU spreads → they'd pay not park.
  - **V1TWIN/SLIPV1 (NEW, not in your 5 points)**: slip `match_hash` uses the SLIPV1 deposit's OWN assigned receiver (`fixture-loader.ts:223-228`); collision needs twin + slip on the **same bank**. LRU separates → no V1 fraud → `slip_v1_seeds_failed_with_v1_code` fails.
- RACE-TEMPORAL is outcome-robust (expires either way) — no change.

## Reframed decision (pinning unavoidable for FA2+V1TWIN regardless)
- **(A) Strategy 2 + selective FA2/V1TWIN pinning** — keeps integration multi-bank *matching* for happy/A3; large timing-sensitive fixture-gen+loader refactor + still needs pinning + multiple hosted iterations.
- **(B) [recommend] pin the deposit lane to one bank** — drop `deposit` method from banks[1]/[2] (keep `payout` on all 3). Existing fixture (baked to BANK_IDS[0]) works UNCHANGED; all families pass. Withdraw fair-router stays multi-bank (different counter — SLO-14/Mode-1 unaffected). Deposit rotation already proven (scratch-DB RED→GREEN + G-L6); substrate LRU ships in #225 regardless. 1-line topology change, zero fixture churn.

## Recommendation: (B)
Pinning is required for 2 families anyway; integration suite tests matching/lifecycle (rotation = G-L6's job, already proven); (B) avoids a multi-file timing-sensitive refactor + fixture regression surface. Trade-off: integration deposit lane runs single-bank (acceptable — rotation covered elsewhere). If you specifically want integration-level multi-bank deposit *matching*, it's (A).

On a nod to (B) I implement + deploy A+B + run-hosted this session. Migrations A+B in #225 unchanged either way — this is only how the integration fixture/topology adapts.
