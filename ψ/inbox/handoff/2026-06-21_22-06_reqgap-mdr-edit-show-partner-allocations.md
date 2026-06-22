# Requirement gap (for PM): /mdr Edit profile doesn't show its partner allocations

**Raised by:** next-ui · **Date:** 2026-06-21 · **Area:** Admin portal `/mdr` (MDR fee-rate profiles) · **Type:** functional gap, **backend-dependent**

## The gap (current vs expected)
- **Expected:** Opening **Edit** on an MDR profile should show the partner revenue-share allocations already in that profile (which partners, and each one's deposit/payout % + topup %) — the same allocation editor the **New MDR profile** flow shows.
- **Current:** Edit shows the profile's name + fees + a partner **count only**. It cannot list the actual partners. The allocation editor starts **empty** and only appears if the operator opts into "replace all partners" — so an operator literally cannot see who is in a profile, and can only blind-replace.

## Operator impact
- No way to review/audit a profile's current revenue-share split before changing it.
- Editing is risky: to change one partner you must re-enter the entire allocation from scratch (blind replace), or leave it untouched. Easy to wipe or mis-set partner shares.
- Inconsistent UX between Create (can see/add partners) and Edit (cannot see them).

## Root cause (why it can't be fixed in the portal alone)
The portal has **no data source** for a profile's per-partner allocations:
- the `/mdr` read view exposes only a partner **count**, not the allocation rows;
- the underlying allocation table is locked (zero-grant) to the portal;
- the MDR write EFs have create/update/delete only — no "read allocations" capability.

The Create flow works because it only *adds* new rows (never reads existing ones). Edit needs to *read* the existing rows, and that read surface does not exist yet.

## What's needed (requirement level)
A **read surface that returns each MDR profile's partner allocations** (partner + deposit/payout % + topup %), admin-gated under the existing `mdr:view` permission (same access posture as the rest of `/mdr`). This is a **gateway/backend change** (owner: brew-ops, §ADR-24 area). Engineering options + the security pattern are already specced in the companion engineering handoff: `ψ/inbox/handoff/2026-06-21_22-06_mdr-edit-partner-allocations-read-surface.md` (recommended: add a `partners` array to the existing `/mdr` read view).

## Acceptance criteria (product)
- [ ] On Edit, the profile's current partners are listed with their deposit/payout % and topup %, identical in look to the Create editor.
- [ ] The operator can adjust a single partner without re-entering the whole set.
- [ ] Access unchanged: only `mdr:view` admins can see allocations; others see nothing.
- [ ] No regression to Create or to the save (PATCH) semantics.

## Dependency / sequencing
1. **Backend (brew-ops):** ship the gated allocation read surface (per the eng handoff). ← blocker
2. **Portal (next-ui):** wire Edit to load + display the allocations like Create; remove the "replace to edit" gate. (~small, ready to do as soon as #1 lands — same pattern as prior wirings.)

## Suggested priority
Medium — not a money-correctness bug (the write path + RM engine are unaffected), but a real operator-safety / usability gap on a sensitive revenue-share screen. Pairs naturally with the recent MDR write-UI work.
