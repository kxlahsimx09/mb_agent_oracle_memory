---
title: PROMOTED STALE→VALID — test-deposit-slip-fraud.sh — #559 7feb7d1 realigned Gate 
tags: [tester, repo:mobiz-payment-gateway, current, stale-test-resolved, promotion, deposit, slip-fraud, w1, w1-amend]
created: 2026-06-19
source: integration-tests/test-deposit-slip-fraud.sh@7feb7d1 + controllers/DepositController.go:896-918@68f30db + services/slipFraudCheck.go::EvaluateSlipDestination@68f30db + docs/test-index.md (PR #539 amend, ae09c34..68f30db)
project: github.com/kokarat/mobiz-payment-gateway
---

# PROMOTED STALE→VALID — test-deposit-slip-fraud.sh — #559 7feb7d1 realigned Gate 

PROMOTED STALE→VALID — test-deposit-slip-fraud.sh — #559 7feb7d1 realigned Gate B asserts to the #529/#532 external-destination contract.

What changed: PR #559 (7feb7d1, merged 68f30db) updated three drifted Gate B assertions in integration-tests/test-deposit-slip-fraud.sh to the post-#529/#532 (b88eccb) UpdateDepositStatus contract: Phase 2 payload now reads top-level code=SLIP_DEST_EXTERNAL + data.slip_destination (was slip_receiver_last4/deposit_promptpay_last4); Phase 2 log "FRAUD BLOCK: slip receiver … matches no destination of"; Phase 3 log "FRAUD OVERRIDE: external-destination ignored on".

Why VALID now (static-verified, read-before-run — not trusted from the commit message): controllers/DepositController.go:896-918 returns exactly code:"SLIP_DEST_EXTERNAL" (L908) + data.slip_destination (L911) + override_hint (L912) with HTTP 400 (L906), and logs FRAUD BLOCK (L904) / FRAUD OVERRIDE (L916) with the new wording. The prior STALE row's point-(d) concern — injected receiver 9999999999 == default BANK_ACCOUNT (setup-infra.sh:35) might resolve ok→200 — does NOT bite: services/slipFraudCheck.go::EvaluateSlipDestination only runs the system-bank-account substring compare when the slip carries a receiver.account.bank.account (bankAcc != ""). Phase 2 injects ONLY receiver.account.proxy.account=9999999999, so ExtractSlipReceiverBankAccount returns "" → that branch is skipped; the proxy is compared solely to the deposit promptpay last-4 via VerifySlipReceiverMatchesDeposit (9999 ≠ 1234 → mismatch) → SlipDestMismatch → 400 regardless of BANK_ACCOUNT.

Matrix delta on PR #539: 42V/3S → 43V/2S. Status promotions since prior baseline: 0 → 1. Cumulative range bumped ae09c34..c777dab → ae09c34..68f30db. The other increment commits (#555 d53c129 k8s mem, #556 84b515f main.go startup log, #557 40a282e k8s secrets) are NEUTRAL/out-of-surface.

Lesson: a tester point-(d) "may resolve ok→200" hypothesis on a STALE proposed-fix was over-cautious. The EvaluateSlipDestination system-bank-account compare is gated on bankAcc!="" and proxy-only slips never reach it. Future STALE proposed-fixes on slip-fraud should NOT insist on changing the injected proxy receiver away from 9999999999 — keeping it is correct.

Related: supersedes the 2026-06-16 STALE learning for this test (2026-06-16_stale-test-deposit-slip-fraudsh-529-b88eccb).

---
*Added via Oracle Learn*
