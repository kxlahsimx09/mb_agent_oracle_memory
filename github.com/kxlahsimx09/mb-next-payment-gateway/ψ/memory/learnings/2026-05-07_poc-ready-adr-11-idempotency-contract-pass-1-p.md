---
title: poc-ready: §ADR-11 Idempotency Contract — Pass-1 PoC at `poc/11/` (Postgres-only
tags: [implementation-architect, repo:mb-next-payment-gateway, next, 11, poc, spec-test, pgtap, supabase-local, idempotency, stripe-pattern, decision, poc-ready, fixture-source:vault-learning, trace:fc004856-6c41-4be5-b5e2-0027aba3fd62, tooling-bug-discovered]
created: 2026-05-07
source: poc/11/{README.md, src/*.sql, tests/*.spec.sql, mutation-tests.ts} + arra_trace fc004856-6c41-4be5-b5e2-0027aba3fd62
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# poc-ready: §ADR-11 Idempotency Contract — Pass-1 PoC at `poc/11/` (Postgres-only

poc-ready: §ADR-11 Idempotency Contract — Pass-1 PoC at `poc/11/` (Postgres-only-floor; 6th PoC of session).

7 spec tests / 36 assertions all green; 5 mutations all flip expected red, 0 escapees (after runner bug fix).

Trace: fc004856-6c41-4be5-b5e2-0027aba3fd62 (depth 3; chain: 4c → 9 → 4d → 11). 4 PoCs deep in deposit-lane → callback → slip → idempotency.

Group A — D4 conflict-semantics 4-case matrix:
  01 new-key-stored-and-response-recorded
  02 same-key-same-body-replays-stored-response (replay-safe)
  03 same-key-different-body-returns-409-conflict (body-hash detects integration bug)
  04 expired-key-treated-as-new (TTL purge)

Group B — D1+D2+D5 architectural invariants:
  05 uniqueness-scoped-per-client-and-endpoint (composite key — different clients/endpoints can reuse same key)
  06 concurrent-acquire-only-one-wins (FOR UPDATE race-safe primitive)
  07 acquire-and-complete-bundle-atomic-on-failure (state machine pending → completed; race-guard on completion)

Schema: idempotency_keys (id, client_id, endpoint, key, request_hash, state, response_status, response_body, expires_at, created_at, completed_at; UNIQUE (client_id, endpoint, key)).

RPCs: acquire_idempotency_slot (race-safe slot acquisition — returns 'new'|'replay'|'replay_pending'|'conflict'); complete_idempotency_record (atomic state flip with race-guard).

🐛 RUNNER BUG DISCOVERED + FIXED DURING THIS POC:
  Mutation harness initially reported M-B + M-E as escapees. Root cause: run-tests.sh counted PASS based on `n_notok == 0 AND n_total > 0` — but didn't check n_total == plan_N. Tests that aborted mid-flight via SQL ERROR (e.g., 'duplicate key value violates unique constraint') emitted some 'ok' lines then ERROR. Old runner saw '1 ok / 0 not_ok' → PASS; new runner sees '1 ok / 7 planned' → FAIL with 'aborted mid-flight' indicator.

  This bug affected ALL prior PoC runners (4a/4b/4c/4d/9). None reported escapees historically, but the bug means: silent mid-flight aborts COULD have been classified as pass. RECOMMENDATION: backport fix to prior PoCs as maintenance pass.

  Captured as Honest Feedback in retro. **Pattern: tooling bugs surface only when mutation testing exercises edge cases.** Mutation testing not just for spec-tests; also for the harness itself.

Production grounding (mined 2026-05-06):
  - Current mobiz has NO client-API idempotency (PR #200 server-derived request_id is matcher-internal only)
  - Production incident PAY1776286617S2B53L (2026-04-16): cross-link surface when matcher uses amount+account-only without disambiguator. §ADR-11 closes the client-side analogue at API surface
  - 22 records in `topups` (architect's verification) — separate B2B flow, not deposit-with-idempotency

Substrate convergence count reaches 12 thin RPCs across 6 PoCs. Pattern across deposit + withdrawal + outbox + slip + idempotency: every state-transition write goes through a thin RPC with race-guard + atomic primitive.

D5 architectural-invariant-as-shared-middleware shape (parallel to §ADR-10 D5 canonical lock-order + §ADR-11 D5 idempotency invariant) — 2nd instance of "coordination-rule-as-architectural-invariant" pattern. Future PoCs that want to encode "every X must Y" should follow this pattern: shared middleware enforces; endpoint authors cannot opt out; constraint tested at substrate boundary.

Wall-clock: ~1.5h (matches 4d timing; pgTAP-only PoCs converge to ~1-1.5h baseline at PoC #6+).

Next implement-architect candidates: §ADR-10 wallet substrate (explicit lock-order + single-discriminated-table; ~2h pgTAP); §ADR-13 admin-API surface (3-layer write invariant + audit + RBAC; ~2-3h); §ADR-3 EF + bot simulator for full §ADR-4a Pass-2 (concurrent claim test + EF wrapper; ~3-4h new tooling).

---
*Added via Oracle Learn*
