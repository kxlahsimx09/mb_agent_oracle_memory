---
title: poc-ready: §ADR-4c Deposit Auto-Expire — Pass-1 PoC at `poc/4c/` (Postgres-only-
tags: [implementation-architect, repo:mb-next-payment-gateway, next, 4c, poc, spec-test, pgtap, supabase-local, deposit-auto-expire, expire-rpc, view-contract, decision, poc-ready, fixture-source:vault-learning, fixture-source:repo-flow-doc, trace:bde8b561-1634-4d1d-a8bb-e3deb347d65f]
created: 2026-05-06
source: poc/4c/{README.md, src/*.sql, tests/*.spec.sql, mutation-tests.ts} + evidence/production-shape-summary.md + arra_trace bde8b561-1634-4d1d-a8bb-e3deb347d65f
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# poc-ready: §ADR-4c Deposit Auto-Expire — Pass-1 PoC at `poc/4c/` (Postgres-only-

poc-ready: §ADR-4c Deposit Auto-Expire — Pass-1 PoC at `poc/4c/` (Postgres-only-floor; reuses local Supabase from §ADR-4b/4a PoCs).

7 spec tests across 3 groups: A expire_deposit RPC atomicity + race semantics (4 — atomic flip+outbox, bundle-atomic-on-failure, race-guard, D3 asymmetric); B v_deposits view contract (2 — shows-expired-for-overdue-pending, passthrough-other-statuses); C sweep behavior (1 — flips-eligible-only). 33 assertions all green; 6 mutations all flip ≥1 expected red, 0 escapees. **First-run all green** — process improvements from §ADR-4a retro paid off.

Closes deposit-lane trio: §ADR-4b ✓ + §ADR-4c ✓ + (§ADR-4d future).

Trace ID: bde8b561-1634-4d1d-a8bb-e3deb347d65f (opened at Step 0 — first PoC pass to honor the §ADR-4a retro process improvement). Linked: this learning + production-shape evidence + retro pointer.

Production shape (mined 2026-05-06):
- 48,714 deposits at status='expired' (vs 351,991 paid; ~12% of paid-volume — heavy use)
- callback_logs 'deposit.expired' = 63,312 events, ~1.30 callbacks per expired deposit (production retry ~30% rate)
- DRIFT CANDIDATE flagged: production samples show updatedAt = createdAt despite status='expired' — current's expire flip path bypasses Mongoose middleware that would auto-bump updatedAt. Next-system PoC schema adds explicit expired_at column + auto-bump trigger on updated_at — closes this audit-timestamp drift structurally. Filed as [POC_NOTE:ADR-4c:current-updatedAt-drift] in evidence; pg-tester lane breadcrumb for current regression-candidate.

Process improvements landed (per §ADR-4a retro promises):
1. tests/_skel.sql template — DO-wrapped PERFORM example, plan/finish boilerplate. Used as reference; tests written first-try without PERFORM-outside-DO mistake.
2. run-tests.sh pre-flight grep for top-level `^[[:space:]]*PERFORM[[:space:]]` — catches the syntax error before psql does.
3. arra_trace opened at Step 0 — bde8b561-1634-4d1d-a8bb-e3deb347d65f.

Mutation iteration: Initial M-C wrote `AND expires_at > now()` thinking "add a filter that breaks the unfiltered guard". For fresh pending (expires_at in future), `> now()` is TRUE so RPC still flips → test 04 stayed green. Refined to `AND expires_at <= now()` (the *opposite-asymmetry* check; rejects admin maintenance-cancel on fresh pending) → mutation now correctly red 04. Lesson encoded in retro: when mutating asymmetric guards, write the *opposite-asymmetry*, not just any filter.

Substrate convergence (5th port): expire_deposit joins finalize_deposit + claim_withdrawal_items + link_statement_to_deposit + match_deposits_cascade as the 5th thin RPC for state-transition writes. Pattern durable across deposit + withdrawal lanes, reaching design-doc-stated convergence count.

D10 view contract is the most architecturally novel claim in this PoC — v_deposits.effective_status decouples real-time visibility (0-lag) from sweep-bound callback emission (≤60s). Tests 5 + 6 demo this directly.

Schema: ts_deposits (with explicit expired_at column + updated_at auto-bump trigger), callback_queue (with dedup_key UNIQUE), v_deposits computed view. RPCs: expire_deposit, sweep_expired_deposits.

Known gaps:
- [POC_GAP:ADR-4c:callback-timing-contract] — ≤60s sweep-bound delivery claim not testable cheaply (no time-travel; would need pg_cron actual scheduling test). Documented in README.
- [POC_GAP:ADR-4c:concurrent-sweep-tick-race] — multi-instance sweep race deferred (pg_cron single-instance assumption).

Next implement-architect lane candidates: §ADR-9 callback dispatcher (closes outbox→merchant path; consumer side; needs Bun-based dispatcher simulator); §ADR-4d slip-integration (closes deposit-lane); §ADR-3 full withdrawal lane with EF + bot simulator (first PoC requiring EF runtime).

---
*Added via Oracle Learn*
