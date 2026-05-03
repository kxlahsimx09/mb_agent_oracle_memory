---
title: W8 handoff (mobiz pg-writer received from bot-writer W9 2026-05-01): payout-requ
tags: [technical-writer, repo:cross, repo:mobiz-payment-gateway, repo:bank-bot, current, w8-handoff, uncovered-surface, flow:payout-request, scb, balance-mapping, cross-repo-sync]
created: 2026-05-01
source: docs/flows/payout-request.md (mobiz) + bank-bot/docs/flows/scb-dual-control-withdrawal.md (bot-writer W9)
project: github.com/kokarat/mobiz-payment-gateway
---

# W8 handoff (mobiz pg-writer received from bot-writer W9 2026-05-01): payout-requ

W8 handoff (mobiz pg-writer received from bot-writer W9 2026-05-01): payout-request.md may need a §Preconditions / §Postconditions / §Implementation pointers side-note about SCB system_banks.balance vs available_balance semantic swap (bank-bot PR #110 / commit 84e6649, 2026-04-30). The flow doc currently makes claims at lines 26 (preconditions: non-zero available_balance + headroom check), 62 (postconditions: system_banks.balance and available_balance both decremented by amount), 91 (success postcondition: same fields decremented). The "decrement both fields by amount" claim remains correct (the wire format absorbs the same value either way) but for SCB banks post-2026-04-30 the operator-facing meaning has flipped: `balance` now reflects "ยอดเงินสดที่ใช้ได้" (after-holds cash) and `available_balance` reflects "ยอดเงินในบัญชี" (account total). KTB unchanged. Mobiz's own DestCap guard absorbs the swap defensively via `services.EffectiveDestBalance(max(Balance, AvailableBalance))` (mobiz e1496a2) but the flow doc doesn't yet name the operator-facing implication.

W9 cannot edit §Preconditions / §Postconditions prose without crossing into W8 territory ("W9 edits pointers and markers only" per workflow-9-track-flows.md §Common pitfalls). Action item for W8 (next pg-writer pass that runs W8 revision on payout-request.md): consider adding a side-note paragraph to §Preconditions / §Postconditions naming the SCB-only semantic swap with cross-references to bank-bot `banks/scb/dashboard.js@20289a3` and (unchanged) `banks/ktb/dashboard.js`. Originating breadcrumb: bot-writer learning `2026-05-01_cross-repo-sync-bot-w9-mobiz-pg-writer-for-flo` + bot W9 trace `01a64ce4-239a-4591-bfb8-22aa05101d99`. Mobiz sibling W2 trace: `5900d287-20a2-4883-bef1-55e52e74c857`. Mobiz W9 trace: `3eea7fce-37e7-4874-9534-962518c0f8cd`.

---
*Added via Oracle Learn*
