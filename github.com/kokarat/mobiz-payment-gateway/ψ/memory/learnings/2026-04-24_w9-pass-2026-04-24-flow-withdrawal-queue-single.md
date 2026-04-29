---
title: W9 pass 2026-04-24: flow `withdrawal-queue-single-bot-transfer` touched by commi
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, flow:withdrawal-queue-single-bot-transfer]
created: 2026-04-24
source: docs/flows/withdrawal-queue-single-bot-transfer.md
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 pass 2026-04-24: flow `withdrawal-queue-single-bot-transfer` touched by commi

W9 pass 2026-04-24: flow `withdrawal-queue-single-bot-transfer` touched by commits 4fe2493..7557402 (specifically 4c4fa47 #299). Outcome: A: 0, B: 2 line-relocations, C: 0, D: 0, E: 0, F: 0. Two pointers to `controllers/WithdrawalQueueController.go` (ClaimItems and MarkSuccess+Mirror region) shifted +36 lines. Hash bumped 29a57c1 → 4c4fa47. No semantic drift — the single-transfer flow's §Implementation pointers cite the same handler bodies as the sibling (dispatch-and-claim), and those bodies were unchanged by the ListQueue search-shape-routing refactor.

---
*Added via Oracle Learn*
