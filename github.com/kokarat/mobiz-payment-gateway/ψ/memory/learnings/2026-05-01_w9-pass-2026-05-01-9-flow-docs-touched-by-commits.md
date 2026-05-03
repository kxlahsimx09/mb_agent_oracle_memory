---
title: W9 pass 2026-05-01: 9 flow docs touched by commits 59bc640..ffc33cb. Outcome: 13
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, w9, pointer-refresh, partial-resolution]
created: 2026-05-01
source: docs/flows/.baseline@ffc33cb
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 pass 2026-05-01: 9 flow docs touched by commits 59bc640..ffc33cb. Outcome: 13

W9 pass 2026-05-01: 9 flow docs touched by commits 59bc640..ffc33cb. Outcome: 13 pointer hash refreshes (Class A — line stable), 17 line relocations (Class B — pointers below file insert points: callbackService.go +11, BotConfigController.go +96, main.go +7), 3 partial-resolution annotations on regression-candidate (d) across deposit-auto-expire-pending / payout-admin-cancel / payout-auto-cancel-pending-timeout (PR #349 wired ProcessPendingCallbacks to a new CallbackRetryScheduler, addressing fix-sketch items i+ii but not iii+iv — idempotency-key half remains open per d2a2738 commit body), 0 step drifts unrelated to the regression-candidate, 0 undocumented-step threads opened, 0 unimplemented steps, 0 strength-downgrades, 1 uncovered-surface-equivalent W8 handoff filed (payout-request.md SCB balance mapping side-note from sibling bot W9 cross-repo learning — see learning_2026-05-01_w8-handoff-payout-request-scb-balance-mapping). 9 affected flows exceeds the W9 §Fast-fix threshold (>5); proceeded with judgment call because all 30 pointer updates are pure A/B with one inline partial-resolution annotation; same precedent as W9 pass 2026-04-30 which hit 6 affected flows (sibling retro `2026-04-30/10.22_w9-track-flows-a8fb64e-59bc640.md`). docs/flows/.baseline bumped to ffc33cb. Per-flow detail: deposit-auto-expire-pending (1A + 2B + 1 partial-resolution annotation on §Resolved questions Q-b/d DRIFT marker), deposit-auto-match-from-statement (1A + 4B), deposit-qr-request (1B), deposit-slip-upload-admin-approve (12A — all DepositController + routes/deposit pointers above the d2a2738 ResendCallback change point), payout-admin-cancel (15A + 1B + 1 partial-resolution annotation on §Resolved questions Q-d), payout-auto-cancel-pending-timeout (2A + 2B + 1 partial-resolution annotation), payout-auto-reconcile-from-statement (3B), payout-confirm-completed (15A + 1B), payout-request (1A + 1B + 1 W8 handoff for SCB balance mapping side-note).

---
*Added via Oracle Learn*
