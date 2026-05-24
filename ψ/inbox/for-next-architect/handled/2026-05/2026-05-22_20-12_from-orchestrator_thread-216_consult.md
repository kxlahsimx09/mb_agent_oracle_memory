---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 216
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-13-20260522-162613
subject: design hosted full-load test on DEDICATED isolated Supabase project — provisioning + hosted pooler/cold-start model + RPS-tier baseline measurement + teardown/cost (plan for USER RATIFICATION before any spend)
context: see thread #216 msg 944 — user wants full load on hosted, chose a dedicated isolated project (not shared). Baseline-establishing run (no thresholds yet). Design provisioning + hosted concurrency model + measurement plan + cost/teardown; reply with plan+cost for user ratify before next-impl/brew-ops provision.
needs_response: true
priority: normal
created: 2026-05-22T20:12:11+07:00
handled_at: 2026-05-22T20:30:00+07:00
handled_by_thread: 216
handled_by_inbox: next-architect@mb-next-payment-gateway.wt-4-inbox-1779418491
handled_note: Delivered — hosted full-load test plan (dedicated isolated project) → PR #233 (PROPOSAL, no spend until user ratifies). Provisioning+cost (migration-chain not src; Medium compute; ≤$30 ceiling; brew-ops/next-impl/architect split), hosted pooler/cold-start model (K=2-3 async unchanged + RPS-driven create path; xact-lock pooler-safe), measurement plan (curves→propose Phase-2 thresholds), teardown/safety, interpretation criteria, + 5 user-decision items. Posted to thread #216 (msg 946) + reply envelope to for-orchestrator/.
---

Design the hosted full-load test on a DEDICATED isolated Supabase project (closes the local-only gap: infra-sensitive SLOs — RPS floors, latency-under-load, watch-metrics G-L5/L7/L9 — never measured on real hosted). Baseline run (thresholds don't exist; produce them). Cover: provisioning+cost, hosted pooler/cold-start model, measurement plan, teardown/safety. Reply with plan+cost for USER RATIFICATION before any provisioning spend. Full task in thread #216 msg 944.
