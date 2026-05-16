---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 123
parent_thread: 122
parent_oracle: orchestrator
subject: §ADR-4a §Amendment 2026-05-16 LANDED — PR #124 up; downstream propagation ready to fan out
needs_response: false
priority: normal
created: 2026-05-16T17:47:00+07:00
handled_at: 2026-05-16T17:53:00+07:00
handled_by_thread: 122
handled_note: >-
  §ADR-4a §Amendment landing acknowledged (GitHub PR #124). Fan-out dispatched
  under parent #122 — leg B → next-writer (sub-thread #125), legs D/E →
  next-impl (sub-thread #126). Ratification sub-thread #123 closed. PR #124
  merge + the §ADR-9 callback-flow housekeeping routing call surfaced to the
  user via #122. No reply envelope (needs_response: false).
---

# §ADR-4a §Amendment 2026-05-16 landed — PR #124

Thread #123 ratified amendment (payout holding-state `waiting_to_review` → `review`) is landed. **PR #124** is open:
https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/124

Branch: `architect/w1-adr4a-amendment-review-rename-2026-05-16` (off `main` after PR #121 merged — sequencing note honored).

## What landed

`docs/adr.md`, single file, +72/−15:

- **§ADR-4a §Amendment 2026-05-16** new section — RA1–RA5 verbatim as ratified, + a §Landing note + a Propagation note.
- **RA4 inline edits** — §ADR-4a Decision #6 (sweep triage `→ mark_review`), Decision #7 (lifecycle-RPC family), Decision #8 (`admin-reconcile` → `review` only), §Deferred questions.
- **RA5 cross-cuts** — §ADR-2 C-006; §ADR-4b fair-router trigger B; §ADR-9 §Context lifecycle-RPC list; §ADR-13 (×2); §ADR-15 P3.9.
- **§ADR-4a header + Implementation footer** updated; **revision-log entry** added above PR #121's entry.
- Class: naming canonicalization — no new decision surface. Phase status unchanged: **19 ADRs/amendments `#decision`; 0 live `#provisional`.**

## Sequencing — PR #121 interaction (please note)

PR #121 (§ADR-9 reconciliation) merged between thread #123's draft and this landing. Its new §ADR-9 §Amendment 2026-05-16 block (RC0/RC1/RC5) referenced the holding state + RPC by their pre-rename names. Those live-text references were swept to the canonical names as mechanical RA1/RA2 execution — recorded in the **§Landing note** in the amendment block (RA1–RA5 themselves kept verbatim-as-ratified).

**Two §ADR-9 surfaces deliberately left unchanged — flagging for your routing call:**

1. **§ADR-9 §Context callback-flow list** — `payout.completed`/`failed`/`waiting_to_review`. This is the callback-flow enumeration, *not* the lifecycle-RPC list RA5 scoped — and it sits oddly against PR #121's §ADR-9 §Amendment RC2 (payout *event* taxonomy is 3 terminal events: `success`/`failed`/`cancelled`). `waiting_to_review` is a non-terminal *holding* state; whether it should appear in a callback-flow list at all is a §ADR-9 wire-contract question, not a rename. Left untouched — recommend a separate §ADR-9 housekeeping pass (the list also still says `payout.completed`, not `payout.success`).
2. **§ADR-9 §Amendment dpay-MCP evidence line** — "production `ts_payouts` carries `waiting_to_review`". A production-data fact about mobiz current; correctly stays `waiting_to_review`.

Historical artifacts not renamed (correct per RA5 §ADR-15 carve-out): prior-art learning filenames (`2026-04-18_cross-repo-sync-waiting-to-review-...`, `2026-04-18_payout-confirm-completed-accepts-waiting-to-review-...`); PR #121's revision-log entry (append-only history).

## Downstream propagation — ready to fan out

Per the thread #123 verdict, please dispatch:

- **B** — `epic-payout.md` **PAYOUT-004** (the `review` / might-have-sent story) → **next-writer**. Rename `waiting_to_review` → `review` in story text + acceptance criteria; the lifecycle RPC is `mark_review`.
- **D/E** — PoC code + forward migration + design docs (`docs/design/withdrawal-lane/`) → **next-impl**. The `ts_payouts.status` + `withdrawal_queue.status` enum value and the `mark_review` RPC (greenfield — no mobiz data migration; the divergence from production `waiting_to_review` is deliberate per RA3).

PR #124 has no `needs_response` from you — merge it on the normal queue. No threads opened.

— next-architect, 2026-05-16 17:47 GMT+7
