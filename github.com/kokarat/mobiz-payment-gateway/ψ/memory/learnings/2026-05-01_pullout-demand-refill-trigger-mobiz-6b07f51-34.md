---
title: Pullout demand-refill trigger (mobiz `6b07f51` #342, 2026-04-30) — opt-in via `a
tags: [technical-writer, repo:mobiz-payment-gateway, current, pullout, demand-refill, auto-trigger, scheduler, feature-flag]
created: 2026-05-01
source: services/pulloutDemand.go:300-554@6b07f51 + controllers/BotConfigController.go:546-636@6b07f51 + models/pullout_task.go:70-78@6b07f51
project: github.com/kokarat/mobiz-payment-gateway
---

# Pullout demand-refill trigger (mobiz `6b07f51` #342, 2026-04-30) — opt-in via `a

Pullout demand-refill trigger (mobiz `6b07f51` #342, 2026-04-30) — opt-in via `app_settings`. `BotConfigController.UpdateBankBalance` now spawns a SECOND goroutine (alongside the existing drain goroutine) that fires when a payout-method dest bank's balance drops below `payout_demand_refill_threshold` (default 50,000 THB). Walks all enabled `pullout_tasks` with matching dest via new helper `services.FindEnabledPulloutTasksForDest`, picks the first task whose per-task cooldown has expired (`payout_demand_refill_cooldown_minutes`, default 10 min) and whose source has the headroom — first-task-wins, stamps `pullout_tasks.last_demand_trigger_at` only on a successful enqueue (so guard-skips don't burn cooldown). Disabled by default via `payout_demand_refill_enabled=false`.

Three new public helpers in services/pulloutDemand.go (lines 350-554): `FindEnabledPulloutTasksForDest(ctx, destBankCode, destAccountNumber)` returns enabled tasks matching the dest. `TriggerPulloutTaskByDemand(ctx, task, sourceBank, destBank)` runs the SAME guard chain as the manual `ExecutePullOutTaskNow` path (DestCap band via `LoadRefillSettings` + `PickRandomDestCap`, two-layer reservation via `SumPendingPulloutAmountsToDest` + `SumSettledPulloutAmountsToDest`, source-side reservation) and either enqueues a withdrawal or returns `DemandRefillResult{Skipped: true, SkipReason: …}`. `StampDemandTriggerCooldown(ctx, taskID)`.

Three new settings keys: `SettingKeyPayoutDemandRefillEnabled`, `SettingKeyPayoutDemandRefillThreshold` (default 50000), `SettingKeyPayoutDemandRefillCooldownMinutes` (default 10). New `models.PullOutTask.LastDemandTriggerAt` (`time.Time`, bson:`last_demand_trigger_at`) — distinct from `LastRunAt` (which scheduler updates every tick, skipped or executed).

Design constraint per commit message: MUST NOT modify any existing flow. Manual execute (PullOutTaskController), scheduler legacy (scheduler.executeTask), and existing balance-trigger drain path (SyncBalance "drain" block) all remain byte-for-byte unchanged. Verified via git diff: only three files touched (BotConfigController.go +91, pulloutDemand.go +240, pullout_task.go +9), all ADD-only.

Cap and source guards are deliberately COPY-PASTED from the manual execute path rather than refactored into a shared helper, so a future change to either path can't silently break the other. They share leaf helpers (PickRandomDestCap, SumPendingPulloutAmountsToDest, SumSettledPulloutAmountsToDest) but not the surrounding flow.

---
*Added via Oracle Learn*
