---
title: pullout source-side reservation now uses actual $sum, not count × MaxAmount (#502)
tags: [technical-writer, repo:mobiz-payment-gateway, current, scheduler, pullout]
created: 2026-06-01
source: scheduler/scheduler.go:194-232@37a7eab, services/pulloutDemand.go:131-180@37a7eab
project: github.com/kokarat/mobiz-payment-gateway
---

`37a7eab` #502 (2026-05-31) changed `Scheduler.executeTask`'s source-side in-flight reservation. Effective source balance is now `systemBank.Balance − reserved`, where `reserved` is the **actual `$sum` of in-flight (pending+processing) pullout amounts** leaving the source bank, via the new helper `services.SumPendingPulloutAmountsFromSource(ctx, sourceBankID)` — the exact source-side mirror of `SumPendingPulloutAmountsToDest`.

Previously `reserved = CountPendingPulloutsFromSource × task.MaxAmount` (conservative upper bound assuming every random-band item settles at its ceiling). A 2026-05-31 ampay skip audit found **47% of "effective balance < min" skips were false positives** — banks with real headroom rejected. Example: bank `4232204440`, balance 486,881, 3 pending → old reserved 3×150k = 450k (SKIP) vs new reserved ≈375k (RUN).

`CountPendingPulloutsFromSource` is retained only to populate the skip-log "N pending" count. Cost: one extra aggregate per task tick (~30/min) — negligible vs a false skip that idles a task a full strategy interval. Documented in `current-system.md` §5 (PullOutScheduler row) + §6.4.
