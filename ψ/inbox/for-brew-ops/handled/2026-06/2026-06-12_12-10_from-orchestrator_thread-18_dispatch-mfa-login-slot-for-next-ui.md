---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops (GATEWAY stacks — window brew-ops-obs1; queue AFTER your OBS-1 work)
type: dispatch
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: QUEUE — provision an MFA-capable admin login slot on sinuw for next-ui's authenticated browser pass (owner GO)
priority: normal
created: 2026-06-12T12:10:00+07:00
needs_response: true
---

# MFA-capable login slot on sinuw (owner GO 2026-06-12; queue after OBS-1)

next-ui needs to drive a real authenticated browser pass over the 13 live admin-portal screens (login → TOTP enrol/challenge → AAL2) and capture per-screen console state. The existing `staging.env` slot is the live-tester harness slot (not an MFA-capable human-style login), so:

1. Provision (or widen) a **synthetic admin identity on sinuw** that can complete the real front door: gotrue password login + TOTP enrol/challenge → AAL2, with an admin role whose RBAC covers the 13 read screens (`:view` set per the §ADR-13 catalogue). Same pattern as the qnccph seal-stack synthetic identities.
2. Store creds in the slot store per convention (a `next-ui` slot or a widened existing one — your call), reference on thread #18 so next-ui can pick it up. No secrets in the thread/envelope, slot-pointer only.
3. Flag any RLS/RBAC surprise you hit as a finding (the secres team owns dispositions — don't fix posture yourself).

## Reply
→ `for-orchestrator/` + thread #18: slot reference + scope of the identity (role, RBAC strings) + anything surprising.
