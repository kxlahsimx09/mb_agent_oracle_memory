---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: notify
thread: 137
parent_thread: 132
parent_oracle: orchestrator
subject: RR11 #2 landed — outbound bank-statement matcher EF + wiring + design doc (PR #135)
context: §ADR-4a §Amendment 2026-05-16 (thread #133) statement-driven review-payout auto-reconcile
needs_response: false
priority: normal
created: 2026-05-16T21:17:00+07:00
---

RR11 handoff #2 is landed — **PR #135** on `kxlahsimx09/mb-next-payment-gateway`
(`poc-implement/adr4a-payout-reconcile-2026-05-16`).

## Delivered

- **Outbound matcher** — migration `20260516000003_adr4a_payout_reconcile.sql`:
  `match_payout_statement` / `reconcile_payout` / `sweep_payout_reconcile` RPCs.
  Resolution via the existing `mark_success` lifecycle RPC — **no new RPC, no
  `ts_payouts` / `withdrawal_queue` schema change** (RR8). One nullable
  forensic-link column added: `bank_statements.matched_payout_id`.
- **3 trigger paths (RR1 a/b/c)** — (a) `bot-statements` EF calls
  `match_payout_statement` per inserted row; (b) `mark_review` tail-calls
  `reconcile_payout` (the primary hit path — `mark_review` re-created verbatim
  + one appended line); (c) `pg_cron` job `sweep-payout-reconcile`, 1-min,
  1-hour look-back window.
- **Feature flag** `payout_auto_reconcile_enabled` — seeded **default ON**
  (RR9, thread #133 Q2), fail-closed (absent/unreadable → off).
- **Phase-1 scope** — `review → completed` only (Q1 = (B)). `review → failed`
  not built; the "absence never auto-fails" hard invariant is on record. No
  `failed → completed` resurrection — a debit matching a `failed` payout is an
  anomaly → `review`, never auto-revert.
- **Machine actor (RR7)** — `matched_link_step='payout_reconcile'` +
  `matched_payout_id` + `matched_request_id` on the statement row; matcher
  returns `actor='payout_reconcile_matcher'`, `created_by_type='system'`.
- **Design doc** — NEW `design/withdrawal-lane/payout-reconcile.md` (RR11),
  README + decision-map updated.
- **`open-questions.md` §3** — the "bank-statement import/search to aid admin
  verification" item flipped to **RESOLVED** (RR10).
- **Probe** — `poc/integration/src/probes/payout-reconcile.ts` (statement-driven /
  payout-driven / anomaly sub-checks), wired into the probe registry.

## Verification

Full migration chain + this migration apply clean. Functional test of every
matcher branch passes: `reconciled`, `amount_mismatch`, `anomaly_terminal_mismatch`
(payout stays `failed`, not resurrected), `no_request_id`, `payout_in_flight`,
`disabled` (flag off), and `sweep_payout_reconcile`. The integration fixtures
emit no `direction='out'` statements (the bot-simulator pushes deposit
statements only), so this amendment is **dormant against the existing
74-assertion suite** — `PAY-%-REV-%` triage payouts have no matching debit and
stay `review` — and the new probe is the dedicated load-bearing exercise.

## thread #137 addendum (msg 373 / closed #138) — folded in

The bot-writer RR2 addendum is incorporated into `payout-reconcile.md` §match
gate: (1) practical reach is **KTB only** today — SCB writes the memo but its
scraper does not read it back, so SCB behaves as memo-less (graceful
degradation, no safety loss); (2) the **hard `/queue/claim` `request_id`
contract** is documented — `claim_withdrawal_items` returns `request_id` from
`ts_payouts.request_id` and for `source_type='payout'` the row always exists,
so the field is always populated; the bot's silent `item.request_id||item.id`
fallback is called out as the failure mode the gateway must never trigger.

## Three surfaces flagged (not blocking)

1. **Two callbacks on the payout-driven path.** The implemented `mark_review`
   enqueues a `payout.waiting_to_review` callback (a deliberately-kept §ADR-9
   event — thread #123 §Landing note). So an auto-reconcile produces
   `payout.waiting_to_review` then `payout.success`, not the §Amendment intro's
   literal "callback NOT sent" on `review`. The structural win holds in full
   (wallet settled once, no debit→credit-back→re-debit, client never sees
   `failed`, single forward transition); only the callback count differs.
   Whether to suppress `payout.waiting_to_review` is a §ADR-9 callback-taxonomy
   question — flagging for that surface, not fixed here.
2. **Pre-existing `mark_failed` overload ambiguity.** The substrate carries two
   `mark_failed` signatures — `(uuid,text)` (rpc_withdraw / freeze-settle) and
   `(uuid,text,text)` (§ADR-9 WC RPCs) — so a 2-arg call is ambiguous. Latent
   (the always-`review` sweep no longer calls it 2-arg; `bot-queue-mark` passes
   3). Worth a cleanup migration to drop the stale 2-arg overload.
3. **§ADR-13 `audit_log` not in the substrate floor.** RR7's actor triple is
   recorded on the `bank_statements` row (the §ADR-4b deposit-cascade
   precedent — it also records forensics on `bank_statements`, not `audit_log`).
   Once `audit_log` lands, the actor triple should also be written there.

— next-impl, 2026-05-16 GMT+7

<!-- handled_at: 2026-05-16T21:42:00+07:00 — RR11 #2 EF landed PR #135; flag #1 (waiting_to_review callback) surfaced to user. -->
