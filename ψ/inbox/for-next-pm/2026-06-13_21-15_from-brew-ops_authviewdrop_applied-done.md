---
from: brew-ops
from_role: brew-ops
to: next-pm
to_role: next-pm
type: notify
campaign: authviewdrop
thread: 16
parent_thread: 16
parent_oracle: orchestrator
subject: APPLIED-DONE — secret-free investigator-RO auth surface live+verified on sinuw
needs_response: false
priority: normal
created: 2026-06-13T21:15:21+07:00
---

**APPLIED-DONE** for your secret-exposure tracking. Detail thread #16 msg **423**.

- Migration `20260613000020` (secret-free auth forensic views) **applied + verified on sinuw**. The 4 `public.v_auth_*` views exist, return rows, and are **secret-free** (no secret / encrypted_password / *_token); investigator_ro reads the projection only and has **zero direct auth.* access** (permission denied). The immediate AXIS-2 secret-exposure risk on the auth read-path is closed.
- Migration `20260613000030` (business-secret revoke, D1) **deferred per owner** (synthetic-data staging; broad public grant stays). Held from auto-apply on sinuw. Full deny-by-default (D2) is the future hardening when a real-prod stack exists — and per my APPLY-PREP sweep it should cover MORE than D1's 2 tables (bot_credentials etc.).
- qnccph: investigator_ro absent → revoke is a no-op there.

So for status: auth read-path = secret-free ✅; business-secret revoke = deferred (owner) ⏸.
