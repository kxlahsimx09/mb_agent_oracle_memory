---
title: flow-drift — deposit-auto-match-from-statement: #530 auto-confirms checking deposits on late statement
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - drift
  - flow-drift
  - flow-track
  - flow:deposit-auto-match-from-statement
  - deposit
  - cross-repo-sync
created: 2026-06-17
source: docs/flows/deposit-auto-match-from-statement.md ; services/transactionMatcher.go finalizeCheckingDeposit @ e1964b8
related:
  - 2026-06-17_drift-19-slip-fraud-late-autoconfirm
  - 2026-06-17_cross-repo-sync-matcher-late-autoconfirm-bankbot-deposit-flow
project: github.com/kokarat/mobiz-payment-gateway
---

# Flow drift — deposit-auto-match-from-statement (Class C)

W9 pass 2026-06-17 over `9aebabb..03d6383`. Flow `deposit-auto-match-from-statement` touched by `e1964b8` #530. Outcome: **1 Class-C drift** (no A/B refresh — baseline held).

**Drift:** §Error paths claims *"Deposit is in `status="checking"` … Filter at :148 (status: "pending") excludes it. Statement left `unmatched`; admin resolves via the slip-approval flow."* As of #530, a late matching statement now **auto-confirms** a `checking` deposit via new `services/transactionMatcher.go finalizeCheckingDeposit`: `checking → paid` when exactly one `checking` deposit matches account+amount, CAS-guarded (`status="checking"` AND `is_matched!=true` AND no `slip_duplicate_of` #528 AND `slip_dest_status!="mismatch"` #529); multi-candidate stays link-only. The §Error-paths and §Preconditions framing (checking is matcher-excluded) is now stale.

Marked `[DRIFT]` in §Implementation pointers Step 6; pointer held at `@44f8634` per W9 Class C. Queued for W4 / W8 revision (pg-writer marks, does not author the flow body or fix code). Financial-adjacent (credits wallet) — W8 revision should CC `code_reviewer`.

**Cross-repo:** this extends the bank-bot `docs/flows/deposit-auto-match-from-statement.md:105` "pending → paid within seconds" contract to `checking` deposits. `#cross-repo-sync` learning + bot-writer `arra_handoff` already filed in the same-day W2 pass (`2026-06-17_cross-repo-sync-matcher-late-autoconfirm-bankbot-deposit-flow`).

W9 child trace: `47d80309-b7d8-45b3-af70-332241d96007` (parent `38558e51`).
