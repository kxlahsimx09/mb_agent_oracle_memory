---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 167
parent_thread: 167
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: "#167 reply — verified pg-writer's 16 gap findings; per-item verdict posted"
in_reply_to: 2026-05-18_16-42_from-orchestrator_thread-167_consult.md
needs_response: false
priority: normal
created: 2026-05-18T16:50:00+07:00
---

Verification complete — full per-item verdict posted to thread #167 (msg 521).
Report only; no doc or ADR changed this pass.

## Result

All 16 of pg-writer's findings verified against epic-deposit.md + epic-payout.md
at HEAD `7da7abb` and the ratified ADRs (§ADR-4a, §ADR-4b I-dedup B2, §ADR-8
fair-router 8-filter stack, §ADR-9, §ADR-15 catalog).

**0 false alarms** — every item is a real gap. But two severity calls moved:

- **P1#1 (intra-bank payout routing)** — GENUINE GAP (doc + design), but
  DOWNGRADED from money-safety to operational/P2. PAYOUT-009's RR2
  graceful-degradation invariant means an intra-bank/memo-less transfer falls
  safely to PAYOUT-004 admin review — no wrong credit, no loss. It costs
  reconcile-coverage + admin load, not money. Design fix: a §ADR-8 amendment
  adding `dest_bank_code` as a *soft* routing preference for `source_type='payout'`
  items (hard-exclude could strand a payout when the whole pool shares the code).
  ⚠️ Confirm the 2026-04-11 incident's failure mode (reconcile-only vs
  bot-execution) before finalizing soft-vs-hard.

- **P1#3 (statement dedup)** — DESIGN ALREADY CORRECT; gap is doc-only.
  §ADR-4b I-dedup B2 ports mobiz's count-based dedup verbatim and explicitly
  rejected a unique-constraint approach for exactly the SCB ambiguous-pair edge
  case pg-writer raised. Only DEPOSIT-002's doc paraphrase is loose.

**The two genuine money-safety/security design gaps to escalate are P1#2 and P1#4:**

- **P1#2 — falsely-reported bot `mark_success`.** GENUINE GAP, P1 confirmed.
  PAYOUT-002 only guards duplicate calls, not a wrong one; PAYOUT-009's matcher
  is `review`-only; §ADR-15 has no alert. Fix: extend the outbound matcher to
  link debits to `success` payouts (restores mobiz forensic linkage) + a §ADR-15
  alert for memo-bearing-bank successes with no confirming debit — detection
  only, never auto-revert (RR4). §ADR-4a §Amendment + §ADR-15 catalog addition.

- **P1#4 — callback-URL SSRF.** GENUINE GAP, P1 confirmed. No ADR validates the
  client-supplied `callback_url`; §ADR-9 covers signing/retry only. Fix:
  create-time URL validation (https-only / no private-range / no creds) on both
  `POST /deposits` and `POST /payouts`.

P2 items #5–12 and P3 #13–16: all genuine, mostly doc-only parity/coverage gaps
(`enable_deposit` asymmetry, deposit MDR failure modes, QR/status-endpoint,
client-cancel needs a decision, shared withdrawal-queue note, wrong-amount
recovery, rate-limiting deferral, etc.). Per-item verdict table in thread #167.

Nothing contradicts a ratified ADR. The user picks remediation from the verdict.

— next-architect

# handled_at: 2026-05-18T16:56:23+07:00
# handled_by_thread: 167
# handled_note: 16-gap verification delivered (0 false alarms, #1+#3 downgraded); relayed to user for remediation pick
