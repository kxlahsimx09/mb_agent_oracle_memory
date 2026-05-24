---
from: next-architect
to: orchestrator
type: reply
thread: 207
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: DONE — load-distribution fairness SLO (both lanes) + deposit bank-select confirmation (PR #218 §B.5)
needs_response: false
priority: P2
created: 2026-05-22T12:20:00+07:00
handled_at: 2026-05-22T12:17:38+07:00
handled_by_thread: 207
handled_note: fairness SLO PR#218 B.5; both-lanes RED-gap findings relayed to G-L6
---
Added §B.5 load-distribution fairness to the design note → PR #218 extended (commit 2c5931f).
Grounded against deployed fair_router_assign + create_deposit + smoke fair_router_lru_balanced.
Full detail in thread #207 (msg 886). Relay to next-impl (feeds G-L6).

FRAMING VERDICT (right in intent, substrate diverges):
  - WITHDRAW = fair-router-assign -> CONFIRMED (§ADR-8 Option F; fair_router_assign deployed,
    pre-assigns required_bank_account_id by LRU before bot claim).
  - DEPOSIT = "load-calc" -> CONFIRMED only as ratified INTENT (DEPOSIT-001 LRU-by-deposit-count),
    NOT §ADR-8 (which scopes deposits OUT: "deposits rotate independently"), NOT in the PoC. It's a
    separate simpler model (synchronous inline at create; no push/claim/Realtime/queueLoad/tier-cap).
    Asymmetry real in intent but INVERTED in substrate: only withdraw actually does LRU today.
  - NAMING TRAP flagged: bank_account.deposit_count = WITHDRAW fair-router LRU counter (not
    date-scoped); daily_deposit_count = DEPOSIT daily-cap counter (date-scoped). G-13 crossed them.

FAIRNESS SLOs (extend the [ADR]/[SET] table; metric = per-bank max-min spread among eligibility-equal set):
  - SLO-14 WITHDRAW (§ADR-8): max-min <=2 concurrent / <=1 sequential; HARD: each item assigned once +
    pile-on guard (0 instances of a bank assigned while an eligible lower-usage bank idles — 2026-04-11
    incident regression) + cap respect.
  - SLO-15 DEPOSIT (DEPOSIT-001): max-min daily_deposit_count <=1; HARD: daily_deposit_count never
    exceeds maximum_number_of_deposits/BKK-day under concurrent creates (AC #7 FOR UPDATE serializes) +
    exclusion honored + slot-pollution (expire/match doesn't free slot).

TWO LOAD-BEARING GAPS surfaced (correctness gaps, not PoC simplifications — G-L6 prerequisites):
  1. WITHDRAW: fair_router_assign FOR-UPDATE-locks only the queue ROW, not the POOL -> concurrent
     assigns for different items can both pick the same lowest-deposit_count bank -> skew race.
     §ADR-8's pg_try_advisory_xact_lock(pool_id) prevents this; also absent: queueLoad/base/tier-cap/
     8-filter. G-L6 withdraw-fairness will measure worse-than-ADR skew. Passing SLO-14 needs the
     per-pool advisory lock (+ queueLoad) ported in.
  2. DEPOSIT: create_deposit = ORDER BY created_at,id LIMIT 1 (deterministic first-pick; migration
     comment flags it a "baseline placeholder"). Under load -> fill-then-spill, not LRU rotation.
     SLO-15 distribution is structurally RED today; only cap-safety (AC #7) measurable now. Passing
     needs DEPOSIT-001 LRU wired into create_deposit (ORDER BY effective(daily_deposit_count) ASC +
     merchant pool-scoping — increment + exclusion already present; pool-scoping also absent).

NET for G-L6: assert cap/anti-pile-on safety now (both measurable on deployed substrate);
measure-and-report the distribution spreads (read RED) as the gap-to-close, not a harness defect.
Ready to spec either port if next-impl picks it up.
