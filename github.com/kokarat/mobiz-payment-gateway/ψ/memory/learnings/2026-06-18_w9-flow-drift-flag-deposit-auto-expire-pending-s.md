---
title: W9 flow-drift flag — deposit-auto-expire-pending scheduler now RUN_SCHEDULERS-ga
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, flow-drift, flow:deposit-auto-expire-pending, scheduler, workflow-9]
created: 2026-06-18
source: docs/flows/deposit-auto-expire-pending.md; main.go:195-244@310d8b6
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 flow-drift flag — deposit-auto-expire-pending scheduler now RUN_SCHEDULERS-ga

W9 flow-drift flag — deposit-auto-expire-pending scheduler now RUN_SCHEDULERS-gated (310d8b6 #547, 2026-06-19). main.go's seven periodic schedulers (DepositExpiryScheduler included) are now wrapped in `if os.Getenv("RUN_SCHEDULERS") != "false"` (main.go:195@310d8b6); NewDepositExpiryScheduler relocated main.go:150-152 → :202@310d8b6. Default unset/local still starts them; in production the API Deployment sets RUN_SCHEDULERS=false and a single-replica backend-scheduler Deployment (k8s/base/scheduler-deployment.yaml) runs them, so the deposit-expiry tick fires on ONE pod instead of every API replica (root-cause fix for the backend-api OOM crashloop). Flow behaviour is UNCHANGED (pending deposits still expire after TTL + fire the expiry callback) — this is a deployment-locus + pointer-line shift, not an actor-crossing change. W9 action: flagged [DRIFT — 310d8b6] on the Step-1 main.go pointer; pointer-line A/B refresh + any §Actors note fold into the owed over-threshold W8 revision (flows-baseline HELD @9aebabb). PR #545 (W9 8.A amend).

---
*Added via Oracle Learn*
