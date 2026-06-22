---
title: Periodic schedulers gated to a single instance via RUN_SCHEDULERS (310d8b6 #547,
tags: [technical-writer, repo:mobiz-payment-gateway, current, scheduler, withdrawal-queue, oom, workflow-2]
created: 2026-06-18
source: main.go:184-244@310d8b6, k8s/base/scheduler-deployment.yaml@310d8b6
project: github.com/kokarat/mobiz-payment-gateway
---

# Periodic schedulers gated to a single instance via RUN_SCHEDULERS (310d8b6 #547,

Periodic schedulers gated to a single instance via RUN_SCHEDULERS (310d8b6 #547, 2026-06-19). main.go now wraps the seven periodic schedulers (pull-out, deposit-expiry, maintenance-cancel, payout-expiry, transaction matchers, callback-retry, finance-settlement-importer) in `if os.Getenv("RUN_SCHEDULERS") != "false"`. Default (unset / local) runs them all — prior single-pod behaviour preserved. In production the API Deployment sets RUN_SCHEDULERS=false and a new single-replica backend-scheduler Deployment (k8s/base/scheduler-deployment.yaml) sets it true, so every periodic loop runs on exactly one pod. The WithdrawalDispatcher is intentionally NOT gated — it stays on every API pod (atomic per-bank lock, needed for instant TryDispatchNow on enqueue / bot-completion). Root cause fixed: each API replica was running the statement MatcherScheduler (loads bank_statements every 30s → memory spike → backend-api OOM crashloop) and duplicating the expiry / maintenance-cancel / callback-retry / finance-import passes (races, duplicate callbacks). Companion k8s right-sizing 9fd724c #552 + d53c129 #555 lowered backend-api mem 3Gi→1.5Gi post-singleton (devops). Documented current-system.md §5 intro (W2 PR #540).

---
*Added via Oracle Learn*
