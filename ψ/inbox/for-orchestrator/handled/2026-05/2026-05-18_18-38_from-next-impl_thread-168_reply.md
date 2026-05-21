---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 168
parent_thread: 168
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: re — #168 GO executed: G5–G8 closed (2 PRs verified); G9 is a correction
in_reply_to: 2026-05-18_16-44_from-orchestrator_thread-168_consult.md
needs_response: false
priority: normal
created: 2026-05-18T18:38:00+07:00
---

Executed the #168 close order. Full report on thread #168 (msg 526). Summary:

**Delivered — 2 fork PRs, hosted-verified, neither merged (§9):**
- **PR #158** — G5: ported `cancel_stale_payout` + `sweep_stale_payouts` into
  the integrated substrate (migration `20260518000003`, pushed to
  `spdazjbmyagekwxixfct`), carrying the §ADR-4a §Amendment 2026-05-18 LO1 lock
  order from PR #155; + the cancel/sweep probe and the claim-vs-cancel
  deadlock probe. PAYOUT-005 admin-cancel NOT built — blocked on the
  admin-JWT harness decision per the brief.
- **PR #160** (stacks on #158) — G6 (`mark_success` atomic rollback),
  G7 (cascade Step 2a), G8 (`finalize_deposit` vs `expire_deposit` race).

**Verified:** all 7 new audit-#168 assertions pass on the hosted substrate
across two runs. The runs show 95/96 — the single non-pass is a pre-existing
timing-flaky probe (a *different* one each run: `deposit_d6_concurrent_
cascade_race`, then `d7_realtime_miss_cron_fallback_recovers`); both run
before every #168 probe and were green in the G5 run. Flagged for a
separate look — not a regression here.

**G9 — a correction.** My #158 map called G9 a "clean probe-shaped quick
win, floor-only." Wrong — I read the floor poc, not the integrated substrate.
The three validations (`PAYOUT_DISABLED` / `AMOUNT_OUT_OF_RANGE` /
`UNSUPPORTED_DEST_BANK`) are absent from the integrated `create_payout` + the
`payouts-create` EF entirely; the `client` table has no
`enable_payout`/`min_payout`/`max_payout` columns and there is no
`supported_bank` table. G9 is therefore a substrate port (schema + money-RPC
change) that embeds config decisions — the payout-side mirror of #158's
DOC-2. NOT built this pass (silently rewriting a money RPC + inventing config
is out of scope). Recommend a scoped follow-up like G5, with a design nod on
the min/max/supported-bank shape. Routes to the user.

— next-impl

# handled_at: 2026-05-18T17:34:26+07:00
# handled_by_thread: 168
# handled_note: G5-G8 closed (PR #158/#160); G9 = substrate port, admin-JWT decision pending
