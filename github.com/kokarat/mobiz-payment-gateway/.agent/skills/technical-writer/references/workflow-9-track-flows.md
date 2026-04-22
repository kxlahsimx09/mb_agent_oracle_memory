# Workflow 9 — Track commits against flow map

> Reference document for the `pg-writer-oracle` instance of `technical_writer`.
> Read this file before running the workflow. Do not skim.

W9 is the intent-level counterpart of W2. Where W2 keeps `docs/current-system.md` aligned with code as commits land, W9 keeps the **flow portfolio** under `docs/flows/*.md` aligned with code as commits land. The unit of verification is not the doc section (as in W2) but the `// impl:` pointer per numbered flow step.

Output of a successful W9 pass: every flow doc whose `// impl:` pointers reference a file in the new commit range has been re-verified; stale pointers bumped or relocated; semantic drifts tagged `[DRIFT]` with paired learnings queued for W4; new or removed code surfaces triggering an `arra_thread` or a learning; `docs/flows/.baseline` advanced to the new HEAD; a W9 trace linked into the evolution chain.

W9 **never** edits code, never edits `current-system.md` (that's W2), never authors a new flow (that's W8). W9 refreshes pointers and reports drifts.

---

## When to run this workflow

Run when **all** of the following are true:

- `docs/flows/.baseline` exists (W8 has initialized it at least once, or a prior W9 pass has bumped it; if neither, see §Bootstrap).
- `git log <flows-baseline>..HEAD --stat` shows commits that touched at least one file referenced by any `// impl:` pointer in `docs/flows/`.
- The commit range does **not** exceed the fast-fix thresholds below.

Do **not** run this workflow:

