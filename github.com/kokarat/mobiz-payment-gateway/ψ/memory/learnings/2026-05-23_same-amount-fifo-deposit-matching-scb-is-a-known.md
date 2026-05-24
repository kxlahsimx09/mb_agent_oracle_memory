---
title: same-amount FIFO deposit matching (SCB) is a KNOWN-WONTFIX in mobiz — do NOT re-
tags: [matcher, transactionMatcher, fifo, same-amount, known-wontfix, regression-excluded, current, repo:mobiz-payment-gateway, deposit, money-safety, markForReview, matchByFIFO, do-not-resurface]
created: 2026-05-23
source: Oracle Learn
project: github.com/kokarat/mobiz-payment-gateway
---

# same-amount FIFO deposit matching (SCB) is a KNOWN-WONTFIX in mobiz — do NOT re-

same-amount FIFO deposit matching (SCB) is a KNOWN-WONTFIX in mobiz — do NOT re-surface as a new finding.

## Status: KNOWN-WONTFIX + deliberately de-scoped from regression
- The SCB deposit matcher does NOT FIFO-auto-match multiple same-amount candidates. `matchDepositSCB` (`services/transactionMatcher.go`): when `count > 1` candidates match (same account + amount + last4), it routes to `markForReview` (admin review / pending) — it does NOT call `matchByFIFO`. So 3 identical-amount deposits to one SCB account → 0/3 auto-matched, all parked for review. Distinct amounts match fine (count==1).
- This is DELIBERATE, not a bug. Git history: SCB FIFO was REMOVED for safety — `a4ebd0f` (2026-04-01 "remove unsafe FIFO fallback") + `#200`/`097c707` (2026-04-17 "Remove FIFO linking: skip when multiple candidates match"). Reason: blanket FIFO caused cross-client wrong-credit (same defect class as the 2026-05-20 matchDepositKTB cross-client wrong-credit). Review-on-multi-candidate is the safe choice. (Note: KTB path STILL wires matchByClientScope→matchByFIFO at lines ~193-220; SCB intentionally does not.)
- mobiz (current-system owner) accepts the same-client UX cost and will NOT fix → the user deliberately REMOVED `test-deposit-fifo-single.sh` + `test-deposit-fifo-dual.sh` from `docs/regression-suite.txt` (the curated 28-test suite). Verified: the 2026-05-22 22:56 regression ran 28/28 GREEN (real run, 49m) with ZERO fifo tests in the suite.

## Why agents keep "re-discovering" it
The fifo test FILES still exist in `integration-tests/` and assert PRE-#200 behavior (expect FIFO auto-match). A FULL-DIR run (not the curated regression-suite.txt) — e.g. pg-tester's broad validation 2026-05-23 — executes them and sees fifo fail 0/3. That failure is EXPECTED, not a regression and not a new finding. The same-amount-distinct-amount control (distinct → 3/3) confirms it is purely the same-amount FIFO path.

## Action guidance for future agents
- A fifo-single/dual FAIL in a full-dir run = EXPECTED known-wontfix. Do NOT escalate as a fresh finding.
- The curated regression is `docs/regression-suite.txt` (28 tests, fifo intentionally excluded). Run that for "did we regress", not the whole dir.
- If ever revisited it is a PRODUCT safety-vs-UX decision (owner: human / mobiz; no #current dev role): either (a) accept review-on-multi-candidate as intended → update the fifo tests to expect review; or (b) restore CLIENT-SCOPED FIFO to SCB (guard cross-client to avoid the 2026-05-20 wrong-credit class) → tests pass. Pin with a unit test first either way.

Supersedes the 2026-05-23 "same-amount FIFO matching gap — finding for prioritization" framing (which mis-cast a known-wontfix as a new actionable finding).

---
*Added via Oracle Learn*
