---
title: BENE (§ADR-22 Beneficiary Bank-Account Registry, BENE-001..006) — next-tester VE
tags: [next-tester, repo:mb-next-payment-gateway, next, bank-account, beneficiary-bank-account, adr-22, rbac, rls, probe, evidence, bene, handoff]
created: 2026-06-17
source: tests/integration/run-bene.ts@281be77 + evidence/integration-bene-1781694702977-281be777.json
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# BENE (§ADR-22 Beneficiary Bank-Account Registry, BENE-001..006) — next-tester VE

BENE (§ADR-22 Beneficiary Bank-Account Registry, BENE-001..006) — next-tester VERIFY GREEN 25/25 from ground-truth.

Campaign bankacctbuildt. Built a de-biased probe suite ONLY from the SPEC (origin/campaign/bankacctbuild:docs/spec/beneficiary-bank-account-slice.md) + the ratified epic AC (docs/requirements/epic-beneficiary-bank-account.md) + DB ground-truth + EF responses — next-dev's supabase/ source never read. Result: 25/25 per-AC PASS across 2 consecutive stable runs on the tester stack yupsevcrubgprsbujbpu.

Key reusable facts discovered over the wire (NOT from dev source):
- role_permissions schema on tester = flat {role, permission, created_at} — permission is a single `<resource>:<action>` string (NOT separate resource/action columns). Seeded roles = super_admin, client_admin, client_viewer, partner_user (== the SPEC §1 grant table). The BENE P4 seed adds 15 `bank-account:*` rows.
- SPEC §1 seeded grants (verified exact): super_admin = {view,approve,update,delete} (NO create, NO set-default — admin structurally refused at create); client_admin & partner_user = {view,create,update,delete,set-default}; client_viewer = {view}.
- Partner identity has NO `partner`/`partners` FK table; beneficiary_bank_account.owner_id is polymorphic no-FK (wallet pattern). To make a partner session resolve owner_id, seed partner_profiles(user_id, partner_id, display_name) via service-role; any uuid works as owner_id.
- Clients A–E seeded (22222222-…-000000000001..005). Use A/B for cross-tenant isolation, E for the per-owner-cap fixture.
- 2FA wiring = login-TOTP realised as the AAL2 session (§ADR-2 G1-D), NOT a money-out step-up. No totp_code request field. Drive 2FA purely via the bearer AAL: AAL2 accepted, AAL1 (pre-mfa) → 401. Admin update/delete path applies NO per-action 2FA beyond the AAL2 session (parity).
- v_bank_accounts is a security_invoker view serving BOTH owner-self (own rows) and admin (cross-tenant) — the base-table RLS decides. account_number is FULL within RLS-visible rows (no mask, parity); 22 columns, none credential/balance/secret. Leak-safe edges: foreign-owner → none; below-AAL2 → []; no bank-account:view perm → []; anon → 401 permission-denied.
- EF error snake-codes (negative legs returned exactly): admin_create_not_allowed, invalid_purpose, limit_exceeded(limit:5|3), duplicate_account, not_found, not_approved, not_editable, not_deletable, not_pending, missing_reason, forbidden.

Harness pattern: forked the auth-slice harness (tests/integration/probes/auth/_authctx.ts mintAal2User) into tests/integration/probes/bene/. Self-check (network-independent) gates every run: violation→red, bare-stack→blocked(exit3), bijection=25, purposeAllowed()+seededGrants discriminate. Runner run-bene.ts has a GATE-1 stack-readiness check (table+view ≠404, both EFs ≠404, bank-account:* seed present) → exits 3 BLOCKED on a bare stack, never counts it green.

Stack-readiness note: tester stack was BARE for BENE at dispatch (all 4 objects 404); brew-ops (campaign bankacctdeploy) deployed the 4 migrations + 2 EFs; readiness re-verified before any probe ran. BENE-007 (enforced payout linkage) is OUT — advisory-only, [RATIFICATION_PENDING:owner], no probe.

Evidence: evidence/integration-bene-1781694603536-281be777.json + -1781694702977-281be777.json. Handed to next-investigator to independently falsify every PASS.

---
*Added via Oracle Learn*
