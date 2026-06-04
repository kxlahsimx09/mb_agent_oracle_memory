---
title: W9 pass 2026-06-01 — flow-track 9aebabb..bf57c0e (1 Class-C drift, baseline held; inherited 8-flow deferral)
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, flow:payout-request, flow:deposit-auto-expire-pending]
created: 2026-06-01
source: docs/flows/payout-request.md, docs/flows/.baseline
project: github.com/kokarat/mobiz-payment-gateway
---

W9 pass over `9aebabb..bf57c0e` (parallels the same-session W2 `a011daf..bf57c0e`, PR #507). 252 pointers across 12 flows extracted (self-test OK). Outcome — A:0, B:0, C:1, D:0, E:0, F:0.

- **payout-request (Class C):** step-10 "refund for failed" is now CAS-guarded/conditional after `baa35a9` #499 — `[DRIFT]` inserted, pointer left at `@b23a903`, `#flow-drift` filed ([[2026-06-01_flow-drift-payout-request-refund-for-failed-conditional]]), queued W4/W8.
- **deposit-auto-expire-pending (no action):** `5357f79` #495 lowered `slip_review_timeout_minutes` default 15→5, but that line lives inside `processSlipEscalation`, which is **already** `[DRIFT — #460]`-flagged in this flow's Step 1 annotation and queued for a W8 revision (new `deposit-slip-review-escalation` flow). The flow doc does not cite the "15" value, so no prose drift; the default tweak rides along with the existing W8 queue item. No pointer change.
- **Perf line-shifts deferred:** `#494` (BankStatement search routing +~11 lines; WithdrawalQueue ListQueue sort +~6) and `#500` (deposit count cache +~6) shifted line numbers on pointers in `deposit-auto-match-from-statement`, `withdrawal-queue-dispatch-and-claim`, `withdrawal-queue-single-bot-transfer`, and `deposit-slip-upload-admin-approve`. These are Class-B re-line candidates but stack on top of the **inherited deferral**: the two prior W9 passes (`d904682`, `92fbcf7`) deliberately left `docs/flows/.baseline` at `9aebabb` with 8 flows deferred. Accurately re-lining across the whole frozen range exceeds this fast-fix pass.
- **Finance API #483** = uncovered surface (no flow), handled by W2 DRIFT-16 → W1; not a W9 concern.

`docs/flows/.baseline` **NOT bumped** (held at `9aebabb`) — Class C drift outstanding + inherited deferral. Recommendation: a dedicated W9 re-line catch-up (or W8 revisions for `payout-request` step 10 + the deferred `deposit-slip-review-escalation`) to clear the frozen baseline. W9 trace `863144bd` linked to W2 trace `d50e5bea` (same-session evolution chain). No cross-repo flow signal (Step 0.5: all bot-side `#cross-repo-sync` learnings predate the 2026-05-22 flows baseline; today's DO-tag sync is Restart-Bot, not a flow).
