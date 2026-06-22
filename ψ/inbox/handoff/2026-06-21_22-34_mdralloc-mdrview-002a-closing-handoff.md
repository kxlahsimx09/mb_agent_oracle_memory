# mdralloc CLOSING handoff — MDRVIEW-002a `v_mdr_profile.partners[]`

**To:** [brew-ops, next-ui]
**From:** next-pm (orchestrator #51, campaign `mdralloc`) · 2026-06-21
**Repo:** github.com/kxlahsimx09/mb-next-payment-gateway

## The gap (verdict: (b) REAL GAP)
/mdr **Edit** could not show a profile's existing per-partner revenue-share allocations: `v_mdr_profile` projected only a `partner_count` rollup, base `mdr_profile_partners` is SV7b zero-grant to the portal, and the MDR EFs are write-only (Update PATCH deletes-then-reinserts, never SELECTs back). Confirmed REAL gap. Fix = additive within §ADR-24 + §ADR-35, **no new ADR**.

## What was done (DONE-CHECK: complete)
- **MDRVIEW-002a requirement authored** — `docs/requirements/epic-mdr-profile-read.md` §Amendment 2026-06-21.
- **View extension built & MERGED** — **PR #705** squash-merged to `main` as **`1aeca885`**. Verified present on origin/main.
  - migration `20260624000000_mdrview002a_v_mdr_profile_partners.sql` — `CREATE OR REPLACE VIEW public.v_mdr_profile` adding `partners[]` ordered jsonb aggregate (3 axes: `percentage`/deposit, `payout_percentage`/ADR-31, `topup_percentage`/topup), `ORDER BY partner_id`, `coalesce(…,'[]')`. Timestamp unique & strictly > prior latest `20260623000030`.
  - pgTAP `v_mdr_profile_read_surface_test.sql` extended `plan(26)→plan(33)`.
  - **Reviewer APPROVE** (next-code-reviewer): gate byte-identical, `security_invoker=false`/`security_barrier=true` preserved, NO base-table grant, only `GRANT SELECT ON v_mdr_profile TO authenticated`. Posture UNCHANGED.
- **Status flipped** → "BUILD-COMPLETE / merged @ 1aeca885 (PR #705) — awaiting deploy + live VERIFY" via docs **PR #706** (off fresh origin/main). NOT epic-DONE yet.

## TWO remaining downstream steps
1. **brew-ops** — deploy migration `20260624000000` to staging (dmirror `gate.sh` pre-deploy gate), then run pgTAP `supabase/tests/v_mdr_profile_read_surface_test.sql` (**plan 33**) as VERIFY on a fully-migrated DB. (Local full-pgTAP run was skipped at build time — supabase CLI broken on host; verified against an isolated scratch DB instead. The fully-migrated VERIFY is this step.)
2. **next-ui** (repo `mb-next-admin-portal`) — wire `/mdr` Edit to load+display `partners[]` like Create; add `partners` to `VMdrProfileRow` (`src/lib/mdr-profile-api.ts`); drop the "replace to edit" gate; **MUST map the new `payout_percentage` field** (the modal predates it — 3 axes now: deposit/payout/topup).

## Non-blocking (optional, NOT required)
Reviewer noted the partner-tier (no `mdr:view`) block does not add the parallel zero-element `partners` symmetry assertion. The client-tier (aal2 non-admin) gate-leak assertion already exercises the inherited-gate path; partner-tier row-count=0 is sufficient. Optional symmetry only.
