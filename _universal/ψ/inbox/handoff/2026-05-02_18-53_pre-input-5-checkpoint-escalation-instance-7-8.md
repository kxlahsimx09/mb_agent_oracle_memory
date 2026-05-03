# Handoff to brew-ops — Pre-Input-5 checkpoint escalation (instance #7 + #8 triggered within §ADR-12 lifecycle)

**From:** `system-architect` (`github.com/kxlahsimx09/mb-next-payment-gateway`)
**To:** `brew-ops`
**Date:** 2026-05-02 GMT+7
**Priority:** P2 — workflow improvement; not blocking current architectural work
**Type:** W1 workflow doc update request + discipline-naming externalization
**Expected outcome:** brew-ops updates `.agent/skills/system-architect/references/workflow-1-refine-adr.md` to make Pre-Input-5 checkpoint explicit + expand scope to cover both past-state + future-state claims; closes the meta-process tracking that has been accumulating in retros.

---

## TL;DR

§ADR-9 pass-1 retro (2026-04-30) projected: *"if next architectural pass surfaces another instance, externalize via brew-ops without further iteration"* — referring to **Pre-Input-5 checkpoint** discipline (verify before claiming).

§ADR-12 lifecycle (2026-05-02) **triggered both an instance #7 + an instance #8** within a single ADR baseline pass. Caught by user-pushback, not self-audit. Pattern is now durable enough for workflow-level naming.

**Ask:** update W1 workflow doc to (a) name the discipline explicitly as Step 4 sub-rule, (b) expand scope to cover both past-state ("current does X") + future-state speculation ("Phase-2 will need Y"), (c) document trigger heuristic for self-audit at evidence-sweep time.

---

## Context — what Pre-Input-5 checkpoint is

W1 workflow has implicit discipline encoded across `Inputs you will read (priority order — cheap to expensive)` + `Read current-system code on every pass` anti-pattern + `Claiming without citing` anti-pattern. The implicit rule:

> Every claim about current-system behavior must trace to either (a) Input 1 prior-learning evidence, or (b) Input 5 code-read with follow-up `arra_learn` to memorialize. Claims without trace = `[PROVISIONAL]` + thread.

Originally tracked across retros as "user-surfaced clarification" / "code-read-first lesson" — count incremented when architect made unverified claim that user caught. By §ADR-9 pass-1 retro (2026-04-30), the count had reached **instance #6** with consistent pattern shape.

**§ADR-9 retro projection (verbatim from `2026-04-30_w1-refine-adr-9-callback-dispatcher-baseline` retro / "What would make the next pass cheaper" item 3):**

> *"Pre-Input-5 checkpoint externalization to brew-ops — instance #7 not triggered this pass; if next pass triggers another instance, externalize without further iteration per pass-1.5 retro recommendation."*

**Trigger fired 2026-05-02 within §ADR-12 lifecycle.**

---

## Two instances triggered in §ADR-12 lifecycle

### Instance #7 — Settlement caller (past-state claim wrong)

**Pass:** §ADR-12 pass-1 baseline (2026-05-02 15:42 GMT+7)
**Architect claim:** *"Settlement | admin (Phase-1) / merchant (Phase-2 trigger) | request-driven"* (Decision #1 taxonomy original 4×3 row)
**User pushback:** *"ในตัว current มีแผนจะทำ client create request ด้วยหรอ"* (re Settlement caller)
**Verification triggered:** Architect ran Oracle Input 1 sweep on "settlement request client merchant create endpoint" → discovered learning `2026-04-19_sub-client-tenant-scoping-pr-235-cb78ef7-2026` (PR #235 cb78ef7 2026-04-20) which proves `SettlementController.CreateSettlement` is callable by **merchant + sub-client + admin** in mobiz current — RBAC-permitted via `RequirePermission(PermCreate("settlement"))`.
**Outcome:** §ADR-12 pass 1.5 revise — taxonomy expanded to 5×4 with caller-mechanism dimension; Settlement split into 2 rows (merchant API + admin UI); both Phase-1, neither Phase-2.

**Pattern shape:** classic "current does X" claim made without evidence; user catches via question. **Past-state direction.**

### Instance #8 — Phase-2 auto-recurring (future-state speculation)

**Pass:** §ADR-12 pass-1.5 revise (Decision #2 reframed) (2026-05-02 GMT+7)
**Architect claim (after pass 1.5 revise):** *"Phase-1 user-triggered; Phase-2 auto-recurring trigger-driven"* (Decision #2 with Phase-2 trigger projected to "first merchant SLA negotiation requiring auto-recurring")
**User pushback:** *"current มีแผนจะทำ auto trigger settlement ไหม"*
**Verification triggered:** Architect ran Oracle Input 1 sweep on "settlement auto trigger schedule cron recurring automatic" + "scheduler.go SettlementController scheduled" → **zero results** matching auto-recurring Settlement; **no learning**, **no roadmap evidence**, **no scheduler code**.
**Outcome:** §ADR-12 pass 1.6 revise — Phase-2 auto-recurring removed from Decision #2; Option B parity-only chosen; auto-recurring relegated to §Deferred questions with future-ADR placeholder (§ADR-13 Settlement Scheduling).

**Pattern shape:** "future will need Y" Phase-2 staging projected without driver evidence; user catches via evidence-check question. **Future-state direction.**

---

## Why escalate now (and not just continue tracking in retros)

1. **§ADR-9 retro committed to externalization on next trigger.** Trigger fired. Honoring the projection.

2. **Pattern shape is now durable across 8 instances.** Tracking in retros is data-collection mode; eight is enough to name + externalize.

3. **Bidirectional discipline emerged (past-state + future-state).** Original discipline framing was "current does X" (past-state implicit). §ADR-12 instance #8 surfaced future-state speculation as same-class violation. Workflow doc needs to capture both directions explicitly.

4. **Process debt accumulates without externalization.** Each new architect (or this same architect in future passes) re-derives the discipline from retros instead of reading workflow doc. Workflow-level naming saves discovery cost.

5. **Cognitive load.** §ADR-12 had 3 user-pushback events in single dialogue (instance #7 + instance #8 + admin-UI-idempotency). Multi-flow ADR scope-pressure compounded the discipline lapse. Future broad-scope ADRs need explicit checkpoint to prevent recurrence.

---

## Specific ask — W1 workflow doc updates

**File:** `kxlahsimx09/mb-next-payment-gateway/.agent/skills/system-architect/references/workflow-1-refine-adr.md`
(lives at central memory `kxlahsimx09/mb_agent_oracle_memory/github.com/kxlahsimx09/mb-next-payment-gateway/.agent/skills/system-architect/references/workflow-1-refine-adr.md`)

### Update 1 — Step 4 sub-rule (proposed location)

Add new sub-rule after Step 4's existing "tag gaps with `[AWAITING_THREAD:?]`" guidance:

```markdown
**Pre-Input-5 checkpoint** — every claim about current-system or future-system
behavior must trace to evidence:

- **Past-state claims** ("mobiz current does X" / "current pattern is Y" /
  "the existing controller handles Z"): trace to (a) Input 1 prior-learning
  evidence with file:line citation, OR (b) Input 5 code-read with follow-up
  `arra_learn` filed; otherwise tag `[PROVISIONAL]` + open thread.

- **Future-state claims** ("Phase-2 will need Y" / "merchant could request Z" /
  "the future ADR will close X"): trace to (a) named driver in business
  context with concrete trigger, OR (b) explicit "no driver currently;
  deferred to future-ADR-placeholder per §Deferred questions". Speculative
  Phase-2 staging without driver = same-class violation as past-state claims
  without evidence.

**Self-audit heuristic at Step 3 evidence-sweep:**

Scan draft baseline body for both past-tense ("does", "is", "currently", "in
mobiz") AND future-tense ("will", "Phase-2", "future trigger", "merchant could")
claims. Each unverified claim either: (a) get evidence + cite inline; (b) get
tagged `[PROVISIONAL]`; (c) get demoted to §Deferred questions with future-ADR
placeholder.

**Trigger pattern:** if user pushback during ratification surfaces an
unverified claim, that's a Pre-Input-5 instance. Track count in retro;
externalize to brew-ops on instance N+1 (currently N=8 has externalized).
```

### Update 2 — `Anti-patterns` section

Add to existing list:

```markdown
- **Speculative future-state staging without driver.** Phase-1/Phase-2 staging
  pattern is durable (5 instances across §ADR-2/9/10/11) but only when Phase-2
  has a named driver. Applying staging blindly to "future could change"
  decisions = same-class violation as "current does X without evidence".
  Pattern: project less, ratify more. Defer speculative future to
  future-ADR-placeholder in §Deferred questions; let it open when concrete
  driver emerges.
```

### Update 3 — `When to run` section

Optional addition for trigger heuristic:

```markdown
- After ≥3 ADR ratifications, run a **maintenance pass** to update earlier
  ADRs' deferred-questions + cross-cut citations referencing the now-ratified
  ADRs. Keeps ADR network coherent. Pattern: ADR-network-coherence-as-
  maintenance-pass (instance #1 documented 2026-05-02 across §ADR-4a/4b/4c/7
  citing §ADR-9/10/11/12).
```

---

## Cumulative instance count (for traceability)

For reference (brew-ops doesn't need to validate; just for context):

| # | Date | ADR | Direction | Caught by | Pattern shape |
|---|------|-----|-----------|-----------|---------------|
| 1 | 2026-04-23 | §ADR-4a pass 1 | past-state | user | architect claimed "bankDailyTxn cross-direction" without read |
| 2 | 2026-04-24 | §ADR-8 pass 2 | past-state | user | architect missed "ADR is too long" body-size implicit claim |
| 3 | 2026-04-27 | §ADR-4d | past-state | user | architect claimed C4 Thunder pattern without verifying current |
| 4 | 2026-04-27 | §ADR-4b | past-state | user | tier-cap layer redundancy ambiguity |
| 5 | 2026-04-27 | §ADR-4d | past-state | user | "verify history must preserve" implicit constraint |
| 6 | 2026-04-29 | §ADR-4c pass 1.5 | past-state | user | "current does opportunistic" without code-read; surfaced via "ไม่ clean" |
| 7 | 2026-05-02 | §ADR-12 pass 1 | past-state | user | Settlement caller (admin-only? — caught via PR #235 evidence) |
| 8 | 2026-05-02 | §ADR-12 pass 1.5 | future-state | user | Phase-2 auto-recurring (no driver — caught via evidence-check) |

**Pattern duration:** 9 calendar days (2026-04-23 → 2026-05-02). **Frequency:** ~1 instance per ADR baseline pass on average. **Fix shape consistent:** in-pass revise (pass 1.5+) or ratification gate.

---

## Suggested follow-up

After workflow doc updated:

1. **File `arra_learn` on brew-ops side** — record workflow doc update + cite this handoff as the trigger. Tag `#brew-ops #workflow-edit #w1 #pre-input-5-checkpoint #pattern-naming`.

2. **Notify system-architect** that workflow doc updated — close this handoff loop.

3. **Optional: add to W1 §Definition of Done** — checkbox "scanned body for past-tense + future-tense claims; each cited or `[PROVISIONAL]`-tagged".

---

## References

**Triggering retros + learnings:**
- `ψ/memory/retrospectives/2026-04/30/17.12_w1-refine-adr-9-callback-dispatcher-baseline.md` — projection of externalize-on-next-trigger
- `ψ/memory/retrospectives/2026-05/02/17.53_w1-refine-adr-12-payment-source-flow-pass-2-ratified.md` — instance #7 + #8 triggered + caught
- `learning_2026-05-02_w1-refine-pass-2-adr-12-payment-source-flow-rat` — pattern observations (full lifecycle context)

**Evidence learnings cited:**
- `2026-04-19_sub-client-tenant-scoping-pr-235-cb78ef7-2026` — load-bearing for instance #7 (Settlement merchant API exists in current mobiz)
- (no learning for instance #8 — that was the "evidence absence" finding; absence = evidence per Sherlock Holmes principle)

**Commits:**
- §ADR-12 pass 1.5 revise: `40e5994` (taxonomy 5×4 + admin UI idempotency scope)
- §ADR-12 pass 1.6 revise: `1fa44df` (Phase-2 → Option B parity-only)
- §ADR-12 pass 2 ratification: `eab4a8a` (thread #60 closed)

**PRs:** [#10](https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/10) (§ADR-12 source-flow) — open

---

## Closing

This handoff is **fire-and-forget** from system-architect side. brew-ops triages, evaluates, and either (a) updates W1 workflow doc per suggestion, (b) refines the discipline naming differently, or (c) closes as "no action — discipline is implicit in existing W1 anti-patterns". Any outcome is acceptable; goal is to close the meta-process tracking loop, not lock in specific wording.

System-architect's next architectural work proceeds on Admin-API surface ADR (last remaining major architectural gap) or pauses for cognitive recovery — independent of this handoff resolution.