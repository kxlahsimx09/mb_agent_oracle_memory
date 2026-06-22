---
title: Bank-bot + gateway observability SHIPPED LIVE on staging (2026-06-20, orchestrat
tags: [orchestrator, observability, bank-bot, axiom, sentry, trace-correlation, request-id, ecs, fargate, ap-southeast-7, fleet-relocation, cross-region-ecr, root-boostrap, merge-not-deploy, staging-not-dev, repo:mb-next-bank-bot, repo:mb-next-payment-gateway, accepted]
created: 2026-06-20
source: orchestrator — gateway+bot observability shipped LIVE on staging, 2026-06-20
project: github.com/kxlahsimx09/mb-next-bank-bot
---

# Bank-bot + gateway observability SHIPPED LIVE on staging (2026-06-20, orchestrat

Bank-bot + gateway observability SHIPPED LIVE on staging (2026-06-20, orchestrator follow-on to the monitor* campaign). Gateway logger (MONITOR-001/002) + bank-bot logger now both ship to ONE Axiom dataset `midasgo-staging` (distinguished by root tag source="bankbot" vs gateway ef:*), correlated by a request_id trace UUID; Sentry errors to per-runtime projects (gateway=Deno project midasgo-staging-deno; bot=its own Node.js project via SENTRY_DSN_BOT).

WHAT SHIPPED (all merged + deployed to staging):
- Gateway logger LIVE on sinuw: deposits-create/payouts-create/dispatch-callback ship structured JSON to Axiom (verified: a real deposits-create + the dispatch-callback cron log to Axiom; 502 rows/2h). The logger is console.log(pino-format) + a fire-and-forget shipToAxiom() POST (Supabase EFs capture console.* only).
- Trace-glue PR #661 (gateway): a new ts_payouts.trace_request_id uuid column; payouts-create persists the hop-1 trace UUID (DISTINCT from the PAY… text matcher — must-not-conflate); claim_withdrawal_items RPC returns it; bot-claim maps it. Proven create→claim→Axiom on dev-1 + staging.
- Bot observability PR #33 (mb-next-bank-bot): core/logger.js adds the Axiom transport (source=bankbot tag + base fields request_id/flow_slug/actor) + core/sentry.js (@sentry/node, gated on SENTRY_DSN_BOT, lazy-require, failure-tolerant). The bot prefers item.trace_request_id (forward-compatible) so the gateway↔bot UUID JOIN works once trace_request_id flows.
- deploy.yml fix PR #34 (bot) — retargets the stale workflow to the relocated fleet.

DEPLOY (brew-ops, owner-authorized, AWS_PROFILE=root-boostrap): created 2 Secrets Manager secrets (mb-next-bankbot/axiom-token + sentry-dsn-bot) in ap-southeast-7; rolled all 8 Fargate services (cluster mb-next-bankbot, ap-southeast-7: scb-fleet-scb1/2/3 + ktb-fleet-ktb1, each × {statement, -payout}) to the #33 image + obs env (rev:2), payout-first. Confirmed LIVE: 571 source=bankbot Axiom rows/15min (withdrawal-claim + bot-scrape, actors bot:scb:maker-approver / bot:ktb:transfer).

KEY GOTCHAS (reusable):
1. CREDS GO ON STAGING+PROD ONLY, NOT dev (owner policy). The creds were mistakenly wired to dev-1 first (orchestrator misassumption "build on dev-1") → live test on sinuw logged NOTHING → moved to sinuw + unset from dev-1. ROOT CAUSE of "live test not logging" was TWO layers: (a) creds on wrong stack, (b) the logger EF CODE wasn't deployed to sinuw (sinuw ran 2026-06-19 EFs, a day before the logger; merge≠deploy — confirmed by downloading the deployed bundle).
2. The bank-bot fleet RELOCATED 2026-06-19 (campaign multibank) to ap-southeast-7 (NOT ap-southeast-1), 8 long-lived Fargate services, real service/task-def names prefixed mb-next-bankbot- (e.g. mb-next-bankbot-scb-fleet-scb2-payout). No task-def IaC; env lives on live task defs; sensitive vals via Secrets Manager mb-next-bankbot/* (exec role read-bankbot-secrets path-scoped → new secrets auto-readable). The sanctioned deploy.yml was stale (hardcoded ap-southeast-1 + old names + image-only, no env).
3. CROSS-REGION ECR GAP: build-push-ecr pushes sim-latest/sim-<sha> to ap-southeast-1 ONLY; the relocated fleet pulls from ap-southeast-7 ECR. No replication. Fix: docker buildx imagetools create to replicate the OCI index (preserves digest), OR add ap-southeast-7 to build-push.
4. The bot CI deploy key (mb-next-bbot-restart) is RESTART-ONLY (no DescribeTaskDefinition/RegisterTaskDefinition) → workflow deploys that set env fail; use root-boostrap direct task-def update, OR grant the CI job ECS/PassRole/Secrets in ap-southeast-7.
5. Sentry platform = Deno for the gateway (Supabase EFs), Node.js (vanilla, no web framework — deps: playwright/imapflow/mailparser/mongodb) for the bot.

STILL OPEN: full payout-trace JOIN (gateway UUID == bot request_id) materializes on the next real fleet payout (bots were idle at deploy time). #34 still needs the service-name-prefix fix + owner merge. The MONITOR-003 Axiom rate-alerts still await a 7-day baseline (owner ruled: measure from PROD).

---
*Added via Oracle Learn*
