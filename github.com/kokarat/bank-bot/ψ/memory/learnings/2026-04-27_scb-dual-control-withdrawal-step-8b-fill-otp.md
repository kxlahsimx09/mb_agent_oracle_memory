---
title: ## scb-dual-control-withdrawal §Step 8b: Fill OTP error behavior changed (failed
tags: [flow-drift, drift, scb, approver, otp, waiting_to_review, scb-dual-control-withdrawal, w9]
created: 2026-04-27
source: W9 track-flows pass — range ffd626b..b74e745
project: github.com/kokarat/bank-bot
---

# ## scb-dual-control-withdrawal §Step 8b: Fill OTP error behavior changed (failed

## scb-dual-control-withdrawal §Step 8b: Fill OTP error behavior changed (failed → waiting_to_review) in commit 2b99fb9

**Flow:** `docs/flows/scb-dual-control-withdrawal.md` — Step 8b, pointer `banks/scb/approver.js:572-597@466d56e`.

**Change (commit 2b99fb9, range ffd626b..b74e745):** Hunk `@@ -574,9 +574,20 @@` in `banks/scb/approver.js`. The Fill OTP `catch` block (old 9 lines → new 20 lines) was expanded. Previously a Fill OTP exception returned `{ status: 'failed', error: '...' }`. Now it returns `{ status: 'waiting_to_review', error: 'Fill OTP failed (approve was clicked — OTP may still be pending on SCB): ...' }`.

**Rationale (from code comments):** Fill OTP can fail in two modes — (1) OTP field never rendered → safe to fail; (2) browser died AFTER approve-click + email OTP received, meaning SCB has an orphan task waiting for OTP entry. Marking `failed` in case 2 would refund the wallet while the next batch could still confirm, causing a double-spend. The two modes cannot be cheaply distinguished, so `waiting_to_review` is the safe default for both.

**W9 classification:** Class C (semantic drift) at pointer `572-597@466d56e`. New pointer: `572-608@2b99fb9`. DRIFT annotation added inline.

**Impact on flow doc:** The step 8b prose said "Confirm-click failure escalates to `waiting_to_review`" — now Fill OTP failure also does. The doc was correct but incomplete. The DRIFT marker notes this broadening.

**Cross-repo note:** `scb-dual-control-withdrawal` is a cross-repo flow (mobiz `withdrawal-queue-dispatch-and-claim` is the counterpart). The Fill OTP behavior change is bot-internal (approver.js) and has no mobiz-side signal — mobiz W9 cannot detect this drift from its side. A `#cross-repo-sync` breadcrumb was filed separately (W9 Step 5e).

---
*Added via Oracle Learn*
