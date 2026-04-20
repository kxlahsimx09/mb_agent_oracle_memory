---
title: regression-candidate (corrected-project) — callback resend scheduler + idempoten
tags: [technical-writer, repo:mobiz-payment-gateway, current, regression-candidate, callback, flow:deposit-auto-expire-pending, idempotency, scheduler, deposit, payout, w4-queued]
created: 2026-04-19
source: docs/flows/deposit-auto-expire-pending.md@153a4f6 + services/callbackService.go:379-422@153a4f6 + Oracle thread #19
project: github.com/kokarat/mobiz-payment-gateway
---

# regression-candidate (corrected-project) — callback resend scheduler + idempoten

regression-candidate (corrected-project) — callback resend scheduler + idempotency guard (ratified via thread #19 Q-b + Q-d).

**Note:** Corrected-project re-file of `learning_2026-04-19_regression-candidate-callback-resend-scheduler` which landed at a duplicated-owner path `github.com/kokarat/kokarat/...` due to a typo in the `project` field on the prior `arra_learn` call (extra `/kokarat` segment). Content is identical; only the project attribution is corrected. Per P-001 the mis-filed version is not deleted; it will be superseded by this one via `arra_supersede`.

**Flow affected:** `deposit-auto-expire-pending` step 7; also all other deposit + payout terminal callbacks via `services/callbackService.go` — the fix is cross-cutting.

**Today's gap (ratified as intentional-latent via thread #19):**

`services/callbackService.go:379-422` defines `ResendPendingCallbacks()` — scans `ts_deposits` and `ts_payouts` for `callback_url != "" AND callback_sent = false AND callback_attempts < maxRetries AND status IN <terminal-set>` and re-fires callbacks. Zero callers at `153a4f6`. Not dead code — human ruled "เขียนทิ้งไว้ยังไม่ได้ใช้" (drafted for later, not yet wired).

Consequence: client outage >~12s loses the terminal callback. Scheduler-killed-mid-tick is worse (detached goroutine dies silently).

**Required fix:**

1. Wire `ResendPendingCallbacks` to a scheduler (1-min tick, `lock:callback_resend`, batch 100).
2. Establish idempotency — human explicitly flagged "ต้องมั่นใจว่าจะไม่ส่งซ้ำ". The `callback_sent` flag alone is insufficient (race: HTTP 2xx lands, process dies before flag commit, resend fires duplicate).

   Options:
   - Opt A — client-side dedupe key (delivery UUID per attempt)
   - Opt B — server-side pre-commit flag with TTL (narrows race, doesn't eliminate)
   - Opt C — append-only per-attempt receipt log with response hashes
   - Opt D — Idempotency-Key header (Stripe pattern)

   Recommend **Opt C + Opt D**: server-side audit log + client-visible dedupe key.

**Scope:** follow-up feature PR, NOT the W8 doc pass. pg-writer files this as W4 queue item; escalates to human/code-reviewer for PR scoping.

**Related flows affected when fixed:**
- deposit-auto-expire-pending step 7 (this flow)
- deposit-auto-match-from-statement step 8 (PR #229)
- deposit-slip-upload-admin-approve terminal callback
- payout-request terminal callback
- withdrawal-queue-dispatch-and-claim callback cascade

**Evidence:**
- Code: `services/callbackService.go:379-422@153a4f6`
- Absence: `grep -rn ResendPendingCallbacks --include='*.go' .` returns only the definition
- Code: `services/callbackService.go:156-168@153a4f6` (inline retry)
- Thread: Oracle #19 Q-b + Q-d rulings
- Prior drift learning: `learning_2026-04-19_drift-deposit-auto-expire-pending-step-7-callb`

**Queued for W4.**

---
*Added via Oracle Learn*
