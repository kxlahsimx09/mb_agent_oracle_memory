# Requirement gap / data-integrity: "partners" mean two disjoint things — /partners ≠ MDR partner wallets

**Raised by:** next-ui · **Date:** 2026-06-22 · **Area:** Partners directory (`/partners`) ↔ MDR/settlement/wallet partner allocations · **Type:** data-consistency + latent integrity gap (NOT a portal code bug)

## Symptom (operator-reported)
An MDR profile is bound to **2 partners**, but opening **/partners** shows only **1**. The counts don't line up across screens.

## Root cause — two partner id-spaces that don't reconcile on staging
| What the screen shows | Read surface | Staging count |
|---|---|---|
| `/partners` directory | `v_partners` = **partner_profiles** (AUTH identity) | **1** (U-PT1) |
| MDR / settlement / wallet / residual fan-out allocate to | **partner WALLETS** (`wallet.owner_type='partner'.owner_id`) | **~30** |
| overlap between the two | — | **0** (no partner wallet maps to any profile; even U-PT1's profile has no wallet) |

So the two sets are completely disjoint on staging. The portal is reading **correctly** on both sides — `/partners` reads `v_partners` (profiles); the MDR picker reads `wallet` (partner wallets). The data underneath simply doesn't line up.

## Intended model (already shipped — prov003, 2026-06-18)
`partner_profiles.partner_id` is the **single** partner entity id and is **ALSO** `wallet.owner_id` AND `mdr_profile_partners.partner_id` (gateway `20260618001010_prov003_provision_partner.sql`). `provision_partner(...)` creates the identity + the partner_profiles row + the partner WALLET in one transaction under that one id. So a **correctly-provisioned partner appears in /partners AND is MDR-allocatable under the same id** — consistent by construction.

## Why staging is inconsistent
The ~30 partner wallets were seeded **directly** (not via `provision_partner`), predating the id-unification — so they're **orphan wallets with no partner_profiles**, and the lone profile (U-PT1) has no wallet. The MDR test profile then allocates to 2 of those orphan wallets → "2 in MDR, 1 in /partners".

## Latent concern (carries to production)
Even with clean data, the MDR/settlement partner picker (`listPartnerWallets` reads `wallet` directly; `_mdr_validate_partners` in `20260618000410_mdrwrite_rpcs.sql` checks only that the wallet exists with `owner_type='partner'`) lets an operator allocate revenue-share to a partner WALLET that has **no partner_profile** — i.e. to a "partner" that doesn't appear in `/partners` and has **no name**. If orphan partner wallets can exist in production, real MDR/settlement share could route to an unverified, nameless partner id.

## Impact
- Operator confusion: partner counts/identities disagree across /partners vs MDR/settlement/wallet.
- Integrity risk: MDR allocation to a profileless/nameless partner wallet (revenue-share to an unverified id).
- Not a money-math bug: the RM engine fans to the wallet id regardless; this is identity/observability/integrity, not settlement correctness.

## What's needed
1. **Data reconciliation (brew-ops):** backfill `partner_profiles` for every existing partner wallet (or re-provision via `provision_partner`) so each partner wallet has a profile under the unified id; quarantine/remove orphan test wallets on staging. Decide the **production posture**: should an orphan partner wallet (no profile) be allowed to exist at all?
2. **Integrity guard (gateway, recommended):** make the MDR/settlement partner write validation (and the picker source) require that the partner wallet **resolves to a partner_profile** — reject allocation to an orphan wallet (`unknown_partner`-style). Closes the latent concern above.
3. **Portal follow-up (next-ui, after #1/#2):** once wallets ↔ profiles are linked, the MDR partner picker (and the `EntityCell` partner resolution) can show the partner **name** (`display_name`) instead of the raw wallet id — today it shows the id because "no display name exists on any partner-wallet read surface." This also makes the `/partners` count match the MDR-allocatable set.

## Acceptance criteria
- [ ] The set of MDR/settlement-allocatable partner wallets == the partners shown in `/partners` (every allocatable partner has a profile).
- [ ] Every MDR-allocatable partner resolves to a name (no nameless wallet ids in the picker).
- [ ] Counts/identities are consistent across /partners, MDR, settlement, wallet.
- [ ] (decision recorded) whether orphan partner wallets are permitted in production; if not, a guard rejects them.

## Refs
gateway: `20260618001010_prov003_provision_partner.sql` (id unification), `20260620001010_prov007_b3_softdelete_substrate.sql` (v_partners), `20260618000410_mdrwrite_rpcs.sql` (`_mdr_validate_partners`). portal: `src/lib/mdr-profile-api.ts` (`listPartnerWallets`, `MdrPartnerAllocation`), `src/app/(portal)/partners/page.tsx`, `src/components/ui/entity-cell.tsx` (partner lookup).

## Priority
Medium-high — data-hygiene/integrity to settle BEFORE production (clean now while it's 1 test partner). Portal needs no code change for the core mismatch; the win is data reconciliation + an allocation guard, then a small portal naming follow-up.
