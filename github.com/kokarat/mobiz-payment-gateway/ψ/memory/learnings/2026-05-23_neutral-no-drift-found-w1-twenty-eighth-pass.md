---
title: NEUTRAL / no-drift-found — W1 twenty-eighth pass — #474 d181f34 drops `docs_url`
tags: [tester, repo:mobiz-payment-gateway, current, no-drift-found, idempotency, deposit, payout, w1-twenty-eighth]
created: 2026-05-23
source: controllers/DepositRequestController.go + controllers/PayoutRequestController.go @ d181f34 (PR #474) + integration-tests/test-*.sh (49 files, grep docs_url → 0)
project: github.com/kokarat/mobiz-payment-gateway
---

# NEUTRAL / no-drift-found — W1 twenty-eighth pass — #474 d181f34 drops `docs_url`

NEUTRAL / no-drift-found — W1 twenty-eighth pass — #474 d181f34 drops `docs_url` from the IDEMPOTENCY_KEY_REQUIRED 400 body; zero test impact across all 49 tests.

What's neutral: PR #474 (`controllers/DepositRequestController.go` + `controllers/PayoutRequestController.go`, 12 ins / 8 del each) removes the `docs_url` field — which had leaked the internal path `github.com/kokarat/mobiz-payment-gateway/blob/main/docs/...` to API clients (reported by an integration partner) — from the `400 IDEMPOTENCY_KEY_REQUIRED` body that #392 introduced. `error.code` + `error.message` stay.

Why zero test impact: `grep -lE "docs_url" integration-tests/test-*.sh` → 0 hits. The 34 deposit/payout-create tests that #392 already flipped VALID→STALE fail at the missing-header gate (`if c.Get("X-Idempotency-Key") == "" { return 400 }`) BEFORE reading the 400 body, so a body-field removal changes no outcome — they stay STALE for the same #392 reason. `test-deposit-idempotency.sh` (the one VALID idempotency test) sends the header on every create call and never reaches the missing-key 400. Matrix carries forward verbatim: 10 VALID / 35 STALE / 0 WRONG-SETUP / 0 FLAKY / 2 SUPERSEDED / 2 ON_HOLD.

Other commits in delta bf73072..d181f34: #468 `6bfcf3a` (goodpay routing-agent egress Route, `k8s/envs/goodpay/route-egress.yaml`) + #469 `7cd9ea8` (ampay swagger/api-url → api.ampay.win, `k8s/envs/ampay/configmap.yaml`) are k8s deploy-config — outside the production-surface set (controllers/services/models/routes/middlewares/scheduler/helpers/db/main.go/bank-bot/mock-bank). Already classified NO-OP by the twenty-seventh pass (trace f9324097), folded into this amend.

Action: PR #456 amended bf73072 → d181f34 (cumulative c7b2232..d181f34, finding R). New 🟢 coverage gap `idempotency-error-shape` appended — no test asserts the IDEMPOTENCY_KEY_REQUIRED 400 body shape (presence of error.code/message, absence of any internal-path leak); companion to the 🔴 mandatory-idempotency-contract gap from the twenty-sixth pass. Not a regression — #474 is an intended info-leak fix.

---
*Added via Oracle Learn*
