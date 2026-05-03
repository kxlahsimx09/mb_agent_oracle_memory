---
title: W1 refine pass 2 — §ADR-12 Payment Source-Flow ratified `#decision` (thread #60 
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-12, payment-source-flow, ratified, decision, pass-2, thread-60-closed, user-pushback-instance-3-within-lifecycle, pre-input-5-instance-7-and-8, 9-adrs-ratified-milestone, single-straight-ratification-heuristic-limitation, future-adr-placeholder-as-deferred-pattern]
created: 2026-05-02
source: docs/adr.md@eab4a8a §ADR-12 + thread #60 closed messages 121-122
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine pass 2 — §ADR-12 Payment Source-Flow ratified `#decision` (thread #60 

W1 refine pass 2 — §ADR-12 Payment Source-Flow ratified `#decision` (thread #60 closed across multi-message dialogue with 2 pre-ratification revises).

User ratified all five sub-questions across multi-message dialogue 2026-05-02 GMT+7. **3 user-pushback-as-design-force events within single §ADR-12 lifecycle — new repo record.**

Lifecycle journey:
- Pass 1 baseline (15:42): original 4×3 taxonomy + admin-driven Phase-1 framing
- Pass 1.5 revise (after Settlement-caller + admin-UI pushbacks): taxonomy 5×4 + idempotency middleware scope clarified to machine-driven only
- Pass 1.6 revise (after Phase-2 evidence-check pushback): Decision #2 → Option B parity-only; Phase-2 auto-recurring relegated to §Deferred questions
- Pass 2 ratification: all 5 sub-questions ratified

Ratification quotes:
- C1 ok แล้ว — 5×4 taxonomy
- C2 ok — Option B parity-only
- C3 ok — Pullout single dispatcher (drift-closure-as-decision instance #4)
- C4 ok — Direct-Transfer sync-validate (coordination-rule-as-architectural-invariant instance #3)
- C5 ok — per-flow + machine-driven middleware scope

§ADR-12 body 92 lines unchanged from pass 1.6 (pass 2 = pure marker-strip + status-promotion).

ARCHITECTURE-DECISION PHASE MILESTONE: 9 ADRs ratified #decision covering deposit + payout core architecture:
- Substrate-shaped: §ADR-4a/4b/4c/4d (lane-specific) + §ADR-9 (callback) + §ADR-10 (wallet)
- Surface-shaped: §ADR-11 (client-API idempotency) + §ADR-12 (source-flow taxonomy + ownership)
- Cross-cutting: §ADR-1/2/3/5/6/7/8

Substrate-decision phase + most surface-decision phase substantially complete. Remaining gap: Admin-API surface ADR (last remaining major architectural gap; medium scope; may fold as §ADR-2a subsection per earlier preference).

PATTERNS CONFIRMED DURABLE ACROSS FULL SESSION ARC:

1. Drift-closure-as-decision — 4 instances (§ADR-10 D4 / §ADR-9 D2 / §ADR-11 D1+D5 / §ADR-12 D3). Pattern qualifies as durable.

2. Coordination-rule-as-architectural-invariant — 3 instances (§ADR-10 D5 / §ADR-11 D5 / §ADR-12 D4). Pattern qualifies as durable.

3. Phase-1/Phase-2 staging — 4 instances (§ADR-2 / §ADR-9 / §ADR-10 / §ADR-11). NOT applied in §ADR-12 D2 (Option B parity-only chosen). Pattern usage: only when driver evidence exists; not blindly applied.

4. Single-straight-ratification — 2 instances (§ADR-10 / §ADR-11). NOT applied in §ADR-12 (3 user-pushback events; 2 revise passes). Heuristic limitation surfaced: broad-scope multi-flow ADRs (≥3 flows) need additional 6th enabling condition "scope is cross-cutting (≤2 flows)".

5. User-pushback-as-design-force — 4 instances (§ADR-4c / §ADR-9 cost / §ADR-9 log / §ADR-12 ×3-within-lifecycle). §ADR-12 contributed 3 instances within single ratification dialogue — new repo record.

6. Pre-Input-5 checkpoint expanded — instance #7 (past-state claim wrong: Settlement caller via PR #235) + instance #8 (future-state speculation: Phase-2 auto-recurring without driver). Both directions of "claim without verification" now under same discipline. Lesson: verify before claiming, regardless of direction.

7. Future-ADR-placeholder-as-deferred-question — first instance §ADR-12 §Deferred (auto-recurring Settlement → §ADR-13 Settlement Scheduling placeholder + driver shape). Pattern shape: when speculative future emerges without driver, name placeholder ADR + driver in §Deferred; less architectural debt than committing Phase-2 staging.

8. Architecture-vs-design discipline — held through 3 revises despite scope pressure. Body grew 89 → 92 → 92 lines (small growth despite 2 substantive revises).

LESSON RECORDED — multi-flow ADR project-less-ratify-more pattern: when scoping a multi-flow ADR (4+ flows × 5 decisions = 20 architectural points), project less; ratify more. Defer speculative future to placeholder §Deferred questions rather than committing Phase-2 staging without driver. Especially applicable to broad-scope surface ADRs that span multiple distinct flows.

Threads closed: #60 (closing-message message_id 122 with full ratification arc + pattern observations + architecture-decision phase milestone). Threads opened: none. Commit: eab4a8a. PR #10 (open, not merged).

Trace chain: 85892602 (§ADR-12 pass-1) → this pass (§ADR-12 pass-2 ratified). Cross-ADR producer/consumer/substrate/client-API/source-flow chain extends to 9 links: f9c519ad → 541c6fdd → c327e4d9 → e003baff → b304445f → c7380258 → 5d7a99b1 → 85892602 → this pass (§ADR-4c → §ADR-9 → §ADR-10 → §ADR-11 → §ADR-12).

Open thread inventory in territory after this pass: only #45 (fleet-control, claude-last-pending; no architect action). Zero in-territory active threads.

Today's session arc spans 3 calendar days: 8 W1 passes — §ADR-9 baseline + §ADR-9 ratified + §ADR-10 baseline + §ADR-10 ratified + §ADR-11 baseline + §ADR-11 ratified + §ADR-12 baseline + §ADR-12 ratified (this pass). 4 ratified ADRs + 4 ADRs spanning 3 calendar days.

Next-pass candidate: Admin-API surface ADR (90-120 min; last remaining major architectural gap; may fold as §ADR-2a subsection). After Admin-API: sibling cross-cut amendment maintenance pass (small) + brew-ops handoff documenting 8 patterns surfaced across full session arc.

---
*Added via Oracle Learn*
