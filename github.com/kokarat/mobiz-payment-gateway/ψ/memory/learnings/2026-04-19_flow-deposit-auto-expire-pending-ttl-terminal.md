---
title: flow — deposit-auto-expire-pending — TTL terminal branch for pending deposits.
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, deposit-auto-expire-pending, reverse-engineered, ratification-pending, deposit, scheduler, callback, expires-at]
created: 2026-04-19
source: docs/flows/deposit-auto-expire-pending.md@153a4f6
project: github.com/kokarat/mobiz-payment-gateway
---

# flow — deposit-auto-expire-pending — TTL terminal branch for pending deposits.

flow — deposit-auto-expire-pending — TTL terminal branch for pending deposits.

The `deposit-qr-request` flow leaves a `ts_deposits` row with `status=pending` and an optional `expires_at`. If no Payer transfer ever arrives and no statement ever matches, the deposit must eventually reach a terminal state — clients expect a callback they can act on.

The `DepositExpiryScheduler` is that forcing function. Every 1 minute (`main.go:150`), it:
1. Acquires `lock:deposit_expiry` (55-second Redis lock — deliberate safety valve under 1-minute tick so a long tick cannot starve future ticks).
2. Batch-finds up to 100 deposits where `status=pending AND expires_at <= now AND is_deleted != true AND expires_at != zero`.
3. Per deposit, atomic `UpdateOne` with `status=pending` race guard → `status=expired, updated_at=now`. Guard-miss (`MatchedCount == 0`) means another path (matcher, maintenance-cancel, admin) flipped it first — safe, no duplicate callback.
4. Publishes SSE `event=expired` on the `deposits` channel.
5. Async goroutine fires `SendDepositCallback(..., EventDepositExpired)` when `callback_url != ""` — HMAC-SHA256 signed payload, inline 3-attempt retry with 2s+4s+6s backoff, persists `callback_sent` + `callback_attempts`.
6. Lock releases via `defer` (detached callback goroutines outlive the lock).

Three observable characteristics distinguish this flow from the two neighbours it relates to:

- **vs `deposit-auto-match-from-statement` (happy-path terminal):** both guard atomically on `status=pending`; whichever fires first wins. If the statement arrives AFTER expiry, the matcher takes a secondary path (`services/transactionMatcher.go:420-434`) that parks the statement in `bank_statements.match_status=pending_review` but does NOT resurrect the deposit — admin manual approval required. Safe non-resurrection per the same discipline as thread #17 Q4d ("ไม่ match ปลอดภัยกว่า false-match").
- **vs `deposit-slip-upload-admin-approve`:** slip upload flips the deposit to `status=checking` (not `pending`), which takes it out of this scheduler's filter. Slip-upload-parked deposits can therefore live indefinitely in `checking` without expiring; they only resolve via admin action.
- **vs `scheduler/maintenance_cancel.go` sibling path:** during a maintenance window, maintenance-cancel also writes `status=expired` on pending deposits — ignores `expires_at` entirely. From step 4 onward (atomic update → SSE → callback) the downstream effects are identical. The flow's §Error paths documents this as a prose-only sibling trigger (not drawn) to follow the same-discipline precedent set by auto-match's three triggers.

Four open questions folded into Oracle thread #19 for ratification:

(a) Scope boundary — TTL primary, maintenance sibling in prose only (current choice) or split into two flows / two diagrams?
(b) `services/callbackService.go:379-422` `ResendPendingCallbacks()` has zero callers in the tree — intentional (clients-must-poll, dead code to remove) or latent gap (forgot to wire to a scheduler)? Provisionally marked `[DRIFT]` on step 7; paired drift learning + child trace filed (`856f08bc-3cfc-4e27-8a5d-9ffef8d2f277`).
(c) Late-arrival statement → `pending_review` not resurrection — confirm safe-non-resurrection semantic?
(d) Scheduler-killed mid-tick loses detached callbacks — intentional operational caveat, or regression-candidate for the same resend machinery that (b) would introduce?

Claim strength **S4** pending thread #19. W8 root trace: `43ead641-96bd-49f3-9813-53b69ffaab84`.

---
*Added via Oracle Learn*
