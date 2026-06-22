---
title: Orchestrator campaign family `monitor*` (2026-06-20) — built epic-monitoring (§A
tags: [orchestrator, team-dispatch, monitor-build, epic-monitoring, adr-15, axiom, sentry, keep, trace-correlation, request-id, alert-catalogue, p1-paging, observability, axiom-7day-baseline, backtick-command-substitution-gotcha, repo:mb-next-payment-gateway, accepted]
created: 2026-06-20
source: orchestrator campaign monitor* — epic-monitoring build, 2026-06-20
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Orchestrator campaign family `monitor*` (2026-06-20) — built epic-monitoring (§A

Orchestrator campaign family `monitor*` (2026-06-20) — built epic-monitoring (§ADR-15, MONITOR-001..005) on owner GO. Outcome: the buildable-now monitoring backbone + most of the alert catalogue SHIPPED; epic stays OPEN per owner ("complete the full 34-alert catalogue before epic-DONE"), genuinely gated ~7 days on the Axiom baseline.

WHAT SHIPPED (all merged to main this session):
- MONITOR-002 #654: trace-correlation MVP — pino logger + 3 root base fields (request_id/flow_slug/actor) + flow_slug registry + 4 propagation hops on the callback-dispatch lane via a PASSIVE+exception-proof PostgREST db_pre_request hook lifting X-Request-Id into the txn-LOCAL GUC app.request_id + §1.3 forensic request_id columns (audit_log/callback_attempts/slip_verify_attempts) + the deposits-qr X-Request-Id→X-Deposit-Request-Id collision fix.
- MONITOR-001 #655: ACTIVATED Axiom log-shipping (logger.ts shipToAxiom, fire-and-forget, failure-tolerant, gated on axiomConfigured) + Sentry (sentry.ts, @sentry/deno, dynamic import in try/catch, flush under EdgeRuntime.waitUntil) + extended the trace to deposits-create + payouts-create money lanes. Reviewer scrutinized the "logging NEVER breaks/slows a money request" property.
- MONITOR-005 #653: wallet-high-balance alert + hourly-transaction-report (2 Postgres Keep workflows, ride #mb-alerts-p2) + threshold seed (app_settings.wallet_high_balance_threshold=200000).
- MONITOR-003 #656+#658: the P1 PAGING PATH (telegram-p1-router + telegram-p1-escalation; firingCounter-based ack-aware escalation — an /ack resets firingCounter so ~15 unacked re-fires at 60s ≈ the 15-min window; P1→chat 2002026175 + operator DM per owner decision, NO new channel) + Postgres-sourced alerts P1.3 pool-exhaustion, P1.4 bot-fleet-outage, P1.6 wallet-double-debit, P1.7, P2.10 review-queue-depth, P2.17 payout-failed-with-confirming-debit + the P3 daily-ops-digest (fires 9am-BKK via interval+hour-gate+day-bucket fingerprint, no cron).
- MONITOR-004: VERIFIED GREEN (no build needed — Phase-1 obligations met): investigator_ro is provably SELECT-only (writes refused by TWO mechanisms — read-only GUC + hard GRANT boundary), zero agent/MCP surface by design.
- KF4 design docs #651 (architect authored observability-stack.md + README + mcp-integration.md) — owner-merge pending.

INFRA: Axiom + Sentry were NOT in any store (owner had accounts, hadn't dropped creds). Created placeholder /home/ubuntu/.arra-oracle-v2/fleet-secrets/mb-next-payment-gateway/observability.env; owner filled it; brew-ops verified 100% (Axiom ingest+query, Sentry event+org-read) after owner fixed 2 items (SENTRY_ORG midas-go→midasgo; AXIOM_TOKEN needed query scope) + wired AXIOM_TOKEN/AXIOM_DATASET/SENTRY_DSN to dev-1 ONLY (staging-first per owner; Sentry project platform = Deno for the gateway, Node.js for the bot-fleet cross-repo later). Keep(L2)+Telegram-P2(L3) were already live on Fargate.

REMAINING for epic-monitoring DONE (owner wants full catalogue):
1. Axiom-sourced rate-alerts (P1.1 finalize-fail-rate, P1.2 EF-crash-chain, Axiom-sourced P2.x) — genuinely need a 7-DAY AXIOM BASELINE to set thresholds (Axiom provisioned 2026-06-20 → ready ~2026-06-27). The ONLY hard time-gate.
2. P1.5 Better-Stack dead-man's-switch — needs an owner Better-Stack account (like Axiom/Sentry).
3. The P1-path /ack-wiring (Telegram bot command handler) — brew-ops deploy follow-on.
Then next-pm marks epic-monitoring DONE.

REUSABLE GOTCHA: backticks in team-dispatch-helper --prompt "..." (a double-quoted bash string) trigger COMMAND SUBSTITUTION — `investigator_ro`/`gateway-postgres` became empty in a dispatched prompt. Use SINGLE quotes for the --prompt or avoid backticks. monitoring is PARTIALLY pre-built (Keep+P2 spine live, P2.12/P2.16 fire); always reconcile against HEAD, the audit's "never built/4-of-5 docs absent" was stale (alert-catalog.md + keep-deployment.md already present).

---
*Added via Oracle Learn*
