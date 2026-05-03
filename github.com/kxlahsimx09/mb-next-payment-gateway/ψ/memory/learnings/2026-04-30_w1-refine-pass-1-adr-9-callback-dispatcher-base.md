---
title: W1 refine pass 1 — §ADR-9 Callback Dispatcher baseline (`#provisional` `[RATIFIC
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-9, callback-dispatcher, outbox, at-least-once, idempotency, hmac, retry-budget, dead-letter, baseline, pass-1, provisional, ratification-pending, substrate-convergence-4-instances, thread-56-opened]
created: 2026-04-30
source: docs/adr.md@c3d4411 §ADR-9 + evidence bundle (3 mobiz learnings + W10 baseline) cited in §Revision log
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine pass 1 — §ADR-9 Callback Dispatcher baseline (`#provisional` `[RATIFIC

W1 refine pass 1 — §ADR-9 Callback Dispatcher baseline (`#provisional` `[RATIFICATION_PENDING:56]`).

Closes the load-bearing "callback-dispatcher ADR future" deferral marked across §ADR-4a / §ADR-4b / §ADR-4c. Pure architecture pass per user steering ("อยากจะให้จบแค่ ส่วนที่เป็น architecture decision เท่านั้น ไม่อยากให้หลุด scope ไป design"). Body 67 lines (well under 150-line extract threshold). Architecture-vs-design discipline held throughout — Decision #4 names the retry shape (fixed-step exponential / 6 attempts / dead_letter terminal) without naming the seconds; schema column shape, dispatcher EF body, merchant HTTP contract, admin recovery UX all explicitly Out-of-scope or Deferred.

Substrate convergence count incremented to 4 — §ADR-9 ports §ADR-3 thin-PL/pgSQL + EF-orchestration + pg_cron-sweep pattern (consumer-side; role-reversed from §ADR-4a/4b/4c atomic-RPC producers). Same hybrid push-pull pattern as §ADR-8 fair-router (Trigger A pg_notify + Trigger B sweep) — substrate precedent honored.

Five decisions (each [RATIFICATION_PENDING:56] anchored at the decision line):
- C1 substrate     = Edge Function + pg_notify trigger + pg_cron 1-min sweep (hybrid push-pull)
- C2 delivery      = at-least-once + producer-supplied event_id (= callback_queue.id) as merchant Idempotency-Key + no per-entity FIFO ordering guarantee
- C3 HMAC sign     = dispatch-time (per-retry fresh signature; merchant secret stays at dispatcher EF boundary; key-rotation re-signs in-flight without DB rewrite)
- C4 retry budget  = Phase-1 fixed-step exponential [1m, 5m, 15m, 1h, 6h, 24h] → 6 attempts → ~32h horizon → dead_letter; Phase-2 per-merchant config trigger-driven
- C5 dead-letter   = single-table callback_queue.status='dead_letter'; admin recovery surface deferred to admin-API ADR future; drop rejected by construction (financial events)

Six trade-off alternatives evaluated and rejected: A pure-sweep (60s tail unnecessary), B Realtime-only (silent dual-failure modes), C write-time-sign (couples secret to atomic RPC env, key rotation requires DB rewrite), D Phase-1 per-merchant config (premature abstraction), E drop after N (financial events must remain admin-recoverable), F per-entity FIFO (head-of-line block for no safety gain). 5 revisit triggers documented.

Prior-art bundle: 3 mobiz learnings + 4 in-repo ADR cross-refs + 2 mobiz threads (#19, #31). Constraints register (W10 first-run 2026-04-22) — `callback-webhook` theme deferred → no inheritance-surface constraint applies to §ADR-9 currently. Input 5 not needed (Input 1 cited mobiz code lines `services/callbackService.go:379-422` ResendPendingCallbacks unwired + `:156-168` inline retry, line-precise via prior learnings).

Threads opened: #56 (5 sub-questions C1-C5). Threads closed: none. Commit: c3d4411. PR #7 (open, not merged). Trace chain candidate: §ADR-4c pass-3 (f9c519ad) — §ADR-9 closes the consumer side of §ADR-4c Decision #4 outbox-row contract.

Pre-Input-5 checkpoint NOT triggered this pass — no "current does X" claim made without prior-learning citation. Instance-#6 escalation (from §ADR-4c pass-1.5 retro) does not recur. Body intentionally compact (67 lines vs §ADR-4c pre-extraction 190 lines) — pure architecture content with implementation surface pushed to deferred categories.

No sibling-cross-cut amendments needed — §ADR-9 closes a deferred deferral, doesn't reshape §ADR-4*. Sibling outbox-row contracts (§ADR-4a Decision #7 step iii / §ADR-4b Decision #5 step viii / §ADR-4c Decision #4) cite §ADR-9 retroactively at impl time; no ADR text update required from §ADR-9 baseline.

Next-pass candidate: §ADR-9 ratification (pass 2) when user answers C1-C5; then §ADR-9 body extraction (pass 3) IF body grows past threshold during ratification (currently at 67 lines — comfortably under). Wallet-table cross-cutting ADR remains the strongest standalone next-design candidate after §ADR-9 ratifies.

---
*Added via Oracle Learn*
