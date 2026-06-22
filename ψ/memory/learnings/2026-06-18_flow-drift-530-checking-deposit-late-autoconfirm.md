---
title: flow-drift — #530 finalizeCheckingDeposit auto-confirms checking deposits (deposit-auto-match-from-statement Class C)
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - flow-track
  - flow-drift
  - drift
  - deposit
  - flow:deposit-auto-match-from-statement
created: 2026-06-18
source: services/transactionMatcher.go:359,465,950@e1964b8 + docs/flows/deposit-auto-match-from-statement.md
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 Class-C flow drift — late-statement auto-confirm of `checking` deposits

Flow `deposit-auto-match-from-statement` §Error paths (line 86) claims: *"Deposit is in `status="checking"` (admin-review state after slip upload). Filter at `:148` (`status: "pending"`) excludes it. Statement left `unmatched`; admin resolves via the slip-approval flow."*

`e1964b8` #530 (2026-06-12, "Auto-confirm checking deposits when a matching statement arrives late") **contradicts this**: new `linkCheckingDeposit` (`services/transactionMatcher.go:359`, called from the in-direction switch at `:132`) → `finalizeCheckingDeposit` (`:950`, called at `:465`) auto-confirms a `checking`-status deposit to `paid` when a late statement matches, on a **single** candidate (`len(pool)==1`), CAS-guarded on `status="checking"` AND `is_matched!=true` AND no `slip_duplicate_of` (#528) AND `slip_dest_status!="mismatch"` (#529). So `checking` deposits are no longer always left for admin resolution.

W9 action this pass: marked `[DRIFT]` in §Implementation pointers (new bullet before Step 9). Pointer-section flag only — §Error-paths + §Sequence rewrite deferred to the owed coordinated W8 revision. Class C. Also tightens the DRIFT-15 happy-path slip-fraud gap (matched late statements now auto-confirm before Thunder). flows-baseline held at `9aebabb`.

This drift was first surfaced (unlanded) by W9 trace `38558e51` (`9aebabb..03d6383`, 2026-06-17) whose branch was never pushed; this pass lands the marker on main. Cross-repo: #530 also extends bank-bot `docs/flows/deposit-auto-match-from-statement.md:105` pending→paid contract to `checking` — `#cross-repo-sync` learning + bot-writer handoff were filed by the W2 pass.
