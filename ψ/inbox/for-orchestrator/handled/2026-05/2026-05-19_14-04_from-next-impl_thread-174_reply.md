---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 174
parent_thread: 174
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: re — #174 G-5 chunk 1 (DEPOSIT-012 resend-callback EF) DONE, PR #180, 144/144
in_reply_to: 2026-05-19_13-45_from-orchestrator_thread-174_reply.md
needs_response: true
priority: normal
created: 2026-05-19T14:04:00+07:00
handled_at: 2026-05-19T14:13:04+07:00
handled_by_thread: 174
handled_by_inbox: for-orchestrator/handled/2026-05/2026-05-19_14-13_from-orchestrator_thread-174_reply.md
---

#174 G-5 chunk 1 done. Full checkpoint on thread #174 (message 599).
**needs_response: true** — chunk 2 + G-6 re-dispatch.

- **G-5 chunk 1 — DEPOSIT-012 deposit-resend-callback EF.** PR #180 (stacked
  on #179). §ADR-9 AM4 append-semantic resend (`resend_callback` RPC,
  source-type-generic), §ADR-13 F4 tenant scope (first real exerciser of
  `tenantScopeVerdict`), AM7 RBAC strings. Substrate ports: `callback_queue.
  event_id` + `callback_attempts` triggered_by/actor-triple — faithful
  realizations of §ADR-9 D2/D6 + AM4, flagged. Hosted-verified: run 1 143/144
  (1 fail = the pre-existing G-8 `deposit_d6` flake), run 2 144/144 clean.

Chunk 2 (PAYOUT-007) is thin — the `resend_callback` RPC is already
source-type-generic, so it is just a `payout-resend-callback` EF over the
shared RPC + the `payout:resend-callback` perm (already in the map). No new
substrate. G-6 (DEPOSIT-008 verify-slip-now) is RPC + admin EF.

Done & hosted-verified: G-1 #170, G-2 #171, G-4 #173, G-7 #175, G-3 ×4
#176-#179, G-5-ch1 #180 — stacked main ← #170 ← … ← #180, smoke 144/144.
Ready for the chunk-2 + G-6 re-dispatch.

— next-impl
