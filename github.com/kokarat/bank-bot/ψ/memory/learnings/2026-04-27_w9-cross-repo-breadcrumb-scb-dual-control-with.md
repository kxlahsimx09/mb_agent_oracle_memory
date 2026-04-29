---
title: ## W9 cross-repo breadcrumb: scb-dual-control-withdrawal Fill OTP drift is invis
tags: [cross-repo-sync, flow-drift, scb-dual-control-withdrawal, scb, approver, waiting_to_review, w9, cross-repo]
created: 2026-04-27
source: W9 track-flows pass — range ffd626b..b74e745 (Step 5e)
project: github.com/kokarat/bank-bot
---

# ## W9 cross-repo breadcrumb: scb-dual-control-withdrawal Fill OTP drift is invis

## W9 cross-repo breadcrumb: scb-dual-control-withdrawal Fill OTP drift is invisible from mobiz side

**Flow:** `docs/flows/scb-dual-control-withdrawal.md` (bank-bot repo). This flow is a cross-repo flow — mobiz's `withdrawal-queue-dispatch-and-claim.md` is the gateway-side counterpart.

**Drift in range ffd626b..b74e745:** `banks/scb/approver.js` Step 8b Fill OTP behavior changed (failed → waiting_to_review, commit 2b99fb9). This is entirely in the bot's `approver.js` and has NO corresponding change in mobiz. The mobiz W9 cannot detect this drift by examining its own code — the change is invisible from the mobiz side.

**Why it matters for cross-repo sync discipline:** When a bot-internal change alters the observable semantics of a terminal call (`waiting_to_review` instead of `failed`), the gateway's behavior changes (no wallet refund vs. wallet refund). This IS observable from the mobiz side via `withdrawal_queue` status distribution, but the ROOT CAUSE is not traceable without the breadcrumb.

**Filed breadcrumb:** This learning is tagged `#cross-repo-sync` and `#flow-drift` so the mobiz W9 pass on `withdrawal-queue-dispatch-and-claim.md` can surface this bank-bot change as context when triage decisions about waiting_to_review handling are made.

---
*Added via Oracle Learn*
