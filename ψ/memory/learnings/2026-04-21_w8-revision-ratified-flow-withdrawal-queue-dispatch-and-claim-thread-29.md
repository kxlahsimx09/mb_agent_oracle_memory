---
title: W8 revision ratified — flow:withdrawal-queue-dispatch-and-claim thread #29 closed
name: w8-revision-ratified-flow-withdrawal-queue-dispatch-and-claim-thread-29
description: Thread #29 ratified by human 2026-04-21. Rulings: (Q1) batch-boundary coupling is permanent intent; (Q2) supersede old framing via explicit Change log link per P-001; (Q3) tier-tiered cap is canonical; (Bonus) :220 comment-code drift resolved comment→code (update comment to 1-5). Supersedes 2026-04-20_w8-revision-flow-withdrawal-queue-dispatch-and-claim-dispatcher-semantics.md.
type: project
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - flow
  - w8-revision
  - ratified
  - flow:withdrawal-queue-dispatch-and-claim
  - thread-29
source: docs/flows/withdrawal-queue-dispatch-and-claim.md
project: github.com/kokarat/mobiz-payment-gateway
---

## Outcome

Thread #29 (opened 2026-04-20 during the W8 revision pass on `withdrawal-queue-dispatch-and-claim.md`) ratified by human on 2026-04-21. All three folded questions + the bonus comment-code drift direction ruled. Both `[AWAITING_THREAD:29]` markers stripped from the flow doc in the same commit; `// ratified-via-thread:29` inline annotations added at §Purpose paragraph 2 and §Implementation pointers Step 3.

## Rulings

1. **Dispatcher-bot batch-boundary coupling = permanent design intent.** PR #239's `working_status != busy` filter in `findIdleBanks` is canonical. One batch per bank at a time, end-to-end, no pipelining. Not a transitional safety fix.
2. **Old framing preserved via supersede with explicit linking** (P-001). The 2026-04-18 thread #12 ratification entry in §Change log is retained as historical record; the 2026-04-20 W8-revision entry is retained as the transition entry; a new 2026-04-21 entry explicitly supersedes the "dispatcher can operate every tick without waiting for the bot" claim. No silent rewrite.
3. **Tier-tiered cap is canonical spec**, not transitional: `>=100: 5 fixed`, `>=20: 4-5`, `>=5: 3-5`, `else: 1-5`.
4. **Bonus — `scheduler/withdrawal_dispatcher.go:220` comment-vs-code drift resolved in the code direction.** Comment updated (`random 1-3 (stealth — idle pattern)` → `random 1-5`). The stealth-idle framing was an earlier intent never implemented; keeping the comment aligned with code is the right disposition. The sibling `#drift + #comment-code-mismatch` learning (`2026-04-20_drift-dispatcher-comment-code-mismatch-1-3-vs-1-5.md`) is now **resolved** — queued W4 pickup no longer needed.

## Supersedes

- Prior authoring learning: `ψ/memory/learnings/2026-04-20_w8-revision-flow-withdrawal-queue-dispatch-and-claim-dispatcher-semantics.md` (the pending-ratification version). Reason: thread #29 is now closed with explicit answers; the pending-state framing is outdated.
- Prior drift learning resolution: `ψ/memory/learnings/2026-04-20_drift-dispatcher-comment-code-mismatch-1-3-vs-1-5.md` is resolved by this ratification; the "queue W4" directive in that learning should be treated as closed.

## Related

- Flow doc: `docs/flows/withdrawal-queue-dispatch-and-claim.md` (revised + ratified)
- W8 revision trace: `b27c8d35-f7f3-46b5-8cf4-51e48f4ba7ec` (chained to prior W8 `383d3a2d-…`)
- W9 halt trace: `68ec92a6-1834-4b8a-8a2a-76fd306d35d3` (the pass that escalated to this W8 revision)
- PR: #247 (to be updated with ratification commit)

## Claim strength

Stays **S2**. Ratification confirmed the transcription of new code behavior; it did not upgrade (no new intent asserted beyond code) or downgrade (no divergence surfaced).

## How to apply

- When reading `withdrawal-queue-dispatch-and-claim.md` going forward, the batch-boundary coupling is canonical. A future code change that removes the `working_status != busy` filter in `findIdleBanks` would need its own W8 revision and a fresh ratification thread — it cannot silently override the 2026-04-21 ruling.
- The six deferred flows from the 2026-04-20 W9 threshold-breach (payout-request, payout-confirm-completed, topup-approve-mdr-distribution, deposit-slip-upload-admin-approve, withdrawal-queue-single-bot-transfer, deposit-qr-request) are still pending follow-up passes; see `2026-04-20_w9-halted-threshold-breach-7-flows-escalated-w8-revision.md`.
