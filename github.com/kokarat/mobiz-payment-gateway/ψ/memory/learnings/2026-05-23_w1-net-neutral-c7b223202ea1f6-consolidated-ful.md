---
title: W1 net-neutral — c7b2232..02ea1f6 consolidated full-sweep — 9 production-surface
tags: [tester, repo:mobiz-payment-gateway, current, w1, no-op, net-neutral, idempotency, matcher, slip-verify, deposit, payout, coverage-gap]
created: 2026-05-23
source: docs/test-index.md (baseline 02ea1f6) + helpers/setup-infra.sh:100 (gen_idem_key) + controllers/DepositRequestController.go@15a54a4 (#392) + integration-tests test-*.sh@34f3a4c (#473) + Oracle thread #220
project: github.com/kokarat/mobiz-payment-gateway
---

# W1 net-neutral — c7b2232..02ea1f6 consolidated full-sweep — 9 production-surface

W1 net-neutral — c7b2232..02ea1f6 consolidated full-sweep — 9 production-surface commits ALL NEUTRAL, zero status flips; idempotency-mandatory (#392) subsumed by in-range test fix (#473).

This pass re-established docs/test-index.md on the merged-main line (last MERGED baseline was PR #445 c7b2232). The intervening PR #456 (which ran amended W1 passes through d181f34) was CLOSED-as-subsumed on 2026-05-23 per Oracle thread #220 (user-confirmed): its 42 "STALE-idempotency" rows were factually false at HEAD.

Root cause of the subsumption (verified at HEAD 02ea1f6, P-004): PR #392 (15a54a4) made X-Idempotency-Key MANDATORY on DepositRequestController.CreateDeposit + PayoutRequestController.CreatePayout (routes /api/v1/deposit/create + /api/v1/payout/create, 400 IDEMPOTENCY_KEY_REQUIRED when absent). That WOULD have flipped all 38 create-path tests STALE — but PR #473 (34f3a4c, merge 2be3489) landed in the SAME range and added gen_idem_key() to helpers/setup-infra.sh:100 + injected `-H "X-Idempotency-Key: $(gen_idem_key)"` into every create-path script. Verified: grep -lE "X-Idempotency-Key" integration-tests/test-*.sh => 38 files; test-deposit-flow.sh:186 carries the header right after the create POST. Net zero status flips.

Lesson for future W1: when a production hardening commit (mandatory new header/field on a tested endpoint) and its test-side fix land in the SAME validate range, the pass nets to NEUTRAL — do NOT carry the intermediate STALE finding forward. A single-validator consolidated pass over the whole merged-baseline span avoids the sibling-PR collision that closed #456 (thread #220's own process note).

Other 8 in-range commits each NEUTRAL (no test exercises the surface): #454 deposit-floor (integer-only amounts; bundled botHostLocator irrelevant — tests run their own local bot), #455 announcements API (new surface), #460 defer-Thunder-slip-verify (client UploadSlip path unchanged; slip-fraud test injects slip_verify_result directly), #461 brand-env, #474 idempotency-error-shape, #472 topup-list-filters, #476 payout-account_number-filter, #477 matcher-pending_review-relink-guard (transactionMatcher.go still zero-unit-tested; no test seeds a pending_review-pointed deposit + second statement). #471 ClientRequestLog admin surface NEUTRAL.

Matrix carried forward verbatim: 44 VALID / 1 STALE (test-settlement-cancel.sh) / 0 WRONG-SETUP / 0 FLAKY / 2 SUPERSEDED (test-payout-cancel.sh, test-raw-resp.sh) / 2 ON_HOLD (test-payout-auto-reconcile.sh, test-payout-confirm-completed.sh) / 0 UNKNOWN. Same-amount-FIFO tests stay VALID-with-KNOWN-WONTFIX (excluded from regression-suite.txt per #200).

New coverage-gap rows appended (docs/test-coverage-gaps.md): 🟡 #460 deferred slip-verify + reverify-slip + slip_verify_status state machine (untested); 🟡 #392/#474 mandatory-idempotency contract (only test-deposit-idempotency.sh targets the missing-header 400 and it is DE-TIERED → ~0 CI coverage of the load-bearing contract); 🟡 #477 matcher pending_review re-link guard; 🟢 #472/#476/#471/#455/#454. PR opened on feat/tester-validate-2026-05-24 (do not merge — human review).

---
*Added via Oracle Learn*
