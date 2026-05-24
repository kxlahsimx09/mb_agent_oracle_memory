---
title: W1 observation: range c7b2232..7e239a5 (1 production-surface commit, 2026-05-22)
tags: [tester, repo:mobiz-payment-gateway, current, w1, no-op, twenty-third-baseline, deposit-amount-floor, bot-host-locator, aws, digitalocean, neutral]
created: 2026-05-21
source: git log c7b2232..7e239a5 + git show 7e239a5 + integration-tests/test-*.sh static grep @ 2026-05-22T02:30+07:00
project: github.com/kokarat/mobiz-payment-gateway
---

# W1 observation: range c7b2232..7e239a5 (1 production-surface commit, 2026-05-22)

W1 observation: range c7b2232..7e239a5 (1 production-surface commit, 2026-05-22) is NEUTRAL across the 49-test suite

What's wrong: nothing — twenty-third W1 baseline pass; one production-surface commit (PR #454 7e239a5, squash-merge of "Floor deposit-request amount to whole baht" + "Support AWS EC2 as a bank-bot host alongside DigitalOcean"). All other commits in the range are docs/tester PRs (55abbea PR #447 docs/flow-track, bf051c7 PR #446 docs/track, 5b927c2 PR #445 feat/tester-validate amend). Net status: 0 status flips; matrix carries forward verbatim (44 VALID / 1 STALE / 2 SUPERSEDED / 2 ON_HOLD / 0 UNKNOWN). New coverage gaps appended for both halves of PR #454 (🟡 cloud_provider routing + 🟢 deposit-amount floor).

Why this is right: (a) Deposit-amount floor — controllers/DepositRequestController.go::CreateDeposit floors amount to whole baht AFTER signature verification, rejects <1 THB with 400. 23 tests call /api/v1/deposit/create; all 23 pass integer-literal amounts (500/1000/1500/2000/2500/3000/3500/10000; edge: amount=1 in test-deposit-min-max-limit.sh:168). math.Floor(integer)==integer so request payload is identical pre/post-PR; <1 reject path is unreached (suite min is 1, passes ≥1). The placement after signature validation preserves client signature verifiability — refactor risk only. (b) AWS EC2 host locator — services/botHostLocator.go (new) introduces BotHostLocator interface; services/botOpsService.go::RestartBotByAccount takes a provider arg, empty defaults to "digitalocean" (existing data needs no migration); models/system_bank.go adds per-account cloud_provider field; controllers/SystemBankController.go::RestartBot reads it. grep -lnE "cloud_provider|RestartBot|botHostLocator|BotHostLocator|awsLocator|doLocator|/restart-bot|AWS_REGION" integration-tests/test-*.sh → 0 hits. Existing fixtures don't set cloud_provider, so MongoDB read returns empty string → empty-provider default kicks in → same code path as before.

Minimal fix (proposed, not applied): none — no STALE/WRONG-SETUP findings. Two coverage-gap test sketches appended to docs/test-coverage-gaps.md: (1) 🟡 4-phase regression-tripwire for cloud_provider provider-routing on /restart-bot (DO branch, AWS branch, invalid validator, legacy-empty back-compat); (2) 🟢 6-phase regression-tripwire for deposit-amount floor (integer no-op, decimal floor + signature preserves, <1 reject, ordering regression guard, downstream matcher invariant).

Impact if unfixed: nothing operational today — the gaps are tripwires, not active issues. The 🟡 cloud_provider gap is meaningful because operator restart is the production runbook for bot resurrection during incidents; a regression silently no-ops the restart and leaves the bot down — bank-bot is the load-bearing dependency for every withdrawal-queue test in the suite.

Related: prior pass W1 twenty-second-baseline learning (2026-05-16, range f16d602..c7b2232), W1 sixth-baseline INCIDENT learning (2026-04-28, merge-clobber by writer-fleet PR #310) shows the same single-PR-per-cycle hygiene this pass also preserved.

---
*Added via Oracle Learn*
