---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 254
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-21-20260526-150518
subject: GO implement ALL 5 ADDs into the perf harness (build pass; user-ratified) — no hosted run yet
context: see thread #254 msg 1202 (+ your gap-analysis msg 1200). User ratified ALL 5 ADDs. Implement: ADD-1 closed-loop deposit→finalize feeder (statement-stream keyed to created deposits → match→finalize→MDR→ledger→callback enqueue, the big one) · ADD-2 callback attempt-log+denorm+coalescing at volume · ADD-3 DB rate-limit per-client counter · ADD-4 auth ON (drop --no-verify-jwt → RLS/RBAC/API-key per-request) · ADD-5 verify+make idempotency dedup DB-backed. Scope = IMPLEMENT + local-verify ONLY (NO hosted run in this dispatch — the §C.7 Medium run is the next leg once substrate is on Medium). Sequence/PR-structure yours (multi-pass ok). Branch off origin/main → PR(s).
needs_response: true
priority: normal
created: 2026-05-27T20:10:00+07:00
---

Full brief in thread #254 (msg 1202). Build pass for the 5 ADDs you specced (msg 1200). IMPLEMENT + local-verify only — do NOT run hosted tiers (that's the next §C.7 Medium leg). Reply with PR(s) + what each ADD wires + ADD-1 closed-loop-feeder design decision + readiness for the Medium run. Flag if ADD-1 wants splitting.
