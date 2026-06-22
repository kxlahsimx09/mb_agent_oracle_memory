# Handoff → [brew-ops, next-ui] — partnerguard MDRWRITE-005 BUILD-COMPLETE, deploy-ordering CRITICAL

**From:** next-pm (campaign partnerguard, orchestrator #51 item (2): MDR allocation requires partner_profile)
**Date:** 2026-06-22
**Status:** MDRWRITE-005 **BUILD-COMPLETE — merged @ `6a1ee2ac` (PR #722)** → main. Reviewer APPROVE. **NOT epic-DONE** — awaiting staging deploy + live VERIFY.

## What the guard does
Migration `20260624000300_partnerguard_mdr_require_partner_profile.sql` does a `CREATE OR REPLACE` of the **2-arg `_mdr_validate_partners`** helper (shared by both `admin_create_mdr_profile` and `admin_update_mdr_profile`), adding an `EXISTS(partner_profiles WHERE is_archived = false)` check on each allocated partner wallet's resolved owner. Orphan (no `partner_profiles` row) or archived (`is_archived = true`) ⇒ raise → mapped to error code **`unprofiled_partner`**. Both EFs `admin-mdr-create` / `admin-mdr-update` map it to **HTTP 422**. Test seed fixed; pgTAP `mdr_profile_write_surface_test.sql` plan **62 → 69**.

Enforces the already-shipped prov003 id-unification invariant (`partner_id` unified across `partner_profiles`/`wallet`/`mdr_profile_partners`). No new ADR.

---

## brew-ops — CRITICAL DEPLOY ORDERING ⚠️

The guard migration `20260624000300` **MUST be deployed PAIRED-WITH or AFTER item-#1** (the data remediation), NEVER before:

1. **Item #1 first (or same deploy):** Backfill `partner_profiles` for the ~30 existing staging orphan partner wallets (re-provision via `provision_partner`), AND quarantine/fix the **MDR test profile currently allocated to 2 orphan wallets**.
2. **Why ordering matters:** If the guard lands FIRST on staging, the **next full-replace UPDATE** of that existing MDR test profile will be rejected (`unprofiled_partner`) because its current allocations point at orphan wallets — this breaks the edit path for already-saved data.

**Shared deploy queue — coordinate ordering with the other pending migrations:**
- `20260624000000` MDR view fix (commit `9bf1c884`)
- `20260624000200` system-bank effective-status view (commit `fa16f2a5`)
- `20260624000300` ← this guard (timestamp is unique + highest in the 20260624 series, monotonic increasing)

**VERIFY:** run pgTAP `supabase/tests/mdr_profile_write_surface_test.sql` (**plan 69**) post-deploy. Confirm `unprofiled_partner`/422 on orphan + archived allocation, and that legit (profiled, non-archived) allocations still pass.

---

## next-ui (mb-next-admin-portal) — item #3, AFTER #1/#2

Once wallets ↔ partner_profiles are linked (item #1 backfill complete), update the portal:
- MDR partner **picker** + **EntityCell**: show partner `display_name` instead of the raw wallet id.
This is gated on #1 (the link/backfill) and the deploy — do not start until allocations resolve to real profiles.

---

## Out-of-scope follow-up (owner's call)
The `create_settlement` **partner-self** path is a separate, out-of-scope surface that may also warrant an analogous partner-profile guard. Flagging as a possible separate follow-up — not part of this campaign. Owner decides.

## Refs
- PR #722 (`6a1ee2ac`) build · PR #723 docs status flip · requirement `docs/requirements/epic-mdr-profile-write.md` MDRWRITE-005 · reqgap `ψ/inbox/handoff/2026-06-21_00-29_reqgap-partner-profiles-vs-wallets-disconnect.md` item #2.
