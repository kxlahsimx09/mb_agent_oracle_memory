---
title: cross-repo-sync — waiting_to_review payout ↔ bank-bot markWaitingToReview contract (mobiz W2 3b94a15..b886cc4 ↔ bank-bot W1 0789b4b)
tags:
  - technical-writer
  - repo:cross
  - current
  - cross-repo-sync
  - waiting-to-review
  - payout
  - withdrawal-queue
  - bank-bot
created: 2026-04-18
source: "conversation + arra_trace_list (mobiz W2 a458999c + bank-bot W1 6e1602b6) + bank-bot vault learning 2026-04-18_drift-candidate-markwaitingtoreview-is-a-new.md"
related:
  - 2026-04-17_waiting-to-review-payout-withdrawal-queue-semantics
  - 2026-04-18_payout-confirm-completed-accepts-waiting-to-review-with-conditional-deduction
project: github.com/kokarat/mobiz-payment-gateway
---

# cross-repo-sync — waiting_to_review payout ↔ bank-bot markWaitingToReview

Two W-passes within the same 24-hour window described the two sides of the same shared contract:

| Repo | Pass | Trace | Scope |
|---|---|---|---|
| `github.com/kokarat/mobiz-payment-gateway` | W2 (this pass) | `a458999c-5aec-4a81-ad99-3650141e40f0` | 3b94a15..b886cc4 (5 commits — #211/#212/#213/550dc8d/f44cf44) — confirm-completed accepts waiting_to_review, UpdatePayoutStatus admin identity, bank_transaction_id mirror |
| `github.com/kokarat/bank-bot` | W1 (baseline) | `6e1602b6-de06-494b-a526-fec6230a77d5` | baseline at 7d4b50e (PR #60 commit 0789b4b) — introduces `markWaitingToReview` as a new bot→backend endpoint |

The bank-bot side documented a drift-candidate learning at `github.com/kokarat/bank-bot/ψ/memory/learnings/2026-04-18_drift-candidate-markwaitingtoreview-is-a-new.md` (tagged `#cross-repo-sync`). This learning is the mobiz-side counterpart: same shared concept, opposite repo scope.

## Shared concept

When a bot is unsure whether a bank transfer succeeded (e.g. SCB approver popup timeout, network drop before the confirmation screen), instead of reporting `success` or `failed` the bot calls `PUT /api/v1/bot/queue/:id/waiting-to-review`. Mobiz-side behaviour (owned by this repo's `technical_writer`):

- WithdrawalQueue item: `processing → waiting_to_review` (CAS-guarded).
- Source `ts_payouts` row: `status="waiting_to_review"` mirrored.
- Bank unlocked via `UnlockBankIfDone`.
- **No wallet change, no callback.** Wallet stays debited from payout creation; admin must confirm-completed or move to failed/cancelled.

Bank-bot-side behaviour (owned by `bot-writer-oracle`): the bot's internal detection of the uncertain state and its `markWaitingToReview` RPC — see bank-bot's drift-candidate learning for selector patterns and retry shape.

## Trace chain link constraint (noted in retro)

`arra_trace_link` supports only a **single `prev` pointer per trace** — a linked-list chain, not a DAG. In Step 2b of W2 I already linked mobiz W2 `a458999c` to its prior intra-repo W2 `91e33743` (the horizontal evolution chain). That consumed the single prev slot. The cross-repo sibling trace `6e1602b6` (bank-bot W1) is therefore recorded **here**, in this `#cross-repo-sync` learning, as the semantic (non-navigable) sibling reference. Future writers following the intra-repo chain will find this learning via `arra_search query="waiting_to_review"` and pivot to the bank-bot trace through the explicit trace_id above.

This is a known limitation of `arra_trace_link`; see `workflow-2-track-commit.md §Step 2c Caveat`.

## Commit deltas on each side (for future reconstruction)

**mobiz (this pass):**

- `7526257` — UpdatePayoutStatus admin identity fields + waiting_to_review in refund atomic filter (#211).
- `b7e8165` — ConfirmPayoutCompleted outer guard accepts waiting_to_review (#212).
- `dfafa78` — MarkSuccess mirrors bank_transaction_id onto ts_payouts (#213).
- `550dc8d` — ConfirmPayoutCompleted inner atomic filter accepts waiting_to_review.
- `f44cf44` — CRITICAL conditional wallet deduction in ConfirmPayoutCompleted (fixes double-deduction for waiting_to_review).

**bank-bot (prior W1):**

- PR #60 commit `0789b4b` — introduces `markWaitingToReview` bot→backend call. Bot treats it as a new terminal state for its own queue polling loop. Full delta in bank-bot's W1 baseline.

## Next cross-repo sync triggers

- If bank-bot lands a PR that changes the request shape (e.g. adds `bank_transaction_id_attempted` or `screenshot_url_hash`), mobiz-side §3.4 bullet for `/queue/:id/waiting-to-review` needs a fresh citation bump.
- If mobiz adds a retry-from-waiting-to-review path (admin button "send again"), bank-bot needs to handle receiving a re-claim for an item it already marked waiting-to-review.
- Merchant-facing callback contract for `waiting_to_review` is **still not documented** on either side — the mobiz side explicitly states "no callback" but the merchant docs haven't been updated to reflect that. This is a follow-up for `requirement-writer` / public docs, not this pass.
