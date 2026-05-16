# Session handoff — implementation-architect, 2026-05-06 → 2026-05-07

Closing first major activation of `next-impl` (implementation-architect role) on `mb-next-payment-gateway`. **All 6 PoCs + maintenance + smoke merged to main.** Next session can pick up at Step 1 of the next PoC pass.

## What was delivered (6 PoCs + 2 infra)

| # | ADR | Tests / Assertions / Mutations | Wall-clock |
|---|---|---|---:|
| 1 | §ADR-4b auto-match + cascade | 10 / 49 / 6/6 | 3.5h |
| 2 | §ADR-4a withdrawal lane | 10 / 40 / 7/7 | 1.75h |
| 3 | §ADR-4c auto-expire + view contract | 7 / 33 / 6/6 | 1h |
| 4 | §ADR-9 callback dispatcher (first HTTP layer) | 7 / 37 / 6/6 | 3h |
| 5 | §ADR-4d slip + V1+V2 fraud (closes deposit-lane trio) | 7 / 42 / 6/6 | 1.5h |
| 6 | §ADR-11 idempotency contract | 7 / 36 / 5/5 | 1.5h |
| — | Cross-PoC integration smoke (poc/smoke) | 36 assertions / 6 scenarios / ~0.6s | 30m |
| — | Maintenance — runner plan-N fix backport (4a/4b/4c + 4d) + hidden bug fix | — | 25m |

**Totals: 48 spec tests / 237 assertions / 36/36 mutations pin claim / 0 escapees / ~12.75h.**

## Substrate convergence — 12 thin RPCs

| Port # | RPC | ADR |
|---|---|---|
| 1-5 | claim_withdrawal_items / finalize_deposit / link_statement_to_deposit / match_deposits_cascade / expire_deposit | 4a/4b/4c |
| 6-7 | record_attempt / mark_delivered+mark_dead_letter (callback) | 9 |
| 8-10 | upload_slip / admin_approve_paid+failed / record_slip_verify_attempt | 4d |
| 11-12 | acquire_idempotency_slot / complete_idempotency_record | 11 |

Pattern: every state-transition write goes through a thin RPC with race-guard + atomic primitive. §ADR-3 thin-PL/pgSQL boundary durable across deposit + withdrawal + outbox + slip + idempotency lanes.

## Trace chain (deposit-lane → callback → slip → idempotency)

```
bde8b561 (4c, root)  →  603fb3d5 (9)  →  b49e94e3 (4d)  →  fc004856 (11)
```

Future PoCs can `arra_trace` with `parentTraceId` to extend the chain.

## Process improvements baked in (use these in future passes)

1. **`tests/_skel.sql` template** (per 4a retro promise) — DO-wrapped PERFORM example, plan/finish boilerplate. Copy at scaffold time.
2. **`run-tests.sh` PERFORM lint** (awk-aware of `$$..$$` DO-block boundaries) — catches top-level PERFORM before psql does.
3. **`run-tests.sh` plan-N check** — extract `1..N` from output; require `n_total == plan_n` for PASS. **Prevents silent mid-flight aborts being marked PASS.** Critical fix; backported to all pgTAP runners.
4. **`arra_trace` opened at Step 0 of each pass** (per 4a retro promise) — link via `parentTraceId` to prior session anchor.
5. **SHA-256 helper:** `extensions.digest('payload', 'sha256')` — pgcrypto lives in `extensions` schema in Supabase, not `public`. Helper functions need `SET search_path = pocXX, extensions, public`.
6. **Mock merchant pattern** (poc/9/src/mock-merchant.ts) — programmable behavior + per-event-id signature recording. Reusable for future HTTP-layer PoCs.

## Lessons captured (mining + tooling)

### Mining discipline (from architect's correction on thread #81)

I quoted "100k+ topups records" — production has 22. 3 errors:
- **Quoted counts from memory; didn't re-verify before drift report** → next time: re-run count query before quoting numbers in any architect-facing message.
- **Probed only PRESENT fields** in `topups` schema → next time: probe ABSENT fields too (no callback_url + no customer_id in topups → "this is not a deposit"; load-bearing).
- **Fabricated a use case from intuition** → next time: confirm use case exists at production scale (`COUNT WHERE shape-matches`) before architecting around it.

### Tooling-bug discipline (from runner fix discovery)

