---
from: next-live-tester
to: [next-pm]
date: 2026-06-21T17:30:00+07:00
topic: Likely missing requirement / admin-EF gap — no API to assign a CLIENT to a POOL (pool_members owner_type='client')
status: finding raised by the live-test cast-provisioning refactor (provision-via-API); needs PM triage — is this a real EF/requirement gap or is admin-clients-create.pool_id the intended path?
tags: [#repo:mb-next-payment-gateway, #live-tester, #admin-api, #provisioning, #pool, #pool-members, #rbac, #ef-gap, #d2-gap, #requirement-gap]
---

# Handoff → next-pm: no admin API to assign a client↔pool (pool_members owner_type='client')

## Context — why this surfaced
We're refactoring the LIVE-test cast provisioning to go through the **real admin EFs** (owner directive:
init the cast via the API for realism, no direct DB hits unless strictly necessary). Mapping every cast
entity to an admin EF, we hit ONE operation with **no front-door surface**: putting a **client into a
pool**.

## The observation (what exists vs what's missing)
- The `pool_members` table is `(pool_id, owner_type, owner_id)` — it carries BOTH `owner_type='client'`
  and bank membership (`supabase/migrations/20260510000001_schema_floor.sql:91-94`).
- **Banks→pool HAS an admin EF**: `admin-pools-set-bank` (`{pool_id, bank_account_id, action:add|remove}`)
  — but it writes **`bank_account.pool_id`** only; its `pool_members` references are read-only
  guards/counts (`supabase/functions/admin-pools-set-bank/index.ts`).
- **Clients→pool has NO admin EF.** Nothing in `supabase/functions/` inserts a `pool_members` row with
  `owner_type='client'`. The provisioning RPC does not write it either. So the only way to set/change a
  client's pool membership today is a **direct `INSERT INTO pool_members` as service_role** — which is
  exactly what the live-test fixture does (`poc/integration/src/live/fixture-cast.ts:129-137`) and the
  seed bootstrap (`supabase/migrations/20260510000008_seed_bootstrap.sql:64`).

## Why it matters
- **Provisioning realism / operator surface:** if an operator (or our cast init) must put a client into a
  specific pool so its deposits route to the intended bank, there is no admin-portal/API way to do it —
  only a raw DB write. That's a back-office capability with no front door (the same class as the §ADR-13
  admin-EF coverage the other `admin-*-create` EFs fill).
- It forces the LIVE-test cast init to keep one **declared direct-DB write** purely because the API path
  is absent — the only setup step we can't do through a real EF.

## The open question for PM/dev (please confirm before we treat it as a gap)
`admin-clients-create` accepts a **`pool_id`** body field (`null ⇒ inherit merchant`)
(`supabase/functions/admin-clients-create/index.ts`). **Does setting that `pool_id` actually establish the
client→pool routing** (and if so, via what — a `pool_members` row, a `client.pool_id` column, or
merchant-inheritance)? Two cases:
- **(a) It already routes correctly** → then `pool_members(owner_type='client')` is **legacy/redundant** for
  clients, and the requirement is just to *document* that client pooling = `admin-clients-create.pool_id`
  (and our fixture's direct `pool_members` insert is unnecessary). No new EF needed — but please confirm,
  because the deployed `client` row has **no `pool_id` column** (verified on staging — columns are id,
  name, merchant_id, api_key…, status), which suggests the param lands somewhere non-obvious or is dropped.
- **(b) It does NOT fully route / there's no way to CHANGE a client's pool after create** → then this is a
  **real missing requirement**: an admin EF like `admin-pools-set-client` (or `admin-clients-set-pool`)
  to add/move/remove a client's pool membership, mirroring `admin-pools-set-bank`. This would also be the
  natural place for the RBAC perm (e.g. `pool:update` / `client:update`).

## Suggested triage
1. Confirm how client→pool routing is *meant* to be set (create-time `pool_id` vs membership table) and
   where `admin-clients-create.pool_id` writes.
2. If there's no way to **reassign** a client's pool post-create via API, file it as a D2-class admin-EF
   gap (add `admin-pools-set-client`) + a requirement line in the relevant epic (entity-provisioning /
   pool management).
3. Either way, tell live-tester the sanctioned path so our cast init can drop the last direct-DB write (or
   keep it as an explicitly-declared exception with your sign-off).

## Pointers
- EF surface audited: `supabase/functions/admin-pools-*`, `admin-clients-create`, `_shared/admin-auth.ts`
  (ADR-35 DB-driven RBAC — perms now from `role_permissions` via `resolve_actor`).
- Direct-DB write sites the harness uses today: `fixture-cast.ts:129-137` (cast), `seed_bootstrap.sql:64`.
- Provisioning roles that could carry a new perm: `super_admin`, `super_cs` (the two with `*:create` today).
