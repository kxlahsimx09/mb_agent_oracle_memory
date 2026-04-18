---
title: # drift-candidate — `markWaitingToReview` is a new bot→backend endpoint (DRIFT-8
tags: [technical-writer, repo:bank-bot, current, drift, api, cross-repo-sync, waiting-to-review]
created: 2026-04-18
source: W1 baseline @ 7d4b50e (PR #60, commit 0789b4b)
project: github.com/kokarat/bank-bot
---

# # drift-candidate — `markWaitingToReview` is a new bot→backend endpoint (DRIFT-8

# drift-candidate — `markWaitingToReview` is a new bot→backend endpoint (DRIFT-8 consolidation check needed)

**Tags**: technical-writer, repo:bank-bot, current, drift, api, cross-repo-sync, waiting-to-review

**What**: `core/api.js` (L86-90 @ 7d4b50e) gained a new method `markWaitingToReview(itemId, reason)` that calls `PUT /api/v1/bot/queue/:id/waiting-to-review`. This is a new surface between the bot and the payment-gateway backend.

**Drift status**: CLAUDE.md's "Backend API Endpoints" table lists six endpoints as the complete bot-backend surface; `waiting-to-review` is not in that table at 7d4b50e. This is a documentation drift. It is not catastrophic — the bot code uses the endpoint successfully — but it violates the "CLAUDE.md covers all endpoints" implicit claim.

**Open question** (candidate for W4 reconcile-drift pass): Should this be rolled into the existing DRIFT-8 in `docs/current-system.md` (which covers general CLAUDE.md endpoint-table staleness) or promoted to a standalone new drift marker? Depends on what DRIFT-8 currently says — if DRIFT-8 is "endpoint table is incomplete", append; if DRIFT-8 is something more specific, create a new marker.

**Cross-repo sync check**: The backend route handler must exist in `github.com/kokarat/mobiz-payment-gateway` for this call to work. Next `pg-writer-oracle` pass should confirm the backend side is documented in CLAUDE.md and that the Go handler is referenced in `docs/current-system.md` over there. If the backend route is also undocumented, file as a cross-repo `#drift`.

**Why it matters**: Bot-backend contracts are the thinnest documentation surface. When they drift, debugging a bot-to-backend call failure means reading both codebases. Keep them synchronized.

**How to apply**:
- Next W4 on bank-bot: decide DRIFT-8 consolidation vs new marker; update `docs/current-system.md` §4.1 table if it's missing.
- Next W1 on mobiz-payment-gateway: confirm `/queue/:id/waiting-to-review` handler + BotController endpoint list in their `current-system.md`.

**Source**: docs/current-system.md §4.1 + `core/api.js:86-90` @ 7d4b50e.

---
*Added via Oracle Learn*
