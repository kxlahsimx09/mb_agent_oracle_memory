---
title: W8 handoff — settlement override + confirm-completed flow not yet authored. As o
tags: [technical-writer, repo:mobiz-payment-gateway, current, w8-handoff, uncovered-surface, flow:settlement-admin-override-and-confirm-completed, settlement, admin-action]
created: 2026-05-04
source: controllers/SettlementController.go:1574-1905@b327f46 + routes/settlement.go:34-35@b327f46 + docs/current-system.md §3.2.5
project: github.com/kokarat/mobiz-payment-gateway
---

# W8 handoff — settlement override + confirm-completed flow not yet authored. As o

W8 handoff — settlement override + confirm-completed flow not yet authored. As of `b327f46` #398 (2026-05-05) settlement gained two new admin recovery endpoints `PUT /api/v1/settlements/:id/override` and `PUT /api/v1/settlements/:id/confirm-completed`, mirroring the payout recovery pair. Both are gated by `PermApprove("settlement")`, run inside `session.WithTransaction`, use `FindOneAndUpdate(After)` for wallet writes, fold the insufficient-balance guard into the wallet update filter (`available: $gte deductAmount`), and mirror withdrawal_queue rows to status `overridden`/`success` respectively. They do NOT distribute MDR (settlements only fan MDR via `ApproveSettlement`'s success path). The doc surface is now covered in `current-system.md` §3.2.5 (W2 today's amend on PR #396, commit 0650e33). No flow doc exists for settlement override/confirm-completed — this is uncovered surface per W9 §4 rules: "If the commit introduces a brand-new endpoint, service, or code path that no current flow covers, it is not D — it is an uncovered surface." Proposed flow slug: `settlement-admin-override-and-confirm-completed`. Suggested actors: admin user + settlements collection + wallets + wallets_change_logs + withdrawal_queue + SSE clients. Preconditions: `settlement.status==1` (override) or `==2` (confirm-completed); `override_reason`/`confirm_completed_reason` not yet set. Pair this with the existing `payout-confirm-completed` flow as the structural mirror — most steps map 1:1 (status guard → CAS → wallet $inc with refund/deduct → change-log row → withdrawal_queue mirror → SSE). The diverge points are: no MDR fan-out, queue-mirror status `overridden` vs payout's parity, 400-vs-500 error mapping for insufficient-balance.

---
*Added via Oracle Learn*
