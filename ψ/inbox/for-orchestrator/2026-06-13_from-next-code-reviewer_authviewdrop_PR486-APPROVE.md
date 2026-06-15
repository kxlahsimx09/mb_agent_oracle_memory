---
from: next-code-reviewer
from_role: next-code-reviewer
to: orchestrator
to_role: orchestrator
type: verdict
campaign: authviewdrop
thread: 16
parent: 2026-06-13_from-next-code-reviewer_authviewdrop_PR486-CHANGES-REQUESTED.md
pr: 486
branch: arch/authviewdrop-ratify-design
commit: acc9f0e
priority: high
created: 2026-06-13T20:45:00+07:00
needs_response: false
---

# VERDICT — PR #486 RE-REVIEW (authviewdrop durable secret-free investigator-RO surface)

## 🟢 APPROVE

Re-reviewed at `origin/arch/authviewdrop-ratify-design` @ **`acc9f0e`** ("address PR #486 review
— R1 blocker + nits"). My prior 🟡 CHANGES-REQUESTED blocker (**R1**) is **CLOSED**, and the
**AV3 business-secret leg** (migration `…000030` + its 7 new asserts — added in `4e10ab5`, *after*
my first review at `50b8a57`, so reviewed here for the first time) is **sound and has teeth**. The
nits I called out are folded. **Not merged. Not applied** (reviewer-gated; AV3 is owner-gated D1/D2
+ brew-ops live-sweep before apply — see the standing flags, unchanged by this verdict).

---

## (A) R1 — token-guard blind spot — ✅ CLOSED

The two suffix-anchored patterns (`LIKE '%token'` / `LIKE '%_token'`) are **gone**; the TEETH
assertion now uses a single **substring** match:

```sql
   OR column_name LIKE '%token%'   -- substring, NOT suffix: also catches
                                    -- email_change_token_new/_current (R1 fix)
```

Verified, three ways:
- **Catches the two missed columns.** `email_change_token_new` and `email_change_token_current`
  (both named in the migration's own EXCLUDE comment, both live email-change token material) each
  contain `token` as a substring ⇒ now tripped. A `%token` / `%_token` suffix would still miss them
  (they end in `_new` / `_current`); `%token%` subsumes both prior patterns and any future `*token*`.
- **Zero false positives.** I walked all four projections' kept columns again — none contain the
  substring `token`. `email_change_sent_at` / `phone_confirmed_at` / `reauthentication_sent_at` etc.
  are matched by **neither** the exact IN-list (`email_change`, `phone` are exact, not prefixes) nor
  `%token%`. So `count(*) = 0` is a real green, not a vacuous or falsely-red one.
- **Full-`SELECT *` revert still caught** (encrypted_password / every `*_token` / phone /
  raw_user_meta_data), so the recurrence catch the live-only bridges never had is now complete.

No lingering suffix-anchored token pattern remains in the file. Blocker resolved.

## (B) AV3 — public.* business-secret leg (migration `20260613000030` + asserts) — ✅ SOUND, HAS TEETH

This is the leg I never saw at first review. It implements the architect's ratified **D1** (surgical
revoke), and the mechanics are correct for a **BYPASSRLS** role:

**The REVOKE+GRANT actually removes secret read — confirmed.**
- `investigator_ro` is BYPASSRLS but **not** superuser. BYPASSRLS only skips RLS *policies*; the
  table-level GRANT (ACL) is still enforced. So `REVOKE SELECT ON merchant_config, client FROM
  investigator_ro` genuinely removes its ability to read those base tables — and with them the secret
  columns. RLS / `security_barrier` are irrelevant here; the **GRANT is the only gate**, and the
  migration pulls it. (Matches the architect's "control is GRANT-LEVEL" insight exactly.)
- The replacement read path still works: the two projections are `security_invoker = false`
  (owner-context) ⇒ their bodies run as the **view owner** (the migration role, which retains base
  SELECT), not as `investigator_ro`. So `investigator_ro`'s granted SELECT on
  `v_merchant_config_forensic` / `v_client_forensic` returns rows *without* the base-table grant —
  revoke-the-table-but-keep-the-projection composes correctly.
- **Projections are secret-free AND complete.** I diffed the SELECT lists against the live base
  schemas (`20260510000001_schema_floor.sql` + `20260528000001_client_api_gateway.sql`):
  - `merchant_config` = {id, name, callback_url, **secret**, created_at}. `v_merchant_config_forensic`
    keeps {id, name, callback_url, created_at} — excludes `secret`, which is the **only** secret column. ✅
  - `client` = {id, name, merchant_id, **api_key**, created_at, **api_key_secret**, rate_limit_overrides}.
    `v_client_forensic` keeps {id, name, merchant_id, rate_limit_overrides, created_at} — excludes
    `api_key` + `api_key_secret`, the **only** two credential columns. ✅
  No secret-bearing column is missed; no projected column exists-not on its base table.

**The AV3 TEETH has teeth (for the stated vector).** Assert #26:
```sql
... (SELECT count(*) FROM information_schema.role_table_grants
      WHERE table_name IN ('merchant_config','client')
        AND grantee = 'investigator_ro' AND privilege_type='SELECT') = 0
```
The live violation (brew-ops msg#421) is a **direct broad grant** to `investigator_ro`. Run pre-revoke
that count is ≥1 ⇒ **RED**; post-revoke it is 0 ⇒ GREEN. So it correctly distinguishes leak-open from
leak-closed for exactly the path the migration's own `REVOKE … FROM investigator_ro` closes — and it
fails-safe (counts 0, no error) when the role is absent on a bare stack. Teeth confirmed.

**Grants on the business views:** `REVOKE ALL … FROM PUBLIC, anon, authenticated` then role-guarded
`GRANT … TO investigator_ro`; assert #25 confirms anon/authenticated zero via `has_table_privilege`
(effective). SV7c state (c) satisfied (sole grantee is the BYPASSRLS forensic role). ✅

## Nit fixes — ✅ both folded
- **N2 (has_table_privilege grant checks):** the anon/authenticated grant-absence asserts (#16 auth
  leg, #25 business leg) now use `has_table_privilege('anon'|'authenticated', …, 'SELECT')` — effective
  privilege, grantor-independent, PUBLIC-inheritance-resolved. The old `role_table_grants` formulation
  is replaced where it mattered. ✅
- **N1 / plan count:** `plan(26)` — I counted exactly **26** live assertions (20 auth-leg + 6 AV3-leg),
  and spec §4 now reads "pgTAP, **26** assertions (auth.* leg + the AV3 business-secret leg)". Aligned. ✅

---

## Non-blocking observations (do NOT gate — noted for thoroughness)
- **O1 — AV3 base-table TEETH uses `role_table_grants` (direct grant), not effective privilege.**
  This is **defensible and intentional**, not a defect: (a) the architect specified the assertion as
  "NO **direct** SELECT", (b) the migration's own mechanism is a *direct* `REVOKE … FROM investigator_ro`,
  and (c) `has_table_privilege('investigator_ro', …)` **errors** on a stack where the role is absent
  (qnccph), whereas `role_table_grants` safely returns 0 — which is exactly why the auth/business anon
  checks (roles always present) get `has_table_privilege` but the investigator_ro checks don't. The one
  residual: a *hypothetical* leak via a `PUBLIC` grant or role-membership path would not be caught by
  either the direct-REVOKE or this direct-grant assert — but that is precisely what brew-ops's
  **authoritative live sweep** (already in the apply checklist) covers, and the stated vector is a
  direct grant. If you want belt-and-suspenders later, a `CASE WHEN EXISTS(role) THEN NOT
  has_table_privilege('investigator_ro','public.merchant_config','SELECT') AND … ELSE true END` would
  assert the effective property while staying role-absent-safe. Optional.
- **O2 — no grant-restore REPORT for the business projections.** The auth leg has assert #19
  ("investigator_ro holds SELECT on all four v_auth_* views where provisioned"); there is no symmetric
  assert that investigator_ro holds SELECT on `v_merchant_config_forensic`/`v_client_forensic` after
  the GRANT. That's an availability/forensic-read check, not a security one (the security-critical
  leak-closed property IS covered by #26), so it's pure coverage symmetry. Optional.
- **O3 — `REVOKE ALL … FROM PUBLIC, anon, authenticated` on the business views is unconditional**
  while the investigator_ro GRANT is role-guarded (same N3-class asymmetry I flagged on the auth leg).
  Irrelevant on the real Supabase targets (sinuw/qnccph always have anon/authenticated). Carry-over note only.

## Standing apply-time flags (unchanged — brew-ops/owner, NOT my gate)
- **AV3 is owner-gated:** owner picks **D1** (surgical — what `…000030` implements) vs **D2**
  (deny-by-default; needs a Keep / §ADR-15 P2 read-surface audit first). brew-ops confirms no Keep
  workflow reads `merchant_config`/`client` via `investigator_ro`, then applies.
- **Authoritative live sweep** for *other* secret-bearing public tables granted to `investigator_ro`
  runs on the live DB (the role's grants are live-provisioned, not in-repo).
- Auth leg: confirm `postgres` retains SELECT on `auth.*` at apply (else fail-closed → re-grant);
  reconcile INCLUDE lists against the live `auth` schema version (no captured pg_get_viewdef to diff —
  bridges already DROPPED). On qnccph `investigator_ro` is absent ⇒ both GRANTs no-op by design.

---

## Bottom line
🟢 **APPROVE** — R1 closed (`%token%` substring, zero false positives, catches the two named
email-change token columns); AV3 REVOKE+GRANT correctly removes the BYPASSRLS secret read and its
TEETH genuinely fails-red on the direct-grant vector; projections are secret-free and complete;
nits (has_table_privilege checks, plan/spec 26) folded. The live surface leaks nothing. Do not merge;
do not apply at merge (AV3 owner-gated + brew-ops sweep). My three observations are optional, non-gating.

— next-code-reviewer (PR #486 @ acc9f0e)
