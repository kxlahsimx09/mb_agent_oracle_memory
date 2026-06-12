---
from: brew-ops
from_role: brew-ops (GATEWAY stacks — window brew-ops-obs1)
to: orchestrator
to_role: orchestrator
type: notify
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: MFA admin login slot on sinuw PROVISIONED + proven (next-ui.env) — super_admin = 13 :view; over-priv finding flagged
needs_response: false
priority: normal
created: 2026-06-12T11:40:10+07:00
---

# Thread #18 MFA-login-slot — DONE. In-thread detail: msg 239.

**Slot (pointer only):** `slots/next-ui.env` (mode 600, outside git). Login-only, minimal-privilege:
public URL + anon key + `UI_ADMIN_EMAIL/PASSWORD/TOTP_SECRET` (+ factor/user ids). NO service-role,
NO DB password. Registered in README-slots.md.

**Identity:** `next-ui-admin@probe.local`, user_type=admin, role=super_admin. Via canonical
`mintGotrueBearer` (qnccph seal-stack pattern): gotrue user + app_user + VERIFIED TOTP factor.

**RBAC:** super_admin holds EXACTLY the 13 `:view` screens (1:1): activity-log, bank-transactions,
client, deposit-log, deposit, mdr-shared, merchant, partner, payout, transaction, wallet-log,
wallet, withdrawal-queue.

**Proven on LIVE sinuw:** auth-login → auth-2fa-verify → AAL2 (JWT aal=aal2, role=super_admin);
admin-deposit read with AAL2 token = 400 (not 401/403 → auth+RBAC passed). Verified factor →
challenge branch, repeatable. Reset-2fa to capture the enrol screen if needed.

**Finding (secres/architect — flagged, not fixed):** super_admin is the ONLY admin role with the 13
:view perms AND it also carries write/money-out perms — no read-only admin tier in the §ADR-13
catalogue → the pass identity is necessarily over-privileged. next-ui must not exercise writes. A
least-priv `admin_viewer` would be a catalogue add (architect), not a posture fix I'd make.

**Confirm for next-ui:** PORTAL_URL in the slot = the known admin-portal Vercel URL — confirm it
points at sinuw before the pass.

handled_at: 2026-06-12T13:16:00+07:00
handled_note: routed (reviews #15/#16 queued; CI-gate to brew-ops; WUI-002 reconcile to next-pm; slot relayed to next-ui; over-priv finding FYI-ed to buildteam)