- When `docs/flows/.baseline` is missing **and** no `docs/flows/*.md` files exist — there is nothing to track; W8 must run first to author a flow, which will seed `.baseline` in its Step 9a.
- When the commit range involves files in a brand-new top-level surface that no flow currently references — W2 covers it; W9 has nothing to do.
- As a replacement for a full W8 re-authoring pass when a flow's `Claim strength` needs to downgrade — W9 detects the downgrade and **spawns** a W8 revision; W9 does not re-ratify on its own.
- For commits that only touch target-system code (next-writer's territory).

### Fast-fix thresholds (escalate if exceeded)

- More than **5** flow docs are affected by the commit range → split the pass or escalate.
- More than **50%** of any single flow's numbered steps are affected → escalate to a W8 revision for that flow (the flow as a whole needs re-ratification, not pointer nudges).
- `app.js`-equivalent churn: if `main.go` changed by more than ~50 LOC of behavior **and** it's referenced by any flow → escalate to W2 first, then W9 picks up the relocated pointers.

---

## Preconditions

- [ ] `git status --porcelain` empty.
- [ ] `git fetch origin && git status -sb` shows no `behind` on the branch.
- [ ] `docs/.baseline` exists (not strictly required for W9, but a missing `.baseline` usually indicates W1 hasn't run — flag it).
- [ ] `docs/flows/.baseline` exists **or** at least one `docs/flows/*.md` file exists with `// impl:` pointers (see §Bootstrap for how W9 self-seeds the baseline from pointer commits).
- [ ] Oracle reachable (for Step 0 + drift learnings + thread anchors).
- [ ] At least **25 minutes** of focused time.

---

## Inputs you will read

1. `docs/flows/.baseline` — anchor commit.
2. `git log <flows-baseline>..HEAD --stat` — the commit range.
3. `git show <sha>` + `git show <sha> -- <file>` for each file touched in range.
4. The current versions (HEAD) of touched files — the pointer describes the destination state, not the diff.
5. Every `docs/flows/*.md` — for building the file→flow mapping via `// impl:` grep.
6. Oracle — `arra_search` for prior `#flow-drift`, `#flow-track` on the affected flows; `arra_trace_list` for the prior W9 chain head.
7. The PR description(s) via `gh pr view` — intent signal; code still wins (P-004).

---

## Outputs you will produce

Required:

- Updated `// impl:` pointers in every affected flow doc, each carrying the new `@<short>`.
- `docs/flows/.baseline` bumped to the new HEAD (two-line format, matches `docs/.baseline`).
- At least one `arra_learn` tagged `#flow-track` per affected flow **or** a retro note saying "pass covered the range without finding drift" if no pointer moved.
- W9 root trace (Step 2b) with `queryType="evolution"`, `scope="project"`, all commits in range in `foundCommits`, and `arra_trace_link` to the prior W9/W8 head if one exists.

Conditionally produced:

- One or more `#drift + #flow-drift` learnings per (flow, step) with a `[DRIFT]` or `[UNIMPLEMENTED]` inline marker — fed to W4 queue.
- `arra_thread` + `[UNDOCUMENTED-STEP:<threadId>]` marker for every new actor-crossing code path the range introduced that no flow covers.
- A handoff scheduling a **W8 revision** for any flow whose `Claim strength` downgrades below S2 (e.g., S2 → S4 because > 50% of the steps drifted).
- `#cross-repo-sync` learning when the range involves bank-bot-facing contract code and at least one affected flow crosses into bank-bot territory.

Never produced in this workflow:

- A new flow doc (that's W8).
- Re-ratification of a flow (that's a W8 revision pass).
- Code changes.
- A bumped `docs/.baseline` (that's W1 or W2).

---

## Bootstrap (first-ever W9 run)

If `docs/flows/.baseline` does not exist but at least one `docs/flows/*.md` exists with `// impl:` pointers, W9 self-seeds:

```bash
# Find the OLDEST `@<short>` across all `// impl:` pointers.
# This is the floor — everything older has already been covered by the W8 pass that wrote it.
grep -rhoE '// impl:[^@]+@([a-f0-9]{7,12})' docs/flows/*.md \
  | sed -E 's/.*@([a-f0-9]{7,12}).*/\1/' \
  | while read short; do git log -1 --format='%ct %H' "$short" 2>/dev/null; done \
  | sort -n | head -1 | awk '{print $2}'
# → OLDEST_COMMIT

ISO_DATE=$(TZ=Asia/Bangkok date -Iseconds)
cat > docs/flows/.baseline <<EOF
flows-baseline: ${OLDEST_COMMIT}
last-verified-at: ${ISO_DATE}
EOF
```

Rationale: the oldest `// impl:` hash is the earliest commit *any* flow pointer has been verified at. Scanning `OLDEST_COMMIT..HEAD` over-covers (some pointers were written later and don't need re-verification), but the per-pointer comparison in Step 4 handles that — a pointer whose `@<short>` is newer than the commit that touched its file is already fresh and contributes no drift.

Note this in the retro as "bootstrap pass" so the next operator knows this baseline wasn't a normal W9 bump.

---

## Steps

### Step 0 — Resolve answered threads in territory (blocking, 3–10 min)

Run `references/workflow-thread-resolve.md` (Pass 1 + Pass 2). Pay special attention to `[AWAITING_THREAD:<id>]` anchored inside `docs/flows/*.md` — those are typically questions from prior W8/W9 passes that may resolve items in today's drift queue. `[UNDOCUMENTED-STEP:<threadId>]` markers (W9-specific, see Step 5d below) are also surfaced by this pass.

**Gate:** Step 1 does not start until Pass 1 = 0 remaining answered markers and Pass 2 = 0 unfiled orphans. On a daily-cron schedule, skipping Step 0 ages zombie threads by 24h per cycle — same exposure as W2.

### Step 0.5 — Consume sibling cross-repo-sync learnings (2 min, added 2026-04-22 — Gap 1 root-cause fix)

Before scanning mobiz commits at Step 2, read any `#cross-repo-sync` learnings the sibling repo (bank-bot) filed since the last W9 baseline. These are the producer-side breadcrumbs that bot-writer's W2 leaves when their fix touches a file cited in a mobiz flow doc — without this consumption step they sit unread, which is exactly how the 2026-04-20 `2026-04-19_cross-repo-sync-pr-84-bank-bot-3359d08-is-the.md` incident drifted 2 days against `docs/flows/withdrawal-queue-single-bot-transfer.md`.

```
# Baseline date anchors the "since" window
LAST_VERIFIED=$(awk '/last-verified-at:/{print $2}' docs/flows/.baseline)

# Fetch recent sibling cross-repo-sync learnings
arra_search(
  query="#cross-repo-sync",
  project="github.com/kokarat/bank-bot",
  type="learning",
  limit=50
)
# Filter results client-side: keep where frontmatter `created:` >= $LAST_VERIFIED
```

For each learning that survives the filter:

1. **Read the body.** What bot-side file, contract, or flow did it describe?
2. **Grep mobiz flow docs** for the mentioned file or shared-contract concept: `grep -ln "<bot-file-or-concept>" docs/flows/*.md`.
3. **If any mobiz flow cites the changed bot surface** → add that flow to this pass's affected-flows list (the same list Step 3 builds from mobiz commits). Treat it as a drift candidate: the flow doc likely still describes pre-fix bot behavior.
4. **If no mobiz flow cites it** → informational only; no action.

**DoD:** either this step produced a non-empty consumed list (noted in retro), or the retro explicitly records "no fresh bot-side cross-repo-sync learnings since last baseline". "Forgot to check" is not an option.

**Why this step exists.** Before 2026-04-22, `#cross-repo-sync` learnings were producer-only — bot-writer filed them at commit time (16 existed in vault by 2026-04-22) but no mobiz-side touch point read them. The originating incident (`2026-04-19_cross-repo-sync-pr-84-bank-bot-3359d08-is-the.md`) was filed with full content at bot-commit time, sat unconsumed until the 2026-04-22 session audit caught it. Closes the **consumer gap** from handoff `ψ/inbox/handoff/2026-04-22_12-57_brew-ops_workflow-gaps-memory-drift-session-2026-04-22.md` §Gap 1 incident #2.

### Step 1 — Grounding (3 min)

```
arra_search query="flow-track flow-drift technical-writer" type=all limit=10
arra_trace_list query="flow track-commit" queryType="evolution" limit=5
```

Look for: prior `#flow-drift` still open on the affected flows; the last W9 chain head; any handoff from W8 revision work that expected a W9 follow-up.

If Oracle is unreachable, note it in the retro and continue.

### Step 2 — Define the commit range (2 min)

```
flows_baseline=$(awk -F': *' '/^flows-baseline/{print $2}' docs/flows/.baseline)
git log ${flows_baseline}..HEAD --oneline --stat
```

Reject the fast path (escalate, see §Fast-fix thresholds) if:

- More than 5 flow docs are affected (computed after Step 3, but you can estimate from touched-file count + flow density).
- `main.go` / router had > 50 LOC behavior change.
- A new top-level service directory appeared (`services/<new>/`) referenced by any flow.

### Step 2b — Open the W9 trace + chain to prior (1 min)

Each W9 pass is a follow-up on the most recent W1 baseline, prior W9 pass, or prior W8 revision for this project. It belongs in the **same horizontal evolution chain** that W2 uses for `current-system.md` — the chain is cross-concern (code-level *and* intent-level), representing the project's doc evolution over time.

```
arra_trace(
  query="track-flows — <flows-baseline-short>..<new-short> (<N> commits)",
  queryType="evolution",
  scope="project",
  project="github.com/kokarat/mobiz-payment-gateway",
  foundCommits=[ ...each commit in the range as { hash, shortHash, date, message } ]
)
# store returned trace_id as W9_TRACE

arra_trace_list(project="github.com/kokarat/mobiz-payment-gateway",
                queryType=["project","evolution"], depth=0, limit=5)
# pick the most recent entry — that's the chain head (probably a W2 or prior W9)
arra_trace_link(prevTraceId="<head>", nextTraceId=W9_TRACE)
```

If no prior project/evolution trace exists (bootstrap only), skip `arra_trace_link` and note it in the retro.

### Step 2c — Cross-repo sibling link (1–2 min, conditional)

Same discipline as W2 Step 2c. When the commit range touches a shared-contract file (callback shape, signature helper, OTP endpoint, BOT_SECRET handshake) **and** at least one affected flow crosses into bank-bot territory, look up the most recent bank-bot W2 trace within 24h and link:

```
arra_trace_list(project="github.com/kokarat/bank-bot",
                queryType=["project","evolution"], depth=0, limit=5)
# 24h window; older siblings = older concern
arra_trace_link(prevTraceId="<bank-bot sibling>", nextTraceId=W9_TRACE)
```

File `arra_learn` tagged `#cross-repo-sync + #flow-track` naming both traces + the shared concept. If no matching bank-bot trace exists, defer (bank-bot's next W2 will back-link).

### Step 3 — Build the file → flow map (5 min)

**The stable anchor is the backtick-wrapped `` `<path>[:<line>[-<range>]]@<shorthash>` `` token** inside a flow doc's `## Implementation pointers` section. W8 authors optionally annotate steps with ``​`// impl: <description>`​`` comments, but the `// impl:` annotation is not the extraction anchor — it is free-form prose, appears on some lines and not others (sub-points and shared annotations are common), and has been observed on both sides of the pointer (before and after, with or without the `·` separator). Anchoring extraction on `// impl:` will miss real pointers. Anchor on the pointer token itself.

```bash
# Canonical pointer extractor — scoped to § Implementation pointers only.
# Output: one line per pointer token, pipe-delimited: flow_doc|path_with_optional_line|shorthash
for flow in docs/flows/*.md; do
  awk '
    /^## Implementation pointers/ { in_section = 1; next }
    /^## /                         { in_section = 0 }
    in_section                     { print }
  ' "$flow" \
  | grep -oE '`[^@`]+@[a-f0-9]{7,12}`' \
  | sed -E 's/^`//; s/`$//' \
  | awk -F '@' -v flow="$flow" -v OFS='|' '{print flow, $1, $2}'
done
```

This scans only the `## Implementation pointers` section (stopping at the next `## ` heading), so inline `@<hash>` citations in §Purpose / §Actors / §Preconditions prose are excluded — those are anchored references but not W9 verification targets. The extractor is portable BSD-awk + GNU-grep + sed; no gawk-only features.

Each output line parses as `(flow_doc, path_with_optional_line, shorthash)`. Derive `target_file` by stripping `:<line>[-<range>]`:

```bash
# Given: "routes/bot.go:50@76326c0" → target_file="routes/bot.go", target_line="50", target_short="76326c0"
# Use the derived target_file for the commit-range intersection; keep target_line for Step 4 A-vs-B.
```

The output is a map:

```
target_file → [ (flow_doc, target_path_with_line, target_short), ... ]
```

Intersect this map with the list of files touched in the commit range (`git log ${flows_baseline}..HEAD --name-only | sort -u`). The intersection is the **affected pointer set** — the only things W9 needs to verify this pass.

**Regex self-test (mandatory before trusting an empty intersection).** If the extractor returns zero pointer rows on a portfolio where `docs/flows/*.md` is non-empty, the regex has regressed (or authoring drifted to a new format). Do **not** conclude "no drift" — emit a `#workflow-bug + #w9-extractor-regression` learning instead and halt the pass for human review.

```bash
pointer_count=$(for flow in docs/flows/*.md; do
  awk '/^## Implementation pointers/{f=1;next} /^## /{f=0} f' "$flow" \
    | grep -oE '`[^@`]+@[a-f0-9]{7,12}`'
done | wc -l | tr -d ' ')
flow_count=$(ls docs/flows/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$flow_count" -gt 0 ] && [ "$pointer_count" = "0" ]; then
  echo "FAIL: 0 pointers extracted across $flow_count flow docs — regex regression"
  exit 1
fi
```

If the intersection is empty (pointer count > 0 but no touched file maps to any pointer's target): record that in the retro, bump `.baseline` in Step 6, emit one `#flow-track` learning with `#no-drift-found` tag, skip Steps 4–5.

### Step 4 — Per-pointer triage (5–15 min per pointer)

For each (flow, step, target_file, target_line, target_short) in the affected pointer set, open the file at HEAD and at `${flows_baseline}` and compare. Classify into exactly one of:

| Class | Test | Action |
|---|---|---|
| **A — Hash refresh** | The file was touched somewhere in the range, but **the specific line the pointer targets did not shift** and the named symbol at that line is semantically unchanged. Only `@<short>` moves forward. | Update the pointer's `@<short>` to the newest commit that touched the file. No drift. |
| **B — Line relocation** | **The pointer's target line number shifted** (lines inserted/removed above) but the named symbol at the new line has the same semantics. | Update `path:<new-line>@<new-short>`. No drift. |
| **C — Step drift** | Target line still exists, same symbol, but **behavior changed** (e.g., callback payload field renamed, retry count changed, condition flipped). | Insert `[DRIFT]` inline next to the flow step + file `arra_learn` tagged `#drift + #flow-drift + flow:<slug> + step:<n>`. Queue for W4. Leave pointer at old `@<short>` so the drift shows the exact verification gap. |
| **D — Undocumented step** | The commit introduced a new actor-crossing call **inside code territory an existing flow's pointer set already covers** — i.e., the new call sits near or between numbered steps in that flow's diagram. The flow now has a step gap. | Insert `[UNDOCUMENTED-STEP:<threadId>]` in the flow's §Implementation pointers with a one-line description of what the new call does. Open `arra_thread` asking the human: genuine new step (→ queue W8 revision) or internal helper (→ ignore for flows, may belong in `current-system.md`). |
| **E — Step unimplemented** | A pointer's target was removed or the symbol no longer exists at all. | Replace the pointer with `[UNIMPLEMENTED]` + file `arra_learn` tagged `#drift + #unimplemented + flow:<slug> + step:<n>`. Queue W4. |
| **F — Strength downgrade** | ≥ 50% of a flow's steps now carry `[DRIFT]` or `[UNIMPLEMENTED]` from this pass **or** the accumulated unresolved backlog. | Downgrade the flow doc header from S1/S2 to S4; add `[RATIFICATION_PENDING:<new-threadId>]` in the header (a fresh ratification thread); file `arra_learn` tagged `#flow-strength-downgrade`; handoff to schedule a W8 revision. Do **not** attempt ratification in this pass — W9 is fast-fix, not re-ratification. |

**Rules:**

- Classes A and B are *fast-fix* and are the vast majority of W9 outcomes on a steady-state repo. Don't over-classify to C when the semantics genuinely didn't change.
- **A vs B decision tool**: "did the *specific* line my pointer points to get displaced?" If lines were inserted *above* the pointer's target line and pushed it to a new line number → **B**. If lines were inserted *elsewhere* in the file (below the pointer's target, or in another function entirely) and the pointer's line number is still correct → **A**. `@<short>` bumps in both cases; the line number only bumps in B.
- C and E both feed W4 queue; do not attempt to fix the doc text in W9 beyond adding the marker.
- D always opens a thread; never silently add steps to a flow diagram in W9 (that's authoring = W8).
- **D vs "uncovered surface"**: D applies **only** when the new actor-crossing sits inside code territory an existing flow's pointer set already covers (near or between numbered steps). If the commit introduces a brand-new endpoint, service, or code path that **no** current flow covers, it is **not** D — it is an **uncovered surface**. For uncovered surfaces, do not open a thread; instead file an `arra_learn` tagged `#w8-handoff + #uncovered-surface + flow:<proposed-slug>` naming the new code + suggesting a W8 authoring pass. The next W8 consumer picks it up. W9 never authors flows, and class D is specifically about *gaps within existing flow territory*, not *greenfield territory*.
- F is rare and serious; prefer calling W8 revision today over claiming W9 can re-ratify.

### Step 4b — Section-level marker reconciliation (5 min)

Step 4's classifier targets *pointer-level* drift (Class A/B for hash/line shifts, C/E for behavior/symbol). But threads also live as **section-level prose markers** in §Purpose, §Actors, §Preconditions, §Error paths, and §Postconditions — `[AWAITING_THREAD:<id>]` / `[RATIFICATION_PENDING:<id>]` annotations tied to drift-or-decision threads.

When the W9 pass's commit range contains a fix that closes one of those threads, the **section-level markers must be swept in the same pass** — not deferred to "the next W9 sweep" or to a "small follow-up PR" that easily gets forgotten. See learning `2026-04-21_workflow-bug-orphan-marker-thread-16-driftb` for a real-world case where the deferral rule produced 2 days of orphan markers in a load-bearing flow doc (`bank-bot/docs/flows/ktb-single-transfer-withdrawal.md`, 4 markers stranded across §Purpose / §Error paths / §Postconditions while line 133's `// impl:` pointer correctly recorded `[DRIFT-N RESOLVED]`).

For each flow doc touched in this pass:

```bash
grep -nE '\[(AWAITING_THREAD|RATIFICATION_PENDING):[0-9]+\]' docs/flows/<slug>.md
```

For each marker found:

1. Look up the thread id via `arra_threads(status="closed")` + `arra_threads(status="answered")`.
2. **If status = `pending` or absent from the closed/answered lists**: leave the marker. That's the intended state — the thread is still open.
3. **If status = `closed` AND a commit in this W9 pass's range cites the fix** (commit message references the thread / drift / `// impl:` pointer in the same flow doc references the same fix commit hash):
   - Strip the bracket marker text. Replace inline with `[DRIFT-N RESOLVED via <short-sha>]` matching the existing convention from §Implementation pointers.
   - **Update prose tense as needed (P-004)**: if surrounding text says "this status is currently lost", change to "this status was lost prior to `<short-sha>`". Don't pretend the bug never existed (P-001), but don't lie about current state either (P-004). Past-tense + commit citation strikes the balance.
4. **If status = `closed` / `answered` but no fix commit in this pass's range**: file `#orphan-marker + #flow-drift` learning + route per `workflow-thread-resolve.md` dispatch table. Do not strip on faith — the fix might live in a different repo (cross-repo case) or might never have happened (close-without-fix anti-pattern).
5. **If status = `answered`** (human replied): open the thread inline, classify the answer per `workflow-thread-resolve.md`, and act accordingly. May trigger doc rewrite (handoff to W8 if section-level) or a `[DRIFT-N RESOLVED]` annotation if the answer is a fix-citation.

**Cross-repo coverage**: per the marker-ownership convention from W8 ratifications (e.g., thread #21 Q4 — bank-bot's KTB doc is the bot-owned anchor for `[AWAITING_THREAD:15]` / `[AWAITING_THREAD:16]`), a marker may live in **this repo's** flow doc but the closing fix may land in a **different repo**. Step 4b sweeps both because the doc owner is the only agent that reaches its own doc — pg-writer's W9 sweep cannot reach bank-bot's KTB doc and vice versa.

**Why this lives in Step 4b, not Step 0**: Step 0 (`workflow-thread-resolve.md` Pass 1) is the entry-time grep that catches markers in docs the agent intends to touch. Step 4b is the exit-time grep that catches markers in docs this pass's commit range *fixed*. The two are complementary — Step 0 prevents zombie threads from blocking forward progress; Step 4b prevents in-range fixes from leaving stranded markers behind.

### Step 5 — Apply actions per class (10–30 min)

Apply the per-class action recorded in Step 4. Practical notes:

**Step 5a — A/B pointer refresh (batch).** Edit the flow doc's §Implementation pointers section in one pass per flow. Keep the edits minimal; don't restructure the section.

**Step 5b — C/E drift markers + learnings.** For each `[DRIFT]` / `[UNIMPLEMENTED]`:

```
arra_learn(
  pattern="Flow `<slug>` step <n> drift: <one-line>. Code is now at <path:line@new-short>; flow claim was <path:line@old-short>. <What specifically changed>.",
  concepts=["technical-writer", "repo:mobiz-payment-gateway", "current", "drift", "flow-drift", "flow:<slug>", "step:<n>"],
  source="docs/flows/<slug>.md",
  project="github.com/kokarat/mobiz-payment-gateway"
)
```

Also open a per-finding child trace under W9_TRACE (`parentTraceId=W9_TRACE`) with `queryType="pattern"`, `foundFiles` listing the changed source file + the flow doc, `foundCommits` listing the commit that introduced the drift. Mirrors W1's per-finding child-trace discipline.

**Step 5c — D undocumented step.** Open the thread:

```
arra_thread(
  title="flow:<slug> — undocumented step at <path:line@short>",
  message="While running W9 over commits <range> I noticed the code at <path:line>
           now contains an actor-crossing call that no numbered step in this flow
           covers. Context: <2–3 lines describing what the new call does>.
           Question: should this become a new step in the flow (→ W8 revision),
           or is it an internal helper that belongs in current-system.md only
           (→ ignore for W9, leave an #undocumented-step-benign learning)?"
)
```

Insert `[UNDOCUMENTED-STEP:<threadId>]` in the flow's §Implementation pointers section with a one-line summary.

**Step 5d — F strength downgrade + W8 revision handoff.**

```
arra_thread(
  title="flow:<slug> — re-ratify after strength downgrade S2 → S4",
  message="Accumulated drift in this flow from commits <range> crossed the 50% step
           threshold. W9 has marked the flow with [RATIFICATION_PENDING] in the
           header and scheduled a W8 revision. Specific drifted steps: <list>.
           Please confirm whether the current code behavior should become the new
           canonical intent (ratify the new state) or whether one or more code
           changes should be reverted (file regression candidate)."
)
```

Insert `[RATIFICATION_PENDING:<threadId>]` in the flow doc header. The W8 revision is triggered on the next W8 Step 0 sweep when the thread is answered — no separate scheduling mechanism is needed. Do not attempt to revise the flow body now; W8 will.

**Step 5e — Cross-repo sync.** If any affected flow is cross-repo, file the `#cross-repo-sync + #flow-track` learning naming both W9 and bank-bot's W2 traces + the shared concept.

### Step 6 — Bump `docs/flows/.baseline` (1 min)

Overwrite the file with the new HEAD:

```bash
NEW_HEAD=$(git rev-parse HEAD)
ISO_DATE=$(TZ=Asia/Bangkok date -Iseconds)
cat > docs/flows/.baseline <<EOF
flows-baseline: ${NEW_HEAD}
last-verified-at: ${ISO_DATE}
EOF
```

**Bump only if**:

- Steps 4–5 processed every item in the affected pointer set (no deferrals except for items already documented as C/D/E/F with a marker — those are "processed, queued" and do not block a bump).
- No escalation-to-W1-or-W8 was triggered.

Otherwise leave `.baseline` at the prior hash and note the deferral in the retro.

### Step 7 — Log a session learning per affected flow (5 min)

For each flow touched in Steps 4–5, file one `arra_learn` summarizing the pass:

```
arra_learn(
  pattern="W9 pass <date>: flow `<slug>` touched by commits <range>. Outcome: <A: N refreshed, B: M relocated, C: K drifted, D: J undocumented-step, E: L unimplemented, F: none> | note: <free-form, 1-2 sentences>.",
  concepts=["technical-writer", "repo:mobiz-payment-gateway", "current", "flow-track", "flow:<slug>"],
  source="docs/flows/<slug>.md",
  project="github.com/kokarat/mobiz-payment-gateway"
)
```

If the whole pass produced zero affected flows, file **one** pass-level learning tagged `#flow-track + #no-drift-found` with the commit range and a note that the scan was clean.

### Step 7b — Vault audit hard gate (mandatory pre-commit, 1 min)

W9 writes `arra_learn` at up to **five** call sites per pass — Step 5b (C/E drift markers), Step 5d (F strength downgrade), Step 5e (cross-repo sync), §4 note (uncovered-surface handoff), Step 7 (per-flow session summary or `#no-drift-found`). Every single one carries a `project` field susceptible to the same recurring `<` typo pattern that hit W8 on 2026-04-18 (mobiz `kokarat/bank-bot<` literal `<` in directory name) and 2026-04-19 (bot-side `github.com/kokarat/bank-bot<` in the bot W8 first pass). See `learning_2026-04-19_recurring-pattern-stray-character-appears-in` for the pattern writeup.

Make it a hard gate — run before the Step 8 commit, not after as a retro-time afterthought:

```bash
VAULT=$(ghq list -p kxlahsimx09/mb_agent_oracle_memory)
bash $VAULT/scripts/verify.sh | tee /tmp/w9-verify.txt
grep -E "(✅ no double-wrap|✅ every indexed doc has a title:)" /tmp/w9-verify.txt || {
  echo "FAIL: verify.sh frontmatter checks did not pass — fix before Step 8"
  exit 1
}
```

**Acceptance:** both `✅ no double-wrap` and `✅ every indexed doc has a title:` lines appear. If either is missing, one of this pass's `arra_learn` calls produced a corrupt frontmatter — the typical offender is a stray `<` or `>` in the `project` field that bled through from a template or prompt example. Fix at the source (re-run the offending `arra_learn` with corrected inputs, then `arra_supersede` the corrupt row per P-001), then re-run the gate. Do not proceed to Step 8 until both checks pass.

The cost of skipping this gate is asymmetric: catching a typo here is a 1-minute re-run of `arra_learn`. Catching it post-commit (verify.sh as DoD checkbox only) means the corrupt row is already indexed and must be superseded instead of prevented — a 5–10 minute P-001-compliant cleanup every time it happens. The recurring-typo learning's root-cause hypothesis (template placeholder bleeding through) suggests this will keep happening until a server-side `project` validator lands on the `arra_learn` MCP tool. Until then, the per-workflow pre-commit gate is the mitigation.

### Step 8 — Commit + PR (3 min new / 4 min amend)

W9 runs parallel to W2 on the daily cron (currently manual — cron infra is a P2 follow-up per the 2026-04-19 brew-ops audit, see Change log). When the cron does land, the same stack-up risk that hit W2 overnight 2026-04-19→20 applies: multiple settled-cycle firings while a previous PR sits unmerged stack fresh PRs against a static `.baseline`. Step 8 is split detect → amend / new — same shape as W2 Step 8.0/8.A/8.B (mb_agent_oracle_memory commit `0357769`), with the `docs/flow-track-` branch prefix that distinguishes W9 PRs from W2's `docs/track-`.

#### 8.0 — Detect open W9 PR (run first)

```bash
existing_pr=$(gh pr list --search "head:docs/flow-track- state:open" --author "@me" \
  --json number,headRefName,title --jq '.[0]')
```

- empty → continue with **8.B** (new PR path).
- non-empty → switch to **8.A** (amend path).

#### 8.A — Amend path (existing W9 PR open)

```bash
branch=$(jq -r .headRefName <<< "$existing_pr")
pr_num=$(jq -r .number <<< "$existing_pr")

git fetch origin
git checkout "$branch"
git merge --no-edit origin/main    # absorb new main commits
# Conflicts in docs/flows/* → resolve manually (rare, single-author docs).
# Conflicts elsewhere → out-of-territory; abort + retro note.
```

Layer the new pointer updates on top with an "extend" subject:

```
docs(flows): extend track to <new-short> (W9 amend; cumulative <orig-baseline>..<new-short>)

Adds <N> commits to PR #<pr_num>. Updated:
- <flow-slug> step <n>: <pointer change summary>

Filed <N> new arra_learn entries (PR cumulative now: N+M).
```

Push + rewrite PR metadata to reflect the **cumulative** range:

```bash
git push origin "$branch"
gh pr edit "$pr_num" \
  --title "docs(flows): track <orig-baseline-short>..<new-short> — <N> flows affected (W9, amended)" \
  --body "<regenerated body — list ALL commits cumulatively, ALL flow updates per class, ALL arra_learn ids; link prior W9 trace and the new one (chain continuation per Step 2b); end with 'I will not merge this PR. Awaiting human review.'>"
```

Skip to Step 9. Do **not** open a second PR.

#### 8.B — New PR path (no existing W9 PR)

Branch: `docs/flow-track-<flows-baseline-short>-<new-short>`.

Commit message — **template varies by class-count fired this pass**:

**Multi-class (≥ 2 non-zero classes):** use the full per-class bullet list for auditability.

```
docs(flows): track <flows-baseline-short>..<new-short> — <N flows affected>

- <A> pointer refreshes (hash bumps)
- <B> line relocations
- <C> step drifts queued for W4 (see #drift #flow-drift learnings)
- <D> undocumented-step threads opened
- <E> unimplemented steps queued for W4
- <F> strength-downgrade W8 revisions handed off
- <U> uncovered-surface handoffs filed (W8 queue)
- docs/flows/.baseline bumped to <new-short>

No flow spec changes (new steps / ratification) — those go through W8.
No code behavior changes.
```

**Single-class (exactly 1 non-zero class):** collapse to a single descriptive line. A list of `0`s next to a lone `1` reads as padding and buries the signal in `git log`.

```
docs(flows): track <flows-baseline-short>..<new-short> — 1 pointer updated (<short human-readable>)

- <flow-slug> step <n>: <path>:<old-line>@<old-short> → <path>:<new-line>@<new-short>
  (class B — <1-line reason the line shifted, e.g., "new endpoint inserted above">)
- docs/flows/.baseline bumped to <new-short>

No flow spec changes, no code behavior changes.
```

**Zero-drift pass** (no affected flows in the range at all — range only touched uncovered territory): single line is enough.

```
docs(flows): track <flows-baseline-short>..<new-short> — no flow pointers affected

Range touched only <brief summary of out-of-flow-territory>. Baseline bumped to <new-short>.
#flow-track #no-drift-found learning filed.
```

PR body always lists the affected flows (or "none — range out of flow territory"), each touched flow's outcome, links every new `arra_learn`, and includes the literal line **"I will not merge this PR. Awaiting human review."**

### Step 9 — Retrospective (3 min)

**Path discipline (load-bearing — see §The ψ/ trap).** Before writing, verify the vault symlink resolves:

```bash
readlink ~/.arra-oracle-v2/ψ | grep -q "mb_agent_oracle_memory/ψ$" \
  || { echo "FAIL: ~/.arra-oracle-v2/ψ does not resolve to the canonical vault — halt"; exit 1; }
```

**Write to:**
```
~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_flow-track-<short>.md
```

**Never to any of these traps:**
- ❌ `ψ/memory/retrospectives/...` — relative path, lands in your current cwd (worktree tree)
- ❌ `./ψ/memory/retrospectives/...` — same
- ❌ `<project-path>/ψ/memory/...` — absolute but wrong root; `project` is the product repo, not the vault
- ❌ `.agent/../ψ/memory/...` — symlink traversal may misresolve through the vault's own project subdir

`rrr` template (AI Diary + Honest Feedback mandatory; the section bullets below are W9-specific):

**AI Diary** must cover:

- Commit range; affected flow count; per-class outcome counts (A/B/C/D/E/F).
- Whether the pass was a bootstrap (first W9 run) or a steady-state pass.
- Any flow that reached the 50% step-drift threshold (F) — name it + handoff target date.
- Any thread opened (D or F) — ids.

**Honest Feedback**:

- Was the fast-fix threshold the right line, or did it blur into W8-revision territory?
- Are `// impl:` pointers granular enough to decide A vs B vs C reliably? If you had to guess, the pointer may be too coarse.
- Did the file→flow map produce false positives (files touched but no semantic relationship to the flow step)? If yes, the pointer's line number may be drifting from the real "contract line".

**After writing, verify no stray landed in the project tree:**

```bash
SLUG="<slug-you-used>"  # e.g., 14.37_flow-track-90425ba-b886cc4
# This MUST return empty — any hit = stray leak, follow recovery in §The ψ/ trap.
find ~/Code/github.com/kokarat/mobiz-payment-gateway \
  -path '*/ψ/memory/*' -name "*${SLUG}*" \
  -not -path "*/.agent/*" 2>/dev/null
# And the canonical location MUST exist:
ls ~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/${SLUG}.md
```

**Recovery if stray found** (do NOT just delete — content may not be in vault yet):
```bash
STRAY="<stray-path-from-find>"
VAULT_DEST=~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/
mkdir -p "$VAULT_DEST"
if [ -f "$VAULT_DEST/$(basename "$STRAY")" ]; then
  diff -q "$STRAY" "$VAULT_DEST/$(basename "$STRAY")" && rm "$STRAY" || echo "differs — merge manually"
else
  mv "$STRAY" "$VAULT_DEST"
fi
(cd $(ghq list -p Soul-Brews-Studio/arra-oracle-v3) && bun run index)
```

---

## The ψ/ trap (why path discipline in Step 9 matters)

`ψ/memory/` looks like a vault-relative path but is not. The **canonical vault** lives at:

```
$(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/ψ
```

surfaced to agents via the symlink `~/.arra-oracle-v2/ψ → <vault>/ψ`. Writes going through that symlink land in the vault correctly.

A **stray `ψ/` directory at the root of this project repo** (`mobiz-payment-gateway/ψ/`) would look identical to a vault path but:

1. **Not indexed by Oracle** — `arra_search` can't find it.
2. **Invisible to other agents** — defeats the "shared memory" design.
3. **May get git-tracked accidentally** — `ψ/` is NOT in this repo's `.gitignore` as of 2026-04-19. Once `git add` catches it, it enters the payment-gateway product repo's permanent history.

Historical incidents:
- **21 files** already committed to `mobiz-payment-gateway` git history from this trap, across three failed cleanup attempts (commits `414f568` / `2965cda` / `da4d13a`).
- **2026-04-19 15:06**: a W2 run wrote its retro to `mobiz-payment-gateway/ψ/memory/retrospectives/2026-04/19/15.06_w2-track-commit-admin-cancel-payout.md` (stray) instead of `~/.arra-oracle-v2/ψ/memory/retrospectives/2026-04/19/15.06_...` (vault). Recovered by manually moving to vault + re-indexing (see `arra_search "ψ-trap-retro-leak"`). The same trap applies to W9 — only W2 was bitten because W9 had not run that day.

Step 9's pre-write symlink check + post-write stray-find is the fix. Both must pass. Retro is not "done" until the stray check returns empty.

---

## Definition of Done

- [ ] `docs/flows/.baseline` bumped to new HEAD **only if** no deferrals block the bump; otherwise left at prior hash with deferral noted in retro.
- [ ] Every affected `// impl:` pointer is either refreshed (A/B), marked with `[DRIFT]`/`[UNIMPLEMENTED]` (C/E), carries a `[UNDOCUMENTED-STEP:<threadId>]` (D), or belongs to a flow now carrying `[RATIFICATION_PENDING]` (F).
- [ ] Every `[DRIFT]` / `[UNIMPLEMENTED]` has a matching `#drift + #flow-drift` learning with `source: docs/flows/<slug>.md` and per-finding child trace under W9_TRACE.
- [ ] Every `[UNDOCUMENTED-STEP]` and `[RATIFICATION_PENDING]` anchored in this pass has a paired `arra_thread` open in `status="pending"`.
- [ ] One `#flow-track` learning landed per affected flow (or one `#no-drift-found` if the pass was clean).
- [ ] Every uncovered surface discovered this pass (new endpoint / service / code path with **no** existing flow coverage — not a class-D step-within-flow) has a `#w8-handoff + #uncovered-surface + flow:<proposed-slug>` learning. Uncovered surfaces do not open threads and do not mutate any existing flow doc; they hand off to a future W8 authoring pass.
- [ ] W9 root trace (Step 2b) opened with `queryType="evolution"` + all commits in range. `arra_trace_link` to prior W2/W9 head called (unless bootstrap).
- [ ] Per-finding child traces (Step 5b) for every C/E with `parentTraceId=W9_TRACE`.
- [ ] Cross-repo sibling check (Step 2c) ran: linked to bank-bot W2 trace (+ `#cross-repo-sync` learning), or explicitly recorded no cross-repo signal, or deferred with note. "Forgot to check" is not legal.
- [ ] Step 0 ran to completion: Pass 1 left zero `answered`-status markers in pg-writer territory; Pass 2 returned zero unfiled orphans.
- [ ] **Anchor discipline**: every `arra_thread(...)` in this pass (D and F classes) inserted a paired `[UNDOCUMENTED-STEP:<id>]` or `[RATIFICATION_PENDING:<id>]` marker into the relevant flow doc in the same PR. Orphan thread count = 0.
- [ ] No code files changed. No `docs/current-system.md` changes. No new `docs/flows/<slug>.md` files created (those are W8). Diff is exclusively pointer refreshes + marker insertions + baseline bump + `#drift`/`#flow-track` learnings.
- [ ] Branch pushed; PR opened; **not merged**.
- [ ] Retrospective written with AI Diary + Honest Feedback.
- [ ] Retro is the state carrier; no separate handoff step. Open thread ids + ratification-pending thread ids are listed in the PR body and anchored in the flow doc(s) via `[AWAITING_THREAD:<id>]` / `[RATIFICATION_PENDING:<id>]` — W8/W9 Step 0 picks them up on resolution.
- [ ] **Vault audit hard gate passed (Step 7b)** — `verify.sh` ran **before** the Step 8 commit (not after, not as retro-time afterthought); both `✅ no double-wrap` and `✅ every indexed doc has a title:` present. Any `arra_learn` call this pass produced (up to 5 sites) that carried a corrupt `project` field was fixed at the source + old row superseded per P-001 before PR opens.
- [ ] **Step 4b ran for every flow doc touched this pass** — every section-level `[AWAITING_THREAD:*]` / `[RATIFICATION_PENDING:*]` marker checked against thread status. Closed-with-in-range-fix markers stripped + tense-corrected (P-001 prose retained, P-004 tense fixed). Closed-without-in-range-fix markers got a `#orphan-marker + #flow-drift` learning routed per `workflow-thread-resolve.md`. Pending markers left intact. Cross-repo case (marker in this repo, fix in another) covered explicitly per the marker-ownership convention.
- [ ] **One open W9 PR per repo:** Step 8.0 ran (`gh pr list --search "head:docs/flow-track- state:open" --author "@me"`). If non-empty → this pass took 8.A (amend); if empty → 8.B (new). At end of pass, count of open `docs/flow-track-*` PRs by `@me` on this repo ≤ 1. Independent of the W2 PR gate (different branch prefix).
- [ ] **Retro path discipline (pre-write):** Step 9 ran the `readlink ~/.arra-oracle-v2/ψ` check; the canonical vault symlink resolved; retro written via the absolute `~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/...` path (NOT a relative `ψ/memory/...` path).
- [ ] **Stray-check passed (post-write):** `find ~/Code/github.com/kokarat/mobiz-payment-gateway -path '*/ψ/memory/*' -name "*<slug>*" -not -path '*/.agent/*'` returned empty. The retro is NOT leaking into the product repo's working tree.

---

## Common pitfalls

- **Classifying A/B as C.** A line number shift or a variable rename is not a semantic drift. If the flow step's claim still holds, it's A or B. Over-classifying inflates the W4 queue and wastes reviewer attention.
- **Classifying C as A.** Worse direction. If the callback payload field was renamed but the flow doc still describes the old name, the flow is lying — `[DRIFT]`. Never silently rewrite the flow text to match new code; that's authoring = W8.
- **Editing the flow body in W9.** W9 edits pointers and markers only. Touching §Purpose, §Actors, §Success criteria, §Error paths, §Postconditions, or the sequence diagram steps turns W9 into W8 without the ratification discipline — leaks spec-level claims without thread coverage.
- **Bumping `.baseline` with deferrals outstanding.** If an undocumented-step thread (D) was opened but the human hasn't answered, the commit range is not fully processed. Leave `.baseline` at prior hash; retro explains why.
- **Scanning only touched files, not also their callers.** A function in `services/` may be called from a controller the flow's step 2 pointer targets. If the function's behavior changed, the controller's behavior changed too — same drift surface. Always expand one level when the touched file is a pure helper with no direct actor-crossing.
- **Reusing `#drift` alone as the tag.** W4's queue filters by `#drift + #repo:mobiz-payment-gateway + #current + #technical-writer`. Flow drifts must additionally carry `#flow-drift + flow:<slug>` so W4 can route them separately from code-level drift (different resolution paths: flow drift may require W8 revision, not just code fix).
- **Forgetting that W9 is read-only against code.** W9 never edits `.go` files. If a drift appears to warrant a code fix, the fix is *outside* W9's scope; the `#drift` learning is its only output.
- **Not chaining W9 passes.** Like W2, W9 forms an evolution chain. A W9 pass that didn't call `arra_trace_link(prev=<head>, next=W9_TRACE)` will fork the chain and lose the narrative. Step 2b's link is mandatory except on bootstrap.
- **`arra_learn(pattern=...)` expects prose, not a pre-wrapped markdown doc.** arra_learn wraps its own `---\ntitle: ...\n---` around whatever you pass as `pattern`. Passing a document that already contains a frontmatter block (e.g. an earlier arra_learn output, or hand-authored markdown starting with `---\ntitle: ...`) produces the nested **double-wrap** bug: filename begins `_title-*`, outer `title: ---`, two frontmatter blocks, `verify.sh` flags it (Step 7b hard gate). W9 fires `arra_learn` at up to 5 call sites per pass (Step 5b drift markers, Step 5d strength downgrade, Step 5e cross-repo sync, §4 uncovered-surface handoff, Step 7 per-flow summary) — each carries the same exposure. A tool-side strip-and-warn guard (`stripFrontmatterWrap` in Soul-Brews-Studio/arra-oracle-v3 `src/tools/learn.ts`, landed in arra-oracle-v3 commit `b816ca0` on `local/all-prs` 2026-04-20) catches it, but keep `pattern` as 1–2 paragraphs of plain prose and rely on the guard only as a safety net. Pass metadata via the separate `concepts`, `source`, and `project` arguments; the first line of `pattern` seeds both the title and the filename slug.

---

## Escalation

- **Security-sensitive change** (auth, JWT, RBAC, callbacks, MDR, OTP, signature validation) with drift in a flow that covers it → file `#drift` + CC `security_auditor` via `arra_inbox`. Do not ship the W9 PR's pointer refreshes publicly until `security_auditor` has acknowledged the drift.
- **Financial-behavior change** (wallet ops, fees, settlements, payouts) with drift in covering flow → CC `code_reviewer` on the PR.
- **Strength downgrade (F) on > 2 flows in one pass** → the code has drifted substantially from intent across the portfolio. Halt before Step 6 (do not bump baseline), handoff to human with the three offending flows and the commit range. Human decides whether this is a code regression or an intentional redirection that the flows should be re-ratified around.
- **`[UNDOCUMENTED-STEP]` threads > 3 in one pass** → the code has accumulated undeclared actor-crossings faster than W9 can triage. Handoff to `system_architect` and schedule a coordinated W8 + W9 session instead of filing all threads individually.
- **Bootstrap + first pass finds > 30% drift** → the oldest-pointer baseline is covering a huge historical range. Split the pass: bump `.baseline` to a recent commit, file a `#bootstrap-coverage-gap` learning naming the skipped range, and plan a W8 re-authoring pass for flows whose pointers are > 6 months stale.

### Memory/search/trace anomalies — escalate to brew-ops (non-blocking)

**Fire-and-forget.** Filing a handoff does NOT block this workflow or wait on brew-ops. Finish your pass normally — brew-ops picks up asynchronously on its next session. No `[AWAITING_...]` anchor, no Step 0 sweep. The handoff file itself is the durable record.

If your pass encounters one of these patterns and cannot resolve it in scope:

| Symptom | Likely cause |
|---|---|
| `arra_search` returned 0 for content you know exists | possible FTS5 / vector / tokenizer drift |
| `arra_learn` succeeded but search can't find the new entry | possible indexer / vector connect race |
| `arra_trace` succeeded but `arra_trace_get` returns missing fields | possible trace tool bug (e.g., 2026-04-21 trace project-corrupt incident) |
| `arra_supersede` says success but old doc still appears un-flagged | possible supersede chain breakage |
| Closed thread leaves `[AWAITING_THREAD:N]` markers stranded across repos | cross-repo orphan — see workflow-5 §13c |
| `verify.sh` fails with new pattern not covered by existing fixes | possible new corruption class |
| Path-typo files (`bank-bot<`, `pure-bot`, etc.) keep recurring | input-validation gap |

Don't try to debug in-pass. File a handoff at:

```
$(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/ψ/inbox/handoff/<YYYY-MM-DD>_<HH-MM>_brew-ops_<topic>.md
```

Format per `arra-oracle-v3/.agent/skills/brew-ops/references/workflow-5-memory-audit.md` §How this workflow gets triggered → §B (Escalated handoff). brew-ops picks up on next fresh wake; **your workflow does not wait.**

If unsure whether to escalate: file a P2 handoff with `expected outcome: investigation only`. brew-ops can downgrade to "no action needed" cheaply; a missed real signal is more expensive.

---

## Relationship to other workflows

- **Before W9**: W8 must have authored at least one flow and seeded `docs/flows/.baseline` in its Step 9a (or this is a bootstrap pass — see §Bootstrap).
- **W9 output feeds W4**: every `[DRIFT]` and `[UNIMPLEMENTED]` goes to W4 the same way `#drift` learnings from W2 do; W4 does not distinguish flow-level from code-level drift at triage time (it triages by class A/B/C), only at resolution time.
- **W9 output spawns W8 revisions**: class F always hands off to W8. Class D may hand off if the human answers "yes this is a real step."
- **W9 runs parallel to W2**: the daily cron runs both. A single commit range can appear in two traces (one W2, one W9); `arra_trace_link` chains them into the same evolution line so `arra_trace_chain` reads cleanly.
- **W9 is not W2**: W2 verifies that `current-system.md` reflects the code's structure; W9 verifies that `flows/*.md` reflects the code's *behavior through actor-crossings*. They can both fire on the same commit and produce complementary diffs.
- **W9 is not W8**: W8 authors + ratifies intent; W9 refreshes pointers and reports. A single W9 pass may produce zero flow-body edits.

---

## Change log for this workflow file

- 2026-04-17 — Initial version. Scoped to `pg-writer-oracle` only (mobiz pilot, matches W8 scope). Daily cron alongside W2. Pointer-level verification unit (not doc-section). Six outcome classes A/B/C/D/E/F with clear action mapping. Fast-fix thresholds: ≤ 5 flows, ≤ 50% per-flow step drift; exceeding either escalates to W8 revision. Global `docs/flows/.baseline` (not per-flow); bootstrap fall-back uses the oldest `// impl:` commit hash across the portfolio. Step 2c cross-repo sibling link mirrors W2's identical step for the bank-bot W2 head. W9 never edits flow bodies, never edits code, never authors new flows. `[UNDOCUMENTED-STEP:<threadId>]` introduced as a new marker alongside the existing `[AWAITING_THREAD]` / `[RATIFICATION_PENDING]` family — Step 0 of future W9/W8 passes will catch it via the same doc-anchored grep in `workflow-thread-resolve.md`.
- 2026-04-17 (later) — **Calibration from first-ever W9 run** (retro `ψ/memory/retrospectives/2026-04/17/23.19_flow-track-349b1e5-90425ba.md`, 1× Class-B pointer refresh). Four concrete spec clarifications:
  - **A vs B decision tool** added to §Rules — "did the *specific* line my pointer points to get displaced?" Insertions above the pointer's line → B; insertions elsewhere in the file → A. `@<short>` bumps in both; line number only bumps in B.
  - **Class D vs uncovered surface** — D applies **only** when the new actor-crossing sits inside territory an existing flow already covers. A brand-new endpoint/service/code path with no flow coverage is **not** D; file `#w8-handoff + #uncovered-surface + flow:<proposed-slug>` learning and hand off to W8 authoring. Step 4 table + §Rules + DoD all updated; live run correctly inferred this but spec was ambiguous.
  - **Step 8 commit-message template** split by class-count: full per-class bullet list for multi-class passes; collapsed single-line form for single-class passes; one-liner for zero-drift passes. Padding `A: 0` next to `B: 1` buries the signal in `git log`.
  - **Fast-fix thresholds unchanged** — retro noted sample size of 2 flows is insufficient to stress-test ≤5-flow / ≤50%-step thresholds. Revisit when the portfolio reaches ~10 flows.
- 2026-04-19 — **Step 3 extractor fix (P1, brew-ops audit).** The prior regex `// impl:\s*([^@[:space:]]+)@([a-f0-9]{7,12})` anchored on the `// impl:` annotation being a *prefix* of the pointer. Observed reality across all 6 flow docs in the portfolio: the pointer is backtick-wrapped `` `<path>[:<line>]@<shorthash>` `` and the `// impl:` annotation, when present, appears **after** it as a separately backtick-wrapped `` `// impl: <description>` `` comment (with a `·` separator). On the real portfolio the old regex returned **0 hits across 6 docs**; the new anchor-on-pointer regex returns **79 hits**. The two successful W9 passes in the retros (23.19 and 14.37) did not use the literal spec regex — they inferred the intersection from a human read of `## Implementation pointers`. The extractor has been rewritten to anchor on the pointer token, scope to the `## Implementation pointers` section only (excludes prose citations in §Purpose / §Actors / §Preconditions which use the same `@<hash>` syntax as anchored citations but are not verification targets), and includes a mandatory regex self-test that halts the pass on a non-empty portfolio that extracts zero pointers — so a future authoring-format drift surfaces as a `#workflow-bug` halt instead of a silent false "no-drift" cron result. P2 items (tag convention `flow:<slug>` vs bare `<slug>`; missing cron infrastructure; W8 Step 5 example format drifted from real docs) are documented in the brew-ops audit learning `2026-04-19_pattern-w9-step3-extractor-regex-fix` for follow-up — not fixed in this pass.
- 2026-04-19 (GMT+7, brew-ops post-W8-calibration sync) — **Step 7b (Vault audit hard gate) added, parallel to W8 Step 9b/9d.** W9 writes `arra_learn` at up to 5 call sites per pass (Step 5b drift markers, Step 5d strength downgrade, Step 5e cross-repo sync, §4 uncovered-surface handoff, Step 7 per-flow summary). Each `project` field is susceptible to the same recurring `<` typo pattern that hit W8 on 2026-04-18 (`kokarat/bank-bot<` literal directory name) and 2026-04-19 (bot-side `github.com/kokarat/bank-bot<` in an arra_learn project field). verify.sh was previously a DoD checkbox only — W8's sibling calibration moved it to a hard pre-commit gate; W9 inherits the same discipline here. Fails the pass if `✅ no double-wrap` or `✅ every indexed doc has a title:` is missing. Cites `learning_2026-04-19_recurring-pattern-stray-character-appears-in` for pattern context. DoD line updated to reference Step 7b explicitly rather than leave verify.sh as an unscheduled check. Design notes / loop-representation / decomposition-asymmetry additions from the W8 sibling sync are **not** mirrored into W9 because W9 doesn't author flows or draw diagrams — only the verify.sh gate applies to both workflows.
- 2026-04-20 (brew-ops, W9 audit cross-cutting sync) — **Three sibling-synced fixes propagated from W2's 2026-04-19→20 evolution into W9** (mobiz + bank-bot identical changes):
  1. **§Common pitfalls: `arra_learn(pattern=...)` prose-only rule added** — W9 fires arra_learn at up to 5 sites per pass (same exposure as W4/W8 which got this rule on 2026-04-19); the bullet was missing here. Tool-side `stripFrontmatterWrap` guard (arra-oracle-v3 `b816ca0`) catches violations, but spec-side prose-only discipline keeps agents from relying on the guard.
  2. **Step 9 path discipline + §The ψ/ trap section added** — port from W2's 2026-04-19 fix after the live retro-leak incident at mobiz/ψ/memory/retrospectives/2026-04/19/15.06_w2-track-commit-admin-cancel-payout.md. Step 9 now mandates pre-write `readlink` check + absolute-path-via-symlink + post-write stray-find + recovery recipe. New §The ψ/ trap section explains the topology + cites historical incidents. DoD adds two lines (pre-write check passed, post-write stray-check empty). W9 had not been bitten by the trap (only W2 was 2026-04-19) but inherits the same discipline preemptively.
  3. **Step 8 split into 8.0 (detect) → 8.A (amend) / 8.B (new), with a new DoD line "one open W9 PR per repo".** Mirrors W2 Step 8.0/8.A/8.B (mb_agent_oracle_memory `0357769`) using the `docs/flow-track-` branch prefix. Independent gate from W2's `docs/track-` PR gate. Important caveat: the daily W9 cron infrastructure does NOT yet exist (P2 follow-up flagged in the 2026-04-19 brew-ops audit, learning `2026-04-19_pattern-w9-step3-extractor-regex-fix`); when it lands, this Step 8 split prevents the same overnight stack-up that hit W2. Until then, manual W9 runs benefit from the same gate when humans run W9 multiple times in a day.
- 2026-04-22 (brew-ops, Gap 1 root-cause fix — incident #2) — **Step 0.5 added: consume sibling cross-repo-sync learnings before Step 2 commit scan.** Fetches bank-bot-filed `#cross-repo-sync` learnings created since `docs/flows/.baseline` last-verified-at; for each, greps mobiz flow docs for the mentioned bot file/contract and adds matches to this pass's affected-flows list. Sibling-synced to bank-bot workflow-9-track-flows.md (symmetric rule, swaps producer/consumer direction). Driven by `2026-04-19_cross-repo-sync-pr-84-bank-bot-3359d08-is-the.md` — filed with complete content at bot-commit time 2026-04-20 but sat unconsumed for 2 days because W9 scanned only mobiz commits. Closes the consumer gap (producer side already filed; no mobiz touch-point read them).
