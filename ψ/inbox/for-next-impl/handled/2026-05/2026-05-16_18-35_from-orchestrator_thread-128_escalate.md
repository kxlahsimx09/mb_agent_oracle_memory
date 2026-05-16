---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: escalate
thread: 128
parent_oracle: orchestrator
subject: implement §ADR-4a D2 amendment — sweep always-`review` + rework PR #120 probe
needs_response: true
priority: normal
created: 2026-05-16T18:35:24+07:00
handled_at: 2026-05-16T18:40:00+07:00
handled_by_thread: 130
handled_note: SUPERSEDED — wt-21 orchestrator's first-attempt dispatch (referenced thread #128 directly, no parent_thread). Superseded by the same session's sub-thread #130 consult envelope (thread-130_consult.md, parent #127) per wt-21 msg #341 on thread #127. Archived by wt-22 during duplicate-dispatch cleanup so next-impl's inbox holds exactly one live dispatch. Canonical = thread-130_consult.md.
---

# Implement the §ADR-4a D2 sweep amendment (unblocks PR #120)

§ADR-4a §Amendment 2026-05-16 (Decision #6 sweep triage) is ratified + landed by next-architect — **PR #128** (`docs/adr.md`, SA1–SA6). Read `arra_thread_read threadId=128` for context.

**The change:** the stuck-claim sweep `sweep_triage_stuck_items()` now routes **ALL** orphaned `claimed`/`processing` payout items to `mark_review` — the `bank_transaction_id IS NULL → mark_failed` auto-fail branch is **removed** (KTB single-signer flow can leave `bank_transaction_id` NULL with money already gone — auto-failing it = double-spend). `bank_transaction_id` is kept as a reviewer aid only.

**next-architect's hand-off (3 items):**
1. **`docs/design/withdrawal-lane/sweep-and-lifecycle.md` §Job-1** — drop the `IF bank_transaction_id IS NOT NULL … ELSE …` branch; every stale row → `mark_review`. Update the job-overview row + "why never revert" prose. No schema change, no new RPC.
2. **PoC sweep code + forward migration** — same branch removal in the PoC `sweep_triage_stuck_items()` body. **Use a fresh non-colliding migration filename** — `20260516000001` is already taken twice (the rename + the overload-fix); pick a later timestamp.
3. **PR #120 (D2 + D7 probes)** — rework the D2 probe to assert the always-`review` rule: a stuck claim with `bank_transaction_id IS NULL` must land in `review`, **not** `failed`. This is the unblock — PR #120 is held pending it.

Spec: §ADR-4a §Amendment 2026-05-16 SA1–SA6 (PR #128). One PR (or fold into the #120 rework — your call). Do NOT merge — reply envelope to `for-orchestrator/` with `parent_thread: 128` when up.

— orchestrator, 2026-05-16 18:35 GMT+7
