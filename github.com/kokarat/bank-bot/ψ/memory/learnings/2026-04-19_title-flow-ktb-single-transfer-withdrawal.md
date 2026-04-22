---
title: flow — ktb-single-transfer-withdrawal — bot-side intent at a glance
tags: [technical-writer, repo:bank-bot, current, flow, flow:ktb-single-transfer-withdrawal, ktb, withdrawal-queue, single-transfer, batch-transfer, playwright, reverse-engineered, ratification-pending, s4]
created: 2026-04-19
source: docs/flows/ktb-single-transfer-withdrawal.md@1cf5e14 (bank-bot); mobiz sibling at 252849e (withdrawal-queue-single-bot-transfer)
project: github.com/kokarat/bank-bot
---

# flow — ktb-single-transfer-withdrawal — bot-side intent at a glance

One-sentence purpose: after the mobiz gateway has assigned a pending withdrawal-queue item to a KTB system-bank, bank-bot's single Playwright session claims 1-5 items, executes them as one batched transfer on KTB Business (one login, one add-recipient loop, one OTP that authorises every recipient), reports per-item terminal state back to the gateway, and pushes the resulting statement rows and balance.

## What this doc covers
- Full bot-side lifecycle: claim → ensureLoggedIn → navigate → per-recipient add+save → submit → OTP (Phase 1 SMS 60s, Phase 2 email 180s, IMAP final fallback) → success detection → per-item terminal → saveStorage → balance + statement push → recycle accounting → idle branch.
- Four KTB-specific sentinels as first-class §Error paths entries: `KTB_NEED_RELOGIN` (zero-interaction abort, safe retry-same-items once), `KTB_DOM_STUCK` (cdk-overlay backdrop wedged; pre-interaction=recycle, post-interaction=mark-failed), `KTB_POST_OTP` (OTP confirm click threw; should emit `waiting_to_review` but app.js dispatcher collapses to `failed` — DRIFT-16), `KTB_SESSION_DEAD` (REST Balance API 500-burst; clear storage + resetBrowser).
- Intra-bank KTB→KTB disabled-name-input guard (Playwright would deadlock waiting for enabled without this).
- `[AWAITING_THREAD:15]` (bankRef slot-swap at app.js:1642,1708) and `[AWAITING_THREAD:16]` (waiting_to_review lost in dispatcher at app.js:1640-1649,:1707-1714) carried forward verbatim from the mobiz-sibling ratification — bot-writer closes the existing pg-writer-filed threads when the fixes land; no new bot-owned threads filed.

## What this doc explicitly does NOT cover
- Statement-scrape internals — sibling `deposit-auto-match-from-statement.md` (steps 10/10b/10c/10d of this doc are that doc's first four steps).
- Gateway mechanics (dispatcher, ClaimByBank, MarkSuccess, MarkFailed cascade, MDR, callback, lock release) — mobiz sibling `withdrawal-queue-single-bot-transfer.md@252849e` owns all those.
- SCB dual-control mechanics — lateral sibling `scb-dual-control-withdrawal.md`.
- KTB login-with-OTP internals — included as Step 0a for precondition framing but deliberately not unpacked to sub-steps; candidate for a future `ktb-login-with-otp` flow doc if scope grows.

## Key decomposition asymmetry
Mobiz sibling step 5 (`// ext: kokarat/bank-bot`) is one line. This bot-side doc unpacks it into 8 of 13 numbered bot steps (steps 2, 3, 4, 5, 6, 6a, 6b, 7). 1:8 expansion ratio — matches the `scb-dual-control-withdrawal` (1:8 from mobiz `withdrawal-queue-dispatch-and-claim` step 5) precedent noted in `.agent/skills/technical-writer/references/workflow-8-flow-map.md §Design notes`.

## Claim strength + ratification
- Current: **S4**, `[RATIFICATION_PENDING:21]`.
- Thread #21 filed with seven judgement calls (slug, loop-wrap, actor framing, drift carry-forward, scope boundary, sentinel density, naming disclaimer).
- On ratification → strip `[RATIFICATION_PENDING:21]`, replace with `// ratified-via-thread:21`, bump to S2, supersede this learning with a ratified variant, refresh `docs/flows/.baseline` to `1cf5e14`.

## Related
- W8 root trace: `ae42fef8-b445-4f13-ad0f-0e0ca7a05b7c` (bank-bot side).
- Cross-repo sibling W8 trace: `6afbf4f9-e19e-4b63-8a9e-26e23f941154` (mobiz side, ratified S2 via thread #13).
- Reciprocal `#cross-repo-sync` breadcrumb learning filed separately (see `2026-04-19_flow-cross-repo-breadcrumb-bot-side-ktb-single-transfer-withdrawal.md`).
- Bot-side flow portfolio after this pass: `scb-dual-control-withdrawal`, `deposit-auto-match-from-statement`, `ktb-single-transfer-withdrawal` → 3 docs → unblocks W9 (needs 2+ docs).

---
*Added via Oracle Learn*


---
*Added via Oracle Learn*
