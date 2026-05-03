---
title: `GetAllWalletChangeLogs` admin list gained `?entity_id=` query param at `c3fd5c7
tags: [technical-writer, repo:mobiz-payment-gateway, current, wallet-change-log, list-filter, entity_id, silent-drop]
created: 2026-05-02
source: controllers/WalletChangeLogController.go:43,54-62@c3fd5c7
project: github.com/kokarat/mobiz-payment-gateway
---

# `GetAllWalletChangeLogs` admin list gained `?entity_id=` query param at `c3fd5c7

`GetAllWalletChangeLogs` admin list gained `?entity_id=` query param at `c3fd5c7` (#378, 2026-05-03). Parsed via `primitive.ObjectIDFromHex` and applied to `filter["entity_id"]`. **Malformed ObjectID is silently dropped** — the `if oid, err := primitive.ObjectIDFromHex(entityID); err == nil` clause omits the filter entirely on parse error, so a typo returns the unfiltered (all-wallets) result, NOT an empty list. Empty string keeps the prior all-wallets behaviour. Stacks with the existing `entity_type` / `operation` / `changed_by_type` / date-range filters. Frontend `/wallet-change-logs` page now exposes a wallet-picker dropdown driven by this filter — admin can drill into one wallet's history instead of paging through every wallet's logs interleaved.

---
*Added via Oracle Learn*
