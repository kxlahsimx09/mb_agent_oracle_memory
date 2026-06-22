# Handoff — epic-monitoring build PAUSED at a clean stop (2026-06-20)

**Owner decision: STOP monitoring here, save state, resume later.** epic-monitoring stays OPEN (owner wants the FULL 34-alert catalogue before epic-DONE). The buildable-now backbone + most of the catalogue SHIPPED this session.

## DONE + MERGED to main (5 PRs)
- MONITOR-002 #654 — trace MVP (request-id + pino base-fields + 4 hops via db_pre_request hook + §1.3 forensic columns + deposits-qr collision fix)
- MONITOR-001 #655 — ACTIVATED Axiom log-shipping + Sentry + traced deposits-create/payouts-create money lanes
- MONITOR-005 #653 — wallet-high-balance + hourly-ops-report
- MONITOR-003 #656 + #658 — P1 paging path (telegram-p1-router/-escalation, ack-aware firingCounter, P1→chat 2002026175 + operator DM) + Postgres alerts (P1.3/P1.4/P1.6/P1.7/P2.10/P2.17) + P3 daily-ops-digest
- MONITOR-004 — VERIFIED GREEN (no build; investigator_ro proven SELECT-only, zero agent surface)
- KF4 design docs #651 — OWNER-MERGE PENDING

## CREDS (verified 100% on dev-1)
observability.env (`~/.arra-oracle-v2/fleet-secrets/mb-next-payment-gateway/observability.env`) holds Axiom (token+dataset, query scope granted) + Sentry (DSN+org `midasgo`+project `midago-staging-deno`, platform=Deno for gateway / Node.js for bot-fleet later). Wired to dev-1 ONLY. **Better Stack placeholder appended (BETTERSTACK_HEARTBEAT_URL=REPLACE_ME) — owner to fill for P1.5.**

## REMAINING for epic-monitoring DONE (when resumed)
1. **Axiom-sourced rate-alerts** (P1.1 finalize-fail-rate, P1.2 EF-crash-chain, Axiom P2.x). **OWNER DECISION: measure the 7-day baseline from PROD** (not staging/dev-1). → trigger = deploy Axiom logging to PROD (brew-ops + prod Axiom dataset/creds) → 7 days of prod traffic → author rate-alerts with prod-derived thresholds.
2. **P1.5 Better-Stack dead-man's-switch** — owner filling the Better Stack heartbeat URL placeholder → brew-ops wires Keep push-heartbeat + the monitor.
3. **P1-path /ack-wiring** (Telegram bot command handler) — brew-ops deploy follow-on.
4. Then next-pm marks epic-monitoring DONE (full 34-catalogue + infra in).

## GOTCHA (reusable): backticks in team-dispatch-helper --prompt "..." trigger bash command-substitution → use SINGLE quotes. Full detail: vault learning 2026-06-20_orchestrator-campaign-family-monitor.

## ALSO still owner-gated from the EARLIER pmcloseepic campaign (separate): 4 epic-close docs-flip PRs await merge (#644 statement-matching / #646 admin-audit / #647 callback-delivery / #648 client-api); payout+deposit sealed → owner live_signoff; auth LIVE-applicability; bot-dispatch ADR-8 + BOT-003 legs; wallet WALLET-004/007; roles-write freeze.