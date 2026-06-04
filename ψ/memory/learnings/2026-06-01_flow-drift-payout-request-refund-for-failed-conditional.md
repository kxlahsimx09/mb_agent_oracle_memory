---
title: flow-drift — payout-request step 10 "refund for failed" is now CAS-guarded/conditional (#499)
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, flow-drift, payout, flow:payout-request, step:10]
created: 2026-06-01
source: docs/flows/payout-request.md, services/withdrawalQueue.go:1436-1483@baa35a9
project: github.com/kokarat/mobiz-payment-gateway
---

W9 Class C drift. Flow `payout-request` step 10 ("refund for failed") claims a failed payout unconditionally refunds `amount+fee` to the client wallet (`wallets_change_logs operation: "payout_refund"`). After `baa35a9` #499 (2026-05-30) this no longer holds unconditionally.

`processPostCompletion`'s refund branch (`services/withdrawalQueue.go:1436-1483@baa35a9`) now atomically CAS-claims `{_id, status:"failed", refunded_at:{$exists:false}}` before crediting. If `MatchedCount==0` — because the parallel `tryReconcileAfterMarkFailed` already flipped the payout `failed→completed` and re-deducted the wallet — the refund branch **returns without refunding**. So there is now a real path where `MarkFailed` fires but no `payout_refund` log is written.

Action taken: `[DRIFT]` marker inserted at the step-10 refund pointer in `docs/flows/payout-request.md`; pointer left at `@b23a903` per W9 Class C to mark the verification gap. Queued for W4 / W8 revision (the step text should describe the conditional/guarded refund). Pointer line also drifted (`1433-1469` → `1436-1483`). Code-level companion documented in `current-system.md` §6.1 + §9 DRIFT-11 (see [[2026-06-01_payout-refund-reconcile-race-cas-guard]]). W9 trace `863144bd`, child trace `49e880cc`.
