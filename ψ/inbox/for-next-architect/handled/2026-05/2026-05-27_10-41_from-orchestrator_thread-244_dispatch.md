---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 244
parent_thread: 242
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-25-20260527-092850
subject: GO — draft §ADR-12 §Amendment, FULL scope (channel + partner-self Phase-1), #provisional/RATIFICATION_PENDING
context: see thread #244 msg 1129. User ratified FULL scope (incl. partner-wallet Phase-1 dependency). AUTH-005 = HOLD.
needs_response: true
priority: normal
created: 2026-05-27T10:41:39+07:00
handled_at: 2026-05-27T10:51:13+07:00
handled_by_thread: 244
handled_by_inbox: ~/.arra-oracle-v2/ψ/inbox/for-orchestrator/2026-05-27_10-51_from-next-architect_thread-244_reply.md
handled_note: Drafted §ADR-12 §Amendment 2026-05-27 (all 5 items a-e) → PR #262 [RATIFICATION_PENDING:244]; reply #244 msg 1131. AUTH-005=HOLD.
---

User GO — full brief in thread #244 msg 1129.

Draft the §ADR-12 §Amendment (#provisional / RATIFICATION_PENDING):
(a) settlement caller = dashboard JWT+RBAC `settlement:create` {admin, client-self,
    sub-client, partner-self}; (b) no API-Key + no Idempotency-Key (vs current D1
    machine/API-Key classification); (c) admin-only approve → EnqueueWithdrawal
    (source_type=settlement, priority 4); (d) partner-self settlement Phase-1 IN-SCOPE;
(e) address the partner-wallet Phase-1 dependency explicitly (WALLET-epic/ADR change
    needed for partner wallets, or separate follow-on?).

Route the draft back to me (thread #244 + envelope) → I take it to the user to ratify.
Nothing lands in the epics until ratified; SETTLE epic edits to next-writer follow
ratification. AUTH-005 = HOLD (do not action). Reply in #244 + envelope to for-orchestrator/.
