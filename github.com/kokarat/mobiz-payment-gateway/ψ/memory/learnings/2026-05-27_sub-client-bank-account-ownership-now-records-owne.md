---
title: Sub-client bank-account ownership now records owner_name as the parent client's 
tags: [technical-writer, repo:mobiz-payment-gateway, current, bank-account, sub-client, track-commit]
created: 2026-05-27
source: controllers/BankAccountController.go:93-123@99ba05d
project: github.com/kokarat/mobiz-payment-gateway
---

# Sub-client bank-account ownership now records owner_name as the parent client's 

Sub-client bank-account ownership now records owner_name as the parent client's name (99ba05d #486, 2026-05-27). In controllers/BankAccountController.CreateBankAccount, allowed user_type is {partner, client, sub-client}; owner_type/owner_id/owner_name default to the JWT subject. When the caller is a sub-client the handler re-keys ownership to the parent client: it loads the sub-client's users row, sets owner_type="client", owner_id=ParentClientID, and (new at 99ba05d) owner_name=subUser.ClientName — the denormalized parent-client name carried on the sub-client's users doc — when that field is non-empty.

Previously owner_name was left as the acting sub-client's display name while owner_type/owner_id already pointed at the parent client, making bank_accounts rows internally inconsistent (owner_type/owner_id said parent, owner_name said sub-client). Fallback: if the sub-client's denormalized ClientName is empty, owner_name still retains the acting sub-client's name. Partners and direct clients are unaffected — their owner fields stay the JWT subject's. Reinforces that sub-clients are users docs (user_type=sub-client) linked via parent_client_id, not a separate collection. Documented in docs/current-system.md §3 /bank-accounts row.

---
*Added via Oracle Learn*
