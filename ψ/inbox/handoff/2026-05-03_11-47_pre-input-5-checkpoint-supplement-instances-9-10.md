# Handoff to brew-ops — Pre-Input-5 checkpoint SUPPLEMENT: instances #9 + #10 (from §ADR-13 lifecycle)

**From:** `system-architect` (`github.com/kxlahsimx09/mb-next-payment-gateway`)
**To:** `brew-ops`
**Date:** 2026-05-03 GMT+7
**Priority:** P2 — supplement to existing escalation
**Type:** Pre-Input-5 instance count update + pattern-direction expansion
**Supplements:** prior handoff `2026-05-02_18-53_pre-input-5-checkpoint-escalation-instance-7-8.md` (instances #7 + #8 from §ADR-12 lifecycle)
**Expected outcome:** brew-ops merges instances #9 + #10 into the W1 workflow doc update if not already processed; if already processed, treat as "instance count moved 8 → 10; update count in workflow guidance + Step 4 sub-rule example list."

---

## TL;DR

Two more Pre-Input-5 checkpoint instances triggered within **§ADR-13 lifecycle** (2026-05-03), both **caught proactively by user during ratification dialogue** (same shape as instances #7 + #8). Cumulative count: **8 → 10 in 24 hours.**

**Both new instances reinforce the bidirectional discipline named in the original handoff** — past-state ("current does X") + future-state ("Phase-2 will need Y"). No new direction; just additional volume + 1 same-day pattern fire frequency.

---

## Two new instances

### Instance #9 — §ADR-13 D1 wording vague (past-state)

**Pass:** §ADR-13 pass-1 baseline (2026-05-02 19:04 GMT+7)
**Architect claim:** Decision #1 *"every admin write endpoint runs full validation chain inside the request transaction... no async pre-flight gap on any admin write surface"*
**User pushback:** *"C1 ผมอยากให้เช็ค current ก่อนว่ส admin แต่ละเส้นเป็นยังไงมีข้อจำกัดอะไรรึเปล่า"* (re each admin endpoint constraints)
**Verification triggered:** Architect ran Oracle Input 1 sweep on each admin endpoint scattered across §ADR-4*/§ADR-9/§ADR-11/§ADR-12 + verified mobiz patterns via PR #170 (DirectTransfer) + PR #228 (payout admin-cancel) learnings.
**Discovery:** Original "no async pre-flight gap" wording was too absolute — mobiz precedent (PR #170) explicitly distinguishes *"enqueue FIRST, flip status SECOND"* (sync load-bearing) vs *"Telegram outage must not block a legitimate approval"* (async out-of-band). Pass-1 wording was vague at this distinction.
**Outcome:** §ADR-13 pass 1.5 revise — Decision #1 reframed to **3-layer rule** (Layer 1 sync-validate preconditions / Layer 2 sync-execute load-bearing / Layer 3 async out-of-band notifications).

**Pattern shape:** classic past-state framing-precision claim ("admin endpoints constraint shape") made without proactive evidence verification of each endpoint; user catches via "check current" question. **Past-state direction.**

### Instance #10 — §ADR-13 D2 audit_log table existence missed (past-state)

**Pass:** §ADR-13 pass-1 baseline (2026-05-02 19:04 GMT+7) + pass-1.5 revise (continued)
**Architect claim:** Decision #2 (pass-1) *"NO separate `admin_actions` table — premature without driver"*
**User pushback:** (same dialogue as instance #9 — "check current" applied to D2 also)
**Verification triggered:** Architect ran Oracle Input 1 sweep + discovered learning `2026-04-19_payout-admin-cancel-endpoint-put-payoutsidca` (mobiz PR #228) which explicitly says: *"Audit trail: all five state transitions write to `audit_log` with `actor_type='admin'` + admin id. Replayable."*
**Discovery:** `audit_log` table **already exists** in mobiz (not theoretical "premature without driver"). Pass-1 framing was wrong — claimed absence; reality presence.
**Outcome:** §ADR-13 pass 1.5 revise — Decision #2 reframed to **mobiz pattern preservation FULL** = (a) denormalized admin identity + (b) `audit_log` table (existing) + (c) `wallet_change_logs` cross-link.

**Pattern shape:** past-state absence claim ("no admin_actions table exists") without verifying current state; user catches via "check current" question. **Past-state direction (variant — claim of absence rather than claim of behavior).**

---

## Pattern-direction observations

**Original handoff #7 + #8 named two directions:**
- past-state: "current does X" claim without verification
- future-state: "Phase-2 will need Y" speculation without driver

**§ADR-13 added two more past-state instances** (#9 wording-precision + #10 absence-claim). No new direction; just two **sub-shapes of past-state direction:**
1. **Behavioral claim** ("current sync-validates X") — matches instances #1-7
2. **Absence claim** ("no admin_actions table currently") — instance #10 — same class but framed as negation

**Suggestion for W1 workflow update:** when applying Step 4 sub-rule for past-state Pre-Input-5, add example phrasing for absence-claims:

```
Past-state claims include both:
- "current does X" (behavioral) — verify via Input 1 prior-learning citation or Input 5 code-read
- "current does NOT have Y" (absence) — verify same way; absence requires same evidence rigor as presence
```

The absence-claim sub-shape is easy to miss because architect's mental model is "I don't see evidence for Y, so Y must not exist" — but evidence-of-absence ≠ absence-of-evidence. PR #228 had `audit_log` evidence; architect just hadn't run the search.

---

## Cumulative instance table (8 → 10)

| # | Date | ADR | Direction | Sub-shape | Caught via |
|---|------|-----|-----------|-----------|------------|
| 1 | 2026-04-23 | §ADR-4a pass 1 | past-state | behavioral | mid-pass user clarification |
| 2 | 2026-04-24 | §ADR-8 pass 2 | past-state | behavioral | body-size implicit |
| 3 | 2026-04-27 | §ADR-4d | past-state | behavioral | C4 Thunder verification |
| 4 | 2026-04-27 | §ADR-4b | past-state | behavioral | tier-cap layer ambiguity |
| 5 | 2026-04-27 | §ADR-4d | past-state | behavioral | verify-history constraint |
| 6 | 2026-04-29 | §ADR-4c pass 1.5 | past-state | behavioral | "ไม่ clean" pushback |
| 7 | 2026-05-02 | §ADR-12 pass 1 | past-state | behavioral | Settlement caller via PR #235 |
| 8 | 2026-05-02 | §ADR-12 pass 1.5 | future-state | speculation | Phase-2 evidence-check |
| **9** | **2026-05-02** | **§ADR-13 pass 1** | **past-state** | **behavioral (wording-precision)** | **"check current admin endpoints"** |
| **10** | **2026-05-02** | **§ADR-13 pass 1** | **past-state** | **absence-claim** | **"check current admin endpoints" (audit_log presence)** |

**Frequency observation:** instances #7 + #8 + #9 + #10 = 4 instances in 2 calendar days (2026-05-02 → 2026-05-03). Concentrated in multi-flow ADR (§ADR-12) + cross-cutting ADR (§ADR-13) lifecycles. Pattern likely correlates with **broad-scope ADRs requiring generalization claims** — generalization claims need their own evidence verification per the original handoff lesson. Confirmed at instance #9 (admin endpoints = breadth of generalization) + instance #10 (audit table absence = breadth of negative claim).

---

## No new ask beyond original handoff

Original handoff requested 3 W1 workflow doc updates (Step 4 sub-rule + Anti-pattern + maintenance-pass mode). All apply here unchanged. **Just additional supporting evidence + pattern-volume confirmation.**

If brew-ops has not yet processed original handoff: merge supplement into the same workflow doc update; cite cumulative count "10 instances" not "8".

If brew-ops has already processed: treat as count update (8 → 10) + add absence-claim sub-shape note to past-state framing.

---

## References

**Triggering retros + learnings:**
- `ψ/memory/retrospectives/2026-05/03/11.09_w1-refine-adr-13-admin-api-pass-15-16-2-ratified.md` — instances #9 + #10 captured + Pre-Input-5 expansion section.
- `learning_2026-05-03_w1-refine-pass-15-pass-16-pass-2-adr-13-a` — pattern observations.

**Evidence learnings cited (for instance #10 verification):**
- `2026-04-19_payout-admin-cancel-endpoint-put-payoutsidca` — load-bearing for instance #10 audit_log existence proof.

**Commits:**
- §ADR-13 pass 1 baseline: `b3716d3`
- §ADR-13 pass 1.5 revise: `616208a`
- §ADR-13 pass 1.6+2 ratified: `77fd6c0`

**Original handoff:** `_universal/ψ/inbox/handoff/2026-05-02_18-53_pre-input-5-checkpoint-escalation-instance-7-8.md`

---

## Closing

Fire-and-forget supplement. brew-ops merges as appropriate; system-architect doesn't expect explicit ack.