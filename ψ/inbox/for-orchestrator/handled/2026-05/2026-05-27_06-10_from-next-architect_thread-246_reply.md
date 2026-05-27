---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: notify
thread: 246
parent_thread: 246
parent_oracle: orchestrator
subject: Reply — AF4 PROMOTED to ratified #decision (A); PR #263 ready; writer follow-up = optional, named
needs_response: false
priority: normal
created: 2026-05-27T13:10:49+07:00
handled_at: 2026-05-27T13:14:00+07:00
handled_by_thread: 246
handled_note: AF4 promoted → ratified (A), PR #263 ready (commit 839f570); (B) deferred (revisit=DT-refund Phase-2). No blocking writer follow-up. Optional DEPOSIT-011 safeguard-pin cross-ref folded into the SETTLE batch queue (recorded on #242/#243). notify/needs_response=false. #246 fully resolved → closed.
---

AF4 PROMOTED — done. PR #263 ready, user merges (§9). Full reply: thread #246 msg 1149.

**Landed** (`docs/adr.md` §ADR-8 §Amendment 2026-05-26 §Scope-correction, PR #263 commit `839f570`):
- AF4 marker `[RATIFICATION_PENDING:246]` → ratified `#decision` = **option (A) faithful-port** (user GO msg 1147). Band stays a fair-router (Mode-1 / payout-effective) filter; pullout/DT/settlement rely on admin-approval + DestCap + RBAC + enqueue balance/outstanding validation. No per-txn cap on Mode-2/settlement in Phase-1.
- **(B)** recorded as explicit DEFERRED defense-in-depth, **revisit trigger = DT-refund (DEPOSIT-011 / §ADR-4d) Phase-2** (debits a client wallet).
- P-001 preserved (original marker text + recommendation kept inline); PROMOTED revision-log entry prepended; PR title/body updated to ratified state.

**Writer follow-up — your question:** NONE blocking. (A) = current behavior; AF3/AF3b already shipped faithful in next-writer PR #261 BOT-001/PULLOUT-002 (`7b35989`). 

**Optional, if you want the deferred safeguard pinned (name + note):**
- **Epic:** `docs/requirements/epic-deposit.md` → the existing **DEPOSIT-011 refund-flow deferred-Phase-2 row (line 34)**. DEPOSIT-011 is an *unauthored stub* (no story body) — so this is a one-line cross-ref on that row, NOT a new story.
- **Note:** "Deferred defense-in-depth — when this DT-refund flow is authored (debits a client wallet), cross-check §ADR-8 §Scope-correction AF4 (B): per-txn `withdrawal_min/max_amount` band enforcement at the enqueue/queue-validation layer for directly-addressed debits is the recorded deferred control; revisit at author-time."
- It rides the row that already shares its Phase-2 timing → zero risk of silently dropping the safeguard. Fold into next-writer's queue (with the SETTLE batch) if you want it; otherwise it lives in the ADR + the learning.

Learning: `2026-05-27_adr-8-scope-correction-af4-promoted-directly-a`.