- **Mutation testing is also harness validation** — runner bug existed for 5 PoCs before mutation harness exposed it. Pattern: mutations exercise edge cases that happy-path tests don't.
- **Copy-pasted infrastructure inherits its bugs.** Audit load-bearing logic at copy-time, not just at first-write.
- **pgTAP 1.2 in Supabase doesn't ship `unlike`** — use `doesnt_match` (drop-in replacement). Hidden bug in poc/4a/test 09 silently passed for a day before runner fix surfaced it.

## Open architectural threads (architect to drive)

§ADR-4d gap was misframed by me; architect remapped to 3 tracks. **Not blocking; future PoC passes can fork after architect ratifies:**

- **Track 1 — §ADR-13 amendment** (actor tier: add `client_web_user`) → architect to open thread #82
- **Track 2 — §ADR-4d D1 amendment** (slip_uploaded_by audit triple; depends on Track 1) → thread #83
- **Track 3 — §ADR-16 NEW** (Client Self-Topup B2B; distinct entity from deposits) → thread #84

When tracks ratify, next-impl can:
- Continue use case 1 PoC unchanged (deposit slip-fallback flow)
- Add `slip_uploaded_by` audit field as Pass 2 of §ADR-4d
- Author separate PoC for §ADR-16 (Client Self-Topup) when its baseline ratifies

## Recommended next single-PoC

Ranked by payoff vs cost:

1. **§ADR-10 wallet substrate** — explicit single-discriminated-table + canonical lock-order. Already implicitly tested via 4a/4b but worth explicit PoC. ~2h pgTAP. Orthogonal; no upstream dependencies.

2. **§ADR-13 admin-API surface** (only after Track 1 amendment ratifies) — 3-layer write invariant + audit canonical-with-trigger-denorm + RBAC resource-split. ~2-3h pgTAP.

3. **§ADR-3 §ADR-4a Pass-2 concurrent claim** — first PoC needing real 2-connection harness (Bun postgres lib opening 2 conns simultaneously). Tests SKIP LOCKED behavior under true concurrency; closes `[POC_GAP:ADR-4a:concurrent-claim-test]`. ~3-4h with new tooling.

## Substrate state

- **Local Supabase:** running at `127.0.0.1:54322` (postgres/postgres). 6 schemas coexist: `poc4a`, `poc4b`, `poc4c`, `poc4d`, `poc9`, `poc11`. State persists across sessions until `supabase stop`.
- **MCP `dpay`** registered at user scope (works across worktrees) — read-only MongoDB to mobiz current production. Connection healthy.
- **Worktree:** `mb-next-payment-gateway.wt-3-20260506-114431` — branch `impl/maintenance-runner-fix-2026-05-07` (after PR #29 merge → can branch from main).

## Vault entries filed this session

Learnings (6 + 1 maintenance candidate):
- `2026-05-06_poc-ready-adr-4b-d5-atomic-finalizedeposit-d2`
- `2026-05-06_poc-ready-adr-4a-withdrawal-dispatch-claim-p`
- `2026-05-06_poc-ready-adr-4c-deposit-auto-expire-pass-1-po`
- `2026-05-06_poc-ready-adr-9-callback-dispatcher-pass-1-poc`
- `2026-05-06_poc-ready-adr-4d-deposit-slip-integration-v1v`
- `2026-05-07_poc-ready-adr-11-idempotency-contract-pass-1-p`

Retros (6 in `ψ/memory/retrospectives/2026-05/{06,07}/`):
- `06/13.50_adr-4b-pass-1-poc.md`
- `06/16.05_adr-4a-pass-1-poc.md`
- `06/16.50_adr-4c-pass-1-poc.md`
- `06/18.56_adr-9-pass-1-poc.md`
- `06/20.44_adr-4d-pass-1-poc.md`
- `07/09.40_adr-11-pass-1-poc.md`

Traces: 1 (`bde8b561`, depth 0) + 3 chained children (`603fb3d5`, `b49e94e3`, `fc004856`).

## Closing remarks

First activation of `next-impl` ran ~12.75 hours of focused work across 2 calendar days. Six ADR claims falsified through 237 spec assertions and 36 mutations; one architectural drift surfaced + correctly remapped via thread #81 dialogue with architect; one tooling bug discovered + backported. Pattern compounding visible: 3.5h → 1.5h baseline by PoC #6.

Hand-off to next session.

— next-impl, 2026-05-07 GMT+7
