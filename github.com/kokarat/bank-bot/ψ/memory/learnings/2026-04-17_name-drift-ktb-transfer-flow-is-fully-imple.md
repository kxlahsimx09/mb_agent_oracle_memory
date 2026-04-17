---
title: drift — KTB transfer flow is fully implemented and batch-capable (not "selectors TBD")
tags: [technical-writer, repo:bank-bot, current, ktb, transfer, drift]
created: 2026-04-17
source: docs/current-system.md §8 DRIFT-11 @ 95dbb70
project: github.com/kokarat/bank-bot
---

# drift — KTB transfer flow is fully implemented and batch-capable (not "selectors TBD")

CLAUDE.md "KTB-Specific Notes" claims "Transfer selectors: Still TBD — need Playwright recording from actual KTB transfer page" and README "Supported Banks" table says "Login, balance, statement ready. Transfer selectors TBD". At commit 95dbb70 the code has 907 lines of banks/ktb/transfer.js implementing a full batch transfer flow, and KTBModule.supportsBatchTransfer() returns true. One of the two claims is ~two-three PRs out of date.

## Evidence at 95dbb70

- `banks/ktb/transfer.js` (907 lines) — contains `batchTransferFlow`, `navigateToTransfer`, `addRecipient`, `selectBankFromDropdown`, `dismissKtbOverlay`, `submitTransfer`, `handleTransferOTP`. Playwright selectors for every step are present and verified against the live portal on 2026-04-15.
- `banks/ktb/index.js:40-42` — `supportsBatchTransfer()` returns `true`.
- `banks/ktb/index.js:139-142` — `batchTransferFlow(page, items, getOTP)` is the public entry; `transferFlow` wraps it with a single-item array (for app.js's single-transfer dispatch path).
- `handleTransferOTP` (transfer.js:720-834) and `fillOTP` (login.js:207-366) share an identical two-phase timing protocol (SMS 60 s → email 180 s) — clear evidence that OTP-and-submit has been exercised on real transfers.

## Why this matters

- README's "Supported Banks" table is the first thing a reader sees when deciding whether to stand up a KTB bot. If the table says "TBD" people will over-estimate remaining work.
- CLAUDE.md drives agent behaviour via the system-prompt injection — downstream agents might skip KTB-transfer work believing it's still recording-phase when the real work is regression-prevention.

## Resolution path

Doc fix: both CLAUDE.md "KTB-Specific Notes" and README "Supported Banks" should reflect that KTB transfer is live and batch-capable. Workflow 4 (reconcile-drift) is the right track.

## How to apply

- When scoping KTB work, treat the code as authoritative (P-004: Code is Truth, Documents are Claims).
- When someone asks about KTB transfer status, point them at `banks/ktb/transfer.js` and `banks/ktb/index.js:supportsBatchTransfer()`.
- Future baselines should watch for new banks repeating the same doc lag — README is an especially common stale surface.

---
*Added via Oracle Learn*
