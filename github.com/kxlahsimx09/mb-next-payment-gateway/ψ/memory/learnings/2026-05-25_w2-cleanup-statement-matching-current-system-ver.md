---
title: W2 cleanup — statement-matching current-system verify flags (2026-05-25).
tags: [next-product-writer, w2-cleanup, requirements, statement-matching, adr-4b, dedup, target-account-match, mobiz-code-verify]
created: 2026-05-25
source: W2 cleanup session 2026-05-25, branch cleanup/statement-matching-flags-20260525
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W2 cleanup — statement-matching current-system verify flags (2026-05-25).

W2 cleanup — statement-matching current-system verify flags (2026-05-25).

When a requirement FLAG asks for mobiz current-system code verification, do not escalate to architect first if the ratified ADR already fixes the next-system semantic and the code check only sharpens prose/evidence. Escalate to architect only if code verification contradicts the ADR, exposes ambiguous intent that changes next-system behavior, or requires changing the ratified semantic.

Evidence from this pass:
- G5 date-less statement dedup: mobiz `controllers/BotConfigController.go:761-803` guards the count-based dedup block with `transaction_date_bkk > 0`, so date-less rows bypass current-system dedup and insert. Next-system ADR-4b keeps NULL-safe count-based dedup for uniform behavior; dpay MCP count on 2026-05-25 found 0 production bank_statements rows with missing/null/zero `transaction_date_bkk`, so this is defensive consistency, not volume-driven migration pressure.
- G1 Step-1 `target_account_match`: mobiz `services/transactionMatcher.go:150-225` requires KTB full payer account and applies source-bank filtering when prefix resolves. `:235-337` requires SCB payer last-4, requires source bank code for non-PromptPay transfer rows, and permits PromptPay last4-only when the statement shape does not expose source bank code. There is no broader amount-only fallback.

Applied to `docs/requirements/epic-statement-matching.md` by removing FLAG[G5] and FLAG[G1], replacing them with source-backed bank-specific requirements language.

---
*Added via Oracle Learn*
