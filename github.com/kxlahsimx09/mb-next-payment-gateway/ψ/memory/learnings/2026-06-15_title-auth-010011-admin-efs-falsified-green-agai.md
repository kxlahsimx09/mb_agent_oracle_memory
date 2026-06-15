---
title: title: AUTH-010/011 admin EFs falsified GREEN against deployed staging ground-tr
tags: [next-investigator, auth010, auth011, falsification, staging-ground-truth, rbac]
created: 2026-06-15
source: next-investigator buildgap falsification 2026-06-15
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: AUTH-010/011 admin EFs falsified GREEN against deployed staging ground-tr

title: AUTH-010/011 admin EFs falsified GREEN against deployed staging ground-truth (2026-06-15)

Falsification of the as-deployed admin AUTH-010 (client-key rotate/revoke/retire) + AUTH-011 (set-user-role) behavior on the LIVE staging stack `sinuwgsqqyqzlpaavimf` (NOT the seal stack — see access caveat). buildgap-team member under slug buildgap; read-only; no deploy/mutate.

GROUND-TRUTH ACCESS USED (all read-only): staging.env slot (SUPABASE_URL + ANON + SERVICE_ROLE + ACCESS_TOKEN), the deployed EFs over HTTPS, and the Supabase Management API db/query (`pg_proc.prosrc`, information_schema, role_permissions, audit_log, schema_migrations ledger) — i.e. the TRUTH DB, not harness flags.

CONFIRMED (no contradiction found — actively hunted):
- AC4 (deployed EF over wire): all 4 admin EFs ACTIVE, verify_jwt=false, version=1, updated 2026-06-15T05:40Z. No-bearer / apikey-only -> 401 missing_bearer_token (matches prior smoke). Bearer=anon JWT -> 401 invalid_token. Forged HS256 aal2 JWT -> 401 invalid_token (no RBAC bypass via crafted aal2 claim). GET -> 405 method_not_allowed (proves real handler, not a 404 stub).
- Migrations APPLIED on staging: client two-slot columns (retiring_api_key / retiring_api_key_secret / retire_at) present; api_key.is_nullable=YES (the AUTH-010 DROP NOT NULL applied, enabling revoke). RPCs rotate_client_key / revoke_client_key / retire_client_key / admin_set_user_role all present with correct signatures. Ledger has 030/040/050 (admin set).
- Deployed RPC BODY fingerprints (prosrc on staging): rotate_client_key demotes active->retiring + make_interval overlap + api_key_rotate audit + no_active_key guard; admin_set_user_role has last_super_admin + cannot_demote_self + invalid_role guards. write_audit_log primitive present.
- RBAC truth-data: role_permissions seed grants client:update + user:update to super_admin ONLY; client_admin has NEITHER -> a verified client_admin JWT provably cannot pass requirePermission -> the EF 403s. RPC EXECUTE granted to postgres+service_role only (anon/authenticated/public revoked).

NOT INDEPENDENTLY VERIFIABLE read-only (routes to fleet next-investigator/owner holding seal-stack write creds):
- The literal 403 over the wire for a REAL client_admin gotrue aal2 JWT — needs minting a client session (password/login = owner-held); falsified at the data layer instead (client_admin lacks the verb).
- The two-slot OVERLAP + revoke-immediate + audit-ROW runtime path: zero api_key_rotate/revoke/retire/user_role_change rows exist on staging yet (EFs just deployed, unexercised) — proving the data path requires INVOKING the RPC, which mutates. Out of read-only scope; run on the seal stack by the credentialed investigator.

NUANCE (not a contradiction): the Phase-2 client SELF-SERVICE layer (migration 20260615000060 seed + client:rotate-own-key/revoke-own-key verbs) is on the unmerged branch buildgap/auth010-client-selfservice and is NOT on staging (ledger 060 absent, role_permissions has no own-key verbs). Staging = admin-only set, exactly as deployed. The handoff-inverted self-service is a separate, not-yet-deployed slice.

VERDICT: ground-truth does NOT contradict any claimed admin AUTH-010/011 behavior. reopen=false. Two runtime depths (live 403 + audit-row overlap) remain UNVERIFIABLE read-only and route to the credentialed investigator/owner — not a falsification, an access boundary.

tags: next-investigator, repo:mb-next-payment-gateway, next, verify, auth010, auth011, v1, falsification, buildgap
source: deployed staging sinuwgsqqyqzlpaavimf + branch buildgap/auth010-client-selfservice @ e30410f

---
*Added via Oracle Learn*
