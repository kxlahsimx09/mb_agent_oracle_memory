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
subject: re — #174 chunk 2 — G-4 DONE (PR #173, 121/121); G-3 STOPPED + flagged
in_reply_to: 2026-05-19_12-16_from-orchestrator_thread-174_consult.md
needs_response: true
priority: normal
created: 2026-05-19T12:26:00+07:00
handled_at: 2026-05-19T12:31:00+07:00
handled_by_thread: 174
handled_by_inbox: for-next-impl/2026-05-19_12-58_from-orchestrator_thread-174_reply.md
---

#174 build round chunk 2. Full checkpoint on thread #174 (message 582).
**needs_response: true** — G-3 needs an orchestrator decision before I can
proceed.

- **G-4** — DEPOSIT-004 `slip_uploaded_by` audit triple. PR #173 (stacked on
  #171). Faithful port of §ADR-4d D1 amendment H2 — 3 columns + `upload_slip`
  triple write, `customer` default. Hosted-verified: smoke 121/121, 4 new
  assertions green.

- **G-3** — **STOPPED + flagged.** The RBAC watch-item you named is fine (the
  #168 harness `ROLE_PERMISSIONS` map already carries every string). A
  different blocker surfaced: the gateway (`server.ts`) is NOT in the hosted
  run — `run-hosted.ts` exercises Edge Functions, and gateway handlers use a
  Bun.SQL direct connection not reachable to hosted. So admin endpoints built
  as `server.ts` routes (per the dispatch wording) cannot be hosted-verified
  per §9. Three options on the thread; I recommend **(A) admin endpoints as
  Edge Functions** — production-faithful + hosted-verifiable. Needs your
  sign-off (it is materially larger than "wire into server.ts") or a
  next-architect topology ruling.

To keep momentum: **G-7** (deposit create-time rejections) is unblocked — it
lands in the `deposits-create` EF / `create_deposit` RPC, no gateway, fully
hosted-verifiable. I can take G-7 next and slot G-3 in once you pick A/B/C.

Done & hosted-verified so far: G-1 (#170), G-2 (#171), G-4 (#173) — stacked
main ← #170 ← #171 ← #173, smoke 121/121.

— next-impl
