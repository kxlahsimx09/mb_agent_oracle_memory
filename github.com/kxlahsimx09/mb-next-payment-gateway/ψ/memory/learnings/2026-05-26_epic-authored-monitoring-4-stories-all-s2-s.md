---
title: epic authored — monitoring — 4 stories, all S2.
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, epic, monitoring, observability, s2-ratified, campaign-228, thread-230]
created: 2026-05-26
source: docs/requirements/epic-monitoring.md@writer/monitoring-adr15
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# epic authored — monitoring — 4 stories, all S2.

epic authored — monitoring — 4 stories, all S2.

Subsystem: monitoring (Monitoring & Alerting observability backbone)
Net-new epic from campaign #228 / sub-thread #230 (P1, sequential pass 3 — authored off latest merged main after #250 merged). Translates §ADR-15 (Monitoring/Alerting Substrate, #decision thread #79) into human-readable operator/SRE-facing stories.

Stories (all S2):
- MONITOR-001 3-layer stack (D1): Axiom logs + Sentry errors + Keep self-hosted alert orchestration → Telegram; one alert engine ingests both platforms + bot/DB heartbeats; dedup+correlate+AI-enrich; dead-man's-switch on the engine (D4 routing).
- MONITOR-002 trace correlation (D2/D3): 3 mandatory top-level log fields (request_id + flow + actor/component); single request_id propagated HTTP-entry → EF → DB session (SET LOCAL) → audit/forensic rows → callback metadata + bot scrape. Phase-1 substitute for distributed tracing (OTel Phase-2). Internal request_id ≠ client-facing callback event id.
- MONITOR-003 alert catalogue (D5/D6/D4/D7): versioned .alerts/ YAML + runbook same commit, PR-reviewed; severities P1 page (channel+DM, 15-min ack + auto-escalate) / P2 channel / P3 daily digest; 7 P1 + 16 P2 + 9 P3 = 32 alerts grounded in historical incidents (wallet double-debit jaosua777, KTB login spike, callback dead-letter, payout-success-no-debit SC5 exempt-class); D7 closes bot-lane B3(Q1/Q2/Q4)+B5 drift deferrals with concrete alerts.
- MONITOR-004 MCP-ready (D8): every component agent-queryable by design; Phase-1 ships WITHOUT agent (not a regression); Phase-2 agent access hard read-only until human approval; gated on alert-stabilisation + operator trust.

Grounding: monitoring is GREENFIELD in mobiz current (only ad-hoc logs + cron Telegram reports); only the Telegram destination convention is ported (controllers/TelegramController.go). Alert catalogue cites historical incidents from the ADR's pass-1.5 memory sweep — no fresh dpay needed.

Cross-repo: monitoring substrate is gateway-owned; several alerts CONSUME bot-fleet signals (bankbot v2 emits). Cross-repo column = gateway (+ bot signals) for MONITOR-001/002/003; gateway-only for MONITOR-004.

Files: docs/requirements/epic-monitoring.md (new) + glossary.md (+request id, +observability stack) + INDEX.md (+Monitoring & Alerting section) + README.md (+row after Fleet-Control). Mermaid 1/1 PASS; MDX clean.

PROCESS: branched off latest merged main (b0ad7f4, has #250) per sequential cadence — clean, no conflict. PR opened; pausing for merge before Idempotency (§ADR-11) → A1 → A4.

---
*Added via Oracle Learn*
