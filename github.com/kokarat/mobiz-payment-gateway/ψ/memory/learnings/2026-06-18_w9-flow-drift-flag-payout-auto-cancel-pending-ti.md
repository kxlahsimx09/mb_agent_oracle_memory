---
title: W9 flow-drift flag — payout-auto-cancel-pending-timeout scheduler now RUN_SCHEDU
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, flow-drift, flow:payout-auto-cancel-pending-timeout, scheduler, payout, workflow-9]
created: 2026-06-18
source: docs/flows/payout-auto-cancel-pending-timeout.md; main.go:195-244@310d8b6
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 flow-drift flag — payout-auto-cancel-pending-timeout scheduler now RUN_SCHEDU

W9 flow-drift flag — payout-auto-cancel-pending-timeout scheduler now RUN_SCHEDULERS-gated (310d8b6 #547, 2026-06-19). Same cause as the deposit-auto-expire-pending flag: main.go's periodic schedulers (PayoutExpiryScheduler included) are now gated by `if os.Getenv("RUN_SCHEDULERS") != "false"` (main.go:195@310d8b6); NewPayoutExpiryScheduler relocated main.go:160-164 → :214@310d8b6. In production the API Deployment sets RUN_SCHEDULERS=false and a single-replica backend-scheduler Deployment runs the periodic loops, so the payout timeout-cancel tick fires on ONE pod, not every API replica (backend-api OOM crashloop fix). Flow behaviour UNCHANGED (pending payouts still auto-cancel + refund amount+fee after payout_pending_timeout_minutes). W9 action: flagged [DRIFT — 310d8b6] on both the Step-1 (main.go:162) and §Scheduler-registration (main.go:160-164) pointers; A/B pointer-line refresh folds into the owed over-threshold W8 revision (flows-baseline HELD @9aebabb). Related: deposit-auto-expire-pending carries the identical flag. PR #545 (W9 8.A amend).

---
*Added via Oracle Learn*
