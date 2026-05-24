---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: consult-back
thread: 195
parent_thread: 189
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#195 — next-impl pre-flight done, 4 scope unknowns surfaced before impl-execute"
needs_response: true
priority: normal
created: 2026-05-21T17:04:00+07:00
---

# next-impl → orchestrator (consult-back on thread #195, parent #189)

State-grounding pre-flight complete; no code written, no branch created. Posted full detail on thread #195 (msg 794) — summary here:

## What I read

- p2p-hub `main@1323e14` §D body end-to-end (lines 1169-1947). Schema, RPC pseudocode, mobiz-port spec, Q-D5 ops-surfaces all fully pinned.
- mobiz `controllers/TopupController.go @ 55abbea` sections: `CreateTopup` (96-360), `UpdateTopupStatus` (696-774), `processTopupApproval` (777-1188), `processTopupRejection` (1191-1253), `ProcessTopup` (1257-1450). CAS race-guard pattern + admin-approval-then-balance-inc understood. Partner-MDR explicitly skipped per §D5.
- p2p-hub repo state: greenfield substrate-wise. Only `docs/` + `docs-site/`. No `supabase/`, no test harness — README confirms "No code yet".

## 4 scope unknowns (each cascades; flagging before consuming impl budget)

1. **Working-tree placement** — (A) fresh `git worktree add p2p-hub.wt-impl-195 origin/main -b impl/195-substrate-bootstrap` [recommended] vs (B) reuse local clone on stale architect/phase-c branch.
2. **Hosted-Supabase posture** — (A) local-only this turn [recommended] vs (B) user supplies existing hosted project ref vs (C) provision fresh hosted now.
3. **Supporting-table stub scope** — settle_p2p_match needs `matches` + `outbound_messages`; provider_wallets FKs `providers`. None exist. (A) minimal `[STUB]` rows in same PR [recommended] vs (B) drop FK + inline match params vs (C) punt settle_p2p_match + L2 entirely.
4. **Admin-approval endpoint shape** — (A) Supabase Edge Function [recommended] vs (B) Next.js API route in docs-site/ vs (C) PostgREST-direct RPC only.

## Default bundle if no redirect

**1A + 2A + 3A + 4A** → fresh worktree, local-only Supabase, minimal `[STUB]` supporting tables, Edge Function admin-approval. Single PR. Impl-budget estimate ~6-10h substrate + ~2-3h assertions.

## What happened with user

Asked user via AskUserQuestion this session; user canceled (no answer). Consulting back so you can either (i) decide on user's behalf via accumulated context, (ii) relay to user with framing, or (iii) split across turns.

## Standing by

`[AWAITING_CONSULT:thread-195:4-scope-unknowns]` — no worktree spawned, no branch created, no migration drafted. Will resume impl-execute once direction lands.

Full detail on thread #195 msg 794.
