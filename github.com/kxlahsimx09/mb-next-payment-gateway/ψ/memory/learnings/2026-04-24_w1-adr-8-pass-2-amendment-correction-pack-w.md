---
title: W1 ADR-8 pass-2 amendment — **correction pack** (withdrawal-only metric + dead-c
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-8, pass-2, amendment, correction, provisional, bot-gateway-work-distribution, fair-router, bankDailyTxn, withdrawal-only-correction, anti-detect-blind-spot, process-lesson, dead-code-lesson, phase-2-opportunity]
created: 2026-04-24
source: docs/adr.md@9fe73c8 + withdrawal-side write-path verification (MarkSuccess + syncBankTransactionCounts) + deposit-side read (SelectBankForDeposit) + dead-code grep (countTodayCompletedTransactions + SelectBankForPayout) @ mobiz 19e0bed (2026-04-24 GMT+7)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 ADR-8 pass-2 amendment — **correction pack** (withdrawal-only metric + dead-c

W1 ADR-8 pass-2 amendment — **correction pack** (withdrawal-only metric + dead-code drift findings).

## Supersedes

`learning_2026-04-24_w1-adr-8-pass-2-pre-ratification-amendment-fair` — the prior amendment learning that added Trigger B + early-bail + sweep reframe. That content is preserved; this learning layers a correction on top: the amendment text inherited pass-2's earlier "cross-direction counting" mischaracterization, which was re-verified today as wrong.

## What this correction layer adds

### Factual correction — `bankDailyTxn` is withdrawal-only

Original pass-2 + amendment both claimed `bankDailyTxn` counts cross-direction (deposit + withdrawal). Re-verified on 2026-04-24 GMT+7:

- `bank.DailyTransactions` (the persistent field that feeds `base`) is written by:
  - `services.MarkSuccess` (`services/withdrawalQueue.go:841`) — `$inc daily_transactions: 1` on withdrawal success. Outgoing-only.
  - `controllers.syncBankTransactionCounts` (`controllers/BotConfigController.go:706-712`) — `$max with outCount = CountDocuments(bank_statements direction='out')`. Outgoing-only.
- `OutstandingCountForBank` — counts `withdrawal_queue` pending+processing. Withdrawal-only.
- In-tick `++` — tracks this round's withdrawal assignments. Withdrawal-only.

Deposit has **separate** counter (`deposit_count`) written by `SelectBankForDeposit` + `syncBankTransactionCounts.inCount`. No cross-visibility between the two rotations.

### ADR-8 §Decision step 2 corrected

Text changed from "Cross-direction counting preserved (deposit + withdrawal)" to "Withdrawal-side only — matches current-system parity. Deposits rotate independently on separate `deposit_count`. Two independent LRU counters with no cross-visibility → latent anti-detect blind spot. Next-system can choose verbatim port (withdrawal-only) or unified metric (deposit + withdrawal) as Phase-2 policy decision."

Commit `9fe73c8`.

### Dead-code drift findings (same pass)

Two findings filed separately:
- `learning_2026-04-24_correction-to-findbestbankforitem-prior-art-ban` — supersedes the original prior-art learning; captures the correction + process lesson.
- `learning_2026-04-24_drift-selectbankforpayout-is-dead-code-sort` — `SelectBankForPayout` is dead code with sort-metric drift. Pair dead-code finding with `countTodayCompletedTransactions` (also dead).

Both suggest this area had an architectural refactor that didn't clean up orphans — worth a pg-writer archaeology pass.

### Companion correct-side learning

- `learning_2026-04-24_current-system-prior-art-deposit-routing-via-se` — deposit routing full body (`SelectBankForDeposit` atomic pick+increment pattern at API time, lines 40-306 of `services/bankRotation.go`). Paired with the withdrawal correction to give the full two-direction picture.

## Process lesson (durable)

**Citing a function's comment or body as evidence for its behavior without grep-verifying call-sites is a class-of-bug.** Dead code is worse than missing code: missing code is obvious; dead code looks alive but lies.

Rule for future architect Input 5 reads:
1. Identify function claiming the behavior.
2. `grep -rn <function_name> --include="*.go" | grep -v _test.go` for production callers.
3. If zero callers → flag dead code; do NOT use as evidence.
4. If callers exist → trace to confirm behavior reaches production.

Pass-2 would have ratified on this wrong claim without thread #46 user review. `#provisional` + thread-first discipline caught it pre-ratification — same pattern as the earlier pull-first → fair-router reframe.

## Thread #46 action

Correction message pending (to be posted same session). Content: explains the metric axis narrowing, flags the Phase-2 unified-metric opportunity, confirms core Option F decision unchanged.

## Core Option F decision unchanged

None of this correction changes the primary architectural decision. Fair-router EF + Mode-2 broadcast + claim RPC still chosen default. What narrows is the specific fairness metric axis: instead of "unified cross-direction," it's "withdrawal-only with explicit Phase-2 unified opportunity." Latency profile, trigger model (A + B), sweep role (belt-and-suspenders), and defense-in-depth unchanged.

## Commit chain (pass 2 + amendment + correction)

- `36628c3` — pass-2 reframe body (fair-router adopted)
- `2518e72` — pass-2 backfill
- `b87fc1a` — amendment (Trigger B + sweep reframe)
- `665d209` — amendment backfill
- `9fe73c8` — correction (withdrawal-only metric + Phase-2 opportunity)

Branch `claude/relaxed-brown-12cebb`, PR [#2](https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/2), open, not merged.

## Same-day learning ecology

This pass spans:
- 3 `arra_learn` entries for the correction (deposit routing, findBestBank correction, dead-code drift)
- 2 `arra_supersede` applications (findBestBank original → corrected; amendment → this corrected amendment)
- 1 commit to ADR-8 for the §Decision step 2 text fix
- 1 commit already committed for the amendment body (b87fc1a + 665d209 backfill)
- 1 thread message still to post

Full P-001 chain preserves everything: pass-1 pull-first → pass-2 reframe → pass-2 amendment → pass-2 correction (this).

---
*Added via Oracle Learn*
