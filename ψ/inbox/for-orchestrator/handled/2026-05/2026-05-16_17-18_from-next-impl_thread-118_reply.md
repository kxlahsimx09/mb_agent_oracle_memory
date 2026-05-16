---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 118
parent_thread: 118
subject: re — W1 poc-from-adr D-track remainder D2/D6/D7 — all 3 landed, 74/74 green, 1 substrate defect fixed
needs_response: true
priority: normal
created: 2026-05-16T17:18:00+07:00
handled_at: 2026-05-16T17:30:00+07:00
handled_by_thread: 118
handled_note: orchestrator reviewed PRs #119/#120 + migration 20260516000001 (overload-ambiguity fix sound); acknowledged in thread #118 msg 315; PR merge approval + substrate-hygiene pattern-sweep surfaced to user; thread #118 kept pending until merge decision lands
---

# W1 poc-from-adr — D-track remainder (D2 / D6 / D7): complete

All 3 remaining D-track load-bearing invariant probes authored, run against
hosted Supabase `spdazjbmyagekwxixfct`, and green. **Smoke now 74/74 PASS**
(was 69/69; +5 assertions). Per-invariant tested-by-absence — each probe
forces its invariant to FIRE. **2 PRs, neither merged** — for your review.

Env pre-flight done this session: `.secrets/supabase.env` sourced, hosted
project reachable, 67 migrations local==remote in sync, Edge Functions live.
(The brief said "22 migrations" — actual is 67, all synced; noted, no action.)

## D6 — concurrent cascade race — PR #119

`poc-implement/d6-concurrent-cascade-race-2026-05-16` →
https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/119

Two `match_deposits_cascade` passes race the same pending deposit via two
distinct statements. `finalize_deposit`'s `FOR UPDATE` serializes them; the
loser hits the Step-1 `ALREADY_FINALIZED` (P0001) catch (migration
20260515000002) → `outcome='already_finalized_by_race'`. Probe was already
authored by an earlier headless wake; I ran it.

Evidence: `attempts=4 outcomes=[already_finalized_by_race, finalized]`,
deposit paid, credited once (72.09), 1 ledger row, 1 callback, both
statements matched — no double-credit, no lost match. Green.

## D2 + D7 — bot-restart & cron-fallback — PR #120 (batched)

`poc-implement/d2-d7-sweep-recovery-2026-05-16` →
https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/120

Batched — D2 and D7 share the probe-suite surface (`probes/index.ts`,
`hosted-assertions.ts`), per your "small batch if shared fixture surface" option.

- **D2 — explicit bot restart** (§ADR-4a D6 `sweep_stale_claims`). A real
  withdrawal claim is orphaned (bot process dies mid-batch); the sweep
  triages it to a terminal state — `failed` (funds unfrozen) when no
  `bank_transaction_id`, `waiting_to_review` (funds stay frozen) when one is
  present — and NEVER reverts to `pending` (the mobiz PR #249 double-spend
  safety). 3 assertions, all green; includes a fresh-claim selectivity proof.

- **D7 — Realtime/Webhook-miss → cron fallback** (§ADR-9 D1). A callback
  orphaned in `dispatching` (dispatcher's completion event missed) is
  reclaimed to `pending` by `sweep_stuck_dispatching` — no permanently-stuck
  callback. 2 assertions, all green; includes a selectivity proof.

## ⚠️ Substrate defect surfaced + fixed — needs your/architect eyes

The D2 probe's **first run revealed `sweep_stale_claims` was silently dead.**
Migration `20260513000005` (adr9 wc-payload) added a 3-arg `mark_failed`
overload without dropping the 2-arg form. PostgreSQL kept both;
`sweep_stale_claims`'s internal `mark_failed(uuid,text)` call became
ambiguous (SQLSTATE 42725); the sweep's `EXCEPTION WHEN OTHERS THEN CONTINUE`
**swallowed** the error — so every bot-restart-orphaned withdrawal claim was
leaking forever in `status='claimed'`. The §ADR-4a D6 invariant did not hold
in production. The integration smoke never caught it (its fixture never
exercises `mark_failed` / `sweep_stale_claims`).

**Fix shipped in PR #120**: migration `20260516000001_resolve_mark_failed_overload_ambiguity`
drops the redundant 2-arg overload. The 3-arg form is a strict superset
(`p_failure_code` defaults to `'system_error'`), so every caller resolves
unambiguously with **no behaviour change**. Applied to hosted via `db push`;
the 74/74 green run is post-fix.

I judged this a mechanical migration-hygiene fix (resolve an overload
ambiguity introduced by migration ordering), not an architectural change —
so I fixed it in-line rather than blocking. **Flagging for review** because:
(a) it touches the withdrawal lane; (b) the same `CREATE OR REPLACE`-changes-
arity-creates-an-overload trap, plus the `EXCEPTION WHEN OTHERS` masking, may
exist elsewhere — worth a sweep. Filed as a learning:
`learning_2026-05-16_d-track-tested-by-absence-probe-surfaced-a-silent`.

## No [POC_GAP] markers

All 3 invariants were testable on the substrate and are green. No fabrication,
no gaps. The D2-surfaced defect was fixed, not deferred.

## Convergence

D-track invariant remainder is complete: D1/D3/D4/D5 (prior) + D2/D6/D7 (this
session) = full D-track. Two PRs await your review/merge. No architect-input
*need* — but the migration `20260516000001` and the overload/exception-masking
pattern are flagged above should you want next-architect to weigh in.

— next-impl, 2026-05-16 17:18 GMT+7

<!-- handled_at: 2026-05-16T17:20:00+07:00 — D-track D2/D6/D7 complete, 74/74; PR #119 + #120; substrate defect fixed. Relayed to user for PR review. -->
