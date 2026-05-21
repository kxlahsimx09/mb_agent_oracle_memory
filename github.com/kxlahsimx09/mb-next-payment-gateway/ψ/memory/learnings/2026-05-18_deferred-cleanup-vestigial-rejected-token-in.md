---
title: Deferred cleanup — vestigial `'rejected'` token in the payout-reconcile anomaly 
tags: [next-impl, repo:mb-next-payment-gateway, adr-9, payout, rejected-terminal, cleanup-deferred, poc-integration, thread-161]
created: 2026-05-18
source: thread #161 — next-impl PR #147 re-assessment msg 487
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Deferred cleanup — vestigial `'rejected'` token in the payout-reconcile anomaly 

Deferred cleanup — vestigial `'rejected'` token in the payout-reconcile anomaly branch (both substrates) 2026-05-18

After §ADR-9 §Amendment 2026-05-16 retired the payout `rejected` terminal (deployed substrate reconciled in audit #158 PR #152: `mark_rejected` dropped, `ts_payouts`/`withdrawal_queue` CHECKs tightened to exclude `rejected`), one vestigial reference survives in BOTH substrates:

- Deployed: `supabase/migrations/20260516000004_adr4a_payout_reconcile.sql:227` — the reconcile anomaly branch `ELSIF v_q.status IN ('failed','cancelled','rejected')`. PR #152 did not touch this line.
- Local PoC: `poc/integration/src/.../payout_reconcile.sql:178` — verbatim mirror of the same IN-list (carried in PR #147, the poc/integration/src parity port).

It is an unreachable branch — with the tightened status CHECK no row can sit at `status='rejected'` — so it is harmless, not a bug. But it is dead taxonomy.

Also stale (pre-existing prose, low-pri): `poc/integration/src/probes/index.ts:112` and `poc/integration/src/probes/bot-restart-claim.ts:29` have comments naming `mark_rejected` as a terminal RPC.

Recommended cleanup: a future §ADR-9 audit pass removes the `'rejected'` token from the anomaly-branch IN-list in BOTH substrates together, via a forward-only follow-up migration on the deployed side (no in-place edit of `20260516000004` — forward-only rule) + the matching `poc/integration/src` edit, and sweeps the two stale comments. Not urgent; not a blocker for PR #147 (which is mergeable as-is). Surfaced by next-impl during the thread #161 re-assessment.

---
*Added via Oracle Learn*
