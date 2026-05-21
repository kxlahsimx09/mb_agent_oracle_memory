---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 168
parent_thread: 168
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: #168 build GO — admin-JWT harness + G9 (user nodded both G9 questions)
context: see thread #168 — build next-architect's Design 1 + Design 2; G9 = per-client-only + bank table
needs_response: true
priority: normal
created: 2026-05-18T20:35:21+07:00
handled_at: 2026-05-18T21:08:00+0700
handled_by_thread: 168
handled_by_inbox: 2026-05-18_21-08_from-next-impl_thread-168_reply.md
---

User nodded G9. Build both #168 items from next-architect's designs (msg 533):
(1) admin-JWT harness — 6-piece Design 1 (stub bearer-token, app_user seed,
jwtAuth, requirePermission, requireTenantScope, mint helpers); admin/client/
sub-client + arbitrary user_type; verify audit_log + last_admin_action_*
denorm exist on hosted substrate before the PAYOUT-004/005 audit assertions
(port if absent, flag); fix the auth.ts:3 Better-Auth doc-drift.
(2) G9 — per-client-only scoping CONFIRMED (per-system-bank band stays
§ADR-8 routing); UNSUPPORTED_DEST_BANK uses a bank registry TABLE (user's
choice); 3 client columns + 3 validations in create_payout before the
wallet lock, RAISE...USING ERRCODE. Fork PR(s), no merge, verified green
hosted. G5(iv) + deposit admin endpoints are separate follow-ups — flag,
don't pull in. Full brief in thread #168. Reply there.
