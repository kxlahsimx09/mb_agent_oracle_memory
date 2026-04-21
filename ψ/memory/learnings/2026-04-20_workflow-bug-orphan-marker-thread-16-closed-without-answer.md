---
title: workflow-bug — orphan marker for thread #16 closed without answer
name: workflow-bug-orphan-marker-thread-16-closed-without-answer
description: Thread #16 (drift:bank-bot waiting_to_review lost in single-transfer dispatch) was closed in Oracle with zero human messages, leaving the [AWAITING_THREAD:16] marker stranded in docs/flows/withdrawal-queue-single-bot-transfer.md. W9 2026-04-20 sweep stripped the marker per thread-resolve procedure (closed, any → orphan) and retained the drift description per P-001.
type: feedback
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - workflow-bug
  - orphan-marker
  - thread-resolve
  - flow:withdrawal-queue-single-bot-transfer
source: docs/flows/withdrawal-queue-single-bot-transfer.md
project: github.com/kokarat/mobiz-payment-gateway
---

## Finding

`[AWAITING_THREAD:16]` was anchored in `docs/flows/withdrawal-queue-single-bot-transfer.md` §Error paths at commit `a3e20e1` (the W8 ratification commit for thread #13 which spawned threads #15/#16 as bot-writer-owned drifts). As of W9 2026-04-20, Oracle reports thread #16 with `status="closed"` and exactly one message (claude's opening — no human reply). Per the thread-resolve dispatch table (`closed, any → Orphan marker`), the marker was stripped in this pass; the factual drift description in §Error paths was retained per P-001.

## Why it's a workflow bug

The expected resolution loop (per thread #13 and thread #16 opening message) is:

> "when `bot-writer-oracle` lands the bank-bot code fixes, it closes thread #15/#16; pg-writer's next W9 or thread-resolve sweep strips the markers and updates §Error paths with a resolution note."

Thread #16 was closed without:

- a human message explaining the close (drift classified as not-a-bug? fixed? deferred?),
- a bank-bot PR link citing the fix,
- any `arra_learn` by bot-writer recording the resolution.

So pg-writer has no evidence of what happened — only that the pointer is stale. The doc now says "drift exists, historical record per P-001" without a verified resolution. Operationally this is incomplete.

## Mitigation applied in this pass

- Marker stripped; drift description retained in §Error paths (P-001).
- This learning records the workflow bug.
- Sibling thread #15 (same bot-writer drift class — both drifts live in `bank-bot/app.js:1628-1635 / :1694-1700`) is still `pending` with a human reply ("fixed already, find the log"). W9 2026-04-20 posted a follow-up asking bot-writer to either (a) close the thread with a fix-commit citation or (b) reply here with the fix reference, so pg-writer can verify rather than guess. Thread #16 is in exactly this space but without the human hint that a fix landed.

## Prevention going forward

The thread-resolve procedure's §Anti-patterns section already warns "Closing a thread without touching the doc" — this is the reverse variant: closing a thread without explaining why. Same silent-drift risk. Proposal for the next procedure iteration: bot-writer should be required to post a closing message citing the fix (or the decision to not-fix) before calling `arra_thread_update status="closed"`. Without that, every close-without-message leaves pg-writer's sweep in the "strip marker on faith" trap.

Cross-ref to `feedback_payout_state_invariant.md` — the `waiting_to_review` semantics that thread #16's drift was about are now a load-bearing invariant ratified 2026-04-19. Whether thread #16's drift was ever actually fixed in bank-bot determines whether KTB single-transfer now honors the invariant or still silently flattens ambiguity to `failed`. Until the fix evidence surfaces, treat the KTB single-transfer path as potentially invariant-violating.
