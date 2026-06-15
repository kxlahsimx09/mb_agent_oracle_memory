---
title: Supabase deploy mechanics: apply ONE migration (not the whole pending set) + HOL
tags: [brew-ops, repo:mb-next-payment-gateway, supabase, migrations, db-push, schema-migrations, deploy, investigator-ro, pooler, gotcha]
created: 2026-06-13
source: brew-ops authviewdrop APPLY, thread #16 msg 423, 2026-06-13
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Supabase deploy mechanics: apply ONE migration (not the whole pending set) + HOL

Supabase deploy mechanics: apply ONE migration (not the whole pending set) + HOLD an unwanted pending migration so `supabase db push` skips it.

Tags: #brew-ops #repo:mb-next-payment-gateway #supabase #migrations #deploy #db-push #gotcha

**Problem (authviewdrop APPLY, 2026-06-13):** owner GO to apply ONLY migration 020 to sinuw, but migration 030 (sitting in main, pending) must NOT apply. `supabase db push` applies ALL pending migrations (anything whose version isn't in `supabase_migrations.schema_migrations`) — so a plain `db push` would have applied 030 too.

**Technique:**
1. **Apply one migration without db push:** `git show origin/main:supabase/migrations/<file>.sql | psql -v ON_ERROR_STOP=1 -f -` (admin connection: `PGUSER=postgres.<ref> PGPASSWORD=<slot SUPABASE_DB_PASSWORD>` over the IPv4 session pooler). This runs exactly that file.
2. **Record it applied:** `INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES('<version>','<name>', ARRAY['-- note']) ON CONFLICT(version) DO NOTHING;` — so a later `db push` skips it (no re-churn). schema_migrations cols = (version, name, statements text[]); db push decides skip on `version` presence only.
3. **HOLD an unwanted pending migration:** insert ITS version into schema_migrations too (with a clear `statements` marker that it was held, NOT run) → `db push` skips it → its SQL never auto-fires. This is the standard Supabase migration-skip. ⚠️ It makes schema_migrations claim "applied" while the schema doesn't reflect it — document the skip + prefer a **repo revert** of the held migration as the durable fix (a dangling pending-but-held file is audit-confusion + re-leak risk).

**Connect AS a custom role (e.g. investigator_ro) via the pooler:** username = `<role>.<project-ref>` (Supavisor format), e.g. `investigator_ro.sinuwgsqqyqzlpaavimf`. The role's connection URL was in `investigator.env` as `SINUW_RO_DB_URL`. Owner-context views (`security_invoker=false`) let such a role read a secret-free projection while it has ZERO direct `auth.*` access (`permission denied for schema auth`) — verified live.

---
*Added via Oracle Learn*
