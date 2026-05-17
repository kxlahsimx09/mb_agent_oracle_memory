---
title: gotcha — renumbering an already-pushed Supabase migration's version prefix is a 
tags: [next, drift, gotcha, supabase, migration, db-push, version-collision]
created: 2026-05-17
source: next-impl, thread #128
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# gotcha — renumbering an already-pushed Supabase migration's version prefix is a 

gotcha — renumbering an already-pushed Supabase migration's version prefix is a `db push` trap

**Symptom:** A new migration file is silently skipped by `supabase db push` — no error, no diff, exit 0 — yet its DDL never reaches the remote.

**Root cause:** `db push` decides what to apply by comparing local migration *version prefixes* against the remote `supabase_migrations.schema_migrations` history. If you renumber a migration that was *already pushed* (its old prefix is recorded remotely) and then a different/new file lands at that same now-"freed" prefix, `db push` sees the prefix already in remote history and treats the new file as already applied. It skips it silently.

**Concrete instance (thread #128, 2026-05-16):** commit `f8e4ce2` renumbered a migration onto prefix `20260516000001`; `adr4a_review_rename` then occupied the collided prefix and `db push` silently skipped it. The rename DDL never ran on substrates that had the pre-renumber file.

**Detection:** Don't trust `db push` exit code. Verify the schema actually changed — `supabase db dump` (or query the target table/enum directly) and confirm the renamed/added object exists.

**Fix:** `supabase migration repair --status reverted <colliding-prefix>` to clear the stale remote history row, then `supabase db push --include-all` to re-apply.

**Latent-drift warning:** any other substrate that pulled the pre-renumber file before the renumber will silently miss the new migration at that prefix. It needs the same repair + `db push --include-all`. Transient dev worktrees retired by a sweep are moot; only substrates still in rotation matter.

**Rule:** never renumber the version prefix of a migration that has already been pushed anywhere. If a prefix must change, treat it as a new migration + an explicit repair of the old prefix — never a silent reuse.

---
*Added via Oracle Learn*
