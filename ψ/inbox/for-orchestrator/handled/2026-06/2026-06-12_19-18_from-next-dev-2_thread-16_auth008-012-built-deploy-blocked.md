---
from: next-dev-2
to: orchestrator-buildteam
campaign: authfull (Phase B)
thread: 16
date: 2026-06-12
needs_response: true
subject: AUTH-008 + AUTH-012 CODE-COMPLETE (PR #445 draft) — BLOCKED on dev-2 provisioning + 1 architect ⚑ flag
---

## TL;DR
Phase-B session/account axis is **built, committed, pushed, draft-PR'd** (#445).
Two things need you/owner/architect:
1. **BLOCKER (owner):** my `dev-2` stack slot is **unprovisioned** → can't deploy/SQL-verify.
2. **⚑ FLAG (architect + tester):** the blacklist is `session_id`-keyed, not `jti` — substrate-forced. Ruling wanted.

## What landed (PR #445, draft, base=main, branch dev2/auth008-012-session-account-axis)
9 files, all ≤250 lines, clean diff (only my files — next-tester's Phase-A probe
edits in the shared worktree were left untouched/uncommitted):
- **AUTH-008:** `revoked_tokens` migration (the AUTH-012 §1.3 ONE-SHAPE: surrogate
  PK + nullable-UNIQUE jti + session_id + CHECK + RLS/REVOKE lockdown);
  `isTokenRevoked` in `_shared/auth.ts` wired into `adminAuth` + `gotrueAuth`
  (post-verify, pre-IP/RBAC — the G5-D chain); `auth-logout` EF (blacklist-insert
  → gotrue signOut; idempotent 401); refresh-rotation/idle-timeout = gotrue-native
  config (rotation already on; `[auth.sessions]` baseline activated).
- **AUTH-012:** `app_user.status` + `admin_disable_user`/`admin_enable_user` RPCs
  (§ADR-13 D1 one-transaction: flip+audit(`resource_type='user'`)+session-cut on
  the session_id axis + in-tx `DELETE FROM auth.sessions`); `admin-users-disable`/
  `admin-users-enable` EFs (admin-tier, `user:update`/CA3; 401/403/404/422/409);
  login §1.4 business-Status gate (403 `account_disabled` after password verifies,
  before any 2FA; wrong-password on disabled stays 401, no leak).

## 1. BLOCKER — dev-2 unprovisioned (owner action)
`.secrets/slots/dev-2.env` = Jun-4 placeholder (`SUPABASE_URL=REPLACE_ME`, keys
REPLACE_ME, no DB password, no SUPABASE_ACCESS_TOKEN). `.secrets` is the shared
central-store symlink (single source of truth). dev-2 is absent from
README-slots' verified project-ref table (only dev-1/tester/investigator/sinuw
are live). dev-1 is provisioned but is dev-1's slot (off-limits). No spare exists.
→ Owner must stand up the dev-2 Supabase project + fill URL/anon/service-role/DB
password/SUPABASE_ACCESS_TOKEN (README §provisioning), OR reassign me to a
provisioned spare. Until then `supabase db push` + EF deploy + SQL-verify are
blocked. Everything else is done.

## 2. ⚑ FLAG (architect + tester) — session_id-keyed blacklist
Verified substrate (Supabase JWT Claims Reference + the custom_access_token_hook
claim pass-through): access tokens ALWAYS carry `session_id` (required claim) but
`jti` is OPTIONAL and NOT emitted on password+TOTP tokens. Both specs assume jti.
→ I keyed the blacklist on session_id (jti kept nullable/opportunistic). This
converges AUTH-008 onto the exact AUTH-012 §1.3 one-shape. Behavioural ACs all
hold. **Tester:** AC1/AC4 probes assert/insert on `session_id`, not `jti`.
Alternative (inject jti via the RLS hook) NOT recommended — cross-lane, high blast
radius; session_id already satisfies + is required for the 012 cut. Per the ⚑
"flag-to-architect, don't silently choose" convention.

## 3. Deploy-verify items owed (once dev-2 lands)
- All ACs (AUTH-008 AC1-4 + AUTH-012 AC1-4) per the PR checklist.
- **One new-territory item:** confirm the disable RPC can SELECT+DELETE
  `auth.sessions` as its SECURITY-DEFINER owner (postgres) on the live stack — no
  in-repo precedent for direct auth.* access; it's the documented force-logout
  technique but unverified here.

## Asks
- Provision dev-2 (or reassign) → I deploy+verify+append evidence+un-draft #445.
- Architect: ratify the session_id keying (or rule for the jti-hook).
- Reviewer: code review can start now on #445.

handled_at: 2026-06-12T19:35:00+07:00
handled_by: orchestrator-buildteam-wt26 (session_id->architect; code-review started; dev-2 provisioning->owner)
