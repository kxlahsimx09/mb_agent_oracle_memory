---
title: next-ui — mb-next-admin-portal login path + live-wiring scope reality (verified 
tags: [next-ui, repo:mb-next-admin-portal, next, login, mfa-aal2, rls, deposit, mock-vs-live, bank-statements, thread-13]
created: 2026-06-11
source: thread #13; verified via real gotrue aal2 JWT + Supabase Management API SQL on sinuwgsqqyqzlpaavimf
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# next-ui — mb-next-admin-portal login path + live-wiring scope reality (verified 

next-ui — mb-next-admin-portal login path + live-wiring scope reality (verified 2026-06-11 against sinuw, thread #13).

LIVE-WIRING SCOPE: Only the **Deposit** screen (src/app/(portal)/deposit/page.tsx → src/lib/deposits-api.ts readDeposits) is wired to real staging data — it reads v_deposits via supabase-js and subscribes to ts_deposits (realtime). EVERY other screen (dashboard, bank-transactions, settlement, payout, clients, …) imports from src/lib/mock and shows MOCK data. There is NO bank_statements view/screen in the portal (the code never references the bank_statements table; /bank-transactions is mock). So "watch deposit auto-match" works on /deposit (is_matched / matched_statement_id / effective_status); "watch the raw bank_statements feed" does NOT exist yet — would be a new screen (next-ui builds via impeccable→PR).

LOGIN PATH (proven end-to-end): the portal forces aal2 for entity_type=admin (AUTH2_REQUIRED=["admin"] in src/contexts/auth.tsx). Flow = signInWithPassword → JWT carries custom claim entity_type (injected server-side; gotrue app_metadata is empty) → if no verified TOTP factor the portal goes to ENROLL (QR), else CHALLENGE. So to hand an owner a working admin login you need a factor-FREE account (else enroll 403s insufficient_aal "AAL2 required to enroll a new factor" because GoTrue blocks new-factor enroll at aal1 when a verified factor already exists — chicken/egg). The gotrue /admin/users LIST endpoint reports factors=[] even when a verified factor exists; use /admin/users/{id}/factors to see the truth, and DELETE the stale factor for a clean enroll.

RLS READ (A4 split-by-verb): v_deposits is security_invoker=true → reads ts_deposits under the user's RLS. SELECT policy rls_read_a4 = auth_aal2() AND has_read_perm('deposit') AND (auth_db_is_admin() OR client_id=auth_db_effective_client_id()). has_read_perm/auth_db_is_admin are SECURITY DEFINER and match public.app_user.id = auth.uid() (i.e. app_user.id MUST equal the gotrue user id) then look up role_permissions; super_admin has deposit:view. Net: a real aal2 admin reads rows; aal1 reads 0 (correct). Wired admin test users on sinuw: simlive10-admin / simlive10-admin-nf / probe-admin (all type=admin, role=super_admin, app_user.id == auth.users.id). NOTE: staging deposit/bank_statements data churns live during golden-journey runs — row counts/amounts change minute-to-minute; that's expected, not a wiring bug.

---
*Added via Oracle Learn*
