---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 133
parent_thread: 132
parent_oracle: orchestrator
subject: §ADR-4a §Amendment — statement-driven review-payout auto-reconcile — DRAFTED; ratification thread #133 open
needs_response: false
priority: normal
created: 2026-05-16T19:20:00+07:00
---

# `ReconcileReviewPayoutToCompleted` — amendment drafted, ratification thread open

Thread #132 design direction actioned. The §ADR-4a §Amendment for the statement-driven `review`-payout auto-reconcile is drafted, and the ratification thread is open.

**Ratification thread: #133** — `arra_thread_read threadId=133`. Title: "RATIFY §ADR-4a §Amendment — statement-driven review-payout auto-reconcile". Status: `pending` (awaiting user verdict).

The full proposed amendment text (RR1–RR11) lives in thread #133 message #350 — drafted in-thread per the thread #128 precedent (architect authors the `docs/adr.md` block as `#decision` *after* the verdict; no `#provisional` block goes into `main` pre-ratification).

## What the amendment covers (the four asks in the brief)

1. **Trigger/source (RR1–RR2)** — the scraped `direction='out'` `bank_statements` row, already ingested by the §ADR-4b statement-intake pipeline but currently unconsumed by any matcher. A new outbound matcher consumes it; the disambiguator is the payout `request_id` embedded in the bank-portal transfer description — the same signal mobiz `matchPayout` P1 uses. **The carry-over is confirmed:** `ts_payouts.request_id` is server-derived + 100%-populated, and mobiz already embeds it in the KTB transfer description (pg-writer thread #129). RR2 makes the bot-side embedding a **binding cross-repo contract** — flagged for independent bank-bot-side ratification.

2. **Two resolutions (RR3–RR4)** — `review → completed` on a positive `request_id` debit match → `mark_success`, freeze settled once, **one** `payout.success` callback. `review → failed` gated strictly on a *positive* reversal/return signal → `mark_failed`, one `payout.failed` callback. **Hard invariant: absence of a matching row never auto-fails** — that is the thread #128 anti-pattern; uncertain payouts stay in `review`.

3. **Admin-resolve coexistence (RR6)** — the auto-reconcile uses the *exact same* `mark_success`/`mark_failed` lifecycle RPCs as admin-reconcile (it is a machine actor, not a new authority); it only moves *certain* cases out of `review`; races are benign lock-first-wins no-ops. Zero safety regression — exactly the thread #128 SA5 Option-D framing.

4. **Amendment + ratification thread** — drafted; thread #133 open.

## Two structural points worth surfacing to the user

- **The win is structural, and the next system already has it.** Because thread #128 made all stuck claims route to `review` (callback held, freeze held), resolution is a single *forward* transition. mobiz needs `failed → completed` only because mobiz auto-`failed` the stuck claim first; the next system has no flip-flop to recover from. This amendment is just the forward resolution.

- **One genuine decision point — the `review → failed` auto-direction (Q1).** A bank statement positively proves "landed" (a debit row) but cannot prove "not-landed" from absence. The `→ failed` direction therefore depends on a positive reversal signal whose reliability varies by bank, and mobiz itself never auto-fails via statement. The amendment recommends **(A) include it, reversal-gated**, but **(B) defer `→ failed`, ship only `→ completed`** is a clean option that still captures 100% of the user's stated flip-flop/two-callback win (that win is entirely in the `→ completed` direction). Q2 is the feature-flag default (OFF recommended, matching the auto-cancel precedent).

## Not done (correctly — pending the verdict)

- No `docs/adr.md` edit yet. On a wholesale ratification I author the RR1–RR11 block directly as `#decision` and dispatch the RR11 handoffs (writer: a PAYOUT story; impl: the outbound-matcher EF + `design/withdrawal-lane/payout-reconcile.md`; cross-repo: the RR2 transfer-description contract → bank-bot-writer).
- This is **additive** — it does not touch the in-flight thread #128 sweep impl leg (thread #127 → #130).

## Ask of you

Relay thread #133 to the user for ratification. On the verdict, reply on #133 (or reopen) and I will land the amendment + dispatch handoffs.

— next-architect, 2026-05-16 19:20 GMT+7

<!-- handled_at: 2026-05-16T19:25:00+07:00 — read + actioned by orchestrator. -->
