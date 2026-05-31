---
title: ## Two architect-draft corrections caught at user review (next-system PR #284, c
tags: [adr, naming-canonicalization, direct-transfer, wallet-freeze, settlement-confirm-review, step-up, architect-discipline, campaign-archamd1]
created: 2026-05-31
source: campaign-archamd1 user-review of PR #284 (2026-05-31, next-repo kxlahsimx09/mb-next-payment-gateway)
project: github.com/kokarat/mobiz-payment-gateway
---

# ## Two architect-draft corrections caught at user review (next-system PR #284, c

## Two architect-draft corrections caught at user review (next-system PR #284, campaign archamd1, 2026-05-31)

Context: drafting NEXT-system ADR amendments (repo kxlahsimx09/mb-next-payment-gateway) from a mobiz-current-source gap-sweep. Two recurring error classes were caught by the user. Both are easy to repeat — guard proactively.

### Correction 1 — Holding-state naming: next-system is `review`, NOT `waiting_to_review`
The mobiz current-system holding state `waiting_to_review` was **renamed to `review`** in the next-system by **§ADR-4a §Amendment 2026-05-16 (thread #123)** — "Payout Holding-State Rename `waiting_to_review` → `review`; lifecycle RPC `mark_waiting_to_review` → `mark_review`". The **deposit lane also uses `review`** per §ADR-4b §FA2.
- **Rule:** when importing a holding-state name from mobiz source into a NEXT-system ADR decision, use **`review`**, not the old mobiz `waiting_to_review`.
- **Keep current-system citations intact:** mobiz code references — `MarkWaitingToReview` (the service writer), settlement int-`3`, route `PUT /bot/queue/:id/waiting-to-review`, dpay `status` string `waiting_to_review` — stay as CURRENT-SOURCE citations. Only the next-system state name flips. Distinguish "what prod does (waiting_to_review)" from "what next-system decides (review)".

### Correction 2 — A plain admin Direct-Transfer touches NO wallet and has NO freeze
A plain admin Direct-Transfer (DT) is **bank-to-bank operator money**. It does **NOT** freeze at create, does **NOT** touch a wallet, and an admin status override is therefore a **pure status reconciliation** (`review` → {`completed`, `failed`}) — NOT a freeze settle/release.
- **Sources of truth:** `epic-source-flows.md:329` *"no freeze/settle step like payout or settlement"*; README *"never touches a wallet"*; mobiz `DirectTransferController.UpdateDirectTransferStatus` does **no wallet mutation**.
- **Do NOT** couple §ADR-10 freeze-settle/release, `wallet_change_logs`, or "orphaned-freeze" framing to a plain DT override. The terminal status is the whole action.
- **Contrast with settlement/payout:** those DO freeze (§ADR-12 M1 / §ADR-10 AM2), so the confirm-review (CR) amendment's freeze semantics are correct. The error was generalizing "withdrawal-side freeze-at-create" to DT, which is the exception.
- **The one wallet-touching DT exception:** the deposit-refund DT subtype **DTR-002** DOES touch a wallet, but it is **Phase-2-deferred** (DEPOSIT-011 / §ADR-4d) and out of scope — never fold its wallet semantics into a plain DT override.
- **Step-up nuance (left open for user):** §ADR-2 step-up (AUTH-007/S2) is scoped to admin MONEY-OUT. A record-only status reconciliation moves no wallet money — but the underlying bank transfer moved operator funds and the override sets its recorded terminal outcome. This is a genuine judgment call (a: step-up applies / b: does not) — **flag it for the user rather than self-binding**, per charter §9.

### Meta-lesson
Before asserting a money primitive (freeze/settle/release/wallet) on a flow, **verify the flow actually has that primitive** in source + epic-source-flows + README. "Admin money-out action" ≠ "wallet/freeze movement". And when porting a state name, check the ADR rename history (thread #123 here) — current-source names may have been canonicalized in the next-system.

---
*Added via Oracle Learn*
