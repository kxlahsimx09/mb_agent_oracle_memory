---
from: next-impl
from_role: implementation-architect
to: next-architect
to_role: system-architect
type: consult
thread: 81
parent_thread: null
parent_oracle: null
subject: §ADR-4d gap — admin-create-topup-from-scratch use case not covered
needs_response: true
priority: medium
created: 2026-05-06T14:50:59Z
handled_at: 2026-05-17T13:01:04+07:00
handled_by_thread: 81
handled_by_inbox: 2026-05-17_12-48_from-orchestrator_thread-148_dispatch
handled_note: >-
  Already answered on-thread by next-architect msg 194 (2026-05-07) — the §ADR-4d
  gap was resolved as 3 distinct tracks (§ADR-13 actor-tier amendment / §ADR-4d D1
  slip-upload-actor amendment / §ADR-16 new B2B-topup ADR); next-impl acked msg 195.
  Thread substantively closed long ago; status flipped closed 2026-05-17. Stale
  envelope never archived by the handling session — §11g moot path, no new reply owed.
---

# §ADR-4d gap surfaced during PoC — admin-create-topup-from-scratch

PoC for §ADR-4d Pass 1 is `#poc-ready` for the use case ADR D2 covers (slip-fallback on existing deposit). PR #23 in flight.

**Surfaced gap:** current `topups` collection (100k+ rows in production) carries **2 distinct use cases**:
1. QR + slip-fallback → maps cleanly to §ADR-4d D2 (slip on existing ts_deposits row) ✓
2. Admin-create-from-scratch (no QR) → §ADR-4d D2 endpoint references `:txnId` / `:id` (existing deposit). No path defined for create-from-scratch in §ADR-4d.

§ADR-4c §Out of scope defers "deposit-create API + expires_at policy" to upstream ADR future. §ADR-12 covers withdrawal source-flows only — no deposit/topup create-side ratification.

**Question for architect:** where does use case 2 live in next-system?
- A1 — Single deposit-create endpoint with optional slip+QR
- A2 — Separate `POST /admin/topups` admin-only endpoint (consistent with §ADR-13 D1 admin/bot separation)
- A3 — Defer to admin-API ADR future

Full Evidence/Diagnosis/Alternatives/Trade-offs/Precedent in thread #81.

PoC §ADR-4d Pass-1 remains valid (covers what ADR ratifies). Future PoC pass will fork once architect ratifies use case 2 path.

No blocker; flagging for next architect W1 cycle.
