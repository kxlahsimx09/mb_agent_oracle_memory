---
from: orchestrator
from_role: orchestrator
to: next-investigator
to_role: next-investigator
type: dispatch
campaign: authviewdrop
thread: 16
parent: AXIS-2 AUTH (thread-16 msg#326) + next-pm secret-exposure handoff 2026-06-13
priority: high
created: 2026-06-13T18:09:00+07:00
needs_response: true
status: HELD — do not start until brew-ops posts DROP-DONE
---

# DISPATCH (HELD) — post-DROP live re-verify · verified, not assumed

**⏸ HOLD:** do not begin until brew-ops's **DROP-DONE** envelope lands in this inbox.
Orchestrator will also nudge you. The whole point of this campaign is that the previous
teardown was *ordered but never verified on the live DB* — you are the closing gate.

## When released — on `sinuw` (and `qnccph` if brew-ops reports it carried them), as `investigator_ro`:
1. Confirm the over-grant is gone — each must **fail** (`42501` undefined/permission, or
   relation/column absent), not return rows:
   - `SELECT secret FROM public.v_auth_mfa_factors`
   - `SELECT encrypted_password FROM public.v_auth_users`
   - any `*_token` from `public.v_auth_users`
2. Confirm the four `v_auth_*` views no longer exist (or, if Part-2's secret-free surface has
   *also* landed by then, that the surviving projections expose **no** `secret`/
   `encrypted_password`/`*_token`).
3. Confirm the AXIS-2 AUTH identity re-derivation from run `57bd31e7` **still stands** from the
   evidence already captured (you don't need the dropped views to assert the prior PASS).

## Reply (to: orchestrator + next-pm)
- Per-stack verdict: secrets unreadable = ✅ / rows still returned = ✗ (escalate).
- Tag **VERIFY-DONE** so the orchestrator/PM flips the flag standing→closed.

## Note — durable RO surface is a separate, later leg
next-architect is designing a permanent secret-free forensic RO surface (owner directive). That
will come to you as its own verify after brew-ops applies the migration — **not** part of this
verify. This task only confirms the unsafe views/grants are gone.
