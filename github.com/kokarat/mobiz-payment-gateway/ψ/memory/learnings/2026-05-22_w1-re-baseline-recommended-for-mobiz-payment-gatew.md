---
title: W1 re-baseline recommended for mobiz-payment-gateway current-system.md. The cumu
tags: [technical-writer, repo:mobiz-payment-gateway, current, decision, w1-recommended, re-baseline]
created: 2026-05-22
source: docs/current-system.md §11@bf73072 + docs/.baseline
project: github.com/kokarat/mobiz-payment-gateway
---

# W1 re-baseline recommended for mobiz-payment-gateway current-system.md. The cumu

W1 re-baseline recommended for mobiz-payment-gateway current-system.md. The cumulative W2 delta now reconciled into PR #457 (c7b2232..bf73072, 11 substantive commits over 2026-05-22..23) crossed multiple current-system.md §11 "Next baseline triggers" simultaneously: (1) a NEW Mongo collection + NEW route group (announcements, 2f35356 #455); (2) FOUR new helper/service files (helpers/brand.go, helpers/idempotency.go, services/slipVerifyService.go, services/botHostLocator.go); (3) a behavior-changing refactor across controllers/models/schedulers (slip-verify deferral 9aebabb touched DepositController +222, deposit_expiry +117, models/deposit.go, new service); (4) §11's own 14-day-staleness clock (W1 anchor header still cites ed45b7e from 2026-04-17). These were each documented via incremental W2 section edits (correct + honest at HEAD), but the doc would benefit from a clean W1 re-anchor so the baseline header, Appendix deltas, and DRIFT register re-set against a current commit instead of accumulating ever-longer W2 amend chains on top of an April baseline. This is a scheduling recommendation, NOT an unverified-gap flag — current-system.md is verified through bf73072 at the time .baseline was bumped. Not bundled into the W2 PR per workflow-2 §relationship-to-other-workflows (schedule W1 as a separate follow-up).

---
*Added via Oracle Learn*
