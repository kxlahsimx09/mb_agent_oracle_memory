---
title: W9 incremental pass 2026-05-06: commit range 7c8033b..6e10032 (1 new in-territor
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, no-drift-found, w9-incremental]
created: 2026-05-05
source: docs/flows/.baseline (bumped 7c8033b → 6e10032)
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 incremental pass 2026-05-06: commit range 7c8033b..6e10032 (1 new in-territor

W9 incremental pass 2026-05-06: commit range 7c8033b..6e10032 (1 new in-territory commit since prior W9 PR #407 was opened). Outcome: 0 affected flows, 0 pointer drifts. Sole new commit 6e10032 (Partner: GET /partner/auth/revenue/by-client #408) touched controllers/PartnerController.go + routes/partner.go + scripts/add_partner_revenue_permission.go — none of these files are cited by any docs/flows/*.md pointer (grep -lE 'PartnerController.go|routes/partner.go|add_partner_revenue_permission' docs/flows/*.md returned empty). The endpoint is uncovered-surface territory rather than class-D step-within-flow, so a separate #w8-handoff learning is filed alongside this one. Prior W9 PR #407 covered f89e235..7c8033b with 1 class-C drift (payout-admin-cancel) + 1 uncovered-surface (services/blacklistAutoDetect.go). docs/flows/.baseline bumped 7c8033b → 6e10032.

---
*Added via Oracle Learn*
