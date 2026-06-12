---
title: Admin entity read-views pattern for SV7b zero-grant / credential-bearing tables 
tags: [next-dev, repo:mb-next-payment-gateway, next, rls, auth, rbac, read-view, projection, sv7b, a4, migration, decision, build, portal, entity-read-views, thread-13]
created: 2026-06-11
source: PR #412 (dev/entity-read-views) commit 290bcbc; supabase/migrations/20260611000300_entity_read_views_portal.sql; docs/spec/entity-read-views-slice.md
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Admin entity read-views pattern for SV7b zero-grant / credential-bearing tables 

Admin entity read-views pattern for SV7b zero-grant / credential-bearing tables (next-dev build, PR #412, thread #13, 2026-06-11)

CONTEXT: orchestrator dispatched admin-readable views v_merchants/v_clients/v_partners on sinuw staging so next-ui's /merchants /clients /partners screens read LIVE. Backing tables (merchant_config, client, partner_profiles + *_profiles) existed but had no admin-readable SELECT path — SELECT revoked under SV7b; no has_read_perm policy; super_admin lacked the :view perm.

THE LOAD-BEARING DECISION — do NOT reuse the v_deposits pattern for credential tables. v_deposits is security_invoker=true and inherits the rls_read_a4 policy on its base table ts_deposits; that requires the CALLER to hold base-table SELECT. It cannot be reused for merchant_config/client because they carry credentials (client.api_key, client.api_key_secret, merchant_config.secret) whose SELECT was REVOKED under SV7b (20260611000020 + 20260611000030). Re-granting base SELECT — even column-scoped — re-opens the SV7b hole and contradicts SV7b's explicit rule: "a future client-directory read lands as a CREDENTIAL-FREE PROJECTION amendment, NEVER a row grant on these tables."

THE PATTERN (reusable for v_users/v_roles fast-follows):
  CREATE OR REPLACE VIEW public.v_<entity> WITH (security_invoker = false) AS
  SELECT <non-secret cols only>  -- D4 split discipline
  FROM public.<base>
  WHERE (SELECT public.auth_aal2())
    AND (SELECT public.has_read_perm('<resource>'))
    AND (SELECT public.auth_db_is_admin());
  GRANT SELECT ON public.v_<entity> TO authenticated;   -- VIEW only; base stays zero-grant
  INSERT INTO role_permissions (role,permission) VALUES ('super_admin','<resource>:view') ON CONFLICT DO NOTHING;

WHY owner-context (security_invoker=false): the view runs as the owner (postgres) so it can read the zero-grant base table; base RLS is bypassed → the A4 admin-tier predicate (aal2 ∧ has_read_perm ∧ admin, identical to bank_statements/audit_log policies) MUST be embedded in the view WHERE. This is the GATED counterpart to the un-gated owner-context views (v_payouts/v_bank_balance) the architect flagged as RLS-bypassing. Helpers wrapped (SELECT fn()) → uncorrelated InitPlan → once-per-query (A4 perf contract). auth.uid()/auth.jwt() resolve from the per-request GUC even inside a definer view, so the gate is real.

GOTCHA: the three :view resources (merchant:view/client:view/partner:view) are NEW F3 catalogue members — the has_read_perm resolver is generic so the seed works immediately, but next-architect must add them to the ratified catalogue so rbac_seed_vs_catalogue stays green (filed thread #13 + for-next-architect envelope). Don't edit the catalogue yourself (builder-not-designer).

VERIFY recipe (no EF deploy needed — same as investigator): db push to sinuw, then via Management API db/query impersonate with `BEGIN; SET LOCAL ROLE authenticated; SELECT set_config('request.jwt.claims','{"sub":"<uuid>","aal":"aal2"}',true); SELECT count(*) FROM v_<entity>; COMMIT;`. Results on sinuw: aal2 super_admin → 1 merchant/5 clients/0 partners; aal1 → []; non-admin → []; anon → 42501; super_admin still 42501 on base client table (SV7b intact).

SCOPE FINDINGS (reported to orchestrator, not built): /settlement + /topup have NO table at all in sinuw (settl%/topup%/top_up% → 0) = not-yet-a-feature; /users has no users table (data=app_user + empty *_profiles) — a v_users view is cheap, recommend fast-follow; /roles = app_user.role text + role_permissions map — v_roles cheap or stay fn-only.

---
*Added via Oracle Learn*
