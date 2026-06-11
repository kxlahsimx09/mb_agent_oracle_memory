---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: OWNER DIRECTIVE — deploy mb-next-bank-bot to AWS ECS Fargate NOW (SIM stack: real bot + mock portal), no local-only testing
priority: high
needs_response: true
created: 2026-06-11T14:51:00+07:00
---

# Deploy mb-next-bank-bot → AWS ECS Fargate (owner directive)

Owner verbatim (2026-06-11 14:50 GMT+7): "ผมไม่ได้อยากให้รัน next-bank-bot ใน local ผมอยากเอาขึ้น aws ecs fargate เลย"

The bank-bot Phase-1 build set is fully merged (gateway #398/#399/#400 + bot repo #1/#2, thread #13). The live golden-journey gate must now run against an **AWS-deployed bot**, not a local boot.

## What to deploy

**SIM stack** per amended §ADR-21 M1 (REAL bot + simulated bank portal):
1. **mb-next-bank-bot** (repo kxlahsimx09/mb-next-bank-bot, main HEAD) on **ECS Fargate** — same posture family as the gateway's §ADR-15 keep-Fargate stack. Repo has `Dockerfile` / `Dockerfile.bun` + `docker-compose.yml`, **zero AWS infra yet** — first deploy, you own the infra story (task-def, service, logs, secrets).
2. **SCB mock portal** (`sim/mock-portal/` in the same repo) reachable by the bot — sidecar container in the same task or a separate service, your call. Portal refuses to boot without `X-Sim-Control-Secret` configured.

## Constraints / prerequisites (all pre-flagged on thread #13)

- **Secrets**: per-stack `BOT_CRED_ENC_KEY` (≥16 chars) on the gateway side; `BOT_KEY` pair minted via the REAL issuance path (#398) — no hand-rolled keys; `X-Sim-Control-Secret` for the portal control plane, MUST be a different credential from `BOT_KEY`.
- **Gateway side**: migrations `20260611000100` + `20260611000110` applied on the target stack. Gotcha: pgcrypto lives in the `extensions` schema — `SET search_path` must include it.
- **Image variants**: nextbot-dev is concurrently adding structural sim/-exclusion for the REAL-BANK image (reviewer-routed). The **SIM image NEEDS `sim/` included** — coordinate with nextbot-dev so the exclusion is variant-specific (build stage/target), not a blanket `.dockerignore` that breaks your SIM deploy.
- **No real bank anywhere** in this stack — SIM only. REAL-BANK deploy is a later, separately-gated step.
- Control-plane endpoints (`/sim/inject`, `/sim/clawback`, `/sim/rows`) must be reachable by next-live-tester (they drive the golden journey: inject → scrape → gateway auto-match → clawback). Expose securely (the secret header is the auth) and hand them the base URLs + secret channel.

## Deliverable

Reply envelope to `for-orchestrator/` + thread #13 with: stack name/region, bot + portal endpoints, how next-live-tester gets the control secret, and the deployed image digests. next-live-tester's gate verdict will run against YOUR stack — they are being told to design for a remote target now.
