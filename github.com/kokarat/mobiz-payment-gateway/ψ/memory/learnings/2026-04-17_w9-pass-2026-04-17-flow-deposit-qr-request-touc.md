---
title: W9 pass 2026-04-17: flow `deposit-qr-request` touched by commits 349b1e5..90425b
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, flow:deposit-qr-request]
created: 2026-04-17
source: docs/flows/deposit-qr-request.md
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 pass 2026-04-17: flow `deposit-qr-request` touched by commits 349b1e5..90425b

W9 pass 2026-04-17: flow `deposit-qr-request` touched by commits 349b1e5..90425ba. Outcome: A:0 refreshed, B:1 relocated, C:0 drifted, D:0 undocumented-step, E:0 unimplemented, F:0 strength-downgrade | note: Commit 76326c0 inserted a new `bot.Put("/queue/:id/waiting-to-review", ...)` line at routes/bot.go:33 for the new `waiting_to_review` bot status endpoint; that insert pushed the SaveBankStatements registration from line 49 to line 50. Pointer refreshed routes/bot.go:49@ed45b7e → routes/bot.go:50@76326c0. Semantics of SaveBankStatements unchanged. Controller pointer BotConfigController.go:496@ed45b7e left at its old short — file untouched in range. Commit f7f43bc only touched scheduler/withdrawal_dispatcher.go (not referenced by any deposit flow).

---
*Added via Oracle Learn*
