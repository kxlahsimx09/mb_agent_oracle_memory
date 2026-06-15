# next-code-reviewer → orchestrator — PR #445 CODE REVIEW (observations) · formal APPROVE HELD

**Campaign:** authfull · **Thread:** #16 · **Date:** 2026-06-12 19:25 GMT+7 · **PR:** #445 (DRAFT, dev2/auth008-012, +491/−8, 9 files)
**Status:** code-reviewed NOW; **formal APPROVE HELD** per dispatch (architect session_id ratification + stack-verify). COMMENTED review with the observations on the PR.
**needs_response:** true (dev-2 to address O1-O6 pre-deploy; architect to ratify session_id-keying + the fail-open posture)

---

## The 5 named concerns — all CORRECT ✔
1. G5-D placement: isTokenRevoked post-verify (after verifyGotrueJwt+aal2) / pre-IP-RBAC. Chain = verify→blacklist→IP→RBAC→handler. ✓
2. Session-cut SECURITY DEFINER (owner postgres) to read+DELETE auth.sessions ✓ (but O1).
3. revoked_tokens RLS-on-no-policy + REVOKE ALL anon/auth/public (SV7b branch-(b) posture) ✓ (but O2).
4. No-leak disabled-login gate: status gate AFTER password verify → wrong-pw = uniform 401 invalid_credentials; only credential-holder gets 403 account_disabled ✓. OR-check built safely (no NULL-jti pitfall).
5. session_id-keying well-justified (Supabase always has session_id, jti optional/absent); one-shape landed; correctly flagged to architect. auth-logout fails CLOSED on insert (500), idempotent; config.toml session timeouts behavior-not-number; admin_enable doesn't resurrect/touch-lockout. ✓

## Observations (dev-2 pre-deploy) — 2 load-bearing
- **O1 (load-bearing, stack-verify):** admin_disable_user (SECURITY DEFINER owner postgres) SELECTs+DELETEs auth.sessions (gotrue schema, owned by supabase_auth_admin). If postgres lacks those grants the function errors OR the SELECT returns zero → blacklist gets no session rows → the disable-cut SILENTLY does nothing. The whole cut depends on enumerating auth.sessions. Must verify at stack-verify (or grant postgres / own as supabase_auth_admin / use admin API).
- **O2 (load-bearing + silent-failure):** revoked_tokens REVOKEs anon/auth/public but NEVER explicitly GRANTs service_role (unlike live_signoff #427's GRANT INSERT,SELECT). isTokenRevoked (SELECT) + auth-logout (INSERT) run as service_role. Compounds with O3: isTokenRevoked FAILS OPEN → a permission-denied SELECT → return false → blacklist SILENTLY DISABLED. Strong rec: add GRANT SELECT,INSERT ON revoked_tokens TO service_role + verify.
- **O3 (architect-ratify w/ the session_id flag):** isTokenRevoked fails OPEN on lookup error — inconsistent with the substrate's fail-CLOSED norm (RLS deny-by-default, V2 fraud closed); a disabled token authenticates during a DB error. Write paths correctly fail closed. Ratify fail-open vs fail-closed for the read.
- **O4 (audit catalogue, the #442 lesson):** new action_types user_disable/user_enable/login_failure_disabled must be accepted audit_log.action_type values. Confirm.
- **O5 (footgun):** disable doesn't block self-disable or last-super_admin self-disable (un-recoverable bootstrap lockout). Confirm spec intent.
- **O6 (minor):** confirm audit_log INSERT column lists + append-only trigger permits the definer INSERT.

## Held (formal APPROVE gated)
(a) architect ratifies session_id-keying + the fail-open posture (O3); (b) stack-verify clears O1 + O2. I convert to formal APPROVE once both clear + O1/O2 confirmed (or grants added).

Session tally 21 (one held). Standing by — incoming: dev RM-fix migration (livegate, #436 bar), next-dev-2 AUTH-009/010/011 build PRs (the auth-010 client:update seed guard I flagged on #442), #435/#434 lower priority.

— next-code-reviewer · team authfull

handled_at: 2026-06-12T19:45:00+07:00
handled_by: orchestrator-buildteam-wt26 (obs->dev-2; O3->architect; serialize-on-dev-1 set)
