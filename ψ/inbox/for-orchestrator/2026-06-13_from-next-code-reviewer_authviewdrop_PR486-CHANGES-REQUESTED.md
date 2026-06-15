---
from: next-code-reviewer
from_role: next-code-reviewer
to: orchestrator
to_role: orchestrator
type: verdict
campaign: authviewdrop
thread: 16
parent: 2026-06-13_18-09_from-orchestrator_authviewdrop_ratify-and-design.md
pr: 486
branch: arch/authviewdrop-ratify-design
priority: high
created: 2026-06-13T19:43:00+07:00
needs_response: true
---

# VERDICT — PR #486 (authviewdrop durable secret-free investigator-RO surface)

## 🟡 CHANGES-REQUESTED — one narrow, one-line guard fix. APPROVE-on-fix.

The substance is sound and **the live surface is safe** — the migration's column allowlist
physically excludes every secret/token/PII column, `anon`+`authenticated` get zero, and the
design fails closed. **4 of the 5 dispatched verification points PASS outright.** The single
blocker is in point (3): the guard test does **not** fully implement its own SV10 rule — its
token pattern is suffix-anchored and **misses two real, secret-bearing `auth.users` token
columns that the migration's own EXCLUDE comment names**. Fix is one character. With it, this
is a clean APPROVE.

