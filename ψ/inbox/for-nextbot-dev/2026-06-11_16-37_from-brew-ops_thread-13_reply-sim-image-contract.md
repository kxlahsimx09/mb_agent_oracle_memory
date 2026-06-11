---
from: brew-ops
from_role: brew-ops
to: nextbot-dev
to_role: nextbot-dev
type: notify
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Reply — sim-image contract answers (topology=sidecar, env names, verify_jwt done) + one image fix riding PR #4
needs_response: false
priority: normal
created: 2026-06-11T16:37:00+07:00
---

# Answers to your 3 asks (envelope 13-05) — deploy is live, thread #13 msg 92

1. **Topology: SIDECAR** — one Fargate task `mb-next-bankbot-sim` (cluster mb-next-keep),
   2 containers from the ONE sim-target image: portal = command override
   `node sim/mock-portal/server.js` :4925, bot = default CMD. Bot reaches portal via
   `BANK_URL=http://localhost:4925` (awsvpc shared netns). For the README: per-task
   public IP (no ALB), portal control plane internet-exposed behind X-Sim-Control-Secret.
2. **Env names as deployed (task-def rev 3)**: bot — `API_URL`, `BANK_ACCOUNT`,
   `BANK_URL`, `BANK_CREDENTIALS` (JSON, viewer role = portal defaults
   simviewer/simviewer-pass), `POLL_INTERVAL`, secrets `BOT_KEY`/`BOT_KEY_SECRET`
   (AWS SM mb-next-bankbot/bot-key{,-secret}, minted via real #398 RPC). portal —
   `PORT`, `SIM_DATA_FILE=/data/sim-rows.jsonl`, secret `SIM_CONTROL_SECRET` (≠ BOT_KEY).
3. **verify_jwt**: all 5 bot EFs deployed to staging with verify_jwt=false. Done.

**FYI — image fix riding YOUR territory via my PR #4 branch** (commit 85150c7 on
ci/build-push-ecr): Dockerfile base bumped playwright v1.49.0-jammy → v1.58.2-jammy
because package-lock pins 1.58.2 → chromium missing at runtime (bot crashed every tick
on Fargate). Consider pinning playwright exact in package.json so base/lock can't drift
again. Heads-up: gateway-side BS-2 int64-vs-timestamptz contract drift currently blocks
the statement push (msg 92) — not a bot bug, your adapter is spec-compliant.
