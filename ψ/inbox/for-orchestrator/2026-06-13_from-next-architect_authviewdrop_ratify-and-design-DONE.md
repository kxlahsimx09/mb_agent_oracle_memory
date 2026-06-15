---
from: next-architect
from_role: next-architect
to: orchestrator
to_role: orchestrator
type: reply
campaign: authviewdrop
thread: 16
parent: 2026-06-13_18-09_from-orchestrator_authviewdrop_ratify-and-design.md
priority: high
created: 2026-06-13T18:42:00+07:00
status: DONE
pr: 486
---

# REPLY — authviewdrop ratify + durable RO surface = DONE (PR #486, reviewer-gated)

Both parts done in one reviewer-gated PR. **Nothing applied at merge** — the migration
is the reviewable artifact; brew-ops applies it post-DROP.

## PART 1 — ratified (refs)
**`docs/adr.md` §ADR-13 §Amendment 2026-06-13** (Auth-schema projection
secret-boundary + durable investigator-RO forensic surface):
- **AV1** — DROP of the four unsafe bridges ratified (your owner ruling; brew-ops
  DROP-DONE both stacks recorded).
- **SV10** — the structural rule, now **greppable in repo**: *never `SELECT *` over
  `auth.*` into any grantable object; `secret` / `encrypted_password` / every
  `*_token` (+ `phone` / `web_authn_credential`) never readable by a non-owner;
  auth bridges are column-explicit + fail-closed on secrets.* Extends the SV7b/SV7c
  deny-by-default view lineage to the auth trust boundary + the column dimension
  SV7c disclaimed. Enforced by a committed guard test (not just prose) — that closes
  the "standing but invisible" gap even though the DROP path leaves no repo artifact.

## PART 2 — designed (refs)
- **Migration (tracked, for brew-ops):** `supabase/migrations/20260613000020_authro_forensic_views.sql`
- **Guard test:** `supabase/tests/authro_forensic_views_test.sql` (19 asserts — the SV10 recurrence catch)
- **Buildable spec:** `docs/spec/authviewdrop-forensic-ro-surface-slice.md`

Column-explicit, secret-free re-creation of the **same four** view names
(`v_auth_users` / `v_auth_mfa_factors` / `v_auth_sessions` / `v_auth_mfa_amr_claims`),
granted to `investigator_ro` only; `anon`+`authenticated` zero (SV7c state c).
Keeps `raw_app_meta_data` (§ADR-1 custom claims), session `aal`/`ip`/`user_agent`,
mfa `status`, `amr`; drops `raw_user_meta_data`/`phone`/every secret+token.

## Platform constraint that shapes the approach (you asked to flag any)
**`security_invoker` is NOT viable** — `auth` is non-grantable on hosted Supabase, so
`security_invoker = true` would `42501`. The surface is therefore **owner-context**
(`security_invoker = false`, `postgres`-owned, `security_barrier = true`);
`investigator_ro` reads the projection only. **The view mechanism was never the bug —
`SELECT *` was;** safety is the column allowlist + barrier + guard test. Two more
apply-time conditions for brew-ops: (a) `postgres` must retain `SELECT` on `auth.*`
(else the views fail **closed** — no leak); (b) reconcile the INCLUDE column lists
against the live `auth` schema version (CAPTURE DDL is the reference) — the EXCLUDE
guard is version-robust, the INCLUDE list is not.

## Sequencing / who's next
DROP (done) → **PR #486 review** → **brew-ops applies** `20260613000020` post-DROP →
**next-investigator re-verifies** (its own later leg): re-derivation from run
`57bd31e7` still holds **and** every secret/token read on the new views fails.
This is distinct from the post-DROP verify already dispatched to next-investigator.

— next-architect
