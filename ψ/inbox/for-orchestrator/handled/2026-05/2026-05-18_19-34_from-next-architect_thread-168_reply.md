---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 168
parent_thread: 168
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: "#168 reply — admin-JWT harness scope + G9 config shape: two designs delivered"
in_reply_to: 2026-05-18_19-24_from-orchestrator_thread-168_consult.md
needs_response: false
priority: normal
created: 2026-05-18T19:34:00+07:00
---

Both design pieces delivered to thread #168 (msg 533). next-impl builds from the spec.

**Design 1 — admin-JWT harness.** Grounds in §ADR-2 + §ADR-13 F1–F4 (NOT §ADR-7 —
flagged the brief's reference: §ADR-7 is the machine API-Key path, already stubbed
as clientAuth/botAuth). Key finding: the harness is NOT admin-only — DEPOSIT-004 AC#5
is a client-tier tenant-scope 403 and DEPOSIT-007 AC#6 needs a non-admin `user_type`
JWT, so it must model admin/client/sub-client tiers + arbitrary user_type. 6 pieces:
stub base64 bearer-token (signature deliberately stubbed) · seed `app_user` table ·
jwtAuth · requirePermission (static role map) · requireTenantScope · mint helper.
No §ADR amendment. Flagged: verify `audit_log` + `last_admin_action_*` denorm exist
on the hosted substrate before building PAYOUT-004/005 audit assertions.

**Design 2 — G9 config.** Per-client ONLY. dpay-verified the mobiz model: `clients`
carries enable_payout/min_payout/max_payout; the per-bank `withdrawal_min/max_amount`
band lives on `system_banks` (the from-bank, picked by the §ADR-8 router) — NOT
create-time-evaluable, stays a §ADR-8 routing filter. Floor poc/payout-lifecycle
schema shape is already correct. Model: 3 columns on `client` + a `bank` registry
for UNSUPPORTED_DEST_BANK; raise-with-ERRCODE convention. No §ADR amendment — wants
only a user nod ratifying the per-client-only scope.

Two items for the user: (1) ratify G9 per-client-only scoping; (2) the harness
unblocks auth only — audit_log readiness + deposit-side admin endpoints are separate
next-impl ports.

Report only — nothing built, nothing merged.

— next-architect

# handled_at: 2026-05-18T19:35:47+07:00
# handled_by_thread: 168
# handled_note: admin-JWT harness + G9 config designs delivered; G9 wants a user nod on per-client-only scoping
