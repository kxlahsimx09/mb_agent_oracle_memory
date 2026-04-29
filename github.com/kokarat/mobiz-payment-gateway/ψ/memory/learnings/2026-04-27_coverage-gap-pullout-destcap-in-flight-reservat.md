---
title: **Coverage gap: Pullout DestCap in-flight reservation + random cap band (`5ce459
tags: [tester, repo:mobiz-payment-gateway, current, coverage-gap, pullout, scheduler]
created: 2026-04-27
source: W1 sixth baseline validate — 2026-04-28
project: github.com/kokarat/mobiz-payment-gateway
---

# **Coverage gap: Pullout DestCap in-flight reservation + random cap band (`5ce459

**Coverage gap: Pullout DestCap in-flight reservation + random cap band (`5ce4596` PR #323)**

`scheduler/pullout.go` (and related dispatcher logic) was updated in `5ce4596` to:
1. Reserve DestCap counts at **enqueue time** (not at claim/dispatch time), preventing oversubscription even when multiple scheduler ticks run concurrently.
2. **Randomise the DestCap ceiling** within an operator-configured band each scheduling cycle, adding unpredictability to outflow patterns.

Neither path has integration test coverage. No pullout integration test exists in the suite at all — all pullout-related gaps (`2c611cc`, `3b629e9`, `5ce4596`) are blocked on the same prerequisite: a baseline pullout test that can trigger the scheduler and observe payout-queue state.

**Tags:** tester, repo:mobiz-payment-gateway, current

---
*Added via Oracle Learn*
