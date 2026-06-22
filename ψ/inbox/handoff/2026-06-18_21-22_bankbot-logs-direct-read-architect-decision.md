# Handoff → architect (via owner): `/bankbot-logs` direct-read — ADR-15 BL6-D reversal + rollout

**From:** brew-ops · **Date:** 2026-06-18 21:22 +07:00 · **Status:** NEEDS ARCHITECT DECISION before any DB work
**Upstream:** next-ui handoff `2026-06-18_20-46_bankbot-logs-direct-read-brew-ops.md` (spec `mb-next-admin-portal/docs/handoff-bankbot-direct-read.md`, PR #63 `375ff12`)
**Owner steer so far (2026-06-18):** "lock ด้วย RBAC, ให้ super_admin view ได้คนเดียว" — confirmed = the gated-projection mechanism (see §Owner steer). Owner wants architect sign-off before implementation.

---

## TL;DR
next-ui asks to move portal `/bankbot-logs` off the `admin-bankbot-log` read-EF onto **gated direct-read views** (like every other portal read). It is technically sound and mirrors a ratified, deployed pattern (`v_users` / `v_payouts_read`). **BUT it reverses ratified §ADR-15 BL6-D** (EF-as-sole-read-path) → needs architect/owner sign-off. brew-ops verified all claims and found **two rollout issues** the spec didn't account for (sequencing + realtime). Nothing has been built or deployed. This doc is the decision packet.

## The ask (from next-ui)
Switch `v_bankbot_activity_stream` + `v_bankbot_fleet_now` from **service_role-only** (read only via the EF) to **gated direct-read** (RLS gated-projection), so the portal reads them via PostgREST like `v_clients` / `v_deposits` / `v_payouts_read` / `v_users`. Bankbot is the lone EF-only read exception today. Keep the EF for `resolve_proof` only.

## Verified ground truth (brew-ops, 2026-06-18)
- ✅ Views are **service_role-only today**: `20260616000060_botlog_read_views.sql:99-102` — `REVOKE ALL … FROM PUBLIC, anon, authenticated; GRANT SELECT … TO service_role`.
- ✅ **§ADR-15 BL6-D is ratified** (owner-merge PR #506): *"Admin-only read via an EF, **not** a direct-table view."* BL8-D seeds RBAC `bot-activity-log:view` for `super_admin` only (`20260616000070`).
- ✅ Proposed pattern = **verbatim mirror** of the ratified `20260617000020_v_users_read_surface.sql`: `WITH (security_invoker=false, security_barrier=true)`, in-body gate `(SELECT auth_aal2()) AND (SELECT has_read_perm('…')) AND (SELECT auth_db_is_admin())`, `GRANT SELECT TO authenticated`, base table stays zero-grant. This is the SV7c-P1 / #412 gated-projection class — **NOT** the un-gated `v_payouts` leak class.
- ✅ **Proof is unaffected:** `admin-bankbot-log/index.ts` `resolve_proof` signs a **client-supplied `pointer`** via `createSignedUrl` — it **never reads the views**. Gating the views does not touch proof resolution.

## Why the reversal is defensible (architect's call)
The original EF-only lock (BL6-D) rested on two rationales; both are now satisfiable without the EF read path:
1. **"the retracted v_payouts engine-view leak"** (cited in `20260616000060`'s REVOKE) — that leak was an **un-gated owner-context view granted to authenticated**. The ratified fix for exactly that (SV7c-P1 → `v_payouts_read`) is the **gated-projection** pattern this proposal uses. So the leak rationale is addressed by the pattern itself.
2. **Proof signing** — only `service_role` can sign a private-bucket URL; a view cannot. **Preserved** by keeping the EF for `resolve_proof` only.

→ The change *aligns* bankbot with every other portal read surface; it does not re-open the leak. **But it is a ratified-ADR reversal, so it is the architect's decision, not brew-ops'.**

## Owner steer → how it maps
Owner: "lock with RBAC, super_admin sees it alone." This **is** the gated-projection: gate = `aal2 ∧ has_read_perm('bot-activity-log') ∧ auth_db_is_admin()`; `bot-activity-log:view` is seeded to `super_admin` only ⇒ **super_admin (2FA) sees rows; everyone else → 0 rows; anon + base table stay locked.** Granting another role later = one RBAC grant (the lock the owner described). `GRANT … TO authenticated` is only for PostgREST reachability; the in-body RBAC gate is the actual lock (not a bare grant on an un-gated view).

## ⚠️ Rollout findings (NOT in the spec — need a decision)

### Finding 1 — sequencing: gating the views breaks the EF read path
`admin-bankbot-log/reads.ts` reads both views as **service_role**. Once gated, the in-body helpers (which read the request JWT) return false for service_role ⇒ EF `stream`/`fleet_now` return **0 rows**. The live portal uses the EF until next-ui repoints. So deploying the gated views **before** the portal repoint = empty `/bankbot-logs` in the window.
- **1a. Coordinated cut-over** (deploy views + ship portal repoint together) — simple, clean gate, brief empty window. **Fine for staging.**
- **1b. Expand→contract** (temporary service_role allowance in the gate so EF + portal both work, removed in a follow-up migration) — zero downtime, slightly less pure, 2 migrations. **Recommended for the eventual prod cut.**
- `resolve_proof` is unaffected either way.

### Finding 2 — realtime (handoff step 4) won't work as written
Spec step 4: *"add `bankbot_activity_log` to `supabase_realtime` publication."* Realtime **Postgres-Changes enforces base-table RLS per subscriber** — the table is zero-grant/RLS-locked for `authenticated`, so the portal would receive **no events**. Just adding to the publication is insufficient.
- **2a. Drop realtime from this slice; keep polling** (portal re-fetches the view, as it does today). No security compromise. **Recommended** — ships the core value now.
- **2b. RLS read-policy + base-table grant** — enables realtime but **re-opens direct base-table read** (gated). A *bigger* reversal of BL6/SV7; separate sign-off + higher risk. **Not recommended.**
- **2c. Realtime Broadcast** (INSERT trigger → `realtime.broadcast_changes` + channel authz) — correct modern pattern for an RLS-locked table; a separate design slice.

## Proposed migration shape (if approved — NOT yet written)
One migration `20260618xxxxxx_botlog_gated_read_views.sql` + one pgTAP test:
- re-define `v_bankbot_activity_stream` + `v_bankbot_fleet_now` `WITH (security_invoker=false, security_barrier=true)`, same column/keyset contract (per `reads.ts`), add the in-body gate; `GRANT SELECT TO authenticated`; **base table untouched**; perm already seeded (no re-seed).
- pgTAP (mirror `v_users_read_surface_test.sql`): super_admin+aal2 → rows; no-perm / non-admin / non-aal2 → 0 rows; anon → denied; base table stays unreadable.
- **realtime excluded** (Finding 2).
- PR for owner/reviewer review; **never auto-merge**; staging-first via workflow-7 migration substrate, coordinated with next-ui's portal repoint.

## OPEN DECISIONS FOR ARCHITECT
1. **Approve reversing §ADR-15 BL6-D** (EF-sole-read → gated direct-read views, EF retained for `resolve_proof`)? Record as an ADR-15 amendment if yes.
2. **Sequencing (Finding 1):** staging via 1a coordinated cut-over OK? Build prod-path as 1b expand→contract?
3. **Realtime (Finding 2):** confirm **2a drop-realtime / keep-polling** for this slice (and 2c as a later separate slice if live-update is wanted)? Reject 2b?
4. **RBAC scope:** keep `bot-activity-log:view` → `super_admin` only (owner's steer), or any plan to extend to other admin tiers?

## References
- gateway: `supabase/migrations/20260616000050/60/70_botlog_*.sql`, `20260617000020_v_users_read_surface.sql` (pattern), `20260611000300_entity_read_views_portal.sql`; `supabase/functions/admin-bankbot-log/{index,reads}.ts`; `docs/adr.md` §ADR-15 BL6-D/BL8-D + SV7c / SV7c-P1; `docs/design/bankbot-activity-log/read-path-and-portal.md`; tests `supabase/tests/v_users_read_surface_test.sql` + `botlog_bankbot_activity_log_test.sql`.
- portal: `mb-next-admin-portal/docs/handoff-bankbot-direct-read.md` (PR #63 `375ff12`); follow-up `src/lib/monitoring-api.ts` + `bankbot-logs/page.tsx`.
- upstream inbox: `2026-06-18_20-46_bankbot-logs-direct-read-brew-ops.md`.
