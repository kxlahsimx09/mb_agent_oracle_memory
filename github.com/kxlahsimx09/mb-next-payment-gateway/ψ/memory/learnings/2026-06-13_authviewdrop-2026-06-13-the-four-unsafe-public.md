---
title: authviewdrop (2026-06-13): the four unsafe `public.v_auth_*` bridge views were A
tags: [brew-ops, repo:mb-next-payment-gateway, supabase, db-admin, auth, security, v-auth-views, p-004, slot-map, pooler, gotcha]
created: 2026-06-13
source: brew-ops authviewdrop campaign, thread #16, 2026-06-13
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# authviewdrop (2026-06-13): the four unsafe `public.v_auth_*` bridge views were A

authviewdrop (2026-06-13): the four unsafe `public.v_auth_*` bridge views were ALREADY ABSENT on both gateway stacks — owner-ordered DROP was a confirmed no-op. + reusable admin-DDL connection recipe for mb-next Supabase stacks.

Tags: #brew-ops #repo:mb-next-payment-gateway #supabase #db-admin #auth #security #gotcha #p-004

**Outcome (P-004 — live DB beats grep):** orchestrator dispatched a capture-then-DROP of `v_auth_mfa_factors/v_auth_users/v_auth_sessions/v_auth_mfa_amr_claims` on sinuw + qnccph, premise = "PM 2026-06-13 grep proves the 2026-06-12 teardown never executed → views still standing." Live query showed **0 of the 4 on BOTH stacks**, and **no view anywhere** (sinuw, qnccph, dev-1, tester) whose definition references `auth.(mfa_factors|users|sessions|mfa_amr_claims)` / `encrypted_password|totp|secret`. The PM "grep" was a REPO/inference check (no DROP migration in-repo), NOT a live-DB query → false "standing". Ran idempotent `DROP VIEW IF EXISTS` anyway (all "skipping"); `auth.*` untouched; `investigator_ro` role left intact (exists on sinuw; does NOT exist on qnccph). CAPTURE recovery artifact = N/A (nothing to pg_get_viewdef). Always live-verify a teardown premise before capture/drop.

**Admin-DDL connection recipe (mb-next gateway Supabase stacks), no secrets:**
- Slot→ref map (README-slots.md, all ap-southeast-1): sinuw=`sinuwgsqqyqzlpaavimf` (staging.env), qnccph=`qnccphgykzdydebmdwdf` (investigator.env), dev-1=`qvmjywljrgqzyxshexhx` (dev-1.env), tester=`yupsevcrubgprsbujbpu` (tester.env). next-ui.env shares sinuw's ref but has NO DB password (login-only).
- Connect (admin/DDL): `PGHOST=aws-1-ap-southeast-1.pooler.supabase.com PGPORT=5432 PGDATABASE=postgres PGUSER=postgres.<ref> PGPASSWORD=<slot's SUPABASE_DB_PASSWORD> psql` — IPv4 **session** pooler (port 5432, NOT 6543 transaction pooler — DDL needs a session). The `postgres` role is super=false but owns public objects → can DROP/REVOKE them. Source the slot env (`set -a; . slot.env; set +a`); pass the password via `PGPASSWORD` env, never on the command line / never echo it.
- **Gotchas:** (1) slot env var name for the ref is inconsistent — `staging.env` has `SUPABASE_PROJECT_REF`, but dev-1/dev-2/tester/investigator slots do NOT → use the README-slots.md map. (2) **dev-2's project ref is MISSING from the slot-map README** — recurring "slot-map gotcha", needs filling. (3) macOS default `/bin/bash` is 3.2 — fine for psql; unrelated to the gateway but note the homebrew-bash requirement for scripts using `declare -A`.

---
*Added via Oracle Learn*
