---
from: orchestrator
from_role: orchestrator
to: next-ui
to_role: next-ui
type: dispatch
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: WIRE THE FULL CORE DATA SET — owner wants every main screen they need to watch reading LIVE staging (sinuw), not mock
priority: high
created: 2026-06-11T21:00:00+07:00
needs_response: true
---

# Wire all the core screens to live staging data

Owner verbatim (2026-06-11): "ผมอยากให้คุณ ให้ next-ui ทำการ wiring data หลักๆ ที่ผมจำเป็นต้องดู เข้ากับ ui ให้ครบเลย" — wire ALL the main data the owner needs to watch into the UI, against the live staging stack `sinuwgsqqyqzlpaavimf`. Today only `/deposit` + the new `/bank-statements` are live (PR #8); the dashboard, settlement, payout, wallet, etc. are still 100% mock (`@/lib/mock`).

## Task

1. **Inventory first** — enumerate every screen/route in the portal and mark each LIVE vs MOCK and the backing table/view it should read. Reply that map early so we agree on scope before you grind through all of them.
2. **Wire the core payment/bank-flow screens to live sinuw** under the SAME proven pattern as `/deposit` (aal2 + RLS + `has_read_perm`, realtime, real-`Date.now()` date anchor). Priority order (do the ones whose backing views exist; the owner is watching the bank-bot → deposit → settlement money flow):
   - Dashboard / overview (the landing summary — counts, recent activity)
   - Deposits ✓ (done) · Bank-statements ✓ (done)
   - Settlements
   - Payouts
   - Wallets / wallet change-logs (the credit ledger — the owner saw 4 rows in the journey)
   - Merchants / clients / partners (the entities)
   - Callbacks / webhook delivery log
   - Transactions / ledger if present
3. **For any screen whose backing view/table does NOT exist in sinuw** (or needs an RLS read-perm that isn't granted), DO NOT fake it — list it and hand the exact gap to the orchestrator so I route next-dev (gateway view/RLS) rather than you inventing a shape.
4. **Read-only** — these are view screens. No writes, no mutations of gateway data. Same guardrails as PR #8.

## Process

- Batch sensibly: one PR per coherent cluster (or a few) → next-code-reviewer, rather than one giant PR. Keep each within the file-size rules. Deploy each to the staging alias as it lands (git-less) so the owner can watch progress.
- The login + URL are unchanged (https://mb-next-admin-portal-staging.vercel.app, simlive10-admin@authtest.local). Keep the alias current.
- Reuse existing components/tokens; `impeccable detect` clean; critique + audit per your loop.

## Deliverable (rolling, reply → for-orchestrator/ + thread #13)

First the LIVE-vs-MOCK inventory map + which backing views exist, then PR links per cluster as they land, and a running list of any screens BLOCKED on a missing gateway view/RLS (for next-dev routing).
