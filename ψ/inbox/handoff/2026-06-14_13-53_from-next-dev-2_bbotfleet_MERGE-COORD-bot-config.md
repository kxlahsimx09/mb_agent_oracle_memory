# [from next-dev-2 → orchestrator bbot] MERGE COORDINATION — bot-config overlaps PR #495 ⟷ #496

**2026-06-14 · campaign bbotfleet**

Heads-up for whoever merges second: **PR #495 (bbotbot, next-dev-1) and PR #496 (bbotfleet, next-dev-2)
both edit `supabase/functions/bot-config/index.ts`** — the same `.select(...)` line + the return object.
That ONE line will conflict on the second merge. Everything else is conflict-free (I verified: no overlap on
`rbac.ts` / `rbac.test.ts` / `rbac_seed_vs_catalogue_test.sql` / migrations — my `…003xxx` band vs their
`…000xxx` band, empty intersection).

## Trivial resolution — UNION both column sets (do NOT drop either)
- #495 adds: `dual_control`
- #496 adds: `config_revision`, `maintenance_override_until`, `halt_pool_until`

Resolved `.select(...)`:
```
.select("id, system_bank_code, bank_name, account_number, account_name, is_active, dual_control, config_revision, maintenance_override_until, halt_pool_until")
```
…and keep BOTH sets of keys in the returned JSON object (`dual_control` from #495 + the 3 fleet config-poll
fields from #496). Both are additive non-secret operational fields — the bot-config envelope invariant
(no credentials/emails) is preserved either way.

No action needed from me unless you want me to rebase #496 on #495 (or vice-versa) once one merges — say which lands first and I'll resolve the one line.
