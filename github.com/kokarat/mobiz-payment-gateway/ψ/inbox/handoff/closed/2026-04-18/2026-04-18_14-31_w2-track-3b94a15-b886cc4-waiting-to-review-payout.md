# Handoff — W2 track-commit pass `3b94a15..b886cc4`

**From:** `pg-writer-oracle` (`technical_writer`, mobiz-payment-gateway)
**When:** 2026-04-18 14:29 GMT+7
**PR:** https://github.com/kokarat/mobiz-payment-gateway/pull/214 (awaiting review; do not merge)

## What I did

Workflow 2 pass covering 5 feature commits on the `waiting_to_review` payout flow:
- `#211 / 7526257` — UpdatePayoutStatus admin identity + refund-filter widen
- `#212 / b7e8165` — ConfirmPayoutCompleted outer guard accepts waiting_to_review
- `dfafa78 / #213` — MarkSuccess mirrors bank_transaction_id onto ts_payouts
- `550dc8d` — inner atomic filter patch for #212
- `f44cf44` — CRITICAL conditional wallet deduction (fixes double-deduction)

Updated `docs/current-system.md` §§2, 3.2, 3.2.1, 3.4, 6.1. Bumped `docs/.baseline` to `b886cc4`.

W2 trace: `a458999c-5aec-4a81-ad99-3650141e40f0`. Linked prev → `91e33743-...` (prior mobiz W2).

## What's blocked / deferred

1. **Cross-repo trace link failed.** `arra_trace_link` supports only one `prev` per trace. Intra-repo link consumed it; bank-bot W1 `6e1602b6-...` is recorded semantically in the `#cross-repo-sync` learning instead. Workflow `workflow-2-track-commit.md §Step 2c` should be updated to acknowledge this — either the Oracle tool adds a multi-prev shape, or the workflow tells writers "intra-repo wins, cross-repo goes in a `#cross-repo-sync` learning." Not mine to patch this session.
2. **`f44cf44` + `550dc8d` bypassed the branch-then-PR flow.** Both commits landed directly on main. `AGENTS.md §9` forbids this. Named in the retro; worth an `arra_thread` or human conversation to confirm whether this was a one-time emergency (double-deduction was actively losing money) or a norm shift. Not mine to adjudicate.
3. **Merchant-facing callback contract for `waiting_to_review` is undocumented.** Both bot-side and admin-side code is explicit that no callback fires while a payout is in that state, but public-facing callback docs don't mention the gap. Out of my territory (public docs are `requirement-writer`'s when that agent exists). Filing as the "next unanswered question" for this session — if a human wants to short-circuit, the answer likely goes in a merchant-facing changelog or the Swagger for the callback events enum.
4. **Thread #6 (`[RATIFICATION_PENDING]` in `docs/flows/deposit-slip-upload-admin-approve.md`) is 1+ day old and still `pending`.** Not blocking this pass, but if it's still pending by 2026-04-24, the W8 flow-map doc's authority drops. Consider an `arra_inbox` nudge to the human.

## What the next `pg-writer-oracle` session should do

- If new commits hit `controllers/PayoutController.go` or `services/withdrawalQueue.go`, run Workflow 2 from `b886cc4`.
- If `#213`'s pattern (mirror queue field onto source doc) is extended to settlement / direct_transfer, §6.1 and the `#bank-transaction-id-mirror` learning need a follow-up.
- Watch for any commit to merchant-facing callback docs (file does not yet exist as of this baseline) — that would close the unanswered question above.

## Cross-repo sibling reference

bank-bot W1 trace `6e1602b6-de06-494b-a526-fec6230a77d5` (commit `0789b4b`, PR #60) covers the bot side of `markWaitingToReview`. The `#cross-repo-sync` learning `2026-04-18_cross-repo-sync-waiting-to-review-payout-bank-bot.md` names both traces and the shared contract shape.

## Learnings filed

- `2026-04-18_payout-confirm-completed-accepts-waiting-to-review-with-conditional-deduction.md`
- `2026-04-18_payout-update-status-admin-identity-tracking.md`
- `2026-04-18_bank-transaction-id-mirror-on-marksuccess-payout.md`
- `2026-04-18_cross-repo-sync-waiting-to-review-payout-bank-bot.md`
