---
title: cross-repo-sync — flow `queue-claim-to-processing-state-machine` is the bot-side
tags: [technical-writer, repo:bank-bot, repo:cross, repo:mobiz-payment-gateway, current, flow, flow:queue-claim-to-processing-state-machine, cross-repo-sync, cross-repo-sync-bot-first, mobiz-payment-gateway, withdrawal-queue, queue-claim, decomposition-asymmetry]
created: 2026-04-22
source: Oracle Learn
project: github.com/kokarat/bank-bot
---

# cross-repo-sync — flow `queue-claim-to-processing-state-machine` is the bot-side

cross-repo-sync — flow `queue-claim-to-processing-state-machine` is the bot-side unpacking of mobiz's `withdrawal-queue-dispatch-and-claim.md` step 4 (`POST /bot/queue/claim` — atomic pending→processing). Bot-first in the sense that the mobiz side does NOT have a dedicated doc for the claim's bot-side semantics (just the single `// ext: kokarat/bank-bot` marker at step 4); this bot-side doc authors the counterpart that the mobiz sibling implicitly depends on.

**Counterpart mapping.** Mobiz `withdrawal-queue-dispatch-and-claim.md` (W8 trace `383d3a2d-5a90-4581-8dec-354c7b8318b3`, ratified S2 via thread #12 on 2026-04-18) has one numbered step 4 that reads `BM->>GW: POST /bot/queue/claim (system_bank_id) — atomic pending-to-processing`. That single step unpacks on the bot side into steps 1, 2, 3, 4, 6, 8, 9, 10 of the new flow — an 8-of-10 expansion. The remaining bot-side steps 5 and 7 are the in-session continuation-claim sites that never appear on the gateway side because the gateway only sees the HTTP crossing, not the loop wrapping it. Per `workflow-8-flow-map.md` §Design notes decomposition asymmetry, this is the expected shape at a cross-repo boundary — caller sees one line, implementor unpacks it into the whole state machine.

**What the bot-side doc adds that the mobiz doc cannot see:**
1. Five pre-claim guards (maintenance check, processing-flag guard, KTB `checkApiHealth`, `ensureLoggedIn`, `consecutiveLoginFailures` counter) — the gateway never sees the refusals because no HTTP call is issued on guard failure.
2. Five recycle sentinels (`MAX_ITEMS_BEFORE_RECYCLE`, `MAX_FAILED_BATCHES_BEFORE_RECYCLE`, `MAX_APPROVER_FAILURES_BEFORE_RECYCLE`, `MAX_NAV_FAILURES_BEFORE_RECYCLE`, `MAX_LOGIN_FAILURES_BEFORE_RESET`) — threshold decisions based on in-process counters, invisible to gateway.
3. Four bank-specific error codes (`KTB_SESSION_DEAD`, `KTB_NEED_RELOGIN`, `KTB_DOM_STUCK`, `SCB_POPUP_STUCK`) — raised inside bank modules, handled at `processBatch` catch; gateway only sees the downstream terminal calls.
4. The zero-items-touched contract on `KTB_NEED_RELOGIN` and `KTB_DOM_STUCK` that determines whether one-shot retry (with same items) is safe — a bot-internal invariant the gateway has no way to verify.

**What the mobiz-side doc covers that this doc does not re-explain:**
- Dispatcher's `ready→busy` lock and `findIdleBanks` filter.
- Atomic `FindOneAndUpdate` pending→processing on the gateway MongoDB side.
- `batch_id` mirror + source-row cascade on terminal calls.
- `tryReconcileAfterMarkFailed` safety net (request-id-gated).
- Stale-processing 10-min auto-fail.

**Relationship to `scb-dual-control-withdrawal.md` and `ktb-single-transfer-withdrawal.md`:** those two flows document the per-bank HAPPY-PATH submission mechanics (the code executed AFTER claim returned items). This flow documents the STATE MACHINE AROUND the claim — how we decide whether to call it, what sentinels govern whether we recycle between calls, what error codes short-circuit the cycle. The per-bank flows' preconditions assume "a batch has been claimed"; this flow documents how that precondition is established and defended.

**Search anchors for symmetric cross-repo queries:**
- `arra_search query="flow:queue-claim-to-processing-state-machine cross-repo-sync"` — should return this breadcrumb.
- `arra_search query="queue-claim mobiz-payment-gateway"` — should return this breadcrumb (names `mobiz-payment-gateway` in body) + the mobiz-side `withdrawal-queue-dispatch-and-claim` learnings.
- `arra_search query="queue-claim bank-bot"` — should return this breadcrumb + the new flow learning + mobiz-side breadcrumbs that name `bank-bot` as the territory.
- `arra_trace_get 3e91a25c-a75b-4cf9-97b1-a034332012b3` — returns the W8 root trace for this pass.

---
*Added via Oracle Learn*
