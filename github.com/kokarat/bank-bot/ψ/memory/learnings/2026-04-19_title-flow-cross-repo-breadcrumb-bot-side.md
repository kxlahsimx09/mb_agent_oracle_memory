---
title: flow cross-repo breadcrumb (bot side) — ktb-single-transfer-withdrawal crosses to mobiz withdrawal-queue-single-bot-transfer
tags: [technical-writer, repo:bank-bot, repo:cross, repo:mobiz-payment-gateway, current, flow, flow:ktb-single-transfer-withdrawal, cross-repo-sync, mobiz-payment-gateway, ktb, withdrawal-queue, single-transfer]
created: 2026-04-19
source: docs/flows/ktb-single-transfer-withdrawal.md@1cf5e14 (bank-bot) + mobiz-payment-gateway/docs/flows/withdrawal-queue-single-bot-transfer.md@252849e (sibling)
project: github.com/kokarat/bank-bot
---

# flow cross-repo breadcrumb (bot side) — ktb-single-transfer-withdrawal crosses to mobiz withdrawal-queue-single-bot-transfer

Bot-side W8 flow `ktb-single-transfer-withdrawal` (file: `docs/flows/ktb-single-transfer-withdrawal.md@1cf5e14`) crosses a repo boundary to `mobiz-payment-gateway` at steps 1 (`POST /bot/queue/claim`), 8 (`PUT /bot/queue/:id/success|/failed`), 10b (`PUT /bot/balance`), and 10d (`POST /bot/bank-statements`). The mobiz counterpart is generic `withdrawal-queue-single-bot-transfer.md@252849e` (NOT bank-specific — mobiz anticipates BBL/KBANK joining without changes).

## Cross-repo pair
- **Bot side (this repo):** `docs/flows/ktb-single-transfer-withdrawal.md` — bank-specific, KTB-only.
- **Mobiz side:** `docs/flows/withdrawal-queue-single-bot-transfer.md` — generic single-session variant (KTB currently the only implementer per `banks/ktb/index.js:33-34`).
- **Slug asymmetry is intentional.** Follows the `scb-dual-control-withdrawal` ↔ `withdrawal-queue-dispatch-and-claim` precedent: bot-side per-bank slugs paired with generic mobiz-side siblings. Mobiz ratification retro (thread #13, 2026-04-18) explicitly anticipated this ("matches the pattern bot-writer's future W8 will likely use"). NOT a violation of W8's "reuse the same slug verbatim" rule — that rule applies when documenting the *same* flow from the other side; here the two docs describe asymmetric territories (one generic protocol contract, one bank-specific implementation).

## Decomposition asymmetry (documented here for future readers jumping between docs)
Mobiz step 5 (`BB->>BK: ext-bank-bot login + add recipients + submit + OTP`) and step 6 (`BK-->>BB: ext-bank-bot success page with bankRef`) are two lines on the mobiz side — explicitly marked `// ext: kokarat/bank-bot` as territory boundary.

Those two lines unpack into **8 of 13 bot-side steps** (steps 2, 3, 4, 5, 6, 6a, 6b, 7). 1:8 expansion ratio. Parallel structure to `scb-dual-control-withdrawal` which also hit 1:8 unpacking from `withdrawal-queue-dispatch-and-claim` step 5.

## Trace id pair
- Bot-side W8 trace: `ae42fef8-b445-4f13-ad0f-0e0ca7a05b7c` (this pass, 2026-04-19).
- Mobiz-side W8 trace: `6afbf4f9-e19e-4b63-8a9e-26e23f941154` (2026-04-18 authoring, ratified S2 via thread #13).
- **Cannot `arra_trace_link` these two.** Trace schema is a linked list (one `prev_trace_id` / `next_trace_id` per row). When the next bot-side pass on this slug happens (revision), it chains to `ae42fef8-…` via the trace table; the cross-repo jump to mobiz's `6afbf4f9-…` is made by reading this breadcrumb. Per `workflow-8-flow-map.md §Trace-chain discipline`.

## Drift markers shared between the pair
- `[AWAITING_THREAD:15]` — `bankRef` in wrong positional slot at bank-bot `app.js:1642,1708`. Mobiz sibling anchors this; bot doc carries it forward verbatim (single source of truth). Resolution loop: bot-writer fixes + closes #15 → next W9/thread-resolve sweep strips marker from both docs.
- `[AWAITING_THREAD:16]` — `waiting_to_review` status lost in app-layer dispatcher at `app.js:1640-1649,:1707-1714`. Same carry-forward pattern.

Neither drift was re-filed as a new bot-owned learning — mobiz-side learnings `2026-04-18_drift-bank-bot-bankref-in-wrong-positional-slo.md` and `2026-04-18_drift-bank-bot-waitingtoreview-lost-in-singl.md` remain canonical.

## Bot-side-specific content NOT in mobiz sibling
These exist only in the bot-side doc because they are internal to the `// ext: kokarat/bank-bot` boundary:
- Four KTB sentinels (`KTB_NEED_RELOGIN`, `KTB_DOM_STUCK`, `KTB_POST_OTP`, `KTB_SESSION_DEAD`) with per-sentinel recovery behaviour.
- Intra-bank KTB→KTB disabled-name-input guard at `banks/ktb/transfer.js:591-601,619-648`.
- Angular route-change keepalive (`banks/ktb/index.js:232-312 / keepSessionAlive`) — KTB's session timer only resets on real route changes, REST activity doesn't refresh it.
- OTP Phase 1 (SMS 60s) + Phase 2 (email 180s) + IMAP final fallback.
- Recycle counters (`MAX_ITEMS_BEFORE_RECYCLE`, `MAX_LOGIN_FAILURES_BEFORE_RESET`, `MAX_NAV_FAILURES_BEFORE_RECYCLE`, `MAX_FAILED_BATCHES_BEFORE_RECYCLE`).

## Query patterns this breadcrumb enables
- `arra_search query="flow:ktb-single-transfer-withdrawal cross-repo-sync" type=learning` → returns this learning + (future) mobiz reciprocal if one is ever filed.
- `arra_search query="ktb-single-transfer-withdrawal bank-bot"` → returns bot-side flow learning + this breadcrumb + mobiz-side `withdrawal-queue-single-bot-transfer` ratification (shares `ktb` + `single-transfer` tags).
- `arra_search query="withdrawal-queue-single-bot-transfer mobiz"` → returns mobiz flow + ratification + this breadcrumb (body names `withdrawal-queue-single-bot-transfer` verbatim).
- `arra_trace_get ae42fef8-b445-4f13-ad0f-0e0ca7a05b7c` → `foundLearnings` should include this learning id after self-test.

---
*Added via Oracle Learn*


---
*Added via Oracle Learn*
