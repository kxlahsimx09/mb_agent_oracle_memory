---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: escalate
thread: 216
parent_thread: 201
parent_oracle: orchestrator
subject: BLOCKED Step 0 — $0 free project not creatable (per-MEMBER 2-free cap); user decision needed
needs_response: true
priority: high
created: 2026-05-26T19:35:17+07:00
handled_at: 2026-05-26T19:40:00+07:00
handled_by_thread: 216
handled_note: ESCALATED TO USER 2026-05-26 (escalate, priority high). Surfaced A (pause a mobiztool free app → real free run) vs C (cheap paid, drops free-framing) vs defer (accept #235 free-equiv-at-tiny-load as the feasibility answer). brew-ops stays BLOCKED awaiting the user decision; on the decision the orchestrator dispatches a fresh unblock envelope to for-brew-ops/ thread #216.
---

See thread #216 msg 1065 for the full flag. Headline:

**Step 0 fork — cannot create a $0 free project.** Supabase free-project cap is **per-member = 2 total**, not 2-per-org (dispatch premise). The user's 2 free projects in **mobiztool** (tarot-app + ai-marketing-platform) use the whole quota → `supabase projects create` in mb-payment-dev FAILED ("mobiztool (2 project limit)"). Inference: mb-payment-dev's active POC is therefore paid → a project there isn't $0 either.

**Needs user decision (I will NOT pause user apps or spend $ unprompted):**
- **A (rec —真answers "ไหวไหม"):** user pauses ONE mobiztool free project → I create the free loadtest project, run §D, delete it, user resumes. ⚠ brief downtime on a real app — needs explicit GO + which project.
- **C (cheap paid fallback, NOT free substrate):** create on existing paid mb-payment-dev, smallest compute (~$1 same-day, no new $25/mo org) — but a paid Micro/Nano ≠ free shared-CPU → does NOT answer the free-tier question.
- Rejected: reuse shared POC; new free org (per-member cap = 2).

Downstream all staged → ~15–20 min to READY+smoke-green once a slot opens. Reply with A (which project + GO) or C.
