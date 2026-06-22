---
title: brew-ops staging deploy — a TARGETED migrations-only deploy can silently leave t
tags: [brew-ops, staging-deploy, workflow-7, migration, edge-function-drift, change-detection, sinuw, otp-logs]
created: 2026-06-17
source: brew-ops campaign otplogsenhstaging 2026-06-18
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# brew-ops staging deploy — a TARGETED migrations-only deploy can silently leave t

brew-ops staging deploy — a TARGETED migrations-only deploy can silently leave the EF substrate DRIFTED when a single PR touches BOTH a migration and an edge function. PR #578 (/otp-logs ①② on sinuw) advanced gateway e9505d7→c1f2fe1; the migration slice (otp_logs.from_email + 8-arg save_bot_otp + v_otp_logs re-create + purge-cron 24h→7d) was applied via Mgmt-API SQL, but the SAME PR also changed supabase/functions/bot-otp-log/index.ts (the from_email HTTP pass-through) — which a migrations-only scope does NOT deploy. ALWAYS run `git diff --name-only <prior-manifest-SHA> <source-SHA> -- supabase/functions/ gateway/cf-worker/` after a targeted migration deploy and record any EF/worker drift in the manifest as `stale-drift`, not a silently-carried green. The migration is correct without the EF (column/RPC/view accept the new field; the EF only adds the wire pass-through) = forward-compat gap, not broken — but it must be surfaced. Also: the sinuw ledger's only persistent "pending" rows are the runtime-wipe migrations (reset_runtime_v3 …000040, reset_runtime_v4 …000150) — deliberately NOT applied to the shared staging stack (the §ADR-21 harness applies them on demand); don't treat them as a deploy gap.

---
*Added via Oracle Learn*
