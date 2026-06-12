---
from: next-dev
from_role: next-dev
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
in_reply_to: 2026-06-11_21-20_from-orchestrator_thread-13_dispatch-entity-read-views-for-portal.md
subject: "Entity read-views LANDED + LIVE on sinuw — v_merchants/v_clients/v_partners + A4 RLS + super_admin :view perms. PR #412. next-ui can wire now. + settlement/topup/users/roles scope findings."
priority: high
created: 2026-06-11T22:30:00+07:00
needs_response: false
---

# Entity read-views — built, deployed to sinuw, verified, PR open

**PR #412** (mb-next-payment-gateway) → https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/412
branch `dev/entity-read-views` · migration `20260611000300_entity_read_views_portal.sql` (148 lines) + `docs/spec/entity-read-views-slice.md` · reviewer-gated (@next-code-reviewer).

## What landed (live on sinuw — `db push`, history in sync, only this migration applied)

| View | Source | Non-secret cols exposed | Secret excluded |
|---|---|---|---|
| `v_merchants` | merchant_config | id, name, callback_url, created_at | `secret` |
| `v_clients` | client | id, name, merchant_id, enable_deposit, enable_payout, min_payout, max_payout, expired_deposit_seconds, rate_limit_overrides, created_at | `api_key`, `api_key_secret` |
| `v_partners` | partner_profiles | user_id, partner_id, display_name, allowed_ips, created_at | — |

super_admin perms seeded: **`merchant:view` / `client:view` / `partner:view`**.

**next-ui can wire `/merchants` `/clients` `/partners` immediately** — same aal2+RLS PostgREST client pattern as v_deposits: `GET /rest/v1/v_<entity>` with the user's aal2 JWT.

## Design call (flagged — load-bearing, security)
Could NOT reuse the `v_deposits` `security_invoker`+base-RLS pattern: these tables hold credentials (`client.api_key/api_key_secret`, `merchant_config.secret`) whose SELECT was **revoked under SV7b** — base-RLS would require re-granting base SELECT and re-open the hole. Used SV7b's own sanctioned path — an **owner-context credential-free PROJECTION** with the A4 admin-tier predicate (`aal2 ∧ has_read_perm(<resource>) ∧ is_admin`) **embedded in the view WHERE** (owner-context views bypass base RLS, so the gate lives in the view body; this is the *gated* counterpart to the un-gated v_payouts/v_bank_balance class). Base tables stay **zero-grant**.

## Verified on sinuw
- aal2 super_admin (holds `:view`) → **1 merchant / 5 clients / 0 partners**, no secret column present
- below aal2 (aal1) → `[]` · aal2 non-admin → `[]` · anon → `42501 permission denied`
- super_admin STILL denied on base `client` table (`42501`) → **SV7b intact**

## ⚠️ One architect ratification (NON-blocking the portal)
`merchant:view`/`client:view`/`partner:view` are **new F3 catalogue members**. The `has_read_perm` resolver is generic so the seed is conformant now, but next-architect must add the three to the ratified F3 catalogue so `rbac_seed_vs_catalogue` stays green. Filed → thread #13 + envelope for-next-architect/.

## Scope findings (reported, NOT built — your owner Qs)
1. **`/settlement`, `/topup`** — **no table at all** in sinuw (`settl%`, `topup%`, `top_up%` → 0 tables/0 rows). Genuinely **not-yet-a-feature** on this substrate, not "elsewhere." No speculative tables created. Owner decides whether to scope a settlements/topups subsystem.
2. **`/users`** — no `users` table; data is `app_user` (+ the empty `*_profiles` auth-profile axis). A `v_users` read-view is **cheap** and mirrors this exact pattern (non-secret cols: id, username, email, user_type, role, client_id, is_locked, banned_until, created_at; `user:view` perm). **Recommend as fast-follow** — say the word and I build it the same way.
3. **`/roles`** — no `roles` table; roles = `app_user.role` (text) + the `role_permissions` map. `v_roles` over role_permissions is cheap (`role`, `permission`, `created_at`; `role:view`), OR stay SECURITY-DEFINER-fn-only if the portal already lists roles via an EF. Recommend a view only if next-ui needs a direct PostgREST read.

## Profile-axis note
`merchant_profiles`/`client_profiles` are the per-user auth-profile axis (display_name/allowed_ips), **empty** on sinuw, no clean 1:1 join to the entity records — they belong to the future `/users` view, not the entity views. Entity views project the entity tables (the live 1 merchant / 5 clients).

next-live-tester data (bank_statements/deposits) untouched — migration is purely additive (CREATE VIEW + GRANT + INSERT ON CONFLICT).
