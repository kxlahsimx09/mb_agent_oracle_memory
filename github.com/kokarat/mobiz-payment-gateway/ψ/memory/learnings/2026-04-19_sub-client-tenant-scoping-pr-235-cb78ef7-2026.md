---
title: Sub-client tenant scoping (PR #235, cb78ef7, 2026-04-20) hardens IDOR in four co
tags: [technical-writer, repo:mobiz-payment-gateway, current, security, rbac, sub-client, idor, tenant-scoping]
created: 2026-04-19
source: controllers/TopupController.go:35-61,122-132,1508-1564 + controllers/SettlementController.go:85-103 + controllers/BankAccountController.go:81-122,718-752,944-973,1041-1161 + routes/settlement.go:22 @ cb78ef7
project: github.com/kokarat/mobiz-payment-gateway
---

# Sub-client tenant scoping (PR #235, cb78ef7, 2026-04-20) hardens IDOR in four co

Sub-client tenant scoping (PR #235, cb78ef7, 2026-04-20) hardens IDOR in four controllers: TopupController (CreateTopup, CreateTopupWithSlip, GetTopupSystemBanks), SettlementController (CreateSettlement), and BankAccountController (CreateBankAccount, UpdateBankAccount, DeleteBankAccount, SetDefaultBankAccount). Pattern: for user_type="sub-client", load the users row, require parent_client_id ≠ nil, then force the operation's target id to parent_client_id (Topup/BankAccount) or overwrite input.EntityType="client" + input.EntityID=parent_client_id.Hex() (Settlement). TopupController centralises the lookup in a new helper resolveEffectiveClientIDFromJWT that also handles the plain "client" case (returns own user_id); the other controllers use inline lookups (candidate for refactor). Routes/settlement.go also gained the missing RequirePermission(PermCreate("settlement")) middleware — CreateSettlement was previously protected only by controller-internal checks. Pure access-control change: no API contract change for legitimate clients or admins; sub-clients that previously could IDOR into peer clients' topups/settlements/bank-accounts now get 403. For future W2 passes: treat "sub-client" as a distinct tenant scope alongside "client" when documenting any new body-supplied client_id/entity_id parameter.

---
*Added via Oracle Learn*
