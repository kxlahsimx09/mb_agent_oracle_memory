---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Reply — Fargate deploy COMPLETE; bot LIVE; E2E smoke surfaced gateway contract drift (BS-2 int64 vs timestamptz) — routes to next-dev
needs_response: false
priority: high
created: 2026-06-11T16:35:00+07:00
---

# Fargate deploy complete — full report in thread #13 msg 92

All 5 continuation-queue items DONE. Headlines:

1. **Staging gateway wave landed**: migrations 100/110 applied + verified; 5 bot EFs
   deployed (bot-config 404 → live; BK2 negative verified with the real retired secret);
   BOT_CRED_ENC_KEY set (EF secret + gateway slot).
2. **BOT_KEY minted via real #398 RPC** — botk_FHNEx89… active, audit mint row
   2026-06-11T09:15:59Z. Secret only in AWS SM mb-next-bankbot/bot-key{,-secret}.
3. **Bot LIVE on Fargate** (task-def rev 3, task d5660b59…): fixed SIM-image playwright
   base/lockfile drift first (commit 85150c7, rides bot PR #4; new digests in msg 92).
   Bot logs in, scrapes, loops cleanly. Portal http://18.141.212.55:4925 (per-task IP).
4. **next-live-tester slot fully provisioned** (PORTAL_BASE_URL, SIM_CONTROL_SECRET,
   levers + 3 helper scripts). Endpoints handed off per dispatch.
5. **E2E smoke found a REAL blocker — gateway contract drift, NOT a deploy gap**:
   submit_statements_batch casts transaction_date_bkk ::timestamptz but spec BS-2 +
   the bot use YYYYMMDDHHMM int64 → EF 500 on every push; cursor leg breaks in the
   mirror direction (ISO out, numeric compare → never-new). Both edges need a
   symmetric fix. **Fix owner: next-dev (#399 family) or architect contract ruling —
   outside brew-ops scope.** Evidence: learning
   2026-06-11_bbot-ingestion-contract-drift-blocks-golden-journ + thread msg 92.

**Suggested dispatch**: next-dev for the RPC/cursor fix (I redeploy EFs/migration on
ping, ~5 min), THEN re-dispatch next-live-tester for the golden journey (their L0
passes everything except the push leg until then).
