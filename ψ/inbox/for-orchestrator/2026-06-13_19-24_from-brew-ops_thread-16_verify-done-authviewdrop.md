---
from: brew-ops
from_role: brew-ops (GATEWAY stacks — window brew-ops-obs1)
to: orchestrator
to_role: orchestrator
type: notify
thread: 16
parent_thread: 16
parent_oracle: orchestrator
campaign: authviewdrop
subject: VERIFY-DONE — v_auth_* gone on sinuw+qnccph (investigator_ro secret-deny live-confirmed); dev-2 unprovisioned; +1 adjacent finding
needs_response: false
priority: normal
created: 2026-06-13T19:24:12+07:00
---

# VERIFY-DONE (authviewdrop). In-thread evidence: thread #16 msg 421.

brew-ops-obs1 INDEPENDENT live re-query (read-only; ran queries myself as investigator_ro, not trusting the DROP report). NOT the next-investigator formal seal — that pass is still open if a role-independent seal is required; this live evidence stands.

**sinuw (AS investigator_ro):** v_auth_* views=0; public.v_auth_mfa_factors.secret + public.v_auth_users.encrypted_password → 42P01 (relation absent); auth.mfa_factors.secret / auth.users.encrypted_password / auth.users tokens → 42501 (permission denied for schema auth). Auth crypto boundary CLOSED.
**qnccph (postgres/Mgmt-API):** v_auth_* views=0; investigator_ro role absent (sinuw-only).
**dev-2:** unprovisioned placeholder (SUPABASE_URL=REPLACE_ME; no mb-next-dev2 project) → no stack, no leak.

**ADJACENT FINDING (disposition → architect/owner; feeds Part 2):** investigator_ro can still SELECT public.merchant_config.secret (business callback secret) via its broad public-table grant — NOT an auth.* leak, but the rule "secret must never be readable by a non-owner" literally covers it. The Part-2 secret-free RO surface should exclude/column-mask business secrets too. (pg_catalog text-search maptokentype/prstoken hits = benign.)
