---
title: PARITY: current-production `/bank-accounts` = the client/partner BENEFICIARY ban
tags: []
created: 2026-06-17
source: next-architect (doc-bankacct-spec campaign, 2026-06-17)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# PARITY: current-production `/bank-accounts` = the client/partner BENEFICIARY ban

PARITY: current-production `/bank-accounts` = the client/partner BENEFICIARY bank-account registry (collection `bank_accounts`, mobiz HEAD 03d6383). Tags: #repo:mb-next-payment-gateway #repo:mb-next-admin-portal #current #next #bank-account #system-architect #decision #parity

GROUNDED (dpay prod DB + mobiz Go code, cross-corroborated):
- Model `models/bank_accounts.go:11-43`: owner_type(client|partner), owner_id, owner_name, bank_code, bank_name, account_number, account_name, purpose []string, status int, approved_by/_name/_at, rejected_reason, is_default, note, created_at/updated_at.
- STATUS = int enum 0=pending/1=approved/2=rejected (consts :46-50). Mock `pending|approved|rejected` IS parity-faithful (DB has 0 rejected ROWS today; Mongo schemaless → rejected_reason just unmaterialized; CODE is truth per P-004).
- PURPOSE = ARRAY of {topup, settlement}. Mock's `deposit|payout` is DRIFTED/WRONG — next-UI must use topup|settlement. Partner may register SETTLEMENT-ONLY (:181-190); client topup and/or settlement.
- SUBMISSION = client/partner/sub-client SELF only; CreateBankAccount derives owner from JWT and REJECTS admin user-type (:86-91). sub-client collapses to parent client (owner_type=client). NO admin create-on-behalf path. Admin role only approve/reject (`bank-account:approve` gates both, :605-744) + super_admin edit/delete (admin-bypass branch in Update/Delete).
- PAYOUT-DESTINATION LINKAGE = NONE. Registry NEVER consulted server-side by payouts/settlements/topups; ts_payouts.dest_* and SettlementController BankAccNo are FREE-FORM request-body fields. GetApprovedBankAccounts (:376-428, sort is_default desc) is a client-side PICKER CONVENIENCE only — no FK, no status=approved enforcement, is_default not wired to payout selection.
- ACCOUNT_NUMBER = full plaintext, NO masking to any caller (owner or admin). Per-caller difference is ROW VISIBILITY (tenant filter helpers/tenant_filters.go:274-308 ApplyBankAccountTenantFilters; admin cross-tenant exempt), NOT column masking.
- LIMITS client max 5 / partner max 3 (:24-25). Duplicate (owner+bank_code+account_number) guard (:218-236). 2FA required on create/delete/set-default IF user has 2FA enrolled (verify2FAForBankAccount :40-72). is_default: SetDefault owner-only, requires status=approved (:1237). 24h approval cooldown is a maxpay-UI claim (maxpay-ui-reference §Bank Accounts) — backend enforcement NOT located in ApproveBankAccount → treat as UI-tier until impl confirms.

NEXT-SYSTEM CONSEQUENCES: needs a NEW table (existing next-gateway `bank_account` is the SYSTEM/operator bank, §ADR-4a) — name it distinctly (e.g. beneficiary_bank_account). Needs a NEW §ADR-13 F3 RBAC resource `bank-account` (NOT in the 33-resource list; that has `system-bank`) with actions view/create/approve/update/delete/set-default. Leak-safe read: tenant-isolation RLS gives owner-self read (the `/my` surface) + admin cross-tenant; account_number full within visible rows (parity = no mask; cross-tenant protection is row isolation, mirrors v_deposits/v_system_banks full-to-admin-via-row-gate precedent).

OPEN OWNER QUESTIONS (current has NO equivalent of what the mock implies): (1) mock purpose=payout vs current topup|settlement — resolved by parity to topup|settlement, flag mock drift; (2) ENFORCED payout-destination linkage — current has ZERO server-side linkage; owner said "match current" so parity=no enforcement, but confirm the registry is intended to be decorative server-side (the purpose=payout label has no backend meaning today); (3) admin create-on-behalf — current = self-only; (4) approval is single-step single-approver (no maker/checker).

---
*Added via Oracle Learn*
