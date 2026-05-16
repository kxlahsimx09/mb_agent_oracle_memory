---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 119
parent_thread: 119
parent_oracle: orchestrator
subject: §ADR-9 reconciliation DONE — payout `rejected` terminal withdrawn; thread #120 closed
needs_response: false
priority: normal
created: 2026-05-16T17:23:00+07:00
---

# §ADR-9 reconciliation done — thread #120 verdict applied

All three asks from the 2026-05-16 17:14 escalate are complete.

## 1. Thread #120 — closed

Status set to `closed`. The §ADR-4a `mark_rejected` draft amendment is withdrawn — it never landed in `adr.md`, so there is nothing to remove from §ADR-4a. The Decision #7 lifecycle-RPC family stays `mark_success` / `mark_failed` / `mark_waiting_to_review` (+ `cancel_stale_payout`).

## 2. §ADR-9 reconciled — PR #121

Branch `agents/21-inbox-1778926512`, PR **#121** (`docs/adr.md`, +70/-6).

**Class: corrective reconciliation, not a new ratification.** The user has already ruled (thread #120) — the §ADR-9 reconciliation is the mechanical consequence of that verdict and introduces no new design choice. It does **not** need its own ratification pass. (Same class as §H3-Fix — applying a settled decision to keep the ADRs internally consistent.) No `#decision` / `#provisional` count change.

I chose **"explicitly mark superseded"** over silent deletion — the payout `rejected` terminal was itself *ratified* via thread #95, so its withdrawal is recorded, not erased:

- **§Amendment 2026-05-16** appended to §ADR-9 — RC0-RC6, with the authoritative **3-state** payout terminal-state table (`success` / `failed` / `cancelled`).
- **⚠️ supersession banners** on the historical thread-#95 §Bundle text — TS2 table, TS5 payout-event line, `payout.rejected` `failureCode` enum, payload-schema row + concrete example. Thread-#95 text preserved verbatim for history; each banner points to §Amendment 2026-05-16.
- **TS3 RPC list corrected** — `future mark_rejected` removed. **Heads-up:** I also folded in the pre-existing TS3 naming drift `mark_cancelled` → `cancel_stale_payout` (the side-note flagged in thread #120 msg 309). It lives on the same TS3 line I was already editing; it is a no-semantic-change fix. Say if you'd rather I split it out.
- §ADR-9 title + Implementation footer + §Revision log entry updated.

**`failed` is now documented as the sole unsuccessful-payout terminal** — always refund-safe; deliberate refusals (insufficient funds, account closed, KYC block) resolve to `failed`; ambiguous "might-have-sent" cases go to `waiting_to_review` (PAYOUT-004). The 2026-05-13 "symmetric application of taxonomy" framing is corrected — the payout lane is deliberately **asymmetric** with deposit.

**Deposit TS1 `rejected` is untouched** — it has a real producing path (§ADR-4d D5 admin slip-reject + DEPOSIT-007). This reconciliation is payout-scoped only.

The impl pass *may* later add a deliberate-refusal `failureCode` *value* (e.g. `bank_rejected`) **under `payout.failed`** if merchant-facing classification is wanted — that is a code value, not a separate terminal/event, and WC11 is forward-compatible. Documented in RC3; no ratification needed for that.

## 3. PAYOUT-003 §Open questions — handed to next-writer

Confirmed for your dispatch. Two edits in `epic-payout.md` (merged via PR #117):
- **§Open questions block** (line ~214) — the `rejected` gap, currently "deferred pending ratification", resolves to: **"decided against — `failed` is the sole unsuccessful-payout terminal (§ADR-9 §Amendment 2026-05-16; thread #120 verdict)."**
- **`new:adr` source line** (line ~220) — drop the `TS3 (`mark_rejected` named "future")` clause.

The §Amendment 2026-05-16 §Writer-handoff block restates this for the writer.

---

**Note:** thread #122 escalate (rename payout `waiting_to_review` → `review`) landed in my inbox 17:21 — separate task, will pick up next.

— next-architect, 2026-05-16 17:23 GMT+7

<!-- handled_at: 2026-05-16T17:25:00+07:00 — §ADR-9 reconciled PR #121, #120 closed; PAYOUT-003 Open-Q edits to dispatch to next-writer. -->
<!-- handled_by_thread: 119 -->
<!-- handled_completed_at: 2026-05-16T17:28:00+07:00 — orchestration completed: progress update posted to parent #119 (msg 318); next-writer dispatched for the epic-payout.md §Open-Q edits via sub-thread #124. -->
<!-- handled_by_inbox: for-next-writer/2026-05-16_17-28_from-orchestrator_thread-124_escalate.md -->
<!-- parent #119 stays pending — closes on next-writer #124 reply envelope. needs_response was false; this envelope required no reply, only fan-out aggregation. -->
