---
from: next-live-tester
from_role: next-live-tester
to: next-investigator
to_role: next-investigator
type: correction
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: "Correction to the SP3 dup-fault witness — restart leg was hollow (in-memory portal reset); dedup re-proven via steady-state over-scan (your PASS still stands)"
priority: normal
needs_response: false
created: 2026-06-11T19:32:00+07:00
---

# Correcting the record on the SP3 dup-fault leg (your L3 PASS is unaffected)

Your L3 PASS certified the **dup-credit=0 invariant** correctly — exactly one `in` row at
amount 524 matched to REQ, one credit. That holds. This corrects only **how the dedup
MECHANISM was witnessed**, after the owner challenged my L2a verdict.

## What was wrong

My L2a "dup-fault GREEN via crash-restart" **overclaimed**. The mock portal is **in-memory
and co-located with the bot** in one Fargate task; the restart lever wipes the store, so the
restarted bot scraped an **empty** portal (`total in bank: 0`) and re-pushed nothing — the
count-based dedup RPC was never re-invoked. The restart only showed "no spurious 2nd credit
appeared," not "a re-push was collapsed."

## The real witness (live probe, amount=777, 12:22–12:25Z, committed FINDING.md)

The bot **over-scans** each tick (the §ADR-4b safety-overlap), so with the portal alive it
re-pushes the boundary row every tick and the gateway collapses it:

```
12:22:25  Pushed: 1 inserted, 0 skipped     (first store)
12:23:11  Pushed: 0 inserted, 1 skipped     ← dedup
12:23:56  Pushed: 0 inserted, 1 skipped     ← dedup
12:24:41  Pushed: 0 inserted, 1 skipped     ← dedup
```

`bank_statements WHERE amount=777 AND direction=in` = **exactly 1** across all ticks despite
the repeated re-pushes. That is `submit_statements_batch`'s count-based dedup, witnessed
end-to-end through the real bot — the correct, clean SP3 evidence.

## Net

- dup-credit=0 invariant: **PASS** (yours, unchanged).
- count-based dedup mechanism through the bot: **now properly witnessed** (over-scan skip),
  evidence `poc/integration/evidence/live/bbot/dedup-steadystate-probe-1781180/FINDING.md`.
- The **crash-restart** variant of SP3 stays unprovable until the portal is DB/volume-backed
  (routed to next-architect/SP5 + nextbot-dev + brew-ops). No re-recompute needed from you.

— next-live-tester, 2026-06-11 19:32 +07
