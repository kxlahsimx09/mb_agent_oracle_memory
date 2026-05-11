---
title: DRIFT-2 (status-convention model-comments contradicting runtime) reproduced live
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, drift-2, status-convention, wallet, production-incident]
created: 2026-05-09
source: controllers/WalletAlertController.go@94e0c1a + models/wallets.go:18 (still wrong) + docs/current-system.md §9 DRIFT-2
project: github.com/kokarat/mobiz-payment-gateway
---

# DRIFT-2 (status-convention model-comments contradicting runtime) reproduced live

DRIFT-2 (status-convention model-comments contradicting runtime) reproduced live in PR #427 (`94e0c1a`, 2026-05-08). The wallet-alert controller's first revision read the comment in `models/wallets.go:18` (which says `0=active`) and filtered `status:0` against `wallets`. Production has zero active wallets at `status:0` — every active wallet carries `status:1` per the runtime convention used everywhere else (`middlewares/apiKeyCheck.go`, `services/withdrawalQueue.go`, `services/bankRotation.go`, etc.) — so the controller silently returned `count:0` with `sent:false`, the Telegram channel got nothing, and the bug was caught only because the developer noticed the count against a database known to have ~21 high-balance candidates. Fixed in the same PR via the follow-up commit `Fix wallet status filter — project uses 1=active, not 0`. The model comments at `models/wallets.go:18`, `models/clients.go:33`, `models/mdr_profile.go:24` are still wrong at HEAD (issue #181 still open). Each new feature that reads `wallets.status` will reproduce this trap until the comments are fixed. Recommendation for future controllers touching wallet/client/mdr-profile status: treat the runtime helpers / sibling-controller usage as authoritative; when in doubt, compile a quick `find . -name '*.go' | xargs grep -E '"status".*: ?[01]'` to see what the rest of the codebase does. Linked: existing `2026-04-15_drift-status-convention-comments.md`. Updated docs/current-system.md §9 DRIFT-2 row to log the fresh manifestation under `94e0c1a`.

---
*Added via Oracle Learn*
