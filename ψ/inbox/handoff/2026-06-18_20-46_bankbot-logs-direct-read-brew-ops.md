# Handoff → brew-ops: `/bankbot-logs` direct table read (drop the read EF)

**From:** next-ui · **Date:** 2026-06-18 · **Status:** requested by next-ui, **NEEDS OWNER SIGN-OFF** (reverses ratified §ADR-15 BL6)

Full spec already merged to the portal repo: `mb-next-admin-portal` → `docs/handoff-bankbot-direct-read.md` (PR #63, merge `375ff12`). This inbox note is the pickup pointer + summary.

## The ask
Switch portal `/bankbot-logs` from the `admin-bankbot-log` Edge Function to a **gated direct-read surface** (RLS), so it works like every other portal read (`v_clients` / `v_deposits` / `v_payouts_read` / `v_users` are all gated direct-read views). Bankbot is the lone EF-only exception today.

## ⚠️ Decision reversal — owner must approve first
EF-as-sole-read-path is ratified: `mb-next-payment-gateway` §ADR-15 §Amendment 2026-06-15 BL6/BL8 (owner-merge PR #506); portal req `docs/requirements/ui-bankbot-logs.md` says the page "never queries the RLS-locked table directly"; migration `20260616000060` deliberately `REVOKE ALL … FROM authenticated` citing "the retracted v_payouts engine-view leak." Reversing it is safe ONLY if the gate moves into the view body (v_clients pattern, not v_payouts). Get owner sign-off on the ADR change.

## What brew-ops does (gateway DB)
Objects already exist — no need to create:
- table `bankbot_activity_log` (`20260616000050…`, RLS-locked append-only)
- views `v_bankbot_activity_stream` + `v_bankbot_fleet_now` (`20260616000060…`, currently **service_role-only**)
- perm `bot-activity-log:view` (`20260616000070…`), bucket `bot-proof`
- gate helpers (STABLE, EXECUTE→authenticated, DB-fresh): `auth_aal2()`, `has_read_perm('…')`, `auth_db_is_admin()`

Steps:
1. **Gate + grant the two views** — re-define WITH `security_barrier = true`, add in-body gate `WHERE (SELECT auth_aal2()) AND (SELECT has_read_perm('bot-activity-log')) AND (SELECT auth_db_is_admin())`, keep `security_invoker=false`, then `GRANT SELECT … TO authenticated`. Mirror `20260611000300_entity_read_views_portal.sql` / `20260617000020_v_users_read_surface.sql` exactly. NOT a bare grant on an ungated view (= the leak). Base table stays zero-grant. Keep the filter/keyset columns working (eq bank_account_id/event_type/source/severity, gte/lte occurred_at, ilike detail_text, order occurred_at DESC,id DESC, keyset `before`, limit ≤500 — per EF `reads.ts`).
2. **Proof → keep the EF for `mode:"resolve_proof"` only** (a view can't sign a Storage URL; BOTLOG-005 needs the per-view audit). Alternative only if owner accepts losing the audit: storage RLS on `bot-proof` + client `createSignedUrl`. Recommended = keep EF.
3. **(optional) distinct event types** — gated `v_bankbot_event_types AS SELECT DISTINCT event_type …` (event_type is a fixed CHECK allowlist ~35 values), so the portal drops its 500-row sample.
4. **Realtime** — add `bankbot_activity_log` to the `supabase_realtime` publication (append-only → INSERT only).

## Acceptance
- admin WITH `bot-activity-log:view` reads both views directly (filters+keyset == EF today);
- authenticated WITHOUT the perm / non-AAL2 → **0 rows** (SQL test, like v_users gate tests);
- anon + base table stay locked, append-only intact;
- proof still resolves short-TTL signed (EF retained, or storage-RLS if owner OK);
- SQL tests beside `botlog_*_test.sql`.

## Portal follow-up (next-ui, after grants land)
Separate portal PR: `src/lib/monitoring-api.ts` swap `efPost(stream/fleet_now)` → `supabase.from('v_bankbot_activity_stream'/'v_bankbot_fleet_now')`; keep `resolveBankbotProof` on the EF; `readBankbotEventTypes` → distinct view if shipped; `bankbot-logs/page.tsx` subscribe to the table realtime instead of the `ts_deposits` proxy.

Refs: gateway `supabase/migrations/20260616000050/60/70…`, `20260615000010/20…`, `supabase/functions/admin-bankbot-log/{index,reads}.ts`, `docs/design/bankbot-activity-log/read-path-and-portal.md`.
