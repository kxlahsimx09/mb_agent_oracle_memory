---
title: orchestrator dispatch — #166 payout deadlock: user-intuition concern → investiga
tags: [orchestrator, decision-authority, fan-out, accepted, deadlock, lock-ordering, next-impl, next-architect, next-writer, thread-166, user-intuition]
created: 2026-05-18
source: parent thread #166 — payout deadlock campaign, msgs 499-510
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator dispatch — #166 payout deadlock: user-intuition concern → investiga

orchestrator dispatch — #166 payout deadlock: user-intuition concern → investigate → 3-layer fan-out fix 2026-05-18

Request: the user raised a concurrency concern from intuition — could the PAYOUT-005 (admin manual-cancel) and PAYOUT-008 (auto-cancel sweep) cancel paths deadlock against the bank-bot claim, given the user's belief that "the bot locks the queue first."
Classification: single-thread campaign #166 — investigate (report-only) → then a 3-agent fan-out fix on the same thread.
Confidence: HIGH — user instructed directly each step.
Outcome: next-impl confirmed a genuine lock-order-inversion deadlock (bot claim locks withdrawal_queue→ts_payouts; cancel_stale_payout locks ts_payouts→wallet→withdrawal_queue — opposite order on the same rows → 40P01). Latent (auto-cancel not yet in the integrated substrate). Fixed across 3 layers: §ADR-4a §Amendment 2026-05-18 pinning canonical order withdrawal_queue→ts_payouts→wallet (PR #154), cancel_stale_payout reorder + lock-order-faithful concurrency test (PR #155), PAYOUT-005 AC#2/#3 doc update (PR #156).
User reaction: accepted.

Decision-authority + process lessons:
1. A user's domain intuition ("the bot locks the queue first") was the exact root cause. When a user raises a concern from intuition, dispatch a report-only investigation to verify it rather than dismissing or assuming — next-impl confirmed the intuition was precisely right.
2. Mid-flight scope correction: the user first said PAYOUT-004, then corrected to PAYOUT-005. Handled by posting a visible correction message to the thread + a follow-up correction envelope (no silent retcon) — the agent re-scoped cleanly.
3. Dependency-ordered fan-out: code fix (next-impl) and ADR amendment (next-architect) ran in parallel because the lock order was already determined; the requirement-doc update (next-writer) was held downstream until the §ADR-4a amendment was a committed PR, so the doc follows ratified ground (P-004). All three on one thread (thread-discipline: one campaign, not three threads).
4. Uncommitted-deliverable catch: next-architect first delivered the ADR amendment UNCOMMITTED in its working tree ("flagged for the merge step"). The orchestrator caught it and required a proper committed fork PR — an uncommitted working-tree change is not a durable/reviewable/mergeable deliverable. Every deliverable must be a committed PR per §9.
5. False-assurance test gap: existing PoC race tests passed but exercised a non-faithful claim stand-in (locked rows in the safe order) — they could never have caught the inversion. The fix included building a lock-order-faithful claim RPC for the regression test, teeth-verified (reverting the fix reproduces the deadlock).

---
*Added via Oracle Learn*
