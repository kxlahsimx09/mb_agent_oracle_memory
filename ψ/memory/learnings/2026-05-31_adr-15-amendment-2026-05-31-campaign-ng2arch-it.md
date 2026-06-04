---
title: §ADR-15 §Amendment 2026-05-31 (campaign ng2arch ITEM C, PR #294, NOT merged — pe
tags: [adr-15, monitoring, wallet-high-balance, ops-report, alert-catalog, amendment, ratification-pending, ng2arch, monitor-005]
created: 2026-05-31
source: next-architect (ng2arch follow-on ITEM C)
---

# §ADR-15 §Amendment 2026-05-31 (campaign ng2arch ITEM C, PR #294, NOT merged — pe

§ADR-15 §Amendment 2026-05-31 (campaign ng2arch ITEM C, PR #294, NOT merged — pending user GO) — Wallet-High-Balance Alert + Periodic Ops-Report (D6 catalog expansion #2). Closes the MONITOR-005 gap: current production runs two operational Telegram surfaces §ADR-15 D6 does not enumerate; invokes D6's "expand via amendment when operational pattern reveals gap" clause.

RATIFIED class (a) port-fidelity: MA1 — wallet-high-balance alert EXISTS (`WalletAlertController.TriggerHighBalanceAlert`, hourly external cron, BotAuth; scans ACTIVE CLIENT wallets `balance > WALLET_HIGH_BALANCE_THRESHOLD` default 200,000 THB; change-gated dedup via hash of (client_id, balance bucketed to 50,000) + 23h daily-heartbeat floor); MA2 — periodic transaction ops-report EXISTS (`scheduler/report_scheduler.go`, hourly "Transaction Summary" grouped by merchant: deposit/topup/payout/settlement counts+THB+MDR; business-day-start 02:00 BKK). Both compose §ADR-15 D4 Telegram routing + D5 `.alerts/` YAML+runbook authoring.

FLAGGED class (b) [RATIFICATION_PENDING:ng2arch-c]: (C-s1) alert severity class P2-channel vs P3-digest — lean P2 (actionable financial-float signal, change-gated+heartbeat so no storm); (C-s2) ops-report cadence hourly (port current) vs daily (consolidate into the P3 9am digest) — lean hourly port-fidelity, daily flagged as noise-reduction.

Verify-against-HEAD e35a6e1: §ADR-15 D6 = 32 alerts (7 P1+16 P2+9 P3), none wallet-high-balance, only P3 daily digest 9am — gap confirmed. Story MONITOR-005 authored in epic-monitoring. Repo: kxlahsimx09/mb-next-payment-gateway (next-system); grounding kokarat/mobiz-payment-gateway.

---
*Added via Oracle Learn*
