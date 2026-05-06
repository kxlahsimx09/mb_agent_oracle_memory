---
title: poc-ready: §ADR-4d Deposit Slip Integration + V1/V2 Fraud Detection — Pass-1 PoC
tags: [implementation-architect, repo:mb-next-payment-gateway, next, 4d, poc, spec-test, pgtap, supabase-local, deposit-slip-integration, v1-fraud, v2-fraud, force-approve, append-only, decision, poc-ready, fixture-source:vault-learning, trace:b49e94e3-4679-449f-87d1-03ad78028cc9, deposit-lane-trio-complete]
created: 2026-05-06
source: poc/4d/{README.md, src/*.sql, tests/*.spec.sql, mutation-tests.ts} + evidence/production-shape-summary.md + arra_trace b49e94e3-4679-449f-87d1-03ad78028cc9
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# poc-ready: §ADR-4d Deposit Slip Integration + V1/V2 Fraud Detection — Pass-1 PoC

poc-ready: §ADR-4d Deposit Slip Integration + V1/V2 Fraud Detection — Pass-1 PoC at `poc/4d/` (Postgres-only-floor; reuses local Supabase). Closes deposit-lane trio (4b ✓ + 4c ✓ + 4d ✓).

7 spec tests / 42 assertions all green; 6 mutations all flip expected red; 0 escapees.

Trace: b49e94e3-4679-449f-87d1-03ad78028cc9 (depth 2, parent 603fb3d5… §ADR-9). Deposit-lane chain: 4c → 9 → 4d.

Group A — slip metadata + admin terminal (3):
  01 slip-upload-saves-metadata-only-no-status-flip (D2)
  02 admin-paid-credits-wallet-via-rpc (D5 paid path)
  03 admin-failed-requires-reason-and-skips-wallet-credit (D5 failed path)

Group B — V1+V2 fraud cascade (3):
  04 v2-receiver-mismatch-fail-closed-on-missing-data (deliberate divergence #5 from mobiz current's fail-open)
  05 v1-blocks-on-match-hash-collision-with-prior-deposit (V1 amendment; consumer of §ADR-4b amendment B7)
  06 force-approve-literal-bypasses-v1-and-v2 (C5 super_admin override)

Group C — append-only verify history (1):
  07 slip-verify-attempts-append-only-rejects-update-and-delete (D9; parallel to §ADR-9 D6 callback_attempts pattern)

Process improvement validated: PERFORM lint pre-flight in run-tests.sh CAUGHT a real bug this pass. Test 06 had top-level `PERFORM poc4d._seed_statement(...)` — lint flagged before psql could fail. Wrapped in DO block. Lint refined to use awk + DO-block boundary tracking ($$..$$) so that PERFORM inside DO blocks is allowed. Captured in retro.

Production grounding (mined 2026-05-06):
  - V2 caught 905 / 8736 slip-deposits / 90d (~10.36%, ~1.07M THB direct loss prevented; mobiz #360)
  - V1 caught DEP17777364940AC8L3 + DEP1777733674IBGAQO 3 พ.ค. 2026 (mobiz #362)
  - Slip flow lives in `topups` collection in current; next-system unifies into `ts_deposits` per §ADR-4d D2

Architectural simplification confirmed: V3 caller-guard (mobiz #361) replaced by §ADR-13 D1 endpoint separation — bot endpoint structurally rejects slip-bearing deposits at Layer 1 sync-validation; runtime V3 redundant. PoC respects the architectural decision (no V3 implementation).

D9 append-only `slip_verify_attempts` parallels §ADR-9 D6 `callback_attempts` exactly:
  - Same shape: append-only forensic log + denormalized counter on parent row
  - Same trigger pattern: BEFORE UPDATE/DELETE raise 'append-only blocked'
  - Same atomic-RPC: record_*_attempt INSERTs row + UPDATEs parent denorm in one tx
  - Two ADRs ratify the same pattern across 2 domains (Thunder verify history vs callback delivery history) — pattern durable

Substrate convergence count: 6 thin RPCs (after upload_slip + admin_approve_paid/failed + record_slip_verify_attempt). Pattern across deposit-lane + withdrawal-lane + callback-dispatcher.

Wall-clock: ~1.5h end-to-end (vs 9 ~3h, 4c 1h, 4a 1.75h, 4b 3.5h). Pattern reuse + skel template + lint pre-flight + mental model calibration → fastest pgTAP-only PoC of the series.

Next implement-architect candidates: §ADR-3 full withdrawal lane EF + bot simulator (first PoC needing EF runtime; ~3-4h with new tooling tax); §ADR-11 idempotency contract (smaller scope, ~1-2h).

---
*Added via Oracle Learn*
