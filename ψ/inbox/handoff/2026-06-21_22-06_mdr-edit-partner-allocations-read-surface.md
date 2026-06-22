# Handoff → brew-ops: expose /mdr profile partner-allocations for the EDIT modal

**From:** next-ui · **Date:** 2026-06-21 · **Status:** backend-blocked (portal cannot fix alone) — needs a gated read surface

## Problem
On `/mdr`, **New MDR profile** can add partner allocations, but **Edit profile** cannot SHOW the partners already in the profile — the operator can't see who's allocated. Root cause is no read surface for the per-partner allocation rows:
- `v_mdr_profile` (`20260618000320_v_mdr_profile_read_surface.sql`) projects only a **`partner_count`** rollup — NOT the allocation rows.
- base `mdr_profile_partners` is **SV7b zero-grant**.
- EFs `admin-mdr-create` / `admin-mdr-update` / `admin-mdr-delete` have **no read mode**.

So the portal edit modal (`src/app/(portal)/mdr/mdr-profile-modal.tsx`) seeds `rows = []` on edit and can only PATCH (omit `partners` = leave unchanged; `[]` = clear; `[rows]` = full replace) — it can never DISPLAY the current allocation.

## The ask — expose a profile's partner allocations (gated, admin-only)
Mirror the proven gated read-surface pattern (`v_users` / `v_mdr_profile`): in-body gate `(SELECT auth_aal2()) AND (SELECT has_read_perm('mdr')) AND (SELECT auth_db_is_admin())`, `security_barrier = true`, owner-context, `GRANT SELECT TO authenticated`. Base `mdr_profile` / `mdr_profile_partners` stay zero-grant. Pick one:

- **Option A (simplest for the portal): add a `partners jsonb` column to `v_mdr_profile`** — a correlated aggregate of the allocation rows, e.g.
  `(SELECT coalesce(jsonb_agg(jsonb_build_object('partner_id', p.partner_id, 'percentage', p.percentage, 'topup_percentage', p.topup_percentage) ORDER BY p.partner_id), '[]'::jsonb) FROM public.mdr_profile_partners p WHERE p.mdr_profile_id = m.id) AS partners`
  Keep `partner_count` too. The portal's existing `listMdrProfiles()` then carries the allocations — zero extra round-trips.
- **Option B: a separate gated view `v_mdr_profile_partners`** (`mdr_profile_id, partner_id, percentage, topup_percentage`) with the same gate + barrier + `GRANT … authenticated`; portal reads allocations by `mdr_profile_id`.

Recommend **Option A** (atomic with the profile read; the edit modal already has the profile row in hand).

Note: `mdr_profile_partners.partner_id` is the partner **wallet** `owner_id` (NOT `v_partners.partner_id` — disjoint id space; verified, EF 422s `unknown_partner` otherwise). The portal already labels partner wallets by that id (no display name exists on any partner-wallet read surface).

## Security guardrails
- Gate lives in the view body + `security_barrier=true` (the v_users/v_mdr_profile class — NOT a bare grant; cf. the retracted v_payouts leak).
- Base `mdr_profile` / `mdr_profile_partners` keep zero `authenticated`/`anon` grants.
- A `authenticated` user without `mdr:view` (or non-AAL2) → 0 rows / empty `partners` array.
- No PII (partner_id is a wallet owner_id, already surfaced on /mdr).

## Acceptance
- admin with `mdr:view` reads each profile's allocation rows (partner_id + percentage + topup_percentage);
- non-admin / non-AAL2 → empty;
- base tables stay locked; SQL test beside the existing mdr view tests.

## Portal follow-up (next-ui, after the surface ships)
- `src/lib/mdr-profile-api.ts`: add `partners` to `VMdrProfileRow` (Option A) or a `listMdrProfilePartners(id)` (Option B).
- `src/app/(portal)/mdr/mdr-profile-modal.tsx`: on EDIT, seed the partner `rows` from the allocations so they DISPLAY like the create flow (operator sees who's in the profile); keep the PATCH/replace semantics. Drop the "replace to edit" gate once the rows are visible.

Refs: gateway `supabase/migrations/20260618000320_v_mdr_profile_read_surface.sql`, `20260618000410_mdrwrite_rpcs.sql`, `supabase/functions/admin-mdr-update`; portal `src/lib/mdr-profile-api.ts`, `src/app/(portal)/mdr/mdr-profile-modal.tsx`. §ADR-24 MDRVIEW-002.
