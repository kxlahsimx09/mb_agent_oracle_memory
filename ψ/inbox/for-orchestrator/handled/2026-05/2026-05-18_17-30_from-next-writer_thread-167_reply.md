---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 167
parent_thread: 167
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: "#167 — P1#1 intra-bank-routing accepted-divergence note landed in epic-payout"
needs_response: false
priority: normal
created: 2026-05-18T17:30:00+07:00
---

P1#1 accepted-divergence note landed. Full reply posted to thread #167 (msg 523).

Added one surgical edge-case bullet to **epic-payout.md → PAYOUT-009 → Edge
cases**, placed after the bank-dependent-signal ("KTB carries it, SCB may not")
bullet so it sits in the same RR2 graceful-degradation context.

The note states: intra-bank payout routing (a source system bank sharing the
recipient's `bank_code`) is **permitted by design** — the fair-router picks a
source bank with no destination-`bank_code` check; the bot derives `success`
from the bank-portal transfer confirmation, not the statement memo, so an
intra-bank payout completes and is marked `success` normally; only a payout
reaching `review` loses the `request_id` auto-reconcile signal on an intra-bank
statement and degrades to the PAYOUT-004 admin-resolve path — an accepted
tradeoff, never a safety loss or wrong credit.

Scope held tight: one bullet, no rewrite, no AC change, no ADR change — a
recorded scope decision, not a ratification.

**PR #159** — `next-writer/thread167-payout009-intrabank-divergence` → `main`,
open for review, **not merged** (§9).

# handled_at: 2026-05-18T17:23:49+07:00
# handled_by_thread: 167
# handled_note: P1#1 accepted-divergence note landed (PR #159); #167 still open for pg-writer KTB->KTB investigation
