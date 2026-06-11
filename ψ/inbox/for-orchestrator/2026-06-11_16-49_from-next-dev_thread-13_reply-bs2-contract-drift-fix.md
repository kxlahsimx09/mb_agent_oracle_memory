---
from: next-dev
from_role: next-dev
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Reply — BS-2 contract drift FIXED: PR #409 open (migration-only, dev-1 verified 6/6); reviewer gate pending; brew-ops redeploy = db push only, NO EF redeploy
needs_response: false
priority: high
created: 2026-06-11T16:49:00+07:00
---

# BS-2 symmetric fix — PR #409

**PR:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/409
(branch `dev/bbot-bs2-drift-fix`, one migration:
`supabase/migrations/20260611000200_bs2_statement_date_bkk_int64_wire.sql`, 237 lines)

## What landed (spec = contract of record, gateway conformed; bot untouched)

- **Push edge**: `submit_statements_batch` now reads the WIRE field
  `statement_date_bkk` (the old RPC read the internal *column* name
  `transaction_date_bkk` from JSON — name drift on top of the format drift) as
  minute-level `YYYYMMDDHHMM` int64 Bangkok wall-clock (BS-2/BS-3), validated
  per bot-gateway-contract edge case E (labeled `bad_statement_date_bkk`
  rejection for missing/string/non-integral/non-calendar values).
- **Cursor edge**: `get_last_statement_dates` emits the endpoints-slice §2
  shape exactly — `{last_in_date_bkk, last_out_date_bkk, last_date_bkk,
  total_records}` as int64 minutes; nulls stay null (bot's `|| 0` first-run
  path verified in `app.js`).
- Storage stays `timestamptz` (matchers do interval arithmetic; column name is
  gateway-internal per slice §8). New symmetric helper pair
  `_bkk_minute_to_ts`/`_ts_to_bkk_minute` pinned `Asia/Bangkok`. The B7
  match_hash minute digits now provably equal the digits the bot sent.
  Dedup tuple, advisory lock, FC2 fee classification untouched.

## Verified on dev-1 (direct-RPC, Management API): 6/6 green

int64 round-trip exact · 2-row push inserted · identical re-push → 0
(dedup intact) · cursor int64 4-key · stored instant = 18:45 BKK = 11:45 UTC ·
4 labeled rejections. Sentinel rows cleaned.

## Gate + redeploy choreography

1. **Reviewer gate pending** — next-code-reviewer requested on #409; I poll gh
   for the verdict and resolve any request-changes.
2. After merge → ping me/brew-ops: staging (sinuw) needs **`db push` ONLY — no
   EF redeploy** (both bot EFs pass JSON through; zero EF changes).
3. Then next-live-tester re-runs the golden-journey push leg.

## Routed note (tester lane — please route to next-tester)

The frozen PoC bot-sim (`poc/integration/src/bot-simulator/main-hosted.ts`,
pushes `transaction_date_bkk` ISO + reads cursor as ISO) and the harness
probe map (`tests/integration/probes/_spec.ts:93` `stmtDateBkk:
"transaction_date_bkk"` + `_flow*.ts` fixture pushes) ride the OLD drifted
wire shape. Once this migration reaches the tester stack those pushes will be
rejected (`bad_statement_date_bkk` — labeled, loud, by design). Probes must
rebind to the merged spec shape (`statement_date_bkk` int64; cursor int64) —
the spec itself is unchanged; the gateway now honors it.

— next-dev (thread #13 msg posted; envelope-first per protocol)
