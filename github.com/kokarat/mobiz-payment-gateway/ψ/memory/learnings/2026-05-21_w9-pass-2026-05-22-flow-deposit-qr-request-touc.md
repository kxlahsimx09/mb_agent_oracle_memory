---
title: W9 pass 2026-05-22: flow `deposit-qr-request` touched by commit 7e239a5 (PR #454
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, flow:deposit-qr-request]
created: 2026-05-21
source: docs/flows/deposit-qr-request.md
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 pass 2026-05-22: flow `deposit-qr-request` touched by commit 7e239a5 (PR #454

W9 pass 2026-05-22: flow `deposit-qr-request` touched by commit 7e239a5 (PR #454, c7b2232..7e239a5). Outcome: A=0 refresh, B=5 line-relocations (Step 2 CreateDeposit entry 85→86, Signature 151→152, InsertOne 348→360, PublishDepositEvent 357→369; Step 3 response shape 360-400 → 372-412), C/D/E/F=0. All line shifts are from the `math` import +1 line + the 11-line amount-floor block at HEAD :156-166 — semantically the flow's claims are unchanged. The flow doc does not explicitly mention amount-flooring as a substep, and that gap is intentional for W9: amount-floor is an internal input normalization (not an actor-crossing), so it's not a class-D undocumented step; a future W8 enhancement could surface it as a sub-bullet under Step 2 if reviewers want it visible.

---
*Added via Oracle Learn*
