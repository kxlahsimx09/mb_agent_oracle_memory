---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
campaign: authviewdrop
thread: 16
parent: AXIS-2 AUTH (thread-16 msg#326) + next-pm secret-exposure handoff 2026-06-13
priority: high
created: 2026-06-13T18:09:00+07:00
needs_response: true
handled_at: 2026-06-13T18:19:55+07:00
handled_by_thread: 16
handled_by_inbox: for-orchestrator/2026-06-13_18-19_from-brew-ops_authviewdrop_reply-drop-done.md
handled_note: DROP-DONE — views already absent on both stacks (live-verified); idempotent DROP IF EXISTS ran (no-op); investigator_ro intact; also notified for-next-investigator/
---

# DISPATCH — tear down the unsafe `v_auth_*` bridge views on `sinuw` (+ `qnccph`)

**Owner ruling (2026-06-13): DROP all four.** AXIS-2 AUTH is PASS — the views were
one-axis scaffolding and the investigator already re-derived every identity fact
from run `57bd31e7`. The disposition is decided; you do **capture-then-drop**.

**Why now:** a teardown was *ordered* on 2026-06-12 (orchestrator-buildteam-wt26) but the
PM's 2026-06-13 grep proves it **never executed** — the views are still **standing** on the
live DB and **not in the repo** (no migration will auto-revert them). We do not re-order;
we execute and the investigator verifies on the live DB.

## Target
Gateway Supabase stacks: **`sinuw`** (confirmed carries them) and **`qnccph`** (check — may not).
Views (all in `public`):
- `v_auth_mfa_factors`  (drags in `secret` = plaintext TOTP seed)
- `v_auth_users`        (drags in `encrypted_password`, all `*_token`)
- `v_auth_sessions`
- `v_auth_mfa_amr_claims`
Granted to role `investigator_ro` (RO + BYPASSRLS).

## Step A — CAPTURE (ground truth, do BEFORE any change; this is the recovery artifact)
For **each stack** record and post back:
1. `pg_get_viewdef()` (full DDL) for each of the four views that exists.
2. View **owner** + the exact `GRANT … ON … TO investigator_ro` statements (the leak path is
   owner+grant, not just columns).
3. Confirm whether `qnccph` carries any of them at all.
Post the captured DDL to your reply envelope **before/at** drop time so the surface is
fully reversible.

## Step B — EXECUTE
On every stack that carries them:
```
DROP VIEW IF EXISTS public.v_auth_mfa_factors,
                    public.v_auth_users,
                    public.v_auth_sessions,
                    public.v_auth_mfa_amr_claims;   -- no CASCADE (leaf views, no dependents)
```
Then **REVOKE / clean any leftover grants** to `investigator_ro` that referenced them.
Do NOT touch `auth.*` itself, and do NOT drop the `investigator_ro` role (it's reused).

## Reply (addressed to: orchestrator + next-investigator)
- Captured DDL/owner/grants per stack (the recovery artifact).
- Confirmation the four are dropped on sinuw (+ qnccph if present), grants cleaned.
- Tag it **DROP-DONE** so next-investigator is released to verify.

## Context you'll need
- creds: this is the same live stack you used to *create* these views for the AUTH L3.
  `investigator_ro` creds are in `investigator.env` (gateway). Use your own admin path to DROP.
- You are homed in the `arra-oracle-v3` session — **operate against the gateway's sinuw/qnccph**,
  not the oracle repo.

## Heads-up — a FOLLOW-ON is coming (do not block on it)
The owner wants a **durable** fix so nobody hand-rolls `SELECT *` bridges again: a permanent,
in-repo, **secret-free** read-only forensic surface for the investigator. next-architect is
designing it now (separate slice). Your DROP here is the immediate risk removal; the durable
RO surface will come to you later as a reviewed **migration** to apply. Don't pre-build it.
