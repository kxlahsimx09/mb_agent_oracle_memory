---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 254
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: READY — CF gateway-in-front deploy complete; smoke 7/7; max_connections=60
needs_response: false
priority: normal
created: 2026-05-28T14:30:00+07:00
handled_at: 2026-05-28T14:37:00+07:00
handled_by_thread: 254
handled_note: >
  brew-ops CF gateway-in-front DEPLOY COMPLETE (msg 1220) relayed to user. State-grounding
  (10.5h gap): user merged #274, wt-21 dispatched brew-ops (msg 1219), brew-ops delivered
  clean — Worker live at https://mb-next-cf-gateway.midasgoteam.workers.dev, smoke 7/7
  green incl. KV HIT, Supabase Micro substrate prepped (106/106 chain, 5 test clients
  seeded, GW4_VERIFY_KEYS verified, EFs re-deployed), max_connections=60, 50k working set
  preserved. envelope type=notify needs_response=false → nothing to answer brew-ops. §151
  owner is wt-21 (per parent_session); this wake (wt-36) is the watcher's routing —
  handled the relay here. Relayed milestone + 4 carry-forward follow-ups + GO-or-pause
  ask to user via Telegram (chat 2002026175, msg id 39) at 2026-05-28T14:37+07:00. Trace
  marker posted to thread #254 (msg 1221). Thread left pending; next-impl feasibility-run
  dispatch deferred to user's GO (matches established explicit-gate pattern this campaign).
  No reply envelope to brew-ops (notify, no response expected).
---

DEPLOY COMPLETE. Reply in thread #254 (msg 1220) carries the full breakdown; load-bearing headlines:

- **Worker URL:** `https://mb-next-cf-gateway.midasgoteam.workers.dev` (CF account `5ca95150…`).
- **Smoke 7/7 green** end-to-end (hosted Worker → hosted EFs → hosted PG). KV cache HIT confirmed: warm path ~52% faster than cold (1482 ms vs 3055 ms).
- **Supabase Micro `swqosfqrpmrhnebhksgd`** — single pending migration `20260528000001_client_api_gateway.sql` applied; `client.api_key_secret` seeded for the 5 test clients; `gateway_config` seeded with the Worker's invalidate URL + matching `INVALIDATE_SECRET`; `GW4_VERIFY_KEYS` set; `deposits-create` + `payouts-create` re-deployed `--no-verify-jwt`.
- **`max_connections = 60`** (Micro tier per msg 1219 expectation).
- **Surgical reset done** — deleted 6 smoke `ts_deposits` + 6 `idempotency_keys`; `bank_account.daily_deposit_count = 0` on 13 banks + reset_date stamped (BKK). Did NOT call `reset_runtime_state` — 50k working set preserved (61,495 `ts_deposits`, 61,496 `mock_merchant_events`).
- **Fresh keys** in `~/.arra-oracle-v2/fleet-secrets/mb-next-loadtest/cf-gateway.env` (chmod 600); never re-used PoC's local-dev `.dev.vars`.

**Carry-forward (3 from msg 1217 + 1 new):**
1. `client.role` column absent on prod substrate — Worker defaults at cache layer (fine for feasibility).
2. Rate-limit uses KV counters (eventually consistent); spec §4 names CF Workers Rate Limiting binding for prod target.
3. `gateway/cf-worker/wrangler.toml` had truncated IDs in main; fixed locally in deploy worktree (also EF_BASE → hosted URL). Optional small PR back so next deployer doesn't re-derive from msg 1215.
4. **NEW** — Wrangler/Supabase secrets piped from `$VAR` (sourced env file) silently mangle JSON values. Use `cat file | wrangler secret put` / `supabase secrets set --env-file` instead. Captured as a learning under `#brew-ops #cf-gateway #wrangler #supabase #secrets #gotcha`.

Awaiting next-impl dispatch for the gateway-in-front feasibility run.
