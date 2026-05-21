---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 166
parent_thread: 166
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: deadlock/race check PAYOUT-005 + PAYOUT-008 vs bank-bot claim — HAZARD CONFIRMED
context: see thread #166 — full investigation posted as message 502; report-only, no code changed
needs_response: false
priority: normal
created: 2026-05-18T12:57:00+07:00
---

Investigation complete. Reply posted to thread #166 (message 502); thread
marked answered. Report-only — no code changed this pass.

VERDICT: genuine deadlock hazard. The user's mental model is correct and is
the cause.

Lock-order inversion confirmed:
  • bank-bot claim (`claim_withdrawal_items`) locks withdrawal_queue →
    ts_payouts — poc/integration/src/rpc/withdraw/claim_withdrawal_items.sql
    :50-57 then :73-75 (same in poc/4a/src :63-70 / :90-93).
  • cancel RPC (`cancel_stale_payout`, PAYOUT-008 auto-cancel + per-spec
    PAYOUT-005 admin-cancel) locks ts_payouts → wallet → withdrawal_queue —
    poc/payout-autocancel/src/cancel_stale_payout.sql :30-34 / :45-47 / :67-70.
  • Opposite order on the same two rows → classic 40P01 deadlock.
    FOR UPDATE SKIP LOCKED does not prevent it (governs only the candidate
    SELECT, not the blocking UPDATEs that close the cycle).

Key qualifiers:
  • LATENT, not live — cancel_stale_payout exists only in
    poc/payout-autocancel, not yet in poc/integration or supabase/migrations.
    Activates the moment auto-cancel is ported into the integrated substrate.
  • The autocancel PoC's race tests (tests/02, tests/08) are false assurance —
    they exercise a non-faithful `claim_payout` stand-in that locks
    ts_payouts-first. Real concurrent-claim test still deferred
    ([POC_GAP:ADR-4a:concurrent-claim-test]).
  • The WHERE status='pending' race-guard itself is sound — no lost update
    once a winner exists. Hazard is purely acquisition order beforehand.
  • Blast radius: sweep tolerates 40P01 (per-row EXCEPTION...CONTINUE); bot
    claim has NO handler → one racing payout aborts a whole bank's claim batch.

FIX OWNER: code → next-impl (me). Reorder `cancel_stale_payout` to take the
withdrawal_queue lock (SELECT ... FOR UPDATE on source_id) before the
ts_payouts CAS, giving all paths the consistent prefix
withdrawal_queue → ts_payouts. Apply same order to PAYOUT-005 before it is
implemented. Must land before auto-cancel is ported into the integrated
substrate.

Minor spec note (non-blocking) → next-writer / next-architect: PAYOUT-005
AC #2/#3 (epic-payout.md:331-332) reason per-row only and are silent on the
cross-row order; candidate §ADR-4a amendment to pin canonical lock order
withdrawal_queue → ts_payouts → wallet.

Full detail + the deadlock interleaving in thread #166 message 502.

— next-impl

# handled_at: 2026-05-18T13:04:32+07:00
# handled_by_thread: 166
# handled_note: deadlock investigation delivered (hazard CONFIRMED, report-only); relayed to user for fix decision
