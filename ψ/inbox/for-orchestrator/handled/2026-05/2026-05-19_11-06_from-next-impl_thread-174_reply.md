---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 174
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: re — integration-layer coverage-gap refresh (continue #158/#168) — DONE, report-only
in_reply_to: 2026-05-19_10-59_from-orchestrator_thread-174_consult.md
needs_response: false
priority: normal
created: 2026-05-19T11:06:00+07:00
handled_at: 2026-05-19T11:24:00+07:00
handled_by_thread: 174
---

Integration-layer coverage-gap map refreshed. Full report on thread #174
(message 566). **Report-only — nothing built, nothing merged.**

Verified against the deployed substrate (`supabase/migrations/*`, head
`20260518000006`) + the gateway src, not the floor PoCs (per #168 G9).

12 ranked gaps, G-1..G-12:
- **P0** — G-1 `audit_log` table + `last_admin_action_*` denorm columns absent
  (migration comments only); G-2 DEPOSIT-007 real approve-time V1/V2 fraud
  cascade absent (fires via a `fraud_seed` fixture flag, not the spec'd
  cascade; force-approve two-gate missing).
- **P1** — G-3 admin-API endpoints (RPCs mostly exist, HTTP surface + JWT/RBAC
  unwired); G-4 `slip_uploaded_by_*` audit triple; G-5 DEPOSIT-012 + PAYOUT-007
  resend-callback (zero substrate); G-6 DEPOSIT-008 verify-slip-now; G-7
  DEPOSIT-001 create-time rejections; G-8 two flaky probes (#168 carry-forward).
- **P2 (probe-only)** — G-9 `mark_failed` rollback twin; G-10 PAYOUT-008
  view-contract; G-11 PAYOUT-009 degradation paths; G-12 sweep-restart.

Key distinction: G-1..G-7 are substrate **PORTs** (schema/RPC/endpoint, embed
config decisions — need an architect/ADR check); G-8..G-12 are genuine
**probes** against existing substrate. Recommended close-order leads with G-1
(unblocks G-2/G-3). The three #168 carry-forwards were folded in, not
re-discovered.

User picks the close-scope for the next round.

— next-impl
