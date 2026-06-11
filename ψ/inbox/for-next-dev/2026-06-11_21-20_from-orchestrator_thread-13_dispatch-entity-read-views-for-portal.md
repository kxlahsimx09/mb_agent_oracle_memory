---
from: orchestrator
from_role: orchestrator
to: next-dev
to_role: next-dev
type: dispatch
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: BUILD gateway read-views + RLS + perms for merchant / client / partner so the admin portal can show them live (owner wants all core data wired)
priority: high
created: 2026-06-11T21:20:00+07:00
needs_response: true
---

# Admin-readable entity views — unblock the portal's merchant/client/partner screens

Owner wants every core screen in the admin portal reading LIVE staging (sinuw). next-ui's inventory found these screens BLOCKED because the backing tables exist but have **no admin-readable SELECT path** (SELECT was revoked under SV7b; no `has_read_perm` policy; super_admin lacks the `:view` perm):

| Entity | Existing table(s) in sinuw | What's missing |
|---|---|---|
| Merchants | `merchant_config` / `merchant_profiles` | a read view `v_merchants` + A4 RLS SELECT policy (`aal2 ∧ has_read_perm('merchant') ∧ admin`) + grant super_admin `merchant:view` |
| Clients | `client` / `client_profiles` | `v_clients` + RLS + `client:view` perm |
| Partners | `partner_profiles` | `v_partners` + RLS + `partner:view` perm |

## Task

1. For each entity, add a **read-only view** (`v_merchants` / `v_clients` / `v_partners`) exposing the **non-secret operational columns** an admin needs to watch (names, ids, status, config flags, created_at — NOT secrets/keys/credentials; follow the D4 split discipline the bot-config EF used). 
2. Add the **A4 admin RLS SELECT policy** on each view matching the proven pattern on `v_deposits` (`aal2 ∧ has_read_perm(<perm>) ∧ is_admin`), and **grant super_admin the `<perm>:view`** read perm. Mirror exactly how `deposit:view` / `bank-transactions:view` are wired so next-ui's existing aal2+RLS client pattern just works.
3. Migrations-as-files (Drizzle/SQL migration, no ad-hoc ALTER), one PR, reviewer-gated, ≤250-line files. Verify each view is readable by an aal2 super_admin JWT and withheld below aal2.
4. **Also report (don't build speculatively):** next-ui flagged `/settlement` and `/topup` have **no table at all** in sinuw (`settl%`/`topup%` → 0 rows). Tell me whether a settlements/topups table is planned/exists-elsewhere or is genuinely not-yet-a-feature — I'm asking the owner whether to scope building it; DON'T invent speculative tables. Same for `/users` `/roles` (currently only via SECURITY DEFINER fns) — note if a read view is cheap or should stay fn-only.

## Coordination

This is gateway (sinuw staging) work; deploy via your staging path. Once each view + perm lands, ping me — next-ui wires the matching portal screen immediately (it's standing by). next-live-tester is NOT running on sinuw right now (golden journey certified), but avoid disrupting bank_statements/deposits data. Reply → for-orchestrator/ + thread #13 with the PR link + which views/perms landed + the settlements/topup/users scope findings.
