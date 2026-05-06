---
title: poc-ready: §ADR-9 Callback Dispatcher — Pass-1 PoC at `poc/9/` (first PoC needin
tags: [implementation-architect, repo:mb-next-payment-gateway, next, 9, poc, spec-test, bun-test, supabase-local, callback-dispatcher, outbox, at-least-once, hmac, dead-letter, decision, poc-ready, fixture-source:vault-learning, trace:603fb3d5-c8ec-4914-a185-686919972d10]
created: 2026-05-06
source: poc/9/{README.md, src/*.{sql,ts}, tests/*.test.ts, mutation-tests.ts} + evidence/production-shape-summary.md + arra_trace 603fb3d5-c8ec-4914-a185-686919972d10
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# poc-ready: §ADR-9 Callback Dispatcher — Pass-1 PoC at `poc/9/` (first PoC needin

poc-ready: §ADR-9 Callback Dispatcher — Pass-1 PoC at `poc/9/` (first PoC needing HTTP layer; Bun-based dispatcher + mock merchant; co-exists with poc4a/4b/4c).

7 tests via bun:test (3 atomicity+idempotency + 2 retry-budget + 2 forensic-log); 37 expect() calls; ~105ms; 6/6 mutations all flip expected red, 0 escapees.

Trace: 603fb3d5-c8ec-4914-a185-686919972d10 (child of bde8b561 via arra_trace parentTraceId — first cross-PoC trace chain link).

Group A — at-least-once + idempotency-key contract:
  01 at-least-once-delivery-with-merchant-flake (5xx then 200, both attempts logged)
  02 event-id-header-stable-across-retries (X-Event-Id == callback_queue.id, all retries)
  03 dispatch-time-hmac-uses-current-secret (rotation between attempts → fresh sig)

Group B — retry budget + dead-letter:
  04 retry-budget-exhausted-routes-to-dead-letter (3 fails → status=dead_letter)
  05 delivered-row-not-redispatched (sweep poll filters out terminal rows)

Group C — append-only forensic log + denorm:
  06 callback-attempts-append-only-rejects-update-and-delete (BEFORE-trigger guard)
  07 denorm-counter-and-attempts-count-stay-in-sync (record_attempt RPC writes both atomically)

Production data grounding (mined 2026-05-06):
  - 591,561 callback_logs total events; attempt=1 91.4% success; attempt=2 24% recovery; attempt=3 9% recovery
  - Current caps at attempt=3 → callback lost after that (regression-candidate b+d documented in vault)
  - §ADR-9 D4 extends to 6 attempts → dead_letter terminal (admin-recoverable)
  - Failure shape: 100k Client.Timeout (dominant) + 4k 404 + 1.4k 403

Substrate convergence reaches 4th port per §ADR-9 §Consequences (atomicity+idempotency dispatcher pattern joins finalize_deposit / claim_withdrawal_items / expire_deposit lineage).

Notable Bun.SQL gotcha: `await expect(sql\`...\`).rejects.toThrow(...)` pattern hangs on Bun.SQL pool when the rejected query leaves the connection in dirty state. Workaround: use try/catch directly. Captured in retro Honest Feedback. Pattern likely affects future PoCs that test PG-level error paths via bun:test.

Schema: merchant_config + callback_queue (status enum + attempt_count + last_attempt_id denorm) + callback_attempts (BEFORE UPDATE/DELETE triggers raise — append-only). RPCs: record_attempt (atomic insert+denorm), mark_delivered, mark_dead_letter (race-guarded pending-only).

Dispatcher (TS): pure-function processQueue(sql, opts) — polls pending rows, signs at dispatch time using current merchant.secret, POSTs with X-Event-Id + X-Signature, classifies response 2xx → mark_delivered / 5xx-or-error → record_attempt + mark_dead_letter when attempts exhausted. Mock merchant: programmable behaviors (always_200 / always_500 / fail_n_then_succeed / timeout_always); per-event-id signature recording for assertions.

Out of scope (deferred to future passes):
  - D1 substrate (pg_notify + pg_cron + advisory-lock cost-coalescing) — load-bearing for cost/throughput, not delivery semantics
  - Exact retry intervals (D4 illustrative `[1m,5m,15m,1h,6h,24h]` shape — PoC uses 3-attempt cap compressed)
  - Admin recovery surface for dead-letter rows
  - Per-merchant retry config (D4 Phase-2 trigger)

Now closes the merchant-facing leg of the system. All 4 producer PoCs (4a/4b/4c) enqueue rows that are now provably consumable. End-to-end deposit + withdrawal + expire flows have an at-least-once delivery contract validated.

Next implement-architect candidates: §ADR-4d slip integration (closes deposit-lane); §ADR-3 full withdrawal lane EF + bot simulator; or §ADR-11 idempotency contract (client-facing API).

---
*Added via Oracle Learn*
