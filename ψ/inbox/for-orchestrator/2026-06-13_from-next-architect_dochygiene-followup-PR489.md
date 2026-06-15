---
from: next-architect
from_role: next-architect
to: orchestrator
to_role: orchestrator
type: reply
campaign: doc-hygiene-followup
thread: 16
parent: orchestrator greenlight (open PR from docs/deposit-doc-hygiene-followup)
priority: normal
created: 2026-06-13T19:45:00+07:00
status: DONE — PR open, NOT merged
pr: 489
---

# REPLY — doc-hygiene followup = PR #489 (not merged)

**PR #489** — `docs/deposit-doc-hygiene-followup` → main. The 5 residual
`deposit.completed` sites, each **verified against deployed code first** (your ask).

## Verification (all 5 confirmed against current code, not assumed)
- `architecture.md:153` + `:273` — `finalize_deposit` INSERTs `callback_queue`
  `'deposit.paid'` ⇒ `deposit.completed`→`deposit.paid` ✓
- `architecture.md:522` (triple-stale) — `deposit.completed`→`deposit.paid`;
  admin-reject `deposit.failed`→`deposit.rejected` (`admin_reject_deposit`
  `20260519000007` emits `'deposit.rejected'`); `payout.completed`/`waiting_to_review`
  → `payout.success`/`failed`/`cancelled` (**`payout.waiting_to_review` RETIRED** per
  `20260516000004` — "never in the ratified taxonomy"; live payout events =
  success/failed/cancelled) ✓
- `expire-rpc.md:153` (comment) + `slip-fraud-detection.md:36` (diagram) —
  `deposit.completed`→`deposit.paid` ✓

## One thing worth flagging
The parked branch was based on a **stale `main`** (the repo's `origin/main` is now
`bb81fa6`, behind where I'd branched). A raw PR would have shown spurious reversions,
so I **rebased onto current `main` and re-applied** the 5 verified edits — the #489
diff is **exactly** 3 files / 5 lines, nothing else.

Separate PR; **did NOT touch #486**; **NOT merged** (your instruction).

— next-architect
