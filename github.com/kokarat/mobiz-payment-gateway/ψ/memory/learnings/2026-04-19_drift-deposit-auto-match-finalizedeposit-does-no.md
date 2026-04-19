---
title: drift — deposit-auto-match finalizeDeposit does not abort when client wallet upd
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, flow-divergence, flow:deposit-auto-match-from-statement, wallet, mdr, deposit, financial-code, w4-queue]
created: 2026-04-19
source: services/transactionMatcher.go:592-701@37dfb26 + thread #17 Q4a classification
project: github.com/kokarat/mobiz-payment-gateway
---

# drift — deposit-auto-match finalizeDeposit does not abort when client wallet upd

drift — deposit-auto-match finalizeDeposit does not abort when client wallet update fails.

Classification: DRIFT — needs PR (per thread #17 Q4a, human confirmed "บั๊ก" on 2026-04-19 GMT+7). The code treats a missing or failing wallet update as a log-and-continue step, not a rollback trigger. That means a deposit can reach `status=paid` with the client wallet uncredited, while partner MDR fees have already been distributed — an inconsistency the upstream actor (Client) never sees directly but that a wallet-reconciliation audit would catch as a silent "phantom paid deposit with missing client credit."

Evidence:
- `services/transactionMatcher.go:592-611@37dfb26` — deposit CAS sets `status=paid + is_matched=true` FIRST. Race-guarded on `status: "pending"`, so only one matcher wins. No session, no transaction.
- `services/transactionMatcher.go:627-631@37dfb26` — client wallet lookup. On `walletCol.FindOne` error (wallet not found or query error), code logs `Wallet not found for client %s` and falls through the `else` branch.
- `services/transactionMatcher.go:641-643@37dfb26` — `walletCol.UpdateOne` error path. Logs `Failed to update wallet` and falls through.
- `services/transactionMatcher.go:663-665@37dfb26` — MDR distribution runs unconditionally if `deposit.DepositFee > 0`. Does not check whether client wallet update succeeded.
- `services/transactionMatcher.go:684-701@37dfb26` — callback goroutine fires `EventDepositCompleted` regardless of wallet state.

Why human classified as bug (thread #17 reply 2026-04-19): wallet credit is a load-bearing invariant of the "completed" callback from the client-integrator's perspective; if the wallet isn't credited, the deposit is not truly complete and should not fire the `completed` callback. The current "proceed anyway" behaviour prioritises partner MDR distribution over client credit — that's backwards for a payment gateway.

Remediation sketch (not authored, just traced for the eventual fix):
- Option A (cleanest): wrap the deposit CAS + wallet update + MDR distribution in a MongoDB session transaction (same pattern as `controllers/TopupController.go` approval path). Rollback on any wallet-update failure.
- Option B (minimal): reorder — check wallet exists and UpdateOne succeeds BEFORE the deposit CAS. If wallet update fails, do not flip deposit.status → paid; leave the statement unmatched so the next retry-ticker cycle tries again (or admin resolves).
- Option C (operational): on wallet-update failure, flip deposit to a new `checking` / `pending_review` status (distinct from slip-upload's existing `checking`) and file an admin alert. Preserves partner MDR if that's genuinely desired — which it probably isn't.

The fix involves financial code (wallet ops, MDR distribution), so PR must have `code_reviewer` or human sign-off per AGENTS.md §9.

W4 queue: pg-writer queues this as a DRIFT finding. pg-writer does not author code fixes — drift surfaced, owner picks up.

Parent W8 trace: b9e04355-1599-4bfb-b001-ac7697e9586b. Ratification: thread #17 (closed 2026-04-19, Q4a classification = drift).

---
*Added via Oracle Learn*
