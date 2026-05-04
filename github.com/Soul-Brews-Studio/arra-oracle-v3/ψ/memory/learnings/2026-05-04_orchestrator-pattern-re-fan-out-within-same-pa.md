---
title: # Orchestrator pattern — re-fan-out within same parent on user extension during 
tags: [orchestrator, decision-authority, fan-out, re-fan-out, pending-go, parent-thread-reuse, role-design-extension, soul-brews-core]
created: 2026-05-04
source: orchestrator session 2026-05-04 15:42 GMT+7 (parent thread #69 second-wave fan-out)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# # Orchestrator pattern — re-fan-out within same parent on user extension during 

# Orchestrator pattern — re-fan-out within same parent on user extension during pending-GO

When a user posts an **extension/refinement** to an open parent thread that is already `pending` user GO (subs have closed, unified proposal posted), the correct shape is **re-fan-out into sibling sub-threads on the SAME parent** — not unilateral aggregation by orchestrator, not a new parent.

## Why

- **Voice separation (§11k)** holds: parent thread is user ↔ orchestrator's reasoning; new sub-threads continue 1-on-1 with the experts whose lanes the extension touches.
- **Decision-authority discipline:** orchestrator did not gain authority to incorporate substantive role-design changes unilaterally just because subs converged once. The user's extension creates new domain + mechanics questions; both deserve the same expert decomposition as the original.
- **Activation atomicity:** if parent had the original 11 deltas pending, partial activation under a user-pending refinement would be incoherent. Re-fan-out keeps the proposal one-piece.
- **`parent_thread` field reuse:** the same parent_thread metadata (#69 here) on new sub envelopes lets the orchestrator's Step 0.5 sweep group all replies (original wave + second wave) under one aggregation — clean lifecycle.

## When to apply

- Parent thread `pending` (subs closed, awaiting user GO)
- User posts substantive extension/refinement (not just a GO/cancel/close)
- Extension touches lanes already covered by sub-A/sub-B (or new lanes)
- No prior `auto-incorporate-without-fanout` pattern in `arra_search` for the request shape

## How to apply

1. Post **mid-stream acknowledgment** to parent thread (verbatim user input + gloss + decomposition rationale + sub plan).
2. Open new sibling sub-threads (here: #72 mechanics, #73 domain — sibling to closed #70/#71).
3. Write envelopes with `parent_thread=<original parent>`, `parent_oracle=orchestrator`.
4. Mark `[AWAITING_THREAD:sub-N]` markers in own work doc / parent message.
5. Archive incoming user envelope per §11d with `handled_note` describing the re-fan-out.
6. On sub convergence: aggregate refined unified proposal that **replaces** the prior proposal sections in-place (does not append a separate proposal).
7. Parent stays `pending` until refined proposal GO'd.

## When NOT to apply

- User extension is a GO / cancel / close (terminal signal — process per §11g).
- Extension is a fact lookup orchestrator can answer alone (`arra_search` resolves it).
- Extension scope is trivial and clearly inside one sub's already-closed lane (then: re-open that one sub as a follow-up consult, no second wave).

## Source

- Parent thread #69 (`implementation-architect` role design for `mb-next-payment-gateway`)
- User extension 2026-05-04 15:39 GMT+7 (Telegram chat 2002026175): mine `#current` raw transaction-DB rows + text logs for realistic PoC fixtures
- Re-fan-out: sub-C #72 (brew-ops mechanics) + sub-D #73 (next-architect domain)
- Sibling shape mirrors original sub-A #70 + sub-B #71 (which converged 2026-05-04 15:27 GMT+7 with the unified proposal)

## Tags

orchestrator, decision-authority, fan-out, re-fan-out, pending-GO, parent-thread-reuse, role-design-extension, soul-brews-core, repo:arra-oracle-v3

---
*Added via Oracle Learn*
