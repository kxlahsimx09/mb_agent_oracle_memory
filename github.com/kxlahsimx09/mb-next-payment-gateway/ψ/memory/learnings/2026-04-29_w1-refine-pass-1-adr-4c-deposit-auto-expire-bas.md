---
title: W1 refine pass 1 — §ADR-4c deposit-auto-expire baseline (`#provisional`, thread 
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-4c, deposit, auto-expire, ttl, scheduler, callback, atomic-boundary, substrate-convergence, provisional, ratification-pending, baseline, pass-1]
created: 2026-04-29
source: docs/adr.md@af89309 + thread #55 + flow:deposit-auto-expire-pending mobiz thread #19 (S2)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine pass 1 — §ADR-4c deposit-auto-expire baseline (`#provisional`, thread 

W1 refine pass 1 — §ADR-4c deposit-auto-expire baseline (`#provisional`, thread #55).

Authored §ADR-4c between §ADR-4b and §ADR-4d in `docs/adr.md` (118 lines added; no other sections touched). Completes the deposit-lane trio (4a withdrawal / 4b auto-match / 4c auto-expire / 4d slip-integration). Designs the TTL-terminal branch for pending deposits.

## Substrate convergence (4th port)

`expire_deposit(p_deposit_id)` RPC follows the same thin-PL/pgSQL atomic-boundary shape as §ADR-4a `claim_withdrawal_items`, §ADR-4b `finalize_deposit`, §ADR-4d (admin approve reuses §4b RPC). ADR-3 atomic-wallet-ops substrate is fully general-purpose across deposit/withdrawal lane.

## Two regression-candidates from current closed structurally (Decision #4)

- **(b) latent `ResendPendingCallbacks`** (zero callers in current) — replaced by outbox-row + downstream callback dispatcher (separate ADR future). Resend semantics live in dispatcher, not engine.
- **(d) scheduler-killed mid-tick race** (between `callback_sent=true` commit and process death) — closed by construction via in-RPC `INSERT INTO callback_queue` in same transaction as status flip. Process-kill atomicity guaranteed.

## One substrate simplification

Redis `lock:deposit_expiry` (55s TTL Redis lock under 1-min tick in current) **removed** — pg_cron single-instance + per-row `FOR UPDATE` + race-guard suffices.

## 9 numbered Decisions

1. TTL source = `expires_at` column on `ts_deposits` (parity)
2. Sweep = pg_cron 1-min job, batch 100 (parity; cadence open as C1)
3. Atomic boundary = `expire_deposit(p_deposit_id)` RPC with status race-guard
4. Callback emission = in-RPC outbox row, same transaction as status flip (closes regression-candidates by construction; open as C2)
5. SSE notification via §ADR-5 Realtime Postgres Changes (substrate convergence — no separate emit call site)
6. Late-arrival statement after expire → non-resurrection (rely on §ADR-4b matcher's `WHERE status='pending'` filter; ratification (c) parity; open as C4)
7. Race with §ADR-4d slip-fallback — expire wins on short TTL (already specified in §ADR-4d Decision #7; race-guard makes deterministic)
8. Sweep lock primitive = none (pg_cron single-instance + per-row FOR UPDATE; open as C5)
9. Maintenance-cancel sibling — RPC reuse, full design out of scope (admin-API ADR future; open as C3)

## Open ratification questions (thread #55)

- C1 — Sweep cadence: 1-min parity (rec) vs 30s vs configurable
- C2 — Callback emission: in-RPC outbox (rec) vs after-commit pg_notify (rejected) vs inline pg_net (rejected)
- C3 — Maintenance-cancel scope: out of §ADR-4c body, RPC-reuse contract only (rec) vs include full body
- C4 — Late-arrival statement: rely on §ADR-4b matcher filter (rec) vs explicit reconciliation step
- C5 — Sweep lock primitive: none required (rec) vs port to Postgres advisory lock

## Process note — first pass under mandatory `arra_trace` workflow

This is the first W1 pass after brew-ops landed the workflow patch at central commit `0d47997` (2026-04-29 GMT+7) per thread #54 — `arra_trace` + `arra_trace_link` promoted from "Optional" to mandatory in Step 8. Pass exercises the chain primitive end-to-end: this `arra_learn` → followed by `arra_trace` (capture pass) → `arra_trace_list query="ADR-4b ratification"` (find sibling-completion predecessor) → `arra_trace_link` to chain.

Threads opened: #55. Threads closed: none. Commit: `af89309` on branch `architect/w1-refine-adr-4c-deposit-auto-expire-2026-04-29` / PR [#5](https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/5). Next pass candidate: §ADR-4c ratification when user engages thread #55, OR wallet-table cross-cutting ADR if user wants to step away from deposit lane.

---
*Added via Oracle Learn*
