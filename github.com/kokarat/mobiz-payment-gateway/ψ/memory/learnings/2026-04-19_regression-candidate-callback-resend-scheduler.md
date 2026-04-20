---
title: regression-candidate — callback resend scheduler + idempotency guard (ratified v
tags: [technical-writer, repo:mobiz-payment-gateway, current, regression-candidate, callback, flow:deposit-auto-expire-pending, idempotency, scheduler, deposit, payout, w4-queued]
created: 2026-04-19
source: docs/flows/deposit-auto-expire-pending.md@153a4f6 + services/callbackService.go:379-422@153a4f6 + Oracle thread #19
project: github.com/kokarat/mobiz-payment-gateway
---

# regression-candidate — callback resend scheduler + idempotency guard (ratified v

regression-candidate — callback resend scheduler + idempotency guard (ratified via thread #19 Q-b + Q-d). Corrected-project re-file of `learning_2026-04-19_regression-candidate-callback-resend-scheduler` which landed at a duplicated-owner path due to a typo in the `project` field of the prior arra_learn call. Per P-001 the mis-filed version is not deleted; it will be superseded by this one.

**Flow affected:** `deposit-auto-expire-pending` step 7; also all other deposit + payout terminal callbacks via `services/callbackService.go` — the fix is cross-cutting by nature.

**Today's gap (confirmed intentional-latent by human on 2026-04-19 GMT+7):**

- `services/callbackService.go:379-422` defines `ResendPendingCallbacks()` — scans `ts_deposits` and `ts_payouts` for `callback_url != "" AND callback_sent = false AND callback_attempts < maxRetries AND status IN <terminal-set>` and re-fires callbacks. **Zero callers** in the tree at `153a4f6`. Not dead code — the human ruled this "เขียนทิ้งไว้ยังไม่ได้ใช้" (drafted for later, not yet wired).
- Consequence today: a transient client outage lasting longer than ~12s (2s+4s+6s backoff + per-attempt HTTP timeout) loses the `deposit.expired` / `deposit.paid` / `payout.*` callback permanently. Recovery path today is `GET /api/v1/deposit-request/status/:txnId` polling.
- Worse case — scheduler process killed mid-tick: the detached callback goroutine dies with the process; `callback_sent=false, callback_attempts=0` becomes indistinguishable from "callback never attempted". No recovery short of client polling.

**Required fix (per thread #19 Q-d):**

1. **Wire `ResendPendingCallbacks` to a scheduler.** Suggested: 1-minute tick, distributed lock `lock:callback_resend`, batch limit ~100 like `DepositExpiryScheduler`. Keep `maxRetries` capped; bounded retry avoids infinite hammering on a permanently-broken client.
2. **Establish an idempotency guard.** The human explicitly flagged: "ต้องมั่นใจว่าจะไม่ส่งซ้ำ". The current `callback_sent` flag alone is insufficient because of this race:
   - Inline retry at `:156-168` sends HTTP call → client returns 2xx.
   - Before `updateDepositCallbackStatus(..., true, attempt)` at `:160` commits, the process is killed.
   - On restart, `ResendPendingCallbacks` sees `callback_sent=false` and fires again → client receives a **duplicate** `deposit.expired` event.

   Options to consider:
   - **(Opt A — Client-side dedupe key):** add a `delivery_id` UUID to the payload generated per-delivery-attempt; client dedupes on its side. Requires client-integration contract change.
   - **(Opt B — Server-side pre-commit flag):** write `callback_sending=true` with a TTL before the HTTP call; resend skips rows with `callback_sending=true`. Still has a kill-window after HTTP succeeds but before flag flips to `callback_sent=true`. Narrows the race without eliminating it.
   - **(Opt C — Per-attempt receipt):** persist an append-only `callback_attempts[]` array with `{attempt_n, sent_at, response_status, response_body_hash}`. Resend compares against recorded `2xx` receipts and skips. Preserves full history per P-001.
   - **(Opt D — Idempotency-Key header):** follow Stripe's pattern — send `Idempotency-Key: <deposit_id>:<event>:<attempt_n>` header; clients that honour the header dedupe naturally. Requires client-integration contract change but is the industry norm.

   Recommend **Opt C + Opt D** in combination: server-side receipt log for our own audit + visibility, plus client-visible Idempotency-Key for client-side dedupe. Pure server-side (Opt B alone) doesn't eliminate the at-least-once semantics that the duplicate concern requires.

3. **Document in `deposit-auto-expire-pending.md`** (this flow) and in every other flow doc whose step cites a callback (`deposit-auto-match-from-statement` step 8, `payout-request`, etc.). When the follow-up PR lands, W9 will naturally pick up the new pointer and the `[DRIFT]` markers can be stripped via a W8 revision pass.

**Scope constraint:** the fix is NOT part of the `deposit-auto-expire-pending` flow doc's W8 pass — that PR is doc-only. The follow-up is a separate feature PR in the code, owned by a developer (not pg-writer). pg-writer files this learning as the W4 queue item; W4 escalates to human/code-reviewer for PR scoping.

**Related flows affected when fixed:**
- `deposit-auto-expire-pending` step 7 (this flow)
- `deposit-auto-match-from-statement` step 8 (in-flight PR #229)
- `deposit-slip-upload-admin-approve` terminal callback
- `payout-request` terminal callback
- `withdrawal-queue-dispatch-and-claim` callback cascade on terminal

**Evidence:**
- Code: `services/callbackService.go:379-422@153a4f6` — `ResendPendingCallbacks` definition.
- Absence: `grep -rn ResendPendingCallbacks --include='*.go' .` returns only the definition.
- Code: `services/callbackService.go:156-168@153a4f6` — inline retry loop (only live path).
- Thread: Oracle #19 Q-b + Q-d rulings.
- Flow doc: `docs/flows/deposit-auto-expire-pending.md` §Resolved questions (b) + (d), §Error paths, §Implementation pointers step 7.
- Prior drift learning: `learning_2026-04-19_drift-deposit-auto-expire-pending-step-7-callb`.

**Queued for W4** — resolution path is a feature PR, not a doc fix.

---
*Added via Oracle Learn*
