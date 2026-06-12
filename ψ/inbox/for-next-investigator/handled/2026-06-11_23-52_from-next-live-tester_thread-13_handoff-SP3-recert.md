---
from: next-live-tester
from_role: next-live-tester
to: next-investigator
to_role: next-investigator
type: handoff
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: "L3 re-cert (optional) — SP3 crash-restart on the split HTTPS stack, X-Request-Id live-bbot-1781194462394-63b1c818"
priority: normal
needs_response: true
created: 2026-06-11T23:52:00+07:00
---

# Optional L3 re-cert — the SP3 crash-restart now exercises real dedup

Following the in-memory-portal correction, brew-ops split the portal to its own EC2 (stable
HTTPS), so a bot-only restart now leaves the injected row R standing. I re-ran the journey;
the crash-restart genuinely re-presented R and the gateway dedup collapsed it. If you want the
full money-invariant recompute on this run, here is the key.

**X-Request-Id:** `live-bbot-1781194462394-63b1c818` (amount 747).

## The same four invariants, this run

1. **One credit** — deposit `461267e5-aa8c-4496-8eef-0fe03e292189`, `status=paid`,
   `matched_statement_id` linked; expect exactly one finalize credit set in
   `wallets_change_logs`.
2. **dup-credit=0 THROUGH a real crash-restart** — `bank_statements WHERE amount=747 AND
   direction=in` = exactly **1** (`612e4b76-f98d-4008-994b-2e73fc276d22`, `matched`,
   `matched_request_id=REQ`). The fresh bot (post-restart) re-pushed R and the gateway
   returned `0 inserted, 2 skipped` every tick — the count never grew. The positive excluder
   (`GET /sim/rows` still returned R after the restart) is in frame `…POSITIVE EXCLUDER`.
3. **Clawback unmatched-by-design (SP6)** — the `direction=out` reversal at amount 747 with
   the `อ้างอิง` marker; expect `match_status=unmatched`, no wallet move, no extra callback.
4. **Callback once** — one `callback_queue`/attempt terminal-success for the deposit.

## Evidence

PR #404, `poc/integration/evidence/live/bbot/live-bbot-1781194462394-63b1c818/` +
`L2a-restart-CLOUDWATCH-PROOF.md` (the post-restart `0 inserted, N skipped` lines).

The prior PASS (run `…e7cda45f`) already certified the invariants; this run additionally
certifies the **crash-restart** dedup path the owner asked to see real. Reply to
`for-next-live-tester/` + thread #13. — next-live-tester, 2026-06-11 23:52 +07
