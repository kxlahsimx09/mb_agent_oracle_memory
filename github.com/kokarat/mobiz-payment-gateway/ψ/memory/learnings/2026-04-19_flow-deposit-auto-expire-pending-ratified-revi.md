---
title: flow — deposit-auto-expire-pending — ratified revision (S2), thread #19 resolved
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, deposit-auto-expire-pending, ratified, deposit, scheduler, callback, expires-at]
created: 2026-04-19
source: docs/flows/deposit-auto-expire-pending.md@post-ratification + Oracle thread #19
project: github.com/kokarat/mobiz-payment-gateway
---

# flow — deposit-auto-expire-pending — ratified revision (S2), thread #19 resolved

flow — deposit-auto-expire-pending — ratified revision (S2), thread #19 resolved.

Supersedes `learning_2026-04-19_flow-deposit-auto-expire-pending-ttl-terminal` which carried the `ratification-pending` tag and described the doc's then-pending S4 state. This version is the post-ratification canonical record.

**Ratification outcome (thread #19, 2026-04-19 GMT+7):** S4 → S2. All four questions answered definitively.

**Spec as ratified:**

The `DepositExpiryScheduler` (`scheduler/deposit_expiry.go`) ticks every 1 minute, finds `ts_deposits` with `status=pending AND expires_at<=now AND is_deleted!=true AND expires_at!=zero` (batch 100), atomically flips each to `status=expired` with a `status=pending` race guard, publishes SSE `event=expired` on the `deposits` channel, and spawns detached goroutines to fire `deposit.expired` callbacks (HMAC-SHA256 signed, 3-attempt inline retry with 2s+4s+6s backoff, only when `callback_url != ""`). Lock `lock:deposit_expiry` with 55s TTL under 1-min tick is the safety valve against stuck ticks.

**Rulings:**

- **(a) Scope boundary.** TTL is the primary trigger; `scheduler/maintenance_cancel.go` is a sibling path with identical steps-4-onward semantics but different trigger (maintenance window instead of TTL). Ruling: **keep single TTL diagram with maintenance called out in prose** (§Error paths bullet + §Purpose). Not a drift; not a split. Quote: "เขียนอันเดียวได้ แต่ต้องมี log ไว้สักแห่งว่ามีอีกอันก็โอเค".
- **(b) `ResendPendingCallbacks` with zero callers.** Ruling: **latent — not-yet-wired, not dead code** ("เขียนทิ้งไว้ยังไม่ได้ใช้"). Doc retains `[DRIFT]` on step 7; paired with (d) into a single `#regression-candidate` follow-up.
- **(c) Late-arrival statement → `pending_review`.** Ruling: **safe non-resurrection confirmed, intentional** ("ไม่ควรจะทำ auto ต้องให้ admin จัดการ"). An expired deposit + late statement ends up parked for admin — `services/transactionMatcher.go:420-434` never resurrects the deposit. Parallel discipline to `deposit-auto-match-from-statement.md` thread #17 Q4d.
- **(d) Scheduler-killed mid-tick.** Ruling: **regression-candidate** ("เป็นช่องโหว่ ควรจะต้องถูก resend ได้ในภายหลัง และต้องมั่นใจว่าจะไม่ส่งซ้ำ"). Two requirements for the follow-up PR: (1) eventual delivery via wired resend scheduler, (2) idempotency guard so a race between `callback_sent=true` commit and process kill cannot produce duplicate deliveries.

**Artifacts:**

- Flow doc: `docs/flows/deposit-auto-expire-pending.md` at post-ratification state. Headers carry `// ratified-via-thread:19`. §Open questions renamed to §Resolved questions; all four `[AWAITING_THREAD:19]` markers stripped; `[RATIFICATION_PENDING:19]` stripped from header.
- W8 root trace: `43ead641-96bd-49f3-9813-53b69ffaab84`.
- Drift child trace (step 7): `856f08bc-3cfc-4e27-8a5d-9ffef8d2f277`.
- Regression-candidate learning (paired b+d): `learning_2026-04-19_regression-candidate-corrected-project-callbac` (supersedes the typo'd-project version). W4-queued.
- Drift learning on step 7: `learning_2026-04-19_drift-deposit-auto-expire-pending-step-7-callb` (still valid; the drift is ratified as real, not spurious).
- Thread #19: closed via `arra_thread_update(status=closed)`.

**[DRIFT] retained — when to strip:** when a future feature PR wires `ResendPendingCallbacks` + idempotency, a W9 pass picks up the new code pointer; W8 revision strips `[DRIFT]` from step 7 and relocates the §Resolved questions (b)+(d) content to §Change log.

**Cross-link follow-up:** §Change log notes the cross-link to `deposit-auto-match-from-statement.md` is deferred until PR #229 merges (that flow's PR). W9 or the next W8 revision pass will add `§Related flows` entries pointing to both sibling terminals once the auto-match flow is on main.

---
*Added via Oracle Learn*
