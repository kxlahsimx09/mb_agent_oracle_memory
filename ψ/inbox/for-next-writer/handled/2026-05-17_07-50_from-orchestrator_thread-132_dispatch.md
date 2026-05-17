---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: dispatch
thread: 132
parent_thread: 132
parent_oracle: orchestrator
subject: epic-payout — sweep PAYOUT-004 / PAYOUT-009 for `review`-state callback wording (CS4, §ADR-9 reconciliation)
priority: normal
needs_response: true
created: 2026-05-17T07:50:02+07:00
handled_at: 2026-05-17T09:53:00+07:00
handled_by_inbox: next-writer
handled_by_thread: 132
handled_note: "Dispatch (CS4 doc half — sweep PAYOUT-004/009 for review-state callback wording) was discharged by a prior next-writer session via PR #139 (since merged), with the result posted on thread #132 (msg 389). Inbound envelope was left un-archived — archiving now. Loop-closure note posted on thread #132 and reply envelope filed to for-orchestrator/ (parent_thread 132)."
---

# epic-payout — sweep PAYOUT-004 / PAYOUT-009 for `review` callback wording

§ADR-9 §Reconciliation is **ratified and merged** (PR #138, mb-next): the `review` payout holding-state is **callback-silent**, and `payout.waiting_to_review` is **retired**. The ratified payout callback taxonomy is exactly 3 events: `payout.success` / `payout.failed` / `payout.cancelled`.

This is the CS4 documentation half (the next-impl code half — dropping the `mark_review` callback INSERT — is in flight on PR #135).

## Task

In `docs/requirements/epic-payout.md`, sweep **PAYOUT-004** and **PAYOUT-009** for any mention of:
- a `review`-state callback, or
- a `waiting_to_review` / `payout.waiting_to_review` event

Correct every such mention to: **the client receives exactly one terminal callback; `review` is callback-silent.** Make the prose and any sequence diagrams consistent with §ADR-9 §Reconciliation as merged in #138.

## Before you push — mandatory

Run the **W1 Step 8 mermaid parser gate** (`references/check-mermaid.mjs`) on `epic-payout.md`. PAYOUT-009's diagram has broken the docs-site render before (semicolon-as-statement-separator). Do not push until the parser gate passes.

Open a PR off `main`, do not merge — the user merges. Reply on **thread #132** with the PR number.

— orchestrator, 2026-05-17 07:50 GMT+7
