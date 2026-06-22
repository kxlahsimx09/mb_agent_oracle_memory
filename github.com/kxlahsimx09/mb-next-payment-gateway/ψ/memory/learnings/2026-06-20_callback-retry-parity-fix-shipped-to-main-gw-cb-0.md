---
title: Callback-retry parity fix SHIPPED to main (GW-CB-06, campaign 41-o-business-gap,
tags: [callback-retry-fix, GW-CB-06, ADR-9-amendment, build-workflow, orchestrator, mb-next-payment-gateway, pr-665, pr-667, pr-666, pr-671, app_now-for-testability, trycloudflare-tunnel-infra-blocker, standalone-test-split, next-live-tester]
created: 2026-06-20
source: orchestrator campaign 41-o-business-gap, callback-retry parity fix, 2026-06-20
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Callback-retry parity fix SHIPPED to main (GW-CB-06, campaign 41-o-business-gap,

Callback-retry parity fix SHIPPED to main (GW-CB-06, campaign 41-o-business-gap, 2026-06-20). The undocumented downgrade (NEW callback retry = MAX_ATTEMPTS=3, flat 1-min sweep, ~2-3min window vs CURRENT 7 attempts / 1-3-5-7-9-15-min ladder / ~40min) is FIXED to full parity via the orchestrator-driven build-workflow: next-architect → ADR-9 amendment CBR1-CBR6 + spec (PR #665); next-dev-1 (dev-1) → next_retry_at column + mark_retry writes ladder on app_now() (NOT wall-clock, so live-tests can fast-forward) + claim_batch_for_dispatch gate (next_retry_at IS NULL OR <= app_now()) + claim_for_dispatch/eager+manual-resend left UNGATED + MAX_ATTEMPTS 3->7 (PR #667, pgTAP 18/18 + dev-1 verify 21/21); next-live-tester (fresh own-slug) → rewrote the dead-letter live-test to expect dead-letter only after the 7th attempt on the ladder AND split it into a STANDALONE case (journey-callback-deadletter.ts + runner) per owner, all files <=250 (PR #666); next-code-reviewer APPROVE on both PRs; next-pm updated the register GW-CB-06 -> FIXED (PR #671). All merged by owner except #671 (pending). PROD-DEPLOY pending (brew-ops). KEY GOTCHA: the dead-letter LIVE-RUN is PENDING-INFRA — the trycloudflare quick-tunnel inbound path is dead on this test host (QUIC registers outbound, inbound HTTP never reaches the local mock-merchant -> L0 readiness BLOCKs before clock_set), which blocks ANY live journey (incl deposit-journey) here; needs a brew-ops fix (tunnel / readiness-gate timeout / stable /fail=500 receiver). Pattern: SPEC-first lets dev (code) and live-tester (tests) run parallel off one spec branch via git show; use app_now() for any time-based logic so live-tests are fast-forwardable.

---
*Added via Oracle Learn*
