---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: escalate
thread: 118
parent_oracle: orchestrator
subject: W1 poc-from-adr — D-track remainder integration tests (D2 / D6 / D7)
needs_response: true
priority: normal
created: 2026-05-16T16:22:49+07:00
handled_at: 2026-05-16T17:20:00+07:00
handled_by_thread: 118
handled_note: >-
  D2/D6/D7 D-track invariant probes authored + run green (smoke 74/74) on
  hosted spdazjbmyagekwxixfct. D6 → PR #119; D2+D7 → PR #120 (batched, shared
  probe surface). D2's first run surfaced a silent substrate defect —
  sweep_stale_claims disabled by a mark_failed overload ambiguity — fixed in
  PR #120 via migration 20260516000001. No [POC_GAP]. Reply envelope filed to
  for-orchestrator/ 2026-05-16_17-18_from-next-impl_thread-118_reply.md.
---

# W1 poc-from-adr — D-track remainder (D2 / D6 / D7)

Read thread #118 (`arra_thread_read threadId=118`) for the full brief.

Continuation of the substrate-PoC integration-testing effort. The Phase-B integration PoC (`poc/integration/`, `run-hosted.ts` against hosted Supabase `spdazjbmyagekwxixfct`) is at 69/69 green; D1/D3/D4/D5 landed. Author + run the **3 remaining D-track load-bearing invariant tests**:

- **D2** — explicit bot restart (in-flight claims / cursor state survive a bot process restart).
- **D6** — concurrent cascade race (two match-cascade passes racing the same statement/deposit — race-guard holds, no double-credit).
- **D7** — Realtime-miss → cron fallback (a missed Realtime/Webhook event is caught by the pg_cron sweep — no permanently-stuck row).

Methodology: tested-by-absence (`learning_2026-05-13_tested-by-absence-D-track-methodology`) — force the invariant to FIRE. Anchor cite blocks per `poc/EVIDENCE-CONVENTION.md`. Untestable → `[POC_GAP:<adr>:<test>]` + `arra_learn #poc-gap`, do not fabricate.

Pre-resume env first: `supabase login`, source `.secrets/supabase.env`, verify hosted project + 22 migrations + EFs. Then W1 poc-from-adr per invariant → `run-hosted.ts` → green evidence JSON. One `poc-implement/<slug>-2026-05-16` branch + PR per invariant (or small batch if shared fixture surface — your call). **Do NOT merge** — report each PR.

Reply envelope to `for-orchestrator/` with `parent_thread: 118` — progress per invariant (PR + evidence result), flag any `[POC_GAP]` or architect-input needs.

— orchestrator, 2026-05-16 16:22 GMT+7
