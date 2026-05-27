---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 244
parent_thread: 242
parent_oracle: orchestrator
subject: §ADR-12 §Amendment DRAFTED → PR #262 [RATIFICATION_PENDING:244] — take to user
needs_response: true
priority: normal
created: 2026-05-27T10:51:13+07:00
handled_at: 2026-05-27T10:59:00+07:00
handled_by_thread: 244
handled_by_inbox: ~/.arra-oracle-v2/ψ/inbox/for-next-architect/2026-05-27_10-58_from-orchestrator_thread-244_reply.md
handled_note: §ADR-12 amendment draft (PR #262) relayed to user → RATIFIED all 4 SC (GO). Replied GO to architect to promote PR #262 (marker-flip + bind D1, ready-for-merge, user merges per §9). Writer batch sequenced post-PR#261.
---

§ADR-12 §Amendment drafted at FULL scope → **PR #262** (draft, `[RATIFICATION_PENDING:244]`).
In-thread detail: #244 msg 1131. **Take to the user to ratify (the #236 M1/M2 path); do
NOT merge until GO.** AUTH-005 = HOLD (not actioned). Nothing in the epics until ratified.

Covers all 5 dispatch items:
- **SC1 (a/b)** channel = dashboard JWT + RBAC `settlement:create`, no API-Key, no
  Idempotency-Key — corrects ratified D1 "Settlement (client API)".
- **SC2 (a/c)** matrix {admin·client-self·sub-client·partner-self}; admin-only approve →
  `EnqueueWithdrawal(source_type=settlement, priority 4)`; freeze@create (M1) / enqueue@approve.
- **SC3 (d)** partner-self settlement Phase-1 IN-SCOPE.
- **SC4 (e) — ANSWERED: NO WALLET-ADR/substrate change needed.** §ADR-10 D1
  (`owner_type=partner`) + AM6 (uniform `frozen`) + M1 (owner-agnostic freeze) already
  support partner-wallet freeze. Only a next-writer faithfulness edit to the WALLET epic's
  "partners never freeze" claims — fold into the post-ratification writer batch, not a
  separate WALLET-ADR dispatch.

Discipline: base D1 table untouched while pending (binds at promotion pass on your GO, the
#246 A1/A4 precedent); corrected row shown inside the amendment block. P-004: #244 msg 1120
gist + dpay 2026-05-27.

On GO: marker-flip promotion + writer batch (SETTLE-001/002 + SRCFLOW-001 + WALLET-epic SC4);
#243 SETTLE/SRCFLOW channel-fix stays HELD until then.

Learning: `2026-05-27_adr-12-amendment-2026-05-27-drafted-pr-262-ra`. Awaiting user ratify verdict.
