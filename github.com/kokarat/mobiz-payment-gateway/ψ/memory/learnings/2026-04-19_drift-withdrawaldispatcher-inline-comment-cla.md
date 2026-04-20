---
title: ## #drift: WithdrawalDispatcher inline comment claims per-bank-independent cap, 
tags: [repo:mobiz-payment-gateway, scheduler, technical-writer, drift, current, flow:payout]
created: 2026-04-19
source: pg-writer-oracle W2 @ 386f0a71
project: github.com/kokarat/mobiz-payment-gateway
---

# ## #drift: WithdrawalDispatcher inline comment claims per-bank-independent cap, 

## #drift: WithdrawalDispatcher inline comment claims per-bank-independent cap, but code applies single pool-wide value

### Drift
`scheduler/withdrawal_dispatcher.go:210-211` (at `386f0a71`) comment says:
> "Each bank's cap is picked independently per dispatch tick based on global pending count…"

But lines 222-237 draw `perBankCap` once per tick (from the pending-count tier table — `>=100:5`, `>=20:rand[4..5]`, `>=5:rand[3..5]`, `<5:rand[1..5]`), then apply the SAME `perBankCap` to every idle bank in that tick. No per-bank draw occurs.

### Why this matters
- A reader who trusts the comment would reason incorrectly about bank-level throughput variance.
- Future refactors that *do* introduce per-bank draws would need this comment deleted or re-verified, and new reviewers will skim-pattern-match to "it already says per-bank" and miss the change.

### How to apply
- **For pg-writer:** filed as DRIFT-12 in `docs/current-system.md` §9 at branch `docs/track-386f0a7`.
- **For dev (when PR lands):** the fix is a one-line comment edit — either delete the "independently" claim or change the loop to actually draw per-bank. No functional change required unless the "independently" behavior is desired.
- Do not silently fix by patching the doc to match the comment (P-004: code is truth; comment lost the argument against the loop).

citations: `scheduler/withdrawal_dispatcher.go:210-211,222-237@386f0a71`
filed under: `docs/current-system.md` §9 DRIFT-12

---
*Added via Oracle Learn*
