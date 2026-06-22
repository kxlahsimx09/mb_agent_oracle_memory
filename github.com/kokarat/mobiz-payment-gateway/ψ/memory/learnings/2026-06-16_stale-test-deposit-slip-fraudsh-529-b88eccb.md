---
title: STALE — test-deposit-slip-fraud.sh — #529 b88eccb rewrote the slip receiver-mism
tags: [tester, repo:mobiz-payment-gateway, current, stale-test, drift, deposit, slip-fraud, w1]
created: 2026-06-16
source: integration-tests/test-deposit-slip-fraud.sh:L409-L474 + controllers/DepositController.go:L884-L920@b88eccb (#529)
project: github.com/kokarat/mobiz-payment-gateway
---

# STALE — test-deposit-slip-fraud.sh — #529 b88eccb rewrote the slip receiver-mism

STALE — test-deposit-slip-fraud.sh — #529 b88eccb rewrote the slip receiver-mismatch guard contract (Gate B)

What's wrong: W1 pass ae09c34..03d6383 (HEAD). PR #529 `b88eccb` ("Persist + reliably warn when a slip's destination is external") rewrote the receiver-mismatch guard in controllers/DepositController.go::UpdateDepositStatus (the admin approve→paid path). test-deposit-slip-fraud.sh Gate B (Phase 2 "no override" + Phase 3 "[force-approve]") hard-asserts (TEST_RESULT=1) the OLD contract on three points that all changed: (1) response payload keys `data.slip_receiver_last4` (want "9999") + `data.deposit_promptpay_last4` at L416-424 — #529 replaced these with a single `data.slip_destination`; (2) backend log "[Deposit] FRAUD BLOCK: slip receiver mismatch on <req>" at L426 — #529 changed it to "...slip receiver %q matches no destination of %s..."; (3) log "[Deposit] FRAUD OVERRIDE: receiver mismatch ignored on <req>" at L468 — changed to "...external-destination ignored on %s...". Additionally the new EvaluateSlipDestination matches the slip receiver against BOTH the deposit PromptPay AND the system bank account number; the test injects receiver 9999999999 which equals the default BANK_ACCOUNT (9999999999), so the guard may now resolve "ok" (match) and return 200 instead of 400, failing the L409 HTTP-400 assertion too. Direct runtime fail — this test seeds slip_verify_result via mongosh and calls the approve endpoint directly, no CDN/storage dependency to mask it.

Why this is wrong: it is a test↔code contract drift (AGENTS.md §8 test↔code; P-004 code-is-truth). #529 is an intentional product improvement (more robust receiver matching, persisted slip_dest_status flag, clearer SLIP_DEST_EXTERNAL error code), NOT a regression — so this is #stale-test, not #regression-candidate. The test asserts the pre-#529 payload/log contract.

Minimal fix (proposed, not applied — needs user sign-off, tester does not patch tests in W1): update Gate B assertions to the new contract — read `data.slip_destination` instead of slip_receiver_last4/deposit_promptpay_last4; grep logs for "matches no destination of" (block) and "external-destination ignored on" (override); and inject a slip receiver that mismatches BOTH the deposit PromptPay AND the system bank account (e.g. an external account, not 9999999999) so EvaluateSlipDestination returns SlipDestMismatch and the 400 fires.

Impact if unfixed: the slip-fraud V2 (external-destination) regression tripwire fails a real regression run and stops protecting the deposit-approval external-destination money-safety gate.

Related: matrix row carried VALID since 2026-05-02 (added by tester agent, runtime-verified). Prior baseline ae09c34 (merged PR #517).

---
*Added via Oracle Learn*
