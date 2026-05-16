---
title: epic authored — epic-payout PAYOUT-002/003/004 (terminal-outcome trio) — 3 stori
tags: [next-product-writer, repo:cross, next, requirement, epic, epic-payout, payout-002, payout-003, payout-004, withdrawal-lane, s2-ratified, workflow-1, terminal-outcome-trio, mark-success, mark-failed, sweep-triage, freeze-settle, writer-flagged-unratified-surface, rejected-terminal-deferred]
created: 2026-05-16
source: docs/requirements/epic-payout.md@eb169f5
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# epic authored — epic-payout PAYOUT-002/003/004 (terminal-outcome trio) — 3 stori

epic authored — epic-payout PAYOUT-002/003/004 (terminal-outcome trio) — 3 stories, trust mix S2/S3/S4 = 3/0/0.

W1 author-requirement, single pass, batch of 3 stories under existing epic-payout (overview + PAYOUT-001 + PAYOUT-008 already merged). Mirrors the DEPOSIT-006/007/008 terminal-trio batch shape. Branch writer/payout-002-003-004-terminal-trio-2026-05-16, commit eb169f5.

Stories:
- PAYOUT-002 — bank-bot claims a routed payout, completes the transfer at the bank portal; `mark_success` settles the wallet freeze (balance AND frozen each -= amount+fee, op `payout_settle`) + `payout.success` callback. Cross-repo gateway+bot.
- PAYOUT-003 — bank-bot reports the transfer did not complete; `mark_failed` releases the freeze (frozen -= amount+fee, balance untouched, op `payout_unfreeze`) + `payout.failed` callback. Cross-repo gateway+bot.
- PAYOUT-004 — a stuck claimed/processing payout is sweep-triaged by `bank_transaction_id` (NOT NULL → waiting_to_review; NULL → mark_failed); admin verifies the bank statement + reconciles via mark_success/mark_failed under the §ADR-13 3-layer write invariant. Cross-repo gateway-only (no wire contract — gateway detects a crashed bot by silence).

Subsystem: withdrawal-lane
Sources cited: §ADR-4a (D4 claim RPC, D5 pre-claim health, D6 sweep triage, D7 4-step lifecycle, D8 admin-reconcile), §ADR-9 (§Bundle TS2/TS3/TS5 terminal-state taxonomy + failureCode enum + WC1-WC11 wire contract), §ADR-10 (AM2 freeze-settle, AM3 snapshot audit, AM4 operation enum, AM5 CHECK), §ADR-13 (D1 3-layer write invariant, D2 audit_log+last_admin_action). dpay MCP collections ts_payouts / withdrawal_queue / wallets_change_logs verified 2026-05-16.

Production verification notes:
- ts_payouts.status terminal value in mobiz production = `completed`; withdrawal_queue payout work items already use `success`. Next-system unifies on `success` per §ADR-9 §Bundle TS2 — deliberate divergence, makes stored status + `mark_success` RPC + `payout.success` event read the same word. Documented as a PAYOUT-002 edge case.
- withdrawal_queue payout bank_transaction_id population by status: processing 23/59, failed 1900/5386, waiting_to_review 334/550 (~61%), success 92447/170949 — confirms the §ADR-4a D6 triage discriminator is a real sparse field, populated on a subset.
- wallets_change_logs payout ops: `payout` 180292 (create-time freeze/debit), `payout_refund` 6217 (release on fail/cancel), `payout_confirm_completed` 238 (admin reconcile-to-success). ts_payouts carries admin-reconcile fields confirmed_completed_by / _username / confirm_completed_reason / confirmed_completed_at.

Open threads: none anchored as [AWAITING_THREAD]. One writer-flagged unratified surface noted as a PAYOUT-003 Open Question (NOT escalated to a thread because it is a known-deferred surface, not silent): the §ADR-9 §Bundle TS2 `rejected` payout terminal (deliberate bank refusal — insufficient funds / account closed / KYC block) is ratified in the callback taxonomy, but its dedicated lifecycle RPC `mark_rejected` is named "future" in §ADR-9 TS3 and is NOT ratified in §ADR-4a (whose lifecycle RPCs are mark_success/mark_failed/mark_waiting_to_review only). A PAYOUT story for the bank-reject outcome is therefore deferred pending that RPC's ratification. Flagged for the architect — candidate for a §ADR-4a amendment + a future PAYOUT-00X story.

File-size note: epic-payout.md is now 360 lines, over the 250-line target. Not split mid-pass — same judgment call as the epic-deposit DEPOSIT-006/007/008 batch (file already authored over budget; cluster-split + revision-log archive is a separate housekeeping pass). Flagged in the PR.

File: docs/requirements/epic-payout.md@eb169f5

---
*Added via Oracle Learn*
