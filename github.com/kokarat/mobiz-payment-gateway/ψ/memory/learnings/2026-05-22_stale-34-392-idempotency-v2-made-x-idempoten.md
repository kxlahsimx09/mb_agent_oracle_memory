---
title: STALE (×34) — #392 idempotency-v2 made X-Idempotency-Key MANDATORY on /deposit/c
tags: [tester, repo:mobiz-payment-gateway, current, stale-test, idempotency, deposit, payout, w1-twenty-sixth-baseline]
created: 2026-05-22
source: controllers/DepositRequestController.go:114-122 + controllers/PayoutRequestController.go:94-102 @ 15a54a4 (PR #392) + integration-tests/test-*.sh (34 files, no X-Idempotency-Key)
project: github.com/kokarat/mobiz-payment-gateway
---

# STALE (×34) — #392 idempotency-v2 made X-Idempotency-Key MANDATORY on /deposit/c

STALE (×34) — #392 idempotency-v2 made X-Idempotency-Key MANDATORY on /deposit/create + /payout/create — entire deposit/payout-create test surface flipped VALID→STALE (W1 twenty-sixth baseline, 9aebabb..bf73072).

What's wrong: PR #392 (commit 15a54a4) added an unconditional `idempotencyKey := c.Get("X-Idempotency-Key"); if idempotencyKey == "" { return 400 IDEMPOTENCY_KEY_REQUIRED }` as the FIRST action (after API-key auth, before body/amount/balance logic) of DepositRequestController.CreateDeposit (lines 114-122) and PayoutRequestController.CreatePayout (lines 94-102). No env gate, no feature flag, no test-mode bypass (grep of helpers/idempotency.go + both controllers for Getenv/bypass/disable → 0). 34 of the 38 integration tests that originate a deposit/payout via POST /api/v1/deposit/create or /payout/create send only Content-Type + X-API-Key + X-API-Secret — no idempotency header — so they now get 400 at the first create call (confirmed by direct read of test-deposit-flow.sh:185 and test-payout-flow.sh:211). test-deposit-min-max-limit.sh + test-payout-insufficient.sh additionally pass-for-wrong-reason (the missing-key 400 now precedes the amount/balance rejection they assert). Only test-deposit-idempotency.sh sends the header on every create call → stays VALID and is now the contract's regression guard — BUT it is de-tiered from the regression suite (add6f49 Redis-TLS history), so the mandatory gate has ZERO active CI coverage (new 🔴 coverage gap). The 2 ON_HOLD payout tests (auto-reconcile, confirm-completed) also call /payout/create and are affected but stay ON_HOLD on the separate MarkFailed-race axis (not double-counted in the 34).

Why STALE, not regression-candidate: #392 is an intended, documented hardening (docs/idempotency-api-spec.md ships in the same PR). The production code is correct and desirable — it closes the duplicate-deposit/payout double-spend the feature exists to prevent. This is test↔code drift where the CODE moved (AGENTS.md §8 → STALE). Do NOT relax the controller; fix the tests.

Minimal fix (proposed, NOT applied — needs W2 sign-off): add a unique X-Idempotency-Key header to each /deposit/create and /payout/create call. CRITICAL nuance: the key MUST be DISTINCT per logical request. In loop/burst tests, reusing one key makes iterations 2+ replay the first txnId (helpers.AcquireIdempotencyLock → LockHeldCompletedMatch) or return 422 IDEMPOTENCY_BODY_MISMATCH on body drift — so use ${TS}-${i} or similar. ~38 call sites across 34 files. Recommended: one shared helper in integration-tests/helpers/setup-infra.sh that injects a per-call key into the deposit/payout create curls closes all 34 in a single change.

Impact if unfixed: the deposit/payout E2E suite (the bulk of functional coverage) goes red against HEAD; the regression watcher's nightly run would report ~34 failures. Worse — the new mandatory-key + v2-replay/409/422 contract has no green test guarding it (only the de-tiered idempotency test), so a future regression in that production gate would be invisible.

Other commit in range: #461 3ee8018 (brand identifiers env-driven — callback User-Agent/X-Webhook-Source via helpers.BrandCallback*, TOTP issuer via helpers.BrandTOTPIssuer) is NEUTRAL: defaults preserve ampay behavior, the TOTP issuer label does not affect TOTP code generation/validation (setup-infra login unaffected), and no test asserts on callback header values. CI/k8s/secrets commits #462–#467 are out-of-territory.

Related: extends the W1 baseline series (prior twenty-fifth at 9aebabb, NEUTRAL). Same incident shape as 2026-04-27 2FA-enforcement (1d746ee broke 35 VAs via setup-infra) — an intended production hardening that silently invalidated a swath of tests. PR #456 amended cumulative c7b2232..bf73072.

---
*Added via Oracle Learn*
