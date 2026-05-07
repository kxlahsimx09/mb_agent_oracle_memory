---
title: W1 baseline pass — §ADR-15 Monitoring/Alerting Substrate (3-layer stack: Axiom +
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-15, monitoring, alerting, observability, axiom, sentry, keep, telegram, mcp-integration-readiness, baseline, pass-1, provisional, ratification-pending, thread-79, b3-b5-closure-inline, user-pushback-instance-23, pre-input-5-instance-16, front-load-design-dir-baseline-pattern-instance-1, external-tool-eval-via-webfetch-instance-1, deposit-lane-fraud-detection-operationally-specified]
created: 2026-05-06
source: docs/adr.md@e5d491c §ADR-15 + docs/design/monitoring/{README,observability-stack,keep-deployment,alert-catalog,mcp-integration}.md@e5d491c; thread:#79; learning:2026-04-17_name-telegram-reports-merchant-grouping-bkk; retro:2026-05-05/14.28_w1-refine-adr-4b-amendment-ratification-pass-2.md; external github.com/keephq/keep
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 baseline pass — §ADR-15 Monitoring/Alerting Substrate (3-layer stack: Axiom +

W1 baseline pass — §ADR-15 Monitoring/Alerting Substrate (3-layer stack: Axiom + Sentry + Keep) → Telegram (#provisional, thread #79).

Closes deferred substrate gap from §ADR-4b amendment B3+B5 (2026-05-05; user direction at ratification time: "ตั้งใจจะแก้ทั้งหมดบน next ผ่านระบบที่คอย monitor alarm"). Phase-2 MCP integration substrate-ready by design — committed as readiness contract at baseline (D8) for user's stated long-term vision: "ในอนาคตต่อ MCP ให้ agent มาช่วย investigate".

3-layer architecture:
- Layer 1 (data plane): Axiom (managed; logs/events/traces; APL ≈ SQL/KQL; MCP-native via axiomhq/mcp-server-axiom; 500GB/mo free tier) + Sentry (managed; errors/APM/source maps/release tracking; auto-grouping fingerprint; 5K errors/mo free tier)
- Layer 2 (alert orchestration): Keep self-host on Hetzner CX22 (~$5/mo + sidecar Postgres + Caddy reverse proxy); receives webhooks from Layer 1 + Postgres pg_cron heartbeats + bot fleet heartbeats; dedup + correlate + AI-enrich via Anthropic native; workflow YAML version-controlled in `.alerts/` directory of repo (declarative, LLM-friendly diff review); deadman's-switch via Better Stack free tier
- Layer 3 (notification): Telegram bot @mb_alerts_bot (per user direction; mobiz current Telegram-reports precedent for destination pattern, alerting greenfield); 2 channels (#mb-alerts-p1 P1-page severity → DM admin + channel post; #mb-alerts-p2 P2/P3 channel-mention severity); /ack <alert_id> reply convention; 15-min escalation prefix; no on-call rotation Phase-1 (single architect-developer team; PagerDuty Phase-2 when team grows)

Phase-1 cost: ~$7/month total (Axiom free + Sentry free + ~$5 Hetzner Keep + ~$2 Anthropic enrichment).

8 ratification sub-questions in thread #79:
- D1 substrate split (3-layer stack); rec: yes; alternatives Axiom-alone / Grafana-Cloud / Better-Stack / SigNoz / Datadog / Keep-deferred all evaluated + rejected with rationale
- D2 log shipping mandatory fields = request_id (UUIDv4) + flow_slug (e.g. "deposit-auto-match") + actor (e.g. "bot:bank_account_id") at top level
- D3 trace correlation = request_id propagation Phase-1 (HTTP X-Request-Id → pino child logger in EF → Postgres SET LOCAL app.request_id → audit_log denormalize); OpenTelemetry deferred Phase-2
- D4 alert routing = Telegram @mb_alerts_bot + 2 channels (per user direction "ขอเปลี่ยนเป็น telegram" — modification from initial Slack rec)
- D5 alert authoring convention = Keep workflow YAML at `.alerts/workflows/<slug>.yml` + runbook at `.alerts/runbooks/<slug>.md` in same commit; PR review checklist (threshold tested / runbook actionable / suppression window / severity matches / ADR cross-link if closure-class)
- D6 Phase-1 alert catalog = 5 P1 + 10 P2 + 7 P3 ratified initial set (P1: finalize_deposit fail rate / EF crash chain / Postgres pool exhaustion / bot fleet outage / Keep self-down deadman's-switch)
- D7 §ADR-4b amendment B3+B5 closure mapping (4 P2 alerts: B3-Q1 → P2.7 / B3-Q2 → P2.8 / B3-Q4 → P2.9 / B5 → P2.1); closes 2026-05-05 deferral cleanly; bot adapter responsibility narrows to "emitting telemetry signals"
- D8 MCP integration Phase-2 deferral + readiness contract; substrate-ready by design (Axiom MCP official ready / Postgres MCP ready / Sentry wrapper trivial / Keep wrapper ~100-200 LOC Python); read-only-by-default Phase-2 posture; entry criteria = Phase-1 alerts stabilized + investigation pattern stable + operator trust + substrate version stability

Patterns surfaced this pass:
- User-pushback-as-design-force instance #23 — user surfaced Keep open-source tool that architect's initial Axiom+Sentry-direct rec didn't include; architect WebFetched + reframed as 3-layer stack rather than defending initial proposal
- Pre-Input-5 instance #16 — extends to external open-source tool evaluation (WebFetch + gh CLI for repo metadata; not just current-system code reads); pattern candidate for W1 workflow doc heuristic update
- "Front-load design-dir at baseline when scope known" — instance #1 (NEW pattern); design dir authored alongside ADR body at baseline pass; saves a pass-3 extraction pass (compare §ADR-4a baseline 369 lines → pass-6 extract 51 lines, 5 cycles); when can apply: substrate choice + spec + catalog all clear at baseline; when can NOT apply: discovery-driven baselines where shape emerges via pre-ratification revise (§ADR-12/§ADR-13 lifecycles)
- "External tool eval via WebFetch + gh CLI" — instance #1 (extension of Input 5 to external sources)

Pre-Input-5 instance count: 15 → 16. User-pushback-as-design-force: 22 → 23.

5 design files extracted alongside ADR body:
- `docs/design/monitoring/README.md` (~70 lines) — overview + 3-layer ASCII diagram + cross-references
- `docs/design/monitoring/observability-stack.md` (~180 lines) — Layer 1 Axiom + Sentry shipping conventions, log schema, error grouping policy, cost projection
- `docs/design/monitoring/keep-deployment.md` (~210 lines) — Layer 2 self-host config, source ingestion, workflow YAML examples (P1 routing with AI enrichment + correlation example), Telegram destination
- `docs/design/monitoring/alert-catalog.md` (~210 lines) — Phase-1 catalog (5 P1 + 10 P2 + 7 P3) + B3+B5 closure mapping
- `docs/design/monitoring/mcp-integration.md` (~140 lines) — Phase-2 plan + per-MCP-server scope + read-only-by-default posture

ADR body 140 lines (at extract threshold buffer). Total pass artifact: ~950 lines (ADR + design dir).

Threads opened: #79. Threads closed: none. Commit: `e5d491c`. PR: #18 (stacked on PR #17 branch since PR #17 not merged).

Next pass candidate: §ADR-15 ratification (pass 2) when user ratifies thread #79 — D1-D8 all have architect rec; expect either single-straight-ratify or pass-1.5 within-scope revise on substrate detail.

---
*Added via Oracle Learn*
