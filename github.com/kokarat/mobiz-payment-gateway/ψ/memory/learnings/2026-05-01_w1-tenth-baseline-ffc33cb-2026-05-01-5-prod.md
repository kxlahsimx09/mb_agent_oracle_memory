---
title: W1 tenth baseline (`ffc33cb`, 2026-05-01) — 5 production-surface commits in `59b
tags: [tester, repo:mobiz-payment-gateway, current, w1-tenth-baseline, no-op-pass, neutral-pass, callback-retry, pullout-demand-refill, restart-bot, mock-bank-flake-fix]
created: 2026-05-01
source: docs/test-index.md@ffc33cb + git log 59bc640..ffc33cb (1808e28, 6b07f51, e1496a2, d2a2738, ac7e95a, ffc33cb) + integration-tests/test-*.sh static analysis
project: github.com/kokarat/mobiz-payment-gateway
---

# W1 tenth baseline (`ffc33cb`, 2026-05-01) — 5 production-surface commits in `59b

W1 tenth baseline (`ffc33cb`, 2026-05-01) — 5 production-surface commits in `59bc640..ffc33cb`, all NEUTRAL for the 44-test suite. 0 status flips, 0 newly-broken, 0 newly-added. STALE/ON_HOLD/UNKNOWN/SUPERSEDED rows all carry through from W1 ninth.

Commit-by-commit static-analysis result (no test contract changed):

1. `1808e28` (PR #340) — Mock-bank UI hardening: `refreshTodoList` post-await TOCTOU guard + `clickApprove` throw-on-empty in `integration-tests/mock-bank/public/index.html`. Plus `test-settlement-flow.sh:322` `log_error` → `log_fail` typo fix (false-green WQ-failed branch — `log_error` was undefined in the helper namespace, so the polling loop would `break` on a real WQ failure without flipping `TEST_RESULT=1`). Anti-flake change benefits every approve-driven test (settlement, KTB, payout, burst/mixed). Status unchanged because the assertion contract is unchanged; flagged here as a notable test-quality fix that future-self can grep for.

2. `6b07f51` (PR #342) + `e1496a2` (PR #345) — Pullout demand-refill trigger + DestCap `EffectiveDestBalance(max(balance, available_balance))`. Pullout-only surface; zero `test-*.sh` exercises pullout queue mechanics (existing "pullout" greps are header narrative / mongo init / mock fixture references). NEUTRAL.

3. `d2a2738` (PR #349) — Client/sub-client resend-callback permission downgrade (Approve→Update gate) + new `scheduler/callback_retry.go` 1-min ticker scheduling `services.NewCallbackService().ProcessPendingCallbacks()` with bounds (24h `created_at` window, 2-min `last_callback_at` cooldown, 100-row `SetLimit`, distributed lock `lock:callback_retry`). 2-min cooldown ensures the new ticker cannot fire inside a normal test polling window. Inline first-attempt path (the path tests observe via setup-infra callback receivers) unchanged. NEUTRAL. **Side note:** this commit partially fulfills the W4-queued regression-candidate `2026-04-21_regression-candidate-callback-resend-with-idempo` — the *retry* half is now in tree; the *receiver-side idempotency-key* half is still open.

4. `ac7e95a` (PR #346) — `POST /api/v1/system-banks/:id/restart-bot` operator action gated on `system-bank:restart-bot` permission (admin/super_admin only — explicitly *not* exposed to client/sub-client to prevent fleet DoS). External DigitalOcean dependency makes it a poor integration-test candidate. NEUTRAL.

5. `ffc33cb` (PR #350) — k8s/secrets only; not production-surface for tests.

Pattern library `.agent/skills/integration-test-writer/` not modified in range — no boilerplate / helper / pitfall update needed.

Four new coverage gaps appended to `docs/test-coverage-gaps.md`:
- Pullout demand-refill trigger from `BotConfigController.UpdateBankBalance` (🟡)
- DestCap `EffectiveDestBalance` semantics (🟢)
- `CallbackRetryScheduler` bounds — 24h/2-min/100-row/round-robin (🟡)
- `POST /system-banks/:id/restart-bot` operator action (🟢)

Trace baseline: `ffc33cb`. Prior baseline: `59bc640` (W1 ninth, PR #337). Range: 5 production-surface commits, all NEUTRAL.

---
*Added via Oracle Learn*
