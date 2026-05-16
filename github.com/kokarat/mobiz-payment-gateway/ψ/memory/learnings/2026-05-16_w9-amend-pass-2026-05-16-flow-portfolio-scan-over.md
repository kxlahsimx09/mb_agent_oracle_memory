---
title: W9 amend pass 2026-05-16: flow portfolio scan over `33664cd..c7b2232` (1 code co
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, no-drift-found, flow:deposit-qr-request, flow:payout-request, flow:deposit-slip-upload-admin-approve]
created: 2026-05-16
source: docs/flows/deposit-qr-request.md, docs/flows/payout-request.md, docs/flows/deposit-slip-upload-admin-approve.md @c7b2232
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 amend pass 2026-05-16: flow portfolio scan over `33664cd..c7b2232` (1 code co

W9 amend pass 2026-05-16: flow portfolio scan over `33664cd..c7b2232` (1 code commit, `c7b2232` #444 — rate-limit cap raise). Extends W9 PR #447. Outcome: A=13, B=0, C=0, D=0, E=0, F=0 — pure Class-A hash refresh, no flow drift.

`c7b2232` touched only `controllers/DepositRequestController.go` and `controllers/PayoutRequestController.go`, each a single in-place literal swap (deposit `RequestsPerDay 300000 → 600000`; payout `RequestsPerMinute 60 → 1000`) — equal line count, so no pointer line number shifted. The 13 affected `// impl:` pointers across three flows refreshed `@33664cd → @c7b2232`: `deposit-qr-request` 5 pointers, `payout-request` 4, `deposit-slip-upload-admin-approve` 4.

Not flow-step drift — same reasoning as the #443 pass in PR #447: `payout-request` Step 2's `// impl:` annotation lists "rate limit" as one item in the validation chain and the chain still runs a rate-limit check; the cap value is an internal parameter the flow doc never asserts at step granularity. `payout-request` Step 2's pointer range `82-178` contains the changed line 171 but the step's claim ("validation chain incl. rate-limit check") holds, so Class A, not C. Step 4b: zero live section-level markers in the three touched flow docs. No cross-repo signal (rate-limit caps fully internal to mobiz controllers). W9 amend trace `f0ed43dc`, chained from W2 trace `fc270df2`.

---
*Added via Oracle Learn*
