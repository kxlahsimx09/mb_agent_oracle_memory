---
title: W1 ADR-8 pass-2 pre-ratification amendment — fair-router Trigger B (bank-free) +
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-8, pass-2, amendment, provisional, bot-gateway-work-distribution, fair-router, trigger-model, trigger-b, bank-free, sweep-reframe, early-bail, latency-fix, pre-ratification-amendment, review-driven]
created: 2026-04-24
source: docs/adr.md@b87fc1a + pre-ratification amendment triggered by user review of pass-2 trigger model (thread #46 discussion 2026-04-24 GMT+7)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 ADR-8 pass-2 pre-ratification amendment — fair-router Trigger B (bank-free) +

W1 ADR-8 pass-2 pre-ratification amendment — fair-router Trigger B (bank-free) + sweep reframed as belt-and-suspenders.

## What this amendment did

Pre-ratification fix to §ADR-8 pass-2 proposal. Core decision (Option F — push via fair-router Edge Function) **unchanged**. Execution shape refined to close an operational gap surfaced by user during thread #46 ratification discussion. Commit `b87fc1a` on branch `claude/relaxed-brown-12cebb`.

Supersedes `learning_2026-04-24_w1-adr-8-pass-2-reframe-push-via-fair-router-ef` which recorded the original pass-2 proposal. This amendment preserves pass 2's direction + rationale and layers the trigger-model fix on top.

## The gap the user surfaced

Original pass-2 design had fair-router triggered by `pg_notify` on INSERT only. Sweep at 1 min was the only fallback for "bank frees up → route waiting item." User pointed out:

> "ในเหตุการณ์จริง bank จะ busy นาน และส่วนใหญ่จะ busy กลายเป็นว่า Fair-router จะทำงานฟรีเสมอ แล้วก็ต้องไปรอ sweep ซึ่ง 1 นาทีก็นานเกินไปอีก"

Verified by state-machine analysis:
- Banks typically busy 1-2 min per batch (portal nav + C-002 jittered delays)
- Under original design: INSERT with pool saturated → fair-router returns empty; item `pending_routing`; next routing attempt only at sweep 1-min tick
- **Effective latency ~1 min** — regression from current-system's 30-s dispatcher tick
- Additionally: fair-router wakes on every INSERT even when pool is saturated, doing wasted work

## The fix

### Trigger B — bank-free event
`pg_notify` fires from within lifecycle RPCs (`mark_success` / `mark_failed` / `mark_waiting_to_review`) at transaction end. pg_notify is transactional — only delivered on RPC commit, so no "phantom free-event" risk. Router wakes → scans pool's `pending_routing` items → routes to newly-freed bank. Latency ~100-300ms from free event to next claim.

### Early-bail guard
Router's first query: `COUNT idle+eligible banks in pool`. If zero, return without acquiring advisory lock. Trigger A becomes cheap no-op under saturation. No wasted lock contention.

### Batched routing within single lock window
Trigger B can route multiple waiting items to multiple freed banks in one invocation — matches current-system dispatcher's tick behavior (which loops over unassigned items, calling `findBestBankForItem` for each). Port is now explicit in the ADR.

### Sweep reframed as belt-and-suspenders
Original sweep design had Case 1 (`pending_routing > 1 min`) and Case 2 (stale `required_bank_account_id` + no claim in 1 min) as primary recovery. Amended: both cases remain but are framed as edge-case fallback. Triggers A + B handle normal cycles; sweep catches pg_notify drops, EF crashes mid-execution, advisory-lock timeouts.

## Consequences updated

**Latency profile (amended):**
| Scenario | Latency |
|---|---|
| New item + bank idle | Trigger A → ~100-300ms |
| New item + all banks busy | Trigger A early-bail → Trigger B fires on next free → ~100-300ms from free event |
| Bank frees + items waiting | Trigger B → ~100-300ms |
| Bank frees + no items waiting | Trigger B → router → early-bail or no-route → no-op |
| Dual-trigger failure | Sweep ≤1 min (edge case only) |

**Beats current** in all normal scenarios (current: 30-s tick cycle).

## What did NOT change

- Option F as chosen default — intact
- §ADR-4a Mode 1 retirement — intact
- Pull as exception-only — intact
- RPC + claim mechanism — intact
- Defense-in-depth model — intact
- Advisory-lock-per-pool serialization — intact
- §ADR-4a ratifications (threads #41/#42/#43) — intact

## What this amendment does NOT resolve (future)

- `compute-claim-size` EF (from §ADR-4a) may become redundant if fair-router computes tier cap inline — flagged for implementation-phase merge-or-keep decision.
- Trigger B rate under extreme load (high lifecycle-RPC firing rate) — materialized `bank_daily_usage` view or counter cache; deferred if bind.
- Sub-question 5 in thread #46 wording — context updated via thread message, sub-question itself unchanged.

## Why amendment instead of pass 3

Pass 2 had not yet ratified (`#provisional`, `[RATIFICATION_PENDING:46]`). Changing execution detail pre-ratification is cheaper than ratifying-then-superseding-next-pass. No downstream work depends on pass-2 wording yet. User consented to Option A (amend before ratify) over Option B (ratify + refine in pass 3).

## Thread activity

Thread #46 received an "Amendment 2026-04-24 ~12:30 GMT+7" message (message id 90) explaining the change and updating sub-question 5 context. Core decision + sub-questions 1-4 unchanged. Awaiting user's ratification on the amended proposal.

## Sources cited

- Commit `b87fc1a` — the amendment edit on `docs/adr.md`.
- Original pass-2 commit `36628c3` — preserves pre-amendment ADR-8 text per P-001.
- `learning_2026-04-24_current-system-prior-art-findbestbankforitem-u` — Input 5 finding still underpins the decision.
- `learning_2026-04-22_w1-refine-pass-2-withdrawal-dispatch-claim-ra` — §ADR-4a pass-2 ratification preserved; Mode 1 semantic change intact from pass 2.

## Commit + PR

- Commit: `b87fc1a` on branch `claude/relaxed-brown-12cebb` (continuing PR [#2](https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/2)).
- Diff: +22 / -6 lines on `docs/adr.md`.

## Pattern captured — pre-ratification amendment as workflow discipline

This amendment exemplifies the `#provisional` + thread-first discipline doing its job: pass 2 shipped provisional → user review found operational gap → amendment applied pre-ratification → thread #46 still the ratification anchor. No pass-2-rolled-back-by-pass-3 churn; clean mid-flight correction. Worth archiving as canonical pattern for future architect sessions where a gap is caught during ratification but before `#decision` promotion.

---
*Added via Oracle Learn*
