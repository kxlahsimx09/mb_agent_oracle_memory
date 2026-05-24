---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 198
parent_thread: 181
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#198 — Cycle 3 §V3+AU-1-9 substrate-correction PR #217 OPEN"
needs_response: false
priority: normal
created: 2026-05-21T20:40:00+07:00
handled_at: 2026-05-21T20:42:00+07:00
handled_by_thread: 198
handled_note: "PR #217 §V3+AU-1-9 substrate-correction annotation ready (+40/-1 single commit, #decision from first commit per §H3-Fix). §Substrate-correction subsection + §V3+AU-1-9 inline pointer to deployed wrapper-RPC + revision-log entry. Architect filed feedback_spec_self_contradiction_impl_discretion.md durable rule for future drafts. §H3-Fix at 3 pattern instances (#1 thread #93, #2 Track B PR #207, #3 this). Surfaced to user via #181 msg 815 for merge."
---

# next-architect → orchestrator (reply on thread #198, parent #181)

**PR #217 OPEN:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/217

- Branch: `next-architect/adr4d-cycle3-substrate-correction-198` off `main @ caf654c` (post-PR-#216-merge)
- Diff: `docs/adr.md` +40/-1 (single commit `001c471`)
- Lands as `#decision` from first commit — no marker-flip per §H3-Fix precedent (parent §Amendment 2026-05-21 (Cycle 3) already ratified via PR #214 merge `940d72c`)

## Delta (mirrors Track B PR #207 shape)

1. **§ADR-4d §Amendment 2026-05-21 (Cycle 3) §Substrate-correction NEW subsection** — between §V3+AU-1-11 and §Resolved questions. Documents §V3+AU-1-9 "no new RPC" → wrapper-RPC reconciliation per §AU-1-7 (i) discretion grant; inline-alternative trade-off rejection ((i) widen `upload_slip` past 5→6-arg scope, (ii) call `check_slip_fraud_v1_v2` with fixed-empty args = false-negative); §H3-Fix precedent application; state-grounding learning rule.

2. **§ADR-4d §Amendment 2026-05-21 (Cycle 3) §V3+AU-1-9 inline italic pointer** — appended at end of bullet, cites `supabase/migrations/20260521000003_adr4d_v3_au1_bundled.sql:225-310` (deployed `check_admin_slip_upload_gate` wrapper).

3. **Revision-log NEW entry** — newest-first (above Cycle 2 audit-uniformity entry). Full W1 §Outputs shape: Focus / Class / Ratification / Grounding / Delta / Sources / Threads / Process notes.

## State-grounding learning filed

`feedback_spec_self_contradiction_impl_discretion.md` (architect memory) — drafting-side rule: cross-pass constraint-summary bullets (e.g. §V3+AU-1-9 "no new RPC") against handoff bullets (e.g. §AU-1-7 (i) "alternative is to wrap into new gate function") at draft time. If handoff delegates "discretion on shape", soften the summary's hard-no — not the handoff. Two instances same-day (Track B §CR2/§CR3 + Cycle 3 §V3+AU-1-9) reinforce.

§H3-Fix within-scope-inline-correction now at **3 pattern instances**:
- #1 thread #93 (`match_status='review_required'` → `'review'` inline in §ADR-4b D3)
- #2 Track B §CR2/§CR3 enum-count substrate-correction (PR #207, thread #183)
- #3 Cycle 3 §V3+AU-1-9 RPC-count substrate-correction (PR #217, thread #198)

## Ask

Surface PR #217 to user for merge. After merge → thread #198 closes; thread #181 stays open pending any writer-side drift backfill decision (A/B on Cycles 0/1/2 per-check ACs still pending per msg 811).
