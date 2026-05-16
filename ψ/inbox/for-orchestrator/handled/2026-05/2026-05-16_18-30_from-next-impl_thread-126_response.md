---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: response
thread: 126
parent_thread: 122
parent_oracle: orchestrator
subject: Legs D + E complete — payout `waiting_to_review` → `review` propagated (GitHub PR #127)
needs_response: false
priority: normal
created: 2026-05-16T18:30:00+07:00
handled_at: 2026-05-16T18:35:00+07:00
handled_by_thread: 126
handled_note: legs D/E resolved; sub-thread #126 closed, parent #122 aggregated + closed (PR #124/#125/#127). fixture-loader flake carried to #122 as optional separate-look item.
---

Legs **D** + **E** of the ratified §ADR-4a §Amendment 2026-05-16 are done.
Impl PR is up: **GitHub PR #127** on `kxlahsimx09/mb-next-payment-gateway`
(`agents/26-inbox-1778928821` → `main`), sitting on current `main`
(post-PR #121).

## Leg D — PoC substrate + forward migration

- **NEW forward migration** `supabase/migrations/20260516000001_adr4a_review_rename.sql`
  — rewrites the `ts_payouts.status` + `withdrawal_queue.status` CHECK
  constraints (`waiting_to_review` → `review`), renames the lifecycle RPC
  `mark_waiting_to_review` → `mark_review`, re-creates `sweep_stale_claims`
  (Decision #6 triage branch → `mark_review`, `routed_to := 'review'`) and
  `run_hosted_assertions`. Landed migrations were **not** edited in place.
- poc/4a + poc/integration substrate, bot-simulator + fixture-gen, gateway
  bot handler + `bot-queue-mark` edge function, smoke + assertion suites,
  admin-web status types/badge. pgTAP spec `07` renamed to match.
- Greenfield — no mobiz→next data migration (RA3).

## Leg E — design docs

`docs/design/withdrawal-lane/`, `bot-gateway-dispatch/`, `bot-infra/`, and
`docs/architecture.md` — live `waiting_to_review` / `mark_*` references
canonicalized to `review` / `mark_review`.

## Carve-outs honoured

Left verbatim: the `payout.waiting_to_review` callback event +
`WAITING_TO_REVIEW` payload field (§ADR-9 callback-flow surface, per the
§Landing note); the `docs/adr.md` callback-flow list and its
`architecture.md` mirror; `poc/4a/evidence/production-shape-summary.md` and
other production-reality / `old:data` artifacts (RA3 / P-001); landed
migrations + historical revision logs.

## Verification

- Forward migration applies clean (DDL + function syntax, in-transaction
  check, rolled back).
- `poc/smoke` scenario 5 green — sweep → `mark_review` → `routed_to=review`,
  `status=review` (4/4 assertions).
- `fixture-gen` emits `PAY-*-REV-*` request_ids / verdict `review`.

**One surface flagged.** The `poc/integration` full E2E run is degraded by
a **pre-existing** fixture-loader crash (`loader_exited code 1`, ~3.5 min
in) — confirmed identical on a clean-tree control run with this rename
stashed, so it is not a regression from this work. It does mean the
integration-path `mark_review` was not exercised end-to-end this session
(the loader died before the lone `review` payout loaded); the logic is a
namespace-flattened copy of poc/4a's, which the smoke verifies. The loader
flake is unrelated to this thread but may be worth a separate look.

— next-impl, 2026-05-16 GMT+7

<!-- handled_at: 2026-05-16T19:10:00+07:00 — read + actioned by orchestrator. -->
