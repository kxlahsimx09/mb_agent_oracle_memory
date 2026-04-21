---
title: 
tags: [technical-writer, repo:bank-bot, current, followup, ruled-drift, bank-bot, withdrawal-queue, single-transfer, ktb, waiting-to-review-lost, invariant-upheld, for-bot-writer-closed]
created: 2026-04-21
source: commit 3359d08 (2026-04-20 01:49 +0700) + verification pass at origin/main HEAD ccd04cf, 2026-04-21 + original drift 2026-04-18_drift-bank-bot-waitingtoreview-lost-in-singl
project: github.com/kokarat/bank-bot
---

# 


# ruled-drift — bank-bot waiting_to_review lost in single-transfer (resolved at 3359d08, 2026-04-20)

Drift original (`2026-04-18_drift-bank-bot-waitingtoreview-lost-in-singl`) is resolved. The single-transfer app-layer dispatcher at `app.js` now forwards `waiting_to_review` from the bank layer to `safeMarkWaitingToReview`, no longer collapsing it to `failed`.

**Fix commit:** `3359d08` — "fix: KTB mark waiting_to_review after submit, not failed" (kokarat/bank-bot, 2026-04-20 01:49 +0700 GMT).

**Verified at HEAD (origin/main, `ccd04cf`, 2026-04-21):**

- `app.js:1640-1651` (batch branch) — three-way switch now includes:
  ```js
  } else if (r.status === 'waiting_to_review') {
    await safeMarkWaitingToReview(r.id, r.error || 'Transfer needs review', batchResultScreenshot);
    log.warn(`[Transfer] Waiting to review: ${r.id}`, { error: r.error });
  } else {
    await safeMarkFailed(r.id, r.error || 'Transfer failed', batchResultScreenshot);
  }
  ```
- `app.js:1710-1720` (single-item branch) — same three-way switch with `safeMarkWaitingToReview(itemId, result.error || 'Transfer needs review')`.
- `banks/ktb/transfer.js:161-169` — bank layer still produces `waiting_to_review` for post-submit ambiguity, and the guard is now broader than the drift originally described:
  ```js
  const isPostSubmit = submitted || e?.code === 'KTB_POST_OTP';
  const statusForPending = isPostSubmit ? 'waiting_to_review' : 'failed';
  ```
  The original drift only covered `e?.code === 'KTB_POST_OTP'`; the fix expanded the condition to any post-submit error via the `submitted` flag — strictly more conservative, strictly within the invariant.

**Invariant upheld:** payout-state-semantic-invariant (cross-repo, ratified via Oracle thread #22, 2026-04-19). Bank-layer uncertainty is no longer silently collapsed to `failed` at the app-layer. Sibling gateway fix is PR kokarat/mobiz-payment-gateway#249 (merged 2026-04-20), which closed the gateway-side Path 2 stale-sweep mislabel. With both siblings resolved, the two automated invariant-violation paths in the landscape described by the original drift are closed.

**Remaining adjacent (not this drift — filed as a note, not a new drift yet):** catch-block at `app.js:1721-1725` still calls `safeMarkFailed` when `transferFlow` throws through both bank-layer try/catch and app-layer handling. Likelihood is low because the bank layer's try/catch at `transfer.js:161-168` already maps post-submit exceptions to a returned result object; only truly unexpected exceptions (e.g. Playwright crash inside the bank layer that bypasses its catch) reach this outer catch. If production telemetry shows this path firing on real post-submit flows, a separate drift should be filed to extend the `waiting_to_review` treatment to the outer catch too.

**How to apply (for future changes to this code path):** any new app-layer dispatcher that consumes bank-layer transfer results MUST handle `waiting_to_review` explicitly before falling through to `safeMarkFailed`. The dual-control maker/approver flows (`app.js:462,492,953`) already do this; the single-transfer branches now do too. Treat the three-way switch pattern (success / waiting_to_review / failed) as the canonical shape for any bank-layer result consumer.

**Closure note:** no Oracle thread was opened for this drift. Closure is based on code evidence at origin/main HEAD `ccd04cf` (2026-04-21) plus the originating commit `3359d08`. If a future regression reopens the drift, file a new drift learning rather than reviving this one (P-001).


---
*Added via Oracle Learn*
