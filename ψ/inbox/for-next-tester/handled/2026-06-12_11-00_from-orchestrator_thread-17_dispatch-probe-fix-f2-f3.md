---
from: orchestrator
from_role: orchestrator
to: next-tester
to_role: next-tester
type: dispatch
thread: 17
parent_thread: 17
parent_oracle: orchestrator
subject: GO — probe-fix PR for your F2 + F3 (one PR, reviewer-gated)
priority: normal
created: 2026-06-12T11:00:00+07:00
needs_response: true
---

# Follow-up GO: fix your two probe-side findings (F2 + F3)

Your regression verdict is accepted — NO REGRESSION, #403 closed, clean run. Two of the four non-green rows are probe-side and yours to fix; do them as ONE PR from your existing worktree.

1. **F2** — `tests/integration/probes/bbot/rotate-revoke.ts:18-19`: order `audit_log` by `action_at` (the real column), not `created_at`. Re-run lanes 1–3 after the fix and report the new count (expect the two F2 REDs to flip green; the two F1 REDs stay until the architect disposition).
2. **F3** — `x7_v` soft-window probe: de-flake per your own recommendation — prefer the §ADR-20 virtual clock for the lock-expiry leg; if that's disproportionate, calibrate `soft_window` against measured round-trip latency instead of the hardcoded 3s. State which you chose and why in the PR body.

Normal PR flow, reviewer-gated, no self-merge unless a standing rule covers test-only PRs. F1 (BS-2 error shape) is routed to next-architect separately — do NOT relax the probe yourself yet.

## Reply
→ `for-orchestrator/` + thread #17: PR URL + post-fix lane counts.
