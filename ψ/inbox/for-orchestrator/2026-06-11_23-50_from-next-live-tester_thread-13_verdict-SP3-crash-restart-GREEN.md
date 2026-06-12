---
from: next-live-tester
from_role: next-live-tester
to: orchestrator
to_role: orchestrator
type: verdict
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: "SP3 dup-fault RE-RUN on the stable HTTPS stack — crash-restart now REAL, dedup GREEN-for-real (L2a AMBER→GREEN); X-Request-Id for L3 re-cert"
priority: high
needs_response: false
created: 2026-06-11T23:50:00+07:00
---

# SP3 crash-restart is now a real dedup test — and it passes

Re-ran the golden journey on brew-ops's split stack (portal = its own EC2+Caddy at the
stable HTTPS `https://18-136-227-108.sslip.io`; bot = its own Fargate `mb-next-bankbot-bot`;
SP3 lever now bot-only). **X-Request-Id: `live-bbot-1781194462394-63b1c818`** (amount 747).

## Per-leg verdict

| Leg | Verdict | Note |
|---|---|---|
| L0 / L1a / L1b / L1c / L1d / L1e | **GREEN** | golden journey intact on HTTPS — deposit `461267e5` paid, credited, callback delivered |
| L2b clawback (SP6) | **GREEN** | out-row unmatched-by-design, อ้างอิง marker, original untouched |
| L2a-steady-dedup | **GREEN** | steady-state over-scan: bot re-pushes R each tick, gateway `0 inserted, 1 skipped`, count stays 1 |
| **L2a-dup-fault (SP3 crash-restart)** | **GREEN-for-real** | the headline — see below |
| L3 rotate | SKIPPED | opt-in |

## The crash-restart, the way the owner asked for it

1. **Positive excluder PASSED** — after the bot-only Fargate restart, `GET /sim/rows` STILL
   returned R. The portal (separate EC2) survived. This is the guard that distinguishes a real
   dedup test from the old hollow empty-portal pass; my leg makes GREEN *require* it.
2. **Fresh bot re-scraped the surviving R** — CloudWatch shows the new task re-read its cursor
   (`in=202606112314` = R's minute) and re-collected R.
3. **Gateway count-dedup collapsed the re-push** — every post-restart tick:
   `Pushed: 0 inserted, 2 skipped` (16:21:01 / 16:21:47 / 16:22:33 / 16:23:18 …). The 2
   skipped = R[in,747] + the clawback out-row, both already stored.
4. **dup-credit = 0** — `bank_statements WHERE amount=747 AND direction=in` = exactly **1**
   row (`612e4b76…`, `match_status=matched`, `matched_request_id=REQ`), credit unchanged.

## One honesty note (already corrected)

The harness leg first printed **AMBER**, not because the test failed but because its single
end-of-leg log read missed the skip line in its 40-line window (CloudWatch tail lag). The
bot's own logs are conclusive GREEN — committed as `L2a-restart-CLOUDWATCH-PROOF.md`, and the
harness now polls + latches the skip across the post-restart window. The DB invariant
(count=1) and the positive excluder (R survived) both passed inside the run regardless; the
skip line was the only thing the tail-timing missed.

## Net

The earlier in-memory-portal limitation is closed by brew-ops's split. SP3 now exercises the
gateway count-based dedup against a **surviving** re-presented row — **AMBER→GREEN-for-real**.
Handing the X-Request-Id to next-investigator for an L3 re-cert if you want the full money-
invariant recompute on this run. Evidence: PR #404,
`evidence/live/bbot/live-bbot-1781194462394-63b1c818/`. — next-live-tester, 2026-06-11 23:50 +07
