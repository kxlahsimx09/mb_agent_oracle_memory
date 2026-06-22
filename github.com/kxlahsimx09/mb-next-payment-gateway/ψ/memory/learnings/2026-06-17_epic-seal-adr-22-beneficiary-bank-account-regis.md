---
title: EPIC SEAL — §ADR-22 Beneficiary Bank-Account Registry (BENE-001..006). VERDICT: 
tags: [next-investigator, repo:mb-next-payment-gateway, next, epic-seal, seal, verify, v5, bank-account, beneficiary-bank-account, adr-22, bene, rbac, rls, audit-method]
created: 2026-06-17
source: next-investigator_bankacctseal_findings.md @ seal stack qnccphgykzdydebmdwdf (deployed slice PR #561 / dev HEAD 4687880)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# EPIC SEAL — §ADR-22 Beneficiary Bank-Account Registry (BENE-001..006). VERDICT: 

EPIC SEAL — §ADR-22 Beneficiary Bank-Account Registry (BENE-001..006). VERDICT: SEAL.

Investigator de-bias layer 2 (falsify, don't confirm). next-tester@bankacctbuildt reported 25/25 GREEN on tester stack yupsevcrubgprsbujbpu. I independently falsified EVERY PASS from RAW seal-DB ground-truth on my OWN isolated seal stack qnccphgykzdydebmdwdf (distinct project/keys) — psql as postgres (bypasses RLS) + my own driver minting real gotrue AAL2 identities against the deployed EFs, rows left behind then re-read raw. ZERO contradictions; no probe-PASS contradicted by the truth DB.

Deployed slice on seal = campaign/bankacctbuild PR #561 (dev HEAD 4687880): migrations 20260617000100-130 (bene_bank_account schema/rpcs/read_view/rbac_seed) + EFs bank-accounts + admin-bank-accounts (both 401, not 404-bare). Matches SPEC §5 manifest exactly.

Confirmed from raw data:
- BENE-001: owner session-derived (bogus body owner ignored), pending/!default; admin create 403 admin_create_not_allowed; purpose CHECK (client {topup,settlement}, partner {settlement} only, empty invalid); cap=5 RPC-enforced + 6th limit_exceeded; dup UNIQUE(owner_type,owner_id,bank_code,account_number)->duplicate_account; AAL1->401; 1 bank_account_create audit + created_by triple.
- BENE-002: approve stamps approved_by/at + pending->approved; reject needs reason -> rejected_reason stored; idempotent re-decide 200; not_pending both ways; non-admin owner reaching admin action 403 forbidden; audit + last_admin_action_* denorm (admin actor).
- BENE-003: approved-only set-default; one-default invariant = partial UNIQUE(owner_type,owner_id) WHERE is_default (raw exactly 1 default, prior cleared); pending->not_approved; cross-owner->404 not_found; AAL1->401.
- BENE-004: owner own-pending update/delete; approved->409 not_editable/not_deletable; not-own->404; super_admin BYPASS updates+deletes APPROVED rows; admin path no per-action 2FA (AAL2 bearer only); audit update+delete, delete-audit survives row removal.
- BENE-005: RLS owner-isolation (client own only, sub-client collapses to parent, partner own); admin cross-tenant all axes; account_number FULL no mask in both views; view = exactly 22 SPEC cols, none secret/balance; leak-safe edges (foreign->none, AAL1->[], no-view-perm->[], anon->401). RLS policy = auth_aal2() AND has_read_perm('bank-account') AND (is_admin OR client-own OR partner-own); v_bank_accounts security_invoker=true; authenticated SELECT-only, anon ungranted.
- BENE-006: role_permissions bank-account:* = 15 rows, 6 flat actions, distinct from system-bank; super_admin={view,approve,update,delete} (NO create, NO set-default); client_admin/partner_user={view,create,update,delete,set-default}; client_viewer={view}. Exact SPEC §1 match.

BENE-007 (enforced payout linkage) correctly uncovered — OUT, advisory-only, no enforcement to verify.

Method note: the only anomalies seen were in MY exerciser (reusing FK-bound CLIENT_A across sections tripped the 5-cap -> missing_id); re-run on a wiped slate cleared them and serendipitously re-confirmed the cap. Findings file: next-investigator_bankacctseal_findings.md.

---
*Added via Oracle Learn*
