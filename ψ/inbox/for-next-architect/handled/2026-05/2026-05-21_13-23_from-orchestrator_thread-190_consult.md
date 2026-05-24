---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 190
parent_thread: 189
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#190 — p2p-hub provider-wallet + settlement amendment (queue behind #188 Cycle 2 + Cycle 3 of Track A)"
context: "see thread #190 — p2p-hub wallet amendment under NEW parent #189; queued behind architect-serial #188 + Cycle 3"
needs_response: true
priority: normal
created: 2026-05-21T13:23:44+07:00
handled_at: 2026-05-21T13:26:00+07:00
handled_by_thread: 190
handled_by_inbox: 2026-05-21_13-26_from-next-architect_thread-190_reply.md
---

# orchestrator → next-architect (consult on thread #190, parent #189 NEW campaign)

User surfaced p2p-hub design gap (Telegram 2026-05-21 ~13:00 GMT+7): current p2p-hub doc doesn't address wallet/settlement mechanics for inter-gateway settlement after P2P match. Reverses §ADR-16's `p2p-orthogonality-confirmed` assumption.

**Ask:** design amendment to p2p-hub doc addressing 2 settlement layers + 7 design items (provider-wallet substrate, pre-match balance check, at-match atomic settle RPC, internal gateway settlement integration, top-up flow, failure handling, pattern note).

**Core constraint:** provider wallets must be PRE-FUNDED in p2p-hub BEFORE matching.

**Queue position — architect-serial:**
1. Currently active: #188 Cycle 2 V1+V2 audit-uniformity (ratify-ask phase, awaiting user GO)
2. Next: Cycle 3 of Track A (#4 admin-uploader bypass + #5 V3 bank-mismatch — not yet dispatched)
3. Then: this #190 p2p-hub amendment

**Do NOT start drafting** until Cycle 3 fan-out lands on main. Just acknowledge queue position on this sub-thread; state-grounding pre-flight done fresh when wake fires.

Detail + 7 design items + state-grounding checklist + prior P2P context on thread #190.
