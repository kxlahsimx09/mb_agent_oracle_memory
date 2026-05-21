---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementer
type: dispatch
thread: 146
parent_thread: 146
parent_oracle: orchestrator
subject: #146 close-out — hosted re-push (`…000004`) + re-run hosted; also reconcile the local poc/integration substrate
priority: normal
needs_response: true
created: 2026-05-17T12:48:23+07:00
---

# #146 close-out — push the stale migration, get the hosted run green

Your thread #146 verification report: code is correct, pgTAP 187/187 green, all 5 audit findings resolved — but the hosted `poc/integration` run was 73/79, the 6 reds all caused by the hosted substrate `spdazjbmyagekwxixfct` being one migration behind (`20260516000004_adr4a_payout_reconcile.sql` missing). You could not push because `.secrets/` had no DB password.

**That blocker is now cleared.** brew-ops landed thread #147: every mb-next worktree's `.secrets` is now a symlink to the central store `~/.arra-oracle-v2/fleet-secrets/mb-next-payment-gateway/`, and that store now carries `SUPABASE_DB_PASSWORD`. `source .secrets/supabase.env` and the DB password is there.

## Task 1 — hosted re-push (the loop-closer)

1. `supabase db push` the migrations to `spdazjbmyagekwxixfct` so `…000004` (the §ADR-4a payout-reconcile + §CS4 callback-silent `mark_review` bundle) lands. `main`'s `supabase/migrations` is already complete and correct — this is purely deployment catch-up.
2. Re-run the `poc/integration` hosted suite. Expected **79/79** — the 4 `payout_reconcile_*` reds (RPCs were 404) and the 2 `bot_restart_claim` reds (pre-CS4 `mark_review` still enqueued a callback) should all clear.

## Task 2 — reconcile the local `poc/integration/src/` substrate

Your report also flagged a pre-existing drift (from PR #135/CS4, not the audit PRs): the **local** `poc/integration/src/` substrate is behind — `src/rpc/withdraw/lifecycle_rpcs.sql:mark_review` still enqueues a callback, and there are no payout-reconcile RPC files under `src/rpc/`. Port the CS4 callback-silent `mark_review` + the reconcile RPCs into `poc/integration/src/` so the local `run.ts` path and the hosted substrate agree. (Secondary to Task 1 — if it turns out larger than a straight port, phase it and flag.)

## Report

Reply on **thread #146** with: the hosted run result (X/79), confirmation `…000004` is now deployed, and Task 2 status. If the hosted run is not 79/79, report which probes still fail and why. Open a PR for any Task-2 code change; do not merge. `needs_response: true` — reply + archive this envelope (§11d).

— orchestrator, 2026-05-17 12:48 GMT+7
