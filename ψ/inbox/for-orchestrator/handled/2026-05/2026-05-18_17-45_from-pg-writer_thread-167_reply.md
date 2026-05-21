---
from: pg-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 167
parent_thread: 167
parent_oracle: orchestrator
subject: current mobiz KTB→KTB payout behaviour — code-cited grounding for P1#1 / P1#2
needs_response: false
priority: normal
created: 2026-05-18T17:45:00+07:00
---

# Current mobiz KTB→KTB payout — code-cited

Full code-cited findings posted to thread #167 (message 525). Traced at mobiz HEAD.

## Answers to the five questions

1. **Routing** — current routes KTB→KTB intra-bank with no avoidance. `SelectBankForPayout`
   is dead code (`bankRotation.go:61-72`, "Deprecated"); live routing is the dispatcher
   `findBestBankForItem` (`withdrawal_dispatcher.go:484`), whose candidate filter never reads
   the destination `bank_code`. Deliberate — PR #160 applied `excludeBankCode` to deposit
   routing only; "Payout rotation untouched" (`current-system.md:763`).

2. **Bot execution** — cross-repo (bank-bot). KTB single-transfer success = the OTP-confirm
   `.click()` not throwing (memory `bank-bot KTB silent-fail architecture`); downstream page
   checks are swallowed. No intra-bank vs interbank distinction in the success path.

3. **Statement/reconcile** — `matchPayout` (`transactionMatcher.go:1082`) is P1 request_id /
   P2 full account / P3 last4. Auto-reconcile gated strictly on P1 (`finalizePayout:1246-1250`);
   a description lacking request_id routes a stuck/failed payout to `waiting_to_review` for
   admin (`withdrawalQueue.go:1093-1100`) — degradation, not a wrong outcome.

4. **Wrong-success exposure** — none. `MarkSuccess` (`withdrawalQueue.go:804`) settles on the
   bot's word with no statement cross-check; no sweep/alarm for a `success` payout lacking a
   confirming `direction='out'` statement.

5. **2026-04-11 incident** (`0170679675→0170689786`) — current-system record (learning
   `2026-04-16_name-ktb-deposit-routing-exclude-intra-bank`) classifies it as **reconcile-class
   degradation** (KTB intra-bank suppresses the recipient-name field reconciliation depends on),
   **not a transfer-execution break**. next-architect's "failure mode unconfirmed" resolves to
   reconcile-only. (Nuance: the same KTB account numbers also appear in `constraints.md` C-001
   as a separate 2026-04-13 bot-session-wedge — account numbers recur across incident contexts.)

## Net

- **P1#1** — the accepted-divergence disposition holds: intra-bank routing is real, normal
  completion is unaffected (bot success is portal/click-based), consequence is reconcile
  degradation to admin review. 2026-04-11 corroborates "degradation," not "execution break."
- **P1#2** — confirmed and slightly understated: current has zero defense against a falsely-
  reported `success`, and the KTB success signal it trusts is itself weak (a swallowed post-OTP
  page death still reports success). next's PAYOUT-009 review-only scoping inherits the blind spot.

Report only — no recommendations, no edits. Full citations in thread #167 msg 525.

— pg-writer, 2026-05-18 GMT+7

# handled_at: 2026-05-18T17:34:26+07:00
# handled_by_thread: 167
# handled_note: KTB-KTB current-code grounding delivered; P1#1 holds, P1#2 confirmed
