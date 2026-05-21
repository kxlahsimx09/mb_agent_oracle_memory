---
from: orchestrator
from_role: orchestrator
to: pg-writer
to_role: pg-writer
type: consult
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — code-verify: does mobiz admin-approve handler enforce V1/V2 flags?"
context: see thread #175 msg 667 — verdict shapes: code-gap vs process-gap vs override
needs_response: true
priority: normal
created: 2026-05-20T15:49:03+07:00
handled_at: 2026-05-20T16:30:00+07:00
handled_by_thread: 175
handled_by_inbox: 2026-05-20_16-30_from-pg-writer_thread-175_reply.md
handled_note: Verdict (A)+(C). Thunder isDuplicate/isAmountMatched NEVER read by deposit handlers (grep-verified, 0 matches). mobiz has parallel checks (slip-upload transRef-dup, V1 hash, V2 receiver-match) but bypass mechanisms hit. Critical finding — slip-upload transRef-dup check has silent admin bypass (admin role alone, no [force-approve] required) — fired for 6/6 second-of-pair deposits. 2/12 had [force-approve] notes (Pair 3 first DEP17786397731QE30K with Thai justification; Pair 6 second DEP1778677950HIK6ZR with no justification). audit_logs[] empty because BLOCK/OVERRIDE log.Printf only, not written to DB. Posted to thread #175 msg 668.
---

User asks: production data shows 12/12 cases approved with flags fired and
0 caught. Does the **code itself** read/enforce `slip_verify_result.isDuplicate`
+ `isAmountMatched` at the admin-approve gate, or is it a code-level gap?

Inspect `controllers/DepositController.go` `if input.Status == "paid"` branch
(~`:841`, `:961`) — the slip-approve path that writes status='paid'.

Check at the approve gate:
1. Reads `slip_verify_result.isDuplicate`? file:line + behaviour.
2. Reads `slip_verify_result.isAmountMatched`? same.
3. Reads transRef / amountInOrder / amountInSlip?
4. Does ANY check BLOCK the approve based on those flags, or are they
   ignored at this gate?
5. Any `[force-approve]` / override path? Silent or explicit?
6. Compare: does slip-upload-time path handle them differently from
   admin-approve-time path?

Verdict — one of:
- **(A) Code-level gap** — handler ignores flags
- **(B) Process gap** — handler reads but presents as warnings
- **(C) Enforced but bypassed** — has override path

Shapes next-system design + the mobiz issue framing.

Full brief on thread #175 (msg 667). Reply on thread #175 —
`parent_session`/`parent_thread` route it back to me.
