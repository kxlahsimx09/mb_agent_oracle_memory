# Workflow 2 — Drift report to architect

> Reference document for the `implementation-architect` agent (`next-impl`).
> Read this file before running the workflow. Do not skim.

This workflow produces a drift report when a PoC execution falsifies an ADR-promised claim (W1 Step 5b) or surfaces a load-bearing case the ADR is silent on (W1 Step 5c). The drift report is what `next-architect` consumes to amend the ADR via `arra_supersede`. **PoC drift is evidence into the next refine pass, not a veto** — ratification is not gated on PoC.

---

## When to run

**Pre-condition:** W1 Step 5b or 5c. Not 5a (PoC bug — fix in Step 4 loop), not 5d (test was implementation-grounded — rewrite test), not 5e (mutation passed — rewrite test).

If a PoC is failing for any of 5a/5d/5e reasons, **do not run W2**; fix in W1 and re-run.

---

## Output (one drift report = three artifacts)

A drift report is **the same artifact viewed two ways** — one set of facts, two retrieval surfaces:

1. **`arra_thread`** to `next-architect` — the discussion surface; carries the full Evidence + Diagnosis + Alternatives + Trade-offs + Scope hint + Precedent body.
2. **`arra_learn`** tagged `#poc-drift #handoff` — the searchable surface; condensed body so retroactive sweeps (W1 Input #6) pick it up by tag.
3. **`[POC_DRIFT:<adr-id>:thread-N]`** marker in `poc/<adr-id>/README.md` — the anchored surface; architect's W1 Step 0 thread sweep picks it up by anchor.

All three land in one act (Step 4 below). Forgetting any one breaks the convergence loop.

---

## The drift report shape (code-review skill chain)

The drift report borrows the 4-dimension review structure from `code-review`:

### §1 Evidence

- **PoC commit hash + path** — exact commit on `mb-next-payment-gateway` and the `poc/<adr-id>/` slice.
- **Failing test** — file + spec name + the assertion that did not hold.
- **Minimal repro** — shell command (or pgTAP function call, or `bun test` invocation) that reproduces the failure on the cited commit.
- **Substrate trace** — the mechanism, not the symptom. Postgres EXPLAIN, pgTAP `diag` output, log lines from the substrate; whatever shows *why* the assertion does not hold.

### §2 Diagnosis

- The exact ADR claim line-anchor (`docs/adr.md §<adr-id> Decision N`).
- A 1-3 sentence statement of *which* claim cannot hold and *what mechanism* prevents it. Mechanism, not opinion.
- For 5c (silent-on-case): name the case explicitly + cite the `#current` learning or integration-test that surfaces it.

### §3 Alternatives

At least **2** amendments to the ADR, each with trade-offs:

| Alternative | Shape | Trade-off |
|---|---|---|
| (i) | What the amendment changes | Cost / complexity / scope / cross-ADR impact |
| (ii) | … | … |

If only one alternative is plausible, say so and explain why — don't pad with strawmen.

### §4 Trade-offs (per alternative axes)

Standard axes from `code-review`: complexity, cost, team familiarity, time-to-market, maintainability, operational burden, security surface. Not every axis applies to every drift; pick the load-bearing 2-3.

### §5 Scope hint

One of:

- **single ADR** — amendment is contained;
- **multiple ADRs** — name the cross-cut (e.g. "amends 4b D5 + 4a D7 + 4c D4");
- **missing ADR** — surface a deferred-design dependency; suggest architect open a new ADR slice;
- **`[REOPEN_ADR:<id>:reason]`** — fundamental flaw; ADR may need rebuild, not amendment.

### §6 Precedent (per parent #69 msg 175 §D — 3-line addition)

```
Precedent: <one of>
  - "novel — first observation by PoC"
  - "<vault-learning-id> — analogue in #current production at <date>"
  - "<integration-test path:LN> — exercised in #current integration suite at <commit>"
  - "<docs/flows/<file>#<section>> — flow doc records the same shape in #current"
```

When a precedent exists, also `arra_supersede` against the prior `#drift` learning (the `#current`-side observation) so the chain closes between (i) ADR claim, (ii) PoC failure, (iii) production-incident class.

When no precedent exists: `Precedent: novel — first observation by PoC`. Architect uses this to gauge how much weight to give the drift in the next refine pass.

---

## The 5 steps

### Step 0 — Confirm the trigger

Re-read the failing test classification (W1 Step 5). If the failure is 5a/5d/5e, **abort** — fix in W1.

### Step 1 — Author the drift report body

Write the body locally (or in a scratch buffer) as plain markdown. Sections §1 through §6 above. Length: 50-150 lines. Longer means I haven't finished diagnosing.

### Step 2 — File the `arra_learn`

```
arra_learn(
  pattern="<title — one line>: <one paragraph summary>\n\n## Evidence\n…\n## Diagnosis\n…\n## Alternatives\n…\n## Trade-offs\n…\n## Scope\n…\n## Precedent\n…",
  concepts=["implementation-architect","repo:mb-next-payment-gateway","next","<subsystem-slug>","poc-drift","handoff","drift"],
  project="github.com/kxlahsimx09/mb-next-payment-gateway",
  source="poc/<adr-id>/<failing-test-path>"
)
```

Title shape: `poc-drift: §ADR-<id> D<N> — <one-line-mechanism>`. Title is the searchable surface; make it specific (mechanism, not symptom).

### Step 3 — Open the `arra_thread`

```
arra_thread(
  title="poc-drift: §ADR-<id> D<N> — <mechanism>",
  message="<full body — same as §1-§6>",
  role="claude"
)
```

Address it to `next-architect`. Cite the `arra_learn` id at the top of the message body so architect can pivot between the two surfaces.

### Step 4 — Anchor the marker + drop the inbox envelope

In `poc/<adr-id>/README.md`, anchor `[POC_DRIFT:<adr-id>:thread-N]` near the offending claim. Then drop a `consult` envelope to architect's inbox so the watcher wakes them:

```
~/.arra-oracle-v2/ψ/inbox/for-next-architect/<UTC>_from-next-impl_thread-<N>_consult.md
```

Frontmatter:

```yaml
from: next-impl
from_role: implementation-architect
to: next-architect
to_role: system-architect
type: consult
thread: <N>
subject: drift on §ADR-<id> D<N> — <one-line-mechanism>
needs_response: true
priority: <p1|p2|p3>
created: <ISO-8601 GMT+7>
```

Body ≤ 30 lines headlining (a) the claim that fails, (b) which alternative I lean toward and why, (c) what blocks PoC progress without a resolution.

**Order matters.** Envelope-first is for *replies*; for new consults, the order is: `arra_learn` → `arra_thread` → marker → envelope. The envelope is last so a crash mid-step leaves me with `arra_learn`-and-thread that architect can still find via search.

### Step 5 — Park the PoC

Anchor `[POC_ACTIVE:<adr-id>]` in PoC README — the slot is held but blocked on architect's amendment. Pick a different ADR to PoC in the meantime; do **not** delete the failing tests (P-001).

When architect's amendment lands (`arra_supersede` against the prior ADR text + `#decision` on the new one), re-validate the PoC against the new claim wording. If green, `arra_learn #poc-ready` and remove the `[POC_DRIFT]` anchor (leave a `## Revision` note in the PoC README citing the closed thread).

---

## Outbox-triple worked example (activation-time inclusion)

The `callback_queue` outbox is touched by **three** atomic RPCs across three ADRs:

| ADR | Decision | Outbox role |
|---|---|---|
| §ADR-4c | D4 | `expire_deposit` inserts an expiry callback row in the same txn as flipping the deposit row. |
| §ADR-4a | D7 | `claim_withdrawal_items` inserts a claim-result callback row in the same txn as the lane flip. |
| §ADR-4b | D5 | `finalize_deposit` inserts a settlement callback row in the same txn as the wallet update. |

A PoC that races all three RPCs against the same `callback_queue` table can falsify any one of them. Drift-report scope is `multiple ADRs — amends 4c D4 + 4a D7 + 4b D5`. **One drift report names all three** — architect picks up the cross-cut from the §5 scope hint and routes the amendment as a 3-way `arra_supersede`.

---

## §6 Precedent — three example shapes

```
Precedent: 2026-04-21_drift-deposit-auto-expire-pending-pointer-accuracy
           — analogue: pointer-accuracy drift observed in #current 2026-04-21
           — supersede chain: prior learning →  this poc-drift learning
```

```
Precedent: integration-tests/test-deposit-collision-dual.sh:L42-67
           — exercised in #current integration suite at commit 212f36c
           — drift surfaces in #next PoC where the same race shape lacks the
             at-most-once flip; integration-test does not catch it because the
             #current implementation accepts the over-credit and a downstream
             reconciliation sweep cleans it up.
```

```
Precedent: novel — first observation by PoC
```

---

## 3-round limit

If architect's first amendment doesn't close the drift, allow **two more** rounds (re-validate → re-drift → architect re-amends → re-validate). After three rounds without convergence, escalate per AGENTS.md §11h:

```
[ESCALATE_TO_HUMAN:thread-<N>:poc-drift-3-round-limit:<adr-id>]
```

Pause the PoC, leave `[POC_DRIFT]` anchored, drop a `notify` envelope to the human's inbox.

---

## Failure modes and recovery

- **Filed `arra_learn` without `#poc-drift`** — retroactive sweep (W1 Input #6) misses it. Re-tag with `arra_learn` (P-001 — don't edit; supersede with the corrected tag set).
- **Anchor `[POC_DRIFT]` without an envelope** — silent stall, same shape as the `next-architect` 2026-05-04 stall. Drop the envelope before walking away.
- **Drift report scope-hint says "single ADR" but cross-cut exists** — architect amends 1 ADR, the other two stay broken, PoC still red. Re-mine cross-cuts in §5 before filing.
- **Filed report without §6 Precedent** — convention violation; architect cannot weight the drift against `#current` reality. Add the field even when the answer is *"novel — first observation by PoC"*.

---

**Created:** 2026-05-04 (GMT+7) — activation per parent thread #69 msg 175 §I + §D. §6 `Precedent` field is the 3-line addition from sub-D §7 + sub-C §2. Outbox-triple worked example seeded at activation per msg 168 §4.
