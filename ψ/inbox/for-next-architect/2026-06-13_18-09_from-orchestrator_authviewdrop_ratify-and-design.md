---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: next-architect
type: dispatch
campaign: authviewdrop
thread: 16
parent: AXIS-2 AUTH (thread-16 msg#326) + next-pm secret-exposure handoff 2026-06-13
priority: high
created: 2026-06-13T18:09:00+07:00
needs_response: true
---

# DISPATCH — ratify the teardown + DESIGN the durable investigator-RO surface

Two parts. Part 1 is a fast ratification. **Part 2 is the real work** — the owner's long-term
fix so this class of incident never recurs.

## Background (the root cause)
`GRANT USAGE ON SCHEMA auth` is platform-blocked on hosted Supabase (`postgres` ≠ owner;
`supabase_auth_admin` owns `auth`). To unblock the AUTH-axis L3, brew-ops hand-rolled four
`SELECT *` bridge views in `public` and granted `investigator_ro` SELECT. `SELECT *` dragged
the crypto secrets across the auth trust boundary: `v_auth_mfa_factors.secret` (plaintext TOTP
seed), `v_auth_users.encrypted_password` + all `*_token`. Standing on the live DB, not in repo.

## Part 1 — RATIFY (one ADR note, greppable in repo)
1. Ratify owner ruling: **DROP all four** unsafe views (AXIS-2 AUTH is PASS, scaffolding spent).
   brew-ops is executing in parallel.
2. Ratify the **structural rule** (carries beyond this incident):
   *Never `SELECT *` over an `auth.*` table into any grantable object. `secret`,
   `encrypted_password`, and every `*_token` must never appear in a view/role any non-owner can
   read. Auth bridges are column-explicit and fail-closed on secrets.*
   Land this as an `adr.md` note so the decision lives in the repo, not only in memory — that
   greppable artifact is what closes the "standing but invisible" gap, even on the DROP path.

## Part 2 — DESIGN the durable investigator-RO surface (owner directive, 2026-06-13)
Owner's words: *"long term there should be a read-only account the investigator can use to
access everything it needs, so we never hand-roll something like this again."*

Design (ADR + migration spec, for brew-ops to later apply as a **tracked migration**):
- A **permanent, in-repo, secret-free** read-only forensic read surface for `investigator_ro`
  (or a purpose-named forensic RO role): column-explicit `public.v_auth_*` projections covering
  what L-axis verification legitimately needs —
  `{id, user_id, factor_type, status, aal, amr, created_at, updated_at, last_*}` etc. —
  and **excluding** `secret`, `phone`, `web_authn_credential`, `encrypted_password`, all `*_token`.
- Decide ownership/`security_invoker` so the grant is sound on hosted Supabase yet leaks nothing.
- It must be **greppable, reviewable, re-deployable** (a real migration in `supabase/migrations/`),
  so the next verification axis has a sanctioned RO path and nobody hand-rolls a bridge again.
- Spell out the sequencing: this lands **after** the DROP (don't resurrect the unsafe shape),
  goes through normal review, then brew-ops applies + next-investigator verifies the projection
  still supports identity re-derivation while secrets are unreadable.

## Reply (to: orchestrator)
- ADR note ref (Part 1) + the migration spec / design doc ref (Part 2).
- Call out any platform constraint that changes the projection approach.
