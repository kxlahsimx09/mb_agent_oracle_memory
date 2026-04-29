---
title: §ADR-4d post-ratification amendment — 4 user-driven clarifications shipped same 
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-4d, amendment, post-ratification, thunder-informational, symmetric-admin-gatekeeper, verify-slip-now, append-only-history, slip-verify-attempts-table, in-scope-refinement, user-surfaced-clarifications, amendment-cycle-pattern]
created: 2026-04-28
source: docs/adr.md@89338dd §ADR-4d (post-amendment) + user clarification messages 2026-04-27 evening + thread:#53 closed message context
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# §ADR-4d post-ratification amendment — 4 user-driven clarifications shipped same 

§ADR-4d post-ratification amendment — 4 user-driven clarifications shipped same day; Decisions #4 + #5 revised, Decisions #8 + #9 added.

User read ratified §ADR-4d carefully and surfaced 4 clarifications within hours of ratification (2026-04-27 GMT+7 evening). All within-scope refinements — no C1-C5 reversal; no re-ratification thread needed.

Amendments shipped:

A1 (Decision #4 revised) — Thunder verdict is informational only. Three verdict outcomes captured in `slip_verify_attempts` (Decision #9): genuine | forged | thunder_system_error. Status flips pending → checking REGARDLESS of verdict. Thunder forged-verdict does NOT auto-flip to failed. Admin owns terminal decision.

User quote driving A1: *"ถ้า slip ปลอมต้องบอกว่าปลอมแล้ว ให้ admin เป็นคนกด failed พร้อมให้เค้าใส่เหตุผลเอง"*

A2 (Decision #5 expanded) — Symmetric admin gatekeeper for both terminals:
- PUT /deposits/:id/status=paid → finalize_deposit RPC → wallet credit + MDR + transactions + deposit.completed callback (admin reason optional, approval is signal)
- PUT /deposits/:id/status=failed + reason=<admin's text> → deposit.failed callback (admin's own reason text REQUIRED, not Thunder verdict copy-paste)

Both terminal transitions admin-owned. Generalizes C4 ratified Option D from "admin always-in-loop for paid" to "admin always-in-loop for paid AND failed". Thunder is informational input; never a terminal trigger.

A3 (Decision #8 added) — POST /admin/deposits/:id/verify-slip-now endpoint. JWT + admin permission. One deposit per call (user ratified "เลือกทำได้ทีละอัน"). Pre-condition: slip_uploaded_at NOT NULL AND status IN ('pending', 'checking'). Race-guard: 409 Conflict on terminal statuses. Same verify-slip EF body as sweep — single source of truth, no duplication. Use case: admin doesn't want to wait for T+15min sweep; clicks "verify now" in admin UI.

User quote driving A3: *"จะต้องมีเส้น ให้ admin กด เพื่อ verify slip ทันที"*

A4 (Decision #9 added) — slip_verify_attempts append-only table:

```sql
CREATE TABLE slip_verify_attempts (
    id                       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    deposit_id               uuid NOT NULL REFERENCES ts_deposits(id),
    attempted_at             timestamptz NOT NULL DEFAULT now(),
    triggered_by             text NOT NULL,        -- 'sweep_auto' | 'admin_verify_now' | 'system_retry'
    triggered_by_username    text,                 -- nullable; populated on admin path
    thunder_response_raw     jsonb,                -- full Thunder API response
    verdict                  text NOT NULL,        -- 'genuine' | 'forged' | 'thunder_system_error' | 'thunder_timeout'
    error_message            text,
    duration_ms              int                   -- monitoring
);
CREATE INDEX idx_slip_verify_attempts_deposit_id
    ON slip_verify_attempts(deposit_id, attempted_at DESC);
```

No UPDATE/DELETE per P-001. ts_deposits denormalize: slip_latest_verify_attempt_id (FK), slip_verify_attempt_count (counter), slip_verify_result (latest verdict denorm for fast read).

Re-verify allowed on status IN ('pending', 'checking'). Terminal statuses (paid, failed, expired, cancelled) lock retry. Rate-limit policy deferred to implementation phase per user "defer ไว้ก่อน".

User quote driving A4: *"มันอาจจะมี slip verify ซ้ำ trigger กี่ครั้งก็ได้ ... ผล result จะถูกทับถูกไหม อาจจะต้องแยกเก็บ"*

3 architect-recommendation confirmations from user:
- "1. แยกเลย" — separate table (vs jsonb array on ts_deposits)
- "2. ตามที่แนะนำ" — re-verify on pending+checking
- "3. defer ไว้ก่อน" — rate-limit deferred

Section size: 70 → 99 lines (+29 lines). Under 150-line extract threshold.

Pattern observation — same-session amendment cycle (4th instance):
- §ADR-8 had 5 pre-ratification amendments same day (Trigger B, withdrawal-only metric correction, completeness sub-amendment, business-constraint, doc cleanup)
- §ADR-4b had 0 amendments after ratification (clean ratify)
- §ADR-4d now has 4 post-ratification amendments

Pattern stable enough to capture as durable workflow shape:

> "After ratification, expect 1-3 user-surfaced clarifications within hours/days. Frame as in-scope amendments if they refine direction; frame as new ratification thread if they invert direction. Discriminator: does clarification CONTRADICT C1-Cn answers, or REFINE implementation of those answers? If refine → amendment. If contradict → new thread."

Today's amendments all clearly fall in "refine" — Thunder informational, terminal symmetry, history preservation, explicit verify-now action — none reverse C1-C5; all add granularity within ratified shape.

Cross-references preserved:
- §ADR-4b Decision #5 finalize_deposit RPC reused as paid terminal
- §ADR-4b Decision #6 admin manual re-match parallel "admin action endpoint" pattern reused for verify-slip-now
- §ADR-4c future auto-expire edge case (Decision #7 unchanged)
- §ADR-2 RBAC for admin permissions
- §ADR-5 SSE for slip_verified event

Threads opened: none. Threads closed: none (within-scope amendment; thread #53 stayed closed).

arra_supersede applied: original §ADR-4d ratification learning → amendment learning per P-001 (within-scope refinement chain; original ratification preserved + this amendment is the post-amendment authoritative record).

Commit: 89338dd on PR #4. Backfill commit forthcoming.

Next-pass candidates:
- §ADR-4c (auto-expire) baseline — completes deposit-lane trio
- Wallet-table cross-cutting ADR — atomic boundary
- Deposit-create API ADR — entry point gap
- Callback dispatcher ADR — covers deposit.completed + deposit.failed events from §ADR-4b/4d

---
*Added via Oracle Learn*
