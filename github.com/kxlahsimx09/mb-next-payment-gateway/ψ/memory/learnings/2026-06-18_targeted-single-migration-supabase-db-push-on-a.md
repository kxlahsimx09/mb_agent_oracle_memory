---
title: TARGETED single-migration `supabase db push` on a SHARED stack — when N migratio
tags: [supabase, db-push, migrations, shared-stack, targeted-deploy, edge-functions, go-live, deploy, session-pooler, schema_migrations]
created: 2026-06-18
source: brew-ops campaign capistaging — CLIREAD staging go-live
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# TARGETED single-migration `supabase db push` on a SHARED stack — when N migratio

TARGETED single-migration `supabase db push` on a SHARED stack — when N migrations are pending but only 1 is yours.

CONTEXT (campaign capistaging, 2026-06-19, sinuw staging ref sinuwgsqqyqzlpaavimf): manual deploy of the CLIREAD build (PR #610, migration 20260619000100). Brief said "db push the CLIREAD migration, TARGETED, do NOT push-all (sinuw is shared)". But `supabase migration list` showed SIX pending migrations, not one — CLIREAD plus 5 from OTHER in-flight campaigns (20260618000320 v_mdr_profile_read, 20260618001000/1010/1020/1030 prov002/003/005/006 from PR #605).

GOTCHA: `supabase db push` has NO per-file selector. It applies ALL pending (or all newer-than-remote-tip without `--include-all`). On a shared stack that silently deploys other campaigns' un-authorized migrations = a push-all by accident.

SOLUTION (clean, reversible): temporarily move the non-yours pending migration files OUT of supabase/migrations/ to a /tmp holding dir, `db push --dry-run` to PROVE only yours remains pending, then `db push --yes`, then move the held files BACK and `git status` to confirm the worktree is clean. The blessed CLI path records version+name+statements in schema_migrations exactly as the auto-trigger would — no hand-crafted schema_migrations row needed. Afterward verify with psql that the 5 others are still NOT in schema_migrations.

MECHANICS that worked: session pooler host aws-1-ap-southeast-1.pooler.supabase.com :5432 (aws-0 refused), user=postgres.<REF>, URL-encode password via python urllib.parse.quote. db push needs only DB password (not the PAT); functions deploy needs SUPABASE_ACCESS_TOKEN (now in staging slot). export SUPABASE_GO_BINARY=/home/ubuntu/.local/share/supabase/supabase-go available if the shim errors (not needed this run). "Docker is not running" warning on functions deploy is benign — CLI bundles server-side.

ASSERT go-live without the whole-stack assert (which FAILs on unrelated rbac/seed drift on shared sinuw — expected): probe each EF over HTTP and confirm it returns its OWN JSON, not the platform 404 {"code":404,"message":"Requested function was not found"}. client-deposit-status/<random-uuid> → 404 deposit_not_found (EF-404 = code ran the RPC); client-bank-codes → 401 missing_x_client_id. All 7 CLIREAD EFs verified live.

---
*Added via Oracle Learn*
