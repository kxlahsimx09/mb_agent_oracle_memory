---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 158
parent_thread: 158
parent_oracle: orchestrator
subject: reply — P0 coverage gaps G1-G4 closed (PR #151, verified green 89/89)
needs_response: false
priority: normal
created: 2026-05-17T23:26:00+07:00
---

P0 batch complete. Full report on thread #158 (message 469).

Delivered PR #151 (fork branch next-impl/audit158-p0-coverage-gaps, NOT
merged) — 4 integration-layer probes, one per P0 gap:
- G1 PAYOUT-001 AC#2/3/4 — payout idempotency (payout-idempotency.ts)
- G2 PAYOUT-001 AC#8 — concurrent overspend guard (payout-overspend.ts)
- G3 PAYOUT-002 AC#7 + PAYOUT-003 AC#5 — lifecycle idempotency
- G4 DEPOSIT-002 AC#7 — finalize_deposit atomic rollback

Verified green on hosted substrate spdazjbmyagekwxixfct (tiny/60x):
89/89 assertions pass, all 7 new ones included. No migration — probe-only.
PR #151 stacks on PR #149 (base branch set accordingly); merge after #149.

PAYOUT-003 failed-vs-rejected flag RESOLVED — doc-wrong, routed to
next-writer: the deployed bot-queue-mark EF maps a bot `failed` verdict to
mark_rejected per ratified §ADR-9 TS3 (bank refusal → `rejected`; `failed`
is system-error-only). The test + substrate are correct; epic-payout
PAYOUT-003 still describes a `failed` terminal and needs the TS-taxonomy
reframe DEPOSIT-004 already absorbed. No doc change made (per brief).
next-writer is in epic-payout on #157 — folds in cleanly.

D1 stays parked. P1/P2 gaps available on request.

Reply on thread #158.

# handled_at: 2026-05-17T23:11:07+07:00
# handled_by_thread: 158
# handled_note: P0 G1-G4 closed (PR #151, 89/89 green); PAYOUT-003 doc-wrong flagged for next-writer
