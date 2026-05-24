# Handoff → pg-writer (mobiz technical-writer): KTB balance arg-swap reaches the /bot balance contract

**From:** bot-writer-oracle, W9 pass 2026-05-22 (range b74e745..6231444, trace 5bbd659d-41b9-4772-830e-fb1e54cde228).
**Priority:** P2 (doc-accuracy; no code action).
**Fire-and-forget** — bot W9 did not wait on this.

## What changed
bank-bot PR #110 / commit `20289a3` (2026-04-30) swapped the `api.updateBalance` argument order **inside `processSingleTransfer`** (app.js HEAD lines 1564 + 1780) — i.e. the **KTB single-transfer** balance-push path, not only SCB. New mapping for KTB (same as SCB):
- backend `balance` ← `summary.availableBalance` (cash-available, "ยอดเงินสดที่ใช้ได้")
- backend `available_balance` ← `summary.accountBalance` (account-total, "ยอดเงินในบัญชี")

## Why this is a handoff, not a defer
The prior bot W9 (2026-05-01) cross-repo-sync learning + the scb-dual-control change log asserted **"KTB unchanged"**. That is wrong — the swap is in the shared `processSingleTransfer` function, so KTB's reported fields swapped too. Mobiz's dispatcher `bank.AvailableBalance` headroom check now resolves to KTB's **account total** (less conservative), same direction as SCB. Mobiz will NOT fire a W2 for this (no mobiz code changed), so the mobiz sibling doc won't self-correct.

## Action requested (pg-writer)
Verify/annotate `mobiz/docs/flows/payout-request.md` (the `system_banks.balance` / `available_balance` field-semantics notes — prior pass cited lines 26, 62, 91): the swapped semantics now apply to **KTB as well as SCB**. Update any "SCB-only" / "KTB unchanged" qualifier.

## References
- bot learning: `learning_2026-05-22_flow-ktb-single-transfer-withdrawal-step-0a-st`
- bot doc: `docs/flows/ktb-single-transfer-withdrawal.md` Step 0a `[DRIFT-ktb-balance-arg-swap]` + Step 10 (bank-bot @6231444)
- prior SCB cross-repo learning being corrected: `learning_2026-05-01_cross-repo-sync-bot-mobiz-bank-bot-pr-110`
- bot W9 trace: 5bbd659d-41b9-4772-830e-fb1e54cde228