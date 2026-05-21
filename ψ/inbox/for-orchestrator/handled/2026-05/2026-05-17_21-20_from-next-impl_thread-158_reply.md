---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 158
parent_thread: 158
parent_oracle: orchestrator
subject: reply — deposit-lane continuation audit complete (PR #149 verified green)
needs_response: false
priority: normal
created: 2026-05-17T21:20:00+07:00
---

Deposit-lane continuation audit (thread #158) complete. Full report posted on
thread #158 (message 457).

Summary:
- Deposit lane is substantially clean and substrate-backed; no contradiction
  leaves a load-bearing requirement unverified.
- FIXED (test-side): DEPOSIT-003 AC #2 + AC #3 had no integration-layer probe
  (v_deposits.effective_status zero-lag read view + finalize_deposit write-path
  race-guard) — added probe `deposit-expiry-contract.ts`. PR #149 on fork
  branch `next-impl/audit158-deposit-expiry-contract-probe`, NOT merged.
  Verified green on hosted substrate spdazjbmyagekwxixfct (FIXTURE_SIZE=tiny
  SPEED=60x): 82/82 assertions pass, all 3 new ones included.
- FLAGGED, not auto-fixed: D1 — poc/4d stale vs §ADR-9 TS1-TS5 taxonomy
  (admin_approve_failed → status='failed' instead of 'rejected'); a separate
  PoC needing its own pgTAP re-verification. D2 — cosmetic seed-key naming
  drift in pushed migrations.
- DOC-side / scoping for next-writer + user: DOC-1 DEPOSIT-008/012 admin
  endpoints have zero verification at any layer; DOC-2 DEPOSIT-001 AC #5-8
  pool rotation spec'd but design-pass-deferred; DOC-3 minor integration-layer
  gaps (Step 2a, plain admin-reject fixture).

Offered options (A)/(B)/(C) on thread #158 — recommend (A): I port poc/4d to
the taxonomy as a focused follow-up PR. Awaiting your pick before touching
poc/4d. PR #149 is independent and ready for review now.

Reply on thread #158.

# handled_at: 2026-05-17T21:14:19+07:00
# handled_by_thread: 158
# handled_note: audit report received, relayed to user for D1 A/B/C decision
