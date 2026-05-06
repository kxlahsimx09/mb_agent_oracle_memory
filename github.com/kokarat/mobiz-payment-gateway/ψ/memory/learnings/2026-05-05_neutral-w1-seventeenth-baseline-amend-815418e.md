---
title: NEUTRAL — W1 seventeenth-baseline AMEND (815418e..6e10032 cumulative) — PR #408 
tags: [tester, repo:mobiz-payment-gateway, current, w1-seventeenth-baseline, amend, no-flip-cadence, partner-revenue, mdr-shared, auth-gate, coverage-gap, neutral-pass]
created: 2026-05-05
source: docs/test-index.md@6e10032 + controllers/PartnerController.go::GetRevenueByClient@6e10032 + routes/partner.go:25-32@6e10032 + scripts/add_partner_revenue_permission.go@6e10032 + integration-tests/test-*.sh (48 files, 0 functional hits)
project: github.com/kokarat/mobiz-payment-gateway
---

# NEUTRAL — W1 seventeenth-baseline AMEND (815418e..6e10032 cumulative) — PR #408 

NEUTRAL — W1 seventeenth-baseline AMEND (815418e..6e10032 cumulative) — PR #408 Partner self-service revenue endpoint NEUTRAL across 48 tests, 0 status flips, 1 new 🟢 coverage gap.

What's wrong: nothing — this is the cadence marker for the second-pass amend extending PR #406. PR #408 (6e10032 — `GET /api/v1/partner/auth/revenue/by-client` aggregating `mdr_shared` docs per (client, transaction_type) for the calling partner only) adds brand-new endpoint surface that no existing test exercises. JWT `user_id` is the source of truth for `partner_id` (caller-supplied query param ignored); `user_type=="partner"` gate (admin/client/sub-client/merchant/cs/super_cs → 403); new permission `partner-revenue:view` granted to partner role only via `scripts/add_partner_revenue_permission.go` migration (idempotent `$addToSet` + Redis flush of `role:* / permissions:* / menu:*`). Static check `grep -lE "partner-revenue|/revenue/by-client|GetPartnerRevenueByClient|mdr_shared"` returns 4 hits (3 tests + test-runner.html); on inspection all 3 tests only run `db.mdr_shared.countDocuments(...)` for assertion purposes via mongosh — none call the new HTTP endpoint, none exercise the partner-only auth gate, none depend on the new permission. The endpoint is read-only (aggregation-only), no wallet changes / callbacks / SSE / state machine impact.

Why this is wrong: it isn't — the W1 cadence is supposed to surface BOTH NEUTRAL passes (so a future agent reading the index after a quiet week doesn't assume tester stopped running) AND a coverage tripwire for the new partner-only auth path so a future Phase-2 wiring change doesn't silently break partner revenue isolation. Filed at the request of the wake-prompt's "0 regression → still send Telegram short-note" rule. Coverage-gap escalation is 🟢 (read-only aggregation, no financial flow); could be folded into a broader partner-self-service test if more partner endpoints land.

Minimal fix (proposed, not applied): no test fix needed — PR #408 is purely additive. The new 🟢 coverage gap entry in `docs/test-coverage-gaps.md` covers (a) partner JWT 200 + per-client breakdown, (b) admin/client/merchant/cs 403, (c) caller-spoofed `?partner_id=X` ignored, (d) cancelled MDR rows excluded, (e) >1-year date range rejected, (f) `partner-revenue:view` present on partner role, (g) Redis cache invalidation hits role/permission/menu keys.

Impact if unfixed: cadence-only finding. The endpoint is read-only and aggregation-only — a regression would surface as either (i) cross-partner data leak (security) if a future refactor reads `partner_id` from query params instead of JWT, or (ii) revenue under-/over-reporting if the `status=1` filter is dropped or the 1-year cap is widened to admit unbounded scans. Both are partner-visible, non-financial, escalation-1 severity at most.

Note for writer: route comment at `routes/partner.go:25-27` says "granted to the partner role only via `seed/roles_seed.go`" but the commit body explicitly states `seed/roles_seed.go is INTENTIONALLY NOT modified — that file is insert-only with skip-on-duplicate, so editing it would do nothing for production but might confuse readers who think the permission was applied automatically.` Comment-vs-fact mismatch — flag for `pg-writer` to consider on the next W2 pass; out of tester scope.

Related: 2026-05-05 W1 seventeenth baseline (`815418e..7c8033b` first pass on PR #406) — 3 NEUTRAL commits + 3 coverage gaps (1 escalated 🟡 blacklist, 2 🟢). This amend layers PR #408 on top with the same shape (NEUTRAL + 1 new 🟢 gap).

---
*Added via Oracle Learn*
