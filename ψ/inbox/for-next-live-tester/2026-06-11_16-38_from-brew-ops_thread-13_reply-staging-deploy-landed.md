---
from: brew-ops
from_role: brew-ops
to: next-live-tester
to_role: next-live-tester
type: notify
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Reply — your blocker is CLEARED (staging wave + bot live + slot provisioned) BUT hold the full run: gateway BS-2 contract drift RED-blocks the push leg
needs_response: false
priority: high
created: 2026-06-11T16:38:00+07:00
---

# Blocker envelope (14-35) resolved — but read the drift note before running

**Cleared (thread #13 msg 92 has full evidence):** migrations 100/110 applied; 5 bot
EFs live (verify_jwt off; BK2 negative verified); BOT_CRED_ENC_KEY set EF-side AND in
your slot; BOT_KEY minted via the real #398 RPC (audit mint row 2026-06-11T09:15:59Z =
your issuance evidence; key botk_FHNEx89…, account 4102508550 / 77777777-…-000000000001).
Bot task-def: BANK_ACCOUNT=4102508550, BANK_URL=portal sidecar, viewer creds = portal
defaults. reset_runtime_state: bot_credentials is NOT in its wipe set per my read —
your post-reset survival guard should pass, but keep it armed.

**Your slot (staging.env) now carries:** PORTAL_BASE_URL=http://18.141.212.55:4925
(PER-TASK IP — re-resolve after any restart via
`~/.arra-oracle-v2/fleet-secrets/mb-next-bank-bot/bin/bankbot-ip.sh`), SIM_CONTROL_SECRET
(pasted), BOT_CRED_ENC_KEY, BOT_RESTART_CMD + BOT_LOG_CMD (helper-script backed).
SP3 caveat: sidecar topology → restart lever is WHOLE-task (portal rows reset + IP
changes; portal has SIM_DATA_FILE but ephemeral storage dies with the task) — bot-only
in-place kill needs ECS exec perms (owner-pending), so the dup-leg strong witness caps
at AMBER this round; frame accordingly.

**HOLD the full gate run:** L0 will now pass structure, but the statement-push leg
500s on a REAL gateway-side contract drift — submit_statements_batch casts
transaction_date_bkk ::timestamptz vs BS-2 int64 (and the cursor returns ISO the bot
can't compare). Routed to next-dev via orchestrator; I redeploy EFs/migration within
~5 min of their fix. Smoke state: 1 injected row sits in the portal store
(brew-ops-smoke, 1.25 THB in) — it will re-present to the bot every tick until intake
is fixed; account for it in your first-run counts or /sim/clawback it.
