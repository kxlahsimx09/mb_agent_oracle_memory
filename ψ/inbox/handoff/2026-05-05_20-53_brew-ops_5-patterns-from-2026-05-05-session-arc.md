# Handoff to brew-ops — 5 architectural patterns surfaced during 2026-05-05 system-architect session arc (§ADR-4b + §ADR-4d amendments)

**From:** `system-architect` (`github.com/kxlahsimx09/mb-next-payment-gateway`)
**To:** `brew-ops`
**Date:** 2026-05-05 GMT+7
**Priority:** P3 — workflow doc enhancement; not blocking
**Type:** Pattern documentation for W1 workflow guidance
**Expected outcome:** brew-ops evaluates patterns + decides which to add to W1 workflow doc as named patterns / heuristic updates / brew-ops-side process additions
**Companion to:** prior brew-ops handoff `2026-05-03_11-49_10-patterns-w1-session-arc-2026-04-30-to-2026-05-03.md` (10 patterns from 4-day session arc)

## Context

Single-day session 2026-05-05 GMT+7 ratified 2 ADR amendments to closure:
- §ADR-4b amendment — Bot↔Gateway Statement Push Contract (PR #15, ratified 13.40 via thread #76)
- §ADR-4d amendment — Slip-Bearing Deposit Fraud Detection (V1+V2) (PR #16, ratified 19.45 via thread #77, post-ratification refinement at 20.30)

Architecture-decision phase **substantially complete on deposit lane** — both fraud detection surfaces (statement-side compute primitive + slip-side V1+V2 cascade) ratified.

5 architectural patterns surfaced during this single-day arc that warrant brew-ops review for W1 workflow doc enhancement.

## 5 Patterns

### Pattern 1 — "Deliberate divergence from mobiz current" — **DURABLE RULE (instance #5)**

**Definition:** When porting a design from mobiz current to next-system, default is "port verbatim". But the next-system context (different substrate, different scope, different operational reality) may invalidate the rationale that motivated the current shape. When this happens, divergence is justified — but must be explicit + documented.

**Heuristic:** "Port from mobiz is default. Before porting, ask: does the original rationale for current's shape still apply in next-system context? If yes → port verbatim. If no → diverge explicitly with documented rationale."

**5 cumulative instances:**

| # | Where | What changed | Rationale |
|---|---|---|---|
| 1 | §ADR-4c D10 | mobiz status fields → Postgres view (`effective_status` computed) | Postgres view = cleaner than mobiz field-bloat |
| 2 | §ADR-13 D2 | mobiz per-transition fields → Postgres trigger-based denorm | Trigger handles denorm; less Go boilerplate |
| 3 | §ADR-4b amendment B2 | mobiz count-based check (race-prone) → Postgres advisory lock + RPC | next-system has §ADR-4b D6 admin manual re-match concurrent path; mobiz's "1 bot per account" assumption breaks |
| 4 | §ADR-4b amendment B6 | mobiz MongoDB schemaless → Postgres hybrid (sparse cols + JSONB overflow) | Postgres requires structured schema; hybrid balances |
| 5 | §ADR-4d amendment V2 Layer 1 | mobiz fail-open → next-system fail-closed | greenfield = no legacy class; mobiz's fail-open rationale (legacy data) doesn't apply |

**At 5 instances, pattern is no longer candidate — it's durable architectural rule.**

**Recommended brew-ops actions:**
- (a) Add to W1 workflow doc §"Inputs you will read" or §"How I work (workflows)" as named heuristic
- (b) Consider as system-architect SKILL.md principle (Pattern: "Verify rationale, not just code, when porting from current")
- (c) Add to W1 §Anti-patterns: "Porting verbatim without verifying the rationale applies" = anti-pattern
- (d) Consider as Pre-Input-5 extension: Pre-Input-5 = "verify code claim before crystallizing"; this pattern = "verify rationale before porting decision"

### Pattern 2 — "Architectural separation replaces runtime check" — instance #1 (confirmed durable through application)

**Definition:** When a runtime check inside a shared handler addresses a cross-cutting concern that would naturally belong to endpoint-level separation, prefer the architectural fix.

**Application this session:**

§ADR-4d amendment dropped V3 caller-guard runtime check (mobiz #361 — `if caller user_type ∉ {admin,user} → 403`) in favor of:
- Bot endpoint and admin endpoint = separate routes per §ADR-13 D1 3-layer rule
- Bot endpoint Layer 1 filter: `if deposit.slip_uploaded_at != null → 403`
- Admin endpoint: full slip-bearing approve capability
- Bot cannot structurally reach slip-bearing approve path → V3 runtime check redundant

**Why this is a pattern:**
- Runtime checks accumulate inside shared handlers ("if condition X, do Y")
- Shared handlers grow → bug-class risk grows
- Separating endpoints = separating concerns = no runtime check needed
- §ADR-13 D1 framework supports this naturally

**Recommended brew-ops actions:**
- (a) Add to W1 workflow doc as architectural pattern: "Before adding runtime check inside shared handler, ask: can endpoint separation handle this structurally?"
- (b) Pattern doesn't apply universally; only when concern is cross-cutting + endpoint-level scoping is natural

### Pattern 3 — "Race-case via existing matcher path reuse" — instance #1

**Definition:** When designing race-case handling for state-transition systems, check if an existing ratified path can be reused before extending matcher / handler logic.

**Application this session:**

§ADR-4d amendment C6 race-case (admin reviewing checking deposit when statement arrives mid-review):
- Architect initial proposal: extend linkCheckingDeposit to auto-call finalize_deposit (would require §ADR-4d D5 amendment)
- User counter-proposal: admin button "delegate to auto-match" → UPDATE deposit pending + release statement → matcher Step 1 picks up via existing path
- User's mechanism wins: §ADR-4d D5 invariant preserved (admin retains action ownership); reuses ratified matcher cascade; audit trail explicit (admin reason note)

**Why this is a pattern:**
- Default architect instinct: extend matcher logic for race-case
- Better instinct: check if existing path + admin action handles
- Ratified paths are proven, atomic, idempotent — reuse maximizes safety
- Audit trail is naturally explicit when admin is the trigger

**Recommended brew-ops actions:**
- (a) Pattern observation; not yet workflow-doc-worthy at instance #1
- (b) Watch for instance #2 across other lanes; promote to brew-ops handoff when accumulated

### Pattern 4 — "Within-pass spec expansion via clarifying question" — instance #1

**Definition:** During ratification, user's clarifying question on a port-from-current decision can surface architectural layers that initial spec compressed out. The architect responds by reading current code more carefully + expanding spec to capture full ratified shape.

**Application this session:**

§ADR-4d amendment C2 V2 receiver-mismatch:
- Initial spec: "last-4 + fail-open" (2-layer)
- User clarifying question: "current ก็ fail-open จริงหรอ?"
- Architect verified mobiz code → surfaced 3rd layer (mask-aware position-by-position comparison handling NATID PromptPay middle-4 masks)
- User accepted full port: *"ตามที่แนะนำเลย"*
- Final spec: 3-layer (fail-open + mask-aware + last-4)

**Why this is a pattern:**
- Port-verbatim claims often compress real-world complexity
- User's "is it really like that?" is Pre-Input-5 trigger
- Forcing architect to re-read code surfaces missed layers
- Result: spec quality > initial draft

**Process implication:**
- Pre-Input-5 extends to **port-from-current decisions**, not just direct code claims
- "Verify the rationale + verify the algorithm + verify all branches" before drafting port spec
- Process cost: ~5-10 min per port for thorough code-read; saves a refinement cycle later

**Recommended brew-ops actions:**
- (a) Add to W1 workflow doc §"How I work (workflows)" as Pre-Input-5 extension
- (b) System-architect SKILL.md should note: "When porting helper from current code, read full body + enumerate all branches before drafting port spec"

### Pattern 5 — "Post-ratification within-pass refinement" — instance #1 (NEW within-pass evolution shape)

**Definition:** A small adjustment to a just-ratified amendment, made AFTER ratification but BEFORE merge, triggered by user follow-up question. Distinct from pre-ratification revise (multiple iterations before ratify) and within-pass expansion (during ratify dialogue).

**Application this session:**

§ADR-4d amendment V2 Layer 1 fail-mode:
- Pass-2 ratification at 19.45 → C2 = (a-full) ratified
- User follow-up question at 20.30 about V2 fail-open: "เคสเกิดน้อย แต่ถ้าเกิด ทำไมปล่อยไป?"
- Architect analysis → divergence rationale (greenfield = no legacy class)
- User accepted: "แก้เลย"
- Refinement landed at 20.40 — 1-line code change + 3 paragraphs rationale

**Why this is a NEW shape:**
- Pre-ratification revise: §ADR-12 pass 1.5/1.6 — happens BEFORE ratify, multi-iteration, scope unbounded
- Within-pass expansion (C2 of this amendment): happens DURING ratify dialogue, single iteration, expansion not change
- Post-ratification refinement (this): happens AFTER ratify but BEFORE merge, single small adjustment, change-as-extension

**When appropriate:**
- Adjustment is small (≤10 lines substantive change)
- Consistent with ratified intent (no decision reversal)
- Triggered by user question surfacing corner case
- No re-ratification needed

**Recommended brew-ops actions:**
- (a) Add to W1 workflow doc §"How I work (workflows)" as 3rd within-pass evolution shape
- (b) Distinguish from pre-ratification revise (which DOES require re-ratification) — process clarity for system-architect

## Cumulative pattern instance counts (post-2026-05-05)

```
"Deliberate divergence from mobiz current"             → 5  (DURABLE RULE)
"User-pushback-as-design-force"                        → 21 (continues durable)
"Pre-Input-5 verify-before-claim"                      → 15 (continues durable)
"Architectural separation replaces runtime check"     → 1  (confirmed)
"Race-case via existing matcher path reuse"           → 1
"Within-pass spec expansion via clarifying question"  → 1
"Post-ratification within-pass refinement"           → 1  (NEW shape)
```

## Recommendation

**Highest priority:** Pattern 1 (deliberate divergence from mobiz current) at instance #5 = clear durable rule. Recommend explicit promotion to W1 workflow doc + system-architect SKILL.md.

**Medium priority:** Pattern 4 + Pattern 5 — process clarity for system-architect role; small additions to W1 workflow doc.

**Watch:** Pattern 2 + Pattern 3 — single instance each; promote to handoff when accumulating to instance #2-#3.

## Companion materials

- Today's retros (3 + this refinement = 4 retros total today):
  - `ψ/memory/retrospectives/2026-05/05/14.28_w1-refine-adr-4b-amendment-ratification-pass-2.md`
  - `ψ/memory/retrospectives/2026-05/05/19.36_w1-refine-adr-4d-amendment-baseline.md`
  - `ψ/memory/retrospectives/2026-05/05/20.19_w1-refine-adr-4d-amendment-ratification-pass-2.md`
  - `ψ/memory/retrospectives/2026-05/05/20.53_w1-adr-4d-amendment-v2-fail-closed-refinement.md`

- Today's learnings (5 in Oracle, 2 superseded):
  - `learning_2026-05-05_w1-refine-adr-4b-amendment-baseline-pass-bot` (superseded)
  - `learning_2026-05-05_b2-within-pass-refinement-2026-05-05-adr-4b-a` (preserved)
  - `learning_2026-05-05_w1-refine-adr-4b-amendment-ratification-pass-2` (authoritative)
  - `learning_2026-05-05_w1-refine-adr-4d-amendment-baseline-pass-slip` (superseded)
  - `learning_2026-05-05_w1-refine-adr-4d-amendment-ratification-pass-2` (authoritative)

- Trace chain: 18-link cumulative since §ADR-4c origin (2026-04-29). Today added 4 new traces: §ADR-4b amendment baseline (e4ab88ed) → §ADR-4b amendment ratify (20af7e45) → §ADR-4d amendment baseline (d1b662d7) → §ADR-4d amendment ratify (da9f2e20).

## Background — companion to prior brew-ops handoff

This handoff complements `2026-05-03_11-49_10-patterns-w1-session-arc-2026-04-30-to-2026-05-03.md` (10 patterns from 4-day session arc 2026-04-30 → 2026-05-03). That handoff covered §ADR-9..13 ratification arc; this handoff covers §ADR-4b + §ADR-4d amendment ratification arc (2026-05-05 single day).

If brew-ops processes both together, total pattern count is 15 candidate-or-durable patterns surfaced over recent W1 session arcs. Some likely overlap (e.g., user-pushback-as-design-force is named in both). Net new from this handoff = 4-5 patterns + 1 durable promotion of pattern from prior candidate status.

---

**Awaiting brew-ops review.** No specific deadline; W1 workflow doc enhancement can land at brew-ops convenience.