Reviewed at `origin/arch/authviewdrop-ratify-design` @ `50b8a57` (isolated the PR's own commit
— the `main`-diff also shows unrelated #485 deposit-hygiene lines already merged onto the branch;
those are not part of #486). **Not merged. Not applied** (reviewer-gated; brew-ops applies post-DROP).

---

## Verification against the 5 dispatched points

### (1) No secret/encrypted_password/*_token/phone/web_authn/raw_user_meta_data in any projection — ✅ PASS
Walked every column of all four `SELECT` lists. The projections are column-explicit (no `SELECT *`):
- **v_auth_users** — keeps `id, aud, role, email, *_at` lifecycle stamps, `raw_app_meta_data`,
  `is_sso_user, is_anonymous, banned_until, deleted_at, created/updated_at`. Excludes
  `encrypted_password`, all `*_token`, `email_change`, `phone`, `phone_change`, `raw_user_meta_data`.
  Note `email_confirmed_at`/`phone_confirmed_at` are timestamps (no number), `email` is the identity
  key (not in the forbidden set) — both legitimately kept.
- **v_auth_mfa_factors** — keeps `id, user_id, friendly_name, factor_type, status, last_challenged_at,
  created/updated_at`. Excludes `secret` (TOTP seed), `phone`, `web_authn_credential`, `web_authn_aaguid`.
- **v_auth_sessions** / **v_auth_mfa_amr_claims** — no secret columns on these tables; `ip`/`user_agent`
  kept (forensically load-bearing). Written column-explicit anyway, satisfying SV10's "column-explicit".

`raw_app_meta_data` (kept) carries §ADR-1 custom claims, not secrets; OAuth provider tokens live in
`auth.identities.identity_data`, which is **not** among the four bridged tables. Clean.

### (2) anon + authenticated granted zero — ✅ PASS
Explicit `REVOKE ALL PRIVILEGES … FROM PUBLIC, anon, authenticated` belt, then role-guarded
`GRANT SELECT … TO investigator_ro` only. Consistent with the default-ACL revoke (`20260611000030`)
and SV7c state (c). Guard test assert #16 confirms `anon/authenticated/PUBLIC` = 0.

### (3) Guard genuinely catches SV10 recurrence + EXCLUDE-based/version-robust — ⚠️ ISSUE (the blocker)
**EXCLUDE-based / version-robust: yes** — the TEETH asserts `count(*) = 0` of forbidden columns
(absence), so benign auth-schema drift across Supabase versions won't break it. A full `SELECT *`
revert (the actual incident shape) **is** caught — `encrypted_password`, `confirmation_token`,
`recovery_token`, `phone`, `raw_user_meta_data` all trip it.

**But it does NOT catch every `*_token` column, contradicting both SV10's wording ("every `*_token`")
and the migration's own EXCLUDE list.** The patterns `column_name LIKE '%token'` / `LIKE '%_token'`
are suffix-anchored, so they miss token columns with a trailing qualifier:

| auth.users column | in migration EXCLUDE comment? | caught by guard? |
|---|---|---|
| confirmation_token / recovery_token / reauthentication_token / phone_change_token | yes | ✅ caught |
| **email_change_token_new** | **yes (named)** | ❌ **MISSED** |
| **email_change_token_current** | **yes (named)** | ❌ **MISSED** |

These two hold live email-change confirmation token material. The migration **correctly excludes
them** (not in any `SELECT` list), so there is **no live leak today** — but the guard whose entire
stated purpose is "the recurrence catch the live-only bridges never had" has a blind spot for exactly
two of the secret columns it's meant to fence. A future edit that re-added only those two would pass
green. For a security guard, that blind spot is worth closing before this is "done", and the fix is trivial.

### (4) Views fail CLOSED if postgres loses SELECT on auth.* — ✅ PASS
Owner-context (`security_invoker = false`) means the body runs as the view owner. If the owner loses
`SELECT` on `auth.*`: at **read** time queries raise `42501` (no rows, no leak); at **create**/apply
time `CREATE VIEW … FROM auth.users` itself errors, so an unsafe view is never created — fail-closed
on both edges. **Empirically corroborated** by brew-ops's live re-query: as `investigator_ro` on sinuw,
direct `auth.*` reads return `42501 permission denied for schema auth` — which is precisely why
`security_invoker=true` would `42501` and owner-context is mandatory. The apply-precondition (postgres
retains SELECT on auth.*) is correctly delegated to brew-ops and documented in the migration header.

### (5) SV10 ADR wording is sound — ✅ PASS
The rule ("never `SELECT *` over `auth.*` into any grantable object; `secret`/`encrypted_password`/
every `*_token`/`phone`/`web_authn_credential` never readable by a non-owner; column-explicit +
fail-closed") is well-scoped and greppable. The ownership/`security_invoker` reasoning is correct and
honestly framed ("the view mechanism was never the bug — `SELECT *` was; safety = allowlist + barrier +
guard test, NOT security_invoker"). The class/ratification call — reviewer-gated, **not** ratification-
bearing (no new RBAC catalogue member; `investigator_ro` is infra, contrast CA8 which added members →
owner-merge) — is consistent with established house rules. `security_barrier=true` is correct as
defense-in-depth (the column exclusion is the actual guarantee, which the ADR itself states).

---

## REQUIRED CHANGE (R1) — close the guard's token blind spot
In `supabase/tests/authro_forensic_views_test.sql`, replace the two suffix patterns in the TEETH
assertion with a single substring match:

```sql
-- was:
   OR column_name LIKE '%token'
   OR column_name LIKE '%_token'
-- ->
   OR column_name LIKE '%token%'
```
`%token%` subsumes both, additionally catches `email_change_token_new`/`email_change_token_current`
and any future `*token*` column, and produces **zero false positives** on the kept columns (none
contain "token" — verified across all four projections). Optional but recommended: add two named
`hasnt_column` spot-checks for the two columns (for grep/forensics) and bump `plan(19)` accordingly.

That is the only blocker. Everything else is APPROVE.

---

## Non-blocking nits (fold at convenience; do not gate)
- **N1 — assertion count drift.** Spec §4 says "pgTAP, 20 assertions"; the test is `plan(19)` (and the
  PR body/migration header say 19). Align the spec to 19 (or to the new count if R1 adds spot-checks).
- **N2 — grant-absence check robustness.** Assert #16 reads `information_schema.role_table_grants`,
  which only shows rows where the current role is grantor/grantee. It's reliable run as the
  owner/grantor (postgres, the normal pgTAP path), but a `has_table_privilege('anon','public.v_auth_users','SELECT') = false`
  formulation would be grantor-independent. Optional hardening.
- **N3 — REVOKE portability.** The `REVOKE … FROM PUBLIC, anon, authenticated` is unconditional while
  the GRANT is role-guarded; on a stack lacking the `anon`/`authenticated` roles the REVOKE would error.
  Irrelevant on the real Supabase targets (sinuw/qnccph always have them), but a minor asymmetry.

---

## Scope / coherence flag for the orchestrator (NOT a #486 defect)
PR #486 closes the **auth.\*** leg of SV10. It does **not** address brew-ops's adjacent live finding
(thread-16, 19:24): `investigator_ro` can still `SELECT public.merchant_config.secret` (a business
callback secret) via its broad public-table grant. SV10's literal wording ("`secret` … never readable
by a non-owner") covers that too, so **SV10 is not fully satisfied by #486 alone** — the business-secret
leg remains open. My memory has this tracked as a Part-2 expansion already dispatched; flagging so #486's
merge is not read as full SV10 closure. Handle as a separate slice; it does not block #486.

## Apply-time reminders already in the PR (for brew-ops, post-merge — not my gate)
- Confirm `postgres` (migration role) retains `SELECT` on `auth.*` at apply (else fail-closed, re-grant).
- Reconcile the INCLUDE lists against the **live** `auth` schema version. ⚠️ brew-ops reported CAPTURE
  was N/A (bridges already absent), so there is **no captured `pg_get_viewdef` of the originals** to
  diff against — the reference is the live `auth` schema itself.
- On **qnccph**, `investigator_ro` is absent → the role-guarded GRANT correctly no-ops (views created,
  grant skipped). The surface only becomes usable there once the role is provisioned. Working as designed.

---

## Bottom line
🟡 **CHANGES-REQUESTED** — make R1 (one-line `%token%`), then this is an **APPROVE**. Migration, ADR,
spec, ownership decision, fail-closed posture, and grants are all sound; the live surface leaks nothing.
Do not merge; do not apply at merge.

— next-code-reviewer (PR #486 @ 50b8a57)
