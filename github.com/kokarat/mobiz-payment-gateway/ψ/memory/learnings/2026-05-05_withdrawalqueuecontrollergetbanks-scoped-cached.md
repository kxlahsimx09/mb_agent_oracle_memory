---
title: WithdrawalQueueController.GetBanks scoped + cached (`3727378` PR #403, 2026-05-0
tags: [technical-writer, repo:mobiz-payment-gateway, current, withdrawal-queue, perf, redis-cache, slow-query]
created: 2026-05-05
source: controllers/WithdrawalQueueController.go:351-411@3727378
project: github.com/kokarat/mobiz-payment-gateway
---

# WithdrawalQueueController.GetBanks scoped + cached (`3727378` PR #403, 2026-05-0

WithdrawalQueueController.GetBanks scoped + cached (`3727378` PR #403, 2026-05-05). The dropdown helper at `GET /api/v1/withdrawal-queue/banks` used to aggregate every queue row whose `system_bank_id` was set (~108 K in production), grouped by bank, on every page-load AND every SSE refresh. Two changes: (1) `$match` now also filters `status: {$in: ["pending","processing"]}` — narrows scan to active items only (~31 rows), banks with no in-flight items disappear from the dropdown which matches what ops actually want; the existing `{system_bank_id, status}` compound index covers the new shape, no schema change. (2) Aggregation runs through `helpers.GetOrFetch` with key `withdrawal_queue:banks:active` and 30 s Redis TTL so the SSE-triggered refresh storm hits cache instead of re-running the pipeline. Cache misses re-run the (now small) pipeline. Triggered by DigitalOcean MongoDB SECONDARY slow-query alerts on 2026-05-05 10:29 BKK (multiple within seconds + heartbeat-failed). Verified speedup on dev: 358 ms / 108 735 rows / 42 banks → 41 ms / 31 rows / 17 banks; cache turns most calls into <1 ms hits. Doc at `docs/current-system.md` §6.1.

---
*Added via Oracle Learn*
