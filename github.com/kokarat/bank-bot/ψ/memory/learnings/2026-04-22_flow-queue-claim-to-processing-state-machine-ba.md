---
title: flow — queue-claim-to-processing-state-machine (bank-bot W8 first pass, reverse-
tags: [technical-writer, repo:bank-bot, current, flow, flow:queue-claim-to-processing-state-machine, queue-claim, recycle-sentinel, state-machine, withdrawal-queue, pre-claim-guard, cross-cutting]
created: 2026-04-22
source: Oracle Learn
project: github.com/kokarat/bank-bot
---

# flow — queue-claim-to-processing-state-machine (bank-bot W8 first pass, reverse-

# flow — queue-claim-to-processing-state-machine (first pass, S4 reverse-engineered)

New bot-side W8 authored 2026-04-22 at `docs/flows/queue-claim-to-processing-state-machine.md` (HEAD `098a400`). Previously undocumented cross-cutting state machine that wraps every `POST /bot/queue/claim` call with five pre-claim guards and five post-batch recycle sentinels. The claim is the atomic `pending → processing` transition — getting it wrong either direction is expensive (claim on a sick browser → wallet refunds, refuse to claim unnecessarily → bank lock sits idle).

**Why this flow was missing:** the claim machinery is spread across six code sites in `app.js` (`pollLoop` outer claim + `claimMoreItems` maker-continuation + `claimMoreItemsSimple` KTB-continuation + three pipelined claims inside `startDualControlLoops`). Existing bot-side flow docs (`scb-dual-control-withdrawal`, `ktb-single-transfer-withdrawal`) each scope to one bank's happy-path submission flow and assume the claim has already happened — so the pre-claim guards, the sentinel-based recycle decisions, and the bank-specific error codes (`KTB_SESSION_DEAD`, `KTB_NEED_RELOGIN`, `KTB_DOM_STUCK`, `SCB_POPUP_STUCK`) that short-circuit the state machine had no flow-level home. This doc extracts the shared machinery so the bank-specific withdrawal flows can stay focused.

**Cross-repo counterpart:** `mobiz-payment-gateway/docs/flows/withdrawal-queue-dispatch-and-claim.md` step 4 (`POST /bot/queue/claim` — the atomic pending→processing transition) is a single `// ext: kokarat/bank-bot` marker on the gateway side. This bot-side doc unpacks that marker into the 10-step state machine around it (pre-claim guards + claim + per-batch processing + post-batch sentinels + RECYCLE path). Per `workflow-8-flow-map.md` §Design notes decomposition asymmetry, this is the expected 1:N expansion at cross-repo boundaries — mobiz's step 4 unpacks into our steps 1, 2, 3, 4, 6, 8, 9, 10 (8-of-10).

**Claim strength:** S4 — reverse-engineered from `app.js@098a400` + `core/api.js@098a400`. No ADR and no ratified Oracle thread exists for this cross-cutting machinery; it emerged incrementally across many PRs responding to specific incidents (2026-04-11 bot 0170681475 24-hour stall, 2026-04-14 bot 8204104078 popup-stuck, 2026-04-15 restart-cycle claim-before-login incident). Ratification thread pending — filed separately.

**Anchor points (for future `arra_search` queries on this slug):**
- Pre-claim guards (five): maintenance-window check, processing-flag guard, `checkApiHealth` (KTB), `ensureBrowser` + `ensureLoggedIn` (pre-claim login verification), `consecutiveLoginFailures` counter.
- Recycle sentinels (five): `itemCount >= MAX_ITEMS_BEFORE_RECYCLE` (20), `consecutiveFailedBatches >= MAX_FAILED_BATCHES_BEFORE_RECYCLE` (2, single-transfer), `consecutiveApproverFailures >= MAX_APPROVER_FAILURES_BEFORE_RECYCLE` (2, dual-control), `consecutiveNavFailures >= MAX_NAV_FAILURES_BEFORE_RECYCLE` (5), `consecutiveLoginFailures >= MAX_LOGIN_FAILURES_BEFORE_RESET` (3).
- Bank-specific short-circuits (four): `KTB_SESSION_DEAD` (immediate `resetBrowser`), `KTB_NEED_RELOGIN` (one-shot retry with same items, zero-touched contract), `KTB_DOM_STUCK` (fail-all + RECYCLE, zero-touched contract), `SCB_POPUP_STUCK` (fail-remaining + RECYCLE, may-be-touched).
- Single source of truth: `core/api.js::claimItems` at `:51-55@098a400` (`POST /api/v1/bot/queue/claim`, body `{system_bank_id}`). 404 treated as empty, not error. `AbortSignal.timeout(30000)`.

**Invariant defended:** "a batch we cannot finish is a batch we never started" — guards run BEFORE items leave `pending`, sentinels run AFTER terminal calls have already fired. RECYCLE never throws with items in flight; no queue row is orphaned.

**Follow-up / next W8 passes (from §Recommendation in the gap-finding exercise):**
- `statement-push-error-handling-and-retry` — `POST /bot/bank-statements` 429/timeout/4xx handling, currently subsection of `deposit-auto-match-from-statement` §Error paths.
- `scb-session-dead-recovery-re-login` — mid-batch session loss + browser recycle, currently implicit in `scb-dual-control-withdrawal` preconditions.

---
*Added via Oracle Learn*
