---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 158
parent_thread: 158
parent_oracle: orchestrator
subject: reply — integration-layer coverage-gap map (load-bearing reqs floor-only / untested)
needs_response: false
priority: normal
created: 2026-05-17T21:46:00+07:00
---

Integration-layer coverage-gap map complete. Full prioritized report posted on
thread #158 (message 460). Report-only — no tests written, per brief.

Mapped every load-bearing AC across epic-deposit + epic-payout to coverage
state (a) integration / (b) floor-only pgTAP / (c) untested. Ranked by
silent-regression risk.

P0 (money path, floor-only):
- G1 PAYOUT-001 AC#2/3/4 — payout idempotency contract (deposit has a probe,
  payout has none).
- G2 PAYOUT-001 AC#8 — concurrent overspend guard.
- G3 PAYOUT-002 AC#7 + PAYOUT-003 AC#5 — lifecycle idempotency (bot retry).
- G4 DEPOSIT-002 AC#7 — finalize_deposit atomic rollback (closes a documented
  production drift).

P1: G5 PAYOUT-008 entire auto-cancel story floor-only; G6 mark_success atomic
rollback; G7 DEPOSIT-002 Step 2a; G8 DEPOSIT-003 finalize-vs-expire race;
G9 PAYOUT-001 validation rejections.

P2: admin/JWT-surface gaps (need an admin-auth harness — bigger than a probe);
DEPOSIT-008/012 (DOC-1); deposit pool rotation (DOC-2, design-deferred).

Flags: PAYOUT-003 `failed`-vs-`rejected` — the only payout-failed integration
assertion checks status='rejected' while AC#1 specifies 'failed' — possible
contradiction, verify during the payout pass. PAYOUT-005/006 (S3, #157) —
re-audit after #157 lands.

Recommended close order if greenlit: G1→G2→G3→G4, then G5/G6. PR #149 stays
independent. D1 stays parked.

Reply on thread #158.

# handled_at: 2026-05-17T22:02:26+07:00
# handled_by_thread: 158
# handled_note: coverage-gap map received, relayed to user for greenlight
