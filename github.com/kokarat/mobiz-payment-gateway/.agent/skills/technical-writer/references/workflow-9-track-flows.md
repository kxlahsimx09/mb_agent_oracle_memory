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

```bash
# Extract every // impl: pointer from every flow doc.
grep -rEn '// impl:\s*([^@[:space:]]+)@([a-f0-9]{7,12})' docs/flows/*.md \
  | awk -F: -v OFS='|' '{
      match($0, /\/\/ impl:\s*[^@[:space:]]+@[a-f0-9]+/)
      # emit one line per (flow_path, line_in_doc, target_path, target_line_or_none, target_short)
      # format left as an exercise — use your language of choice
    }'
```

Or equivalent via `rg` / a small script. The output is a map:

```
target_file → [ (flow_doc, flow_step_n, target_line, target_short), ... ]
```

Intersect this map with the list of files touched in the commit range (`git log ${flows_baseline}..HEAD --name-only | sort -u`). The intersection is the **affected pointer set** — the only things W9 needs to verify this pass.

If the intersection is empty: record that in the retro, bump `.baseline` in Step 6, emit one `#flow-track` learning with `#no-drift-found` tag, skip Steps 4–5.

### Step 4 — Per-pointer triage (5–15 min per pointer)

For each (flow, step, target_file, target_line, target_short) in the affected pointer set, open the file at HEAD and at `${flows_baseline}` and compare. Classify into exactly one of:

| Class | Test | Action |
|---|---|---|
| **A — Hash refresh** | Target lines unchanged; file hash `@short` just moved forward. | Update the pointer's `@<short>` to the newest commit that touched the file. No drift. |
| **B — Line relocation** | Target lines moved (insertion or removal above) but same semantics at the same named symbol. | Update `path:<new-line>@<new-short>`. No drift. |
| **C — Step drift** | Target line still exists, same symbol, but behavior changed (e.g., callback payload field renamed, retry count changed, condition flipped). | Insert `[DRIFT]` inline next to the flow step + file `arra_learn` tagged `#drift + #flow-drift + flow:<slug> + step:<n>`. Queue for W4. Leave pointer at old `@<short>` so the drift shows the exact verification gap. |
| **D — Undocumented step** | The commit introduced a new actor-crossing call in the code path the flow covers, but no numbered step claims it. | Insert `[UNDOCUMENTED-STEP:<threadId>]` in the flow's §Implementation pointers with a one-line description of what the new step does. Open `arra_thread` asking the human whether this is a genuine new step (→ queue W8 revision) or an internal helper (→ ignore for flows, may belong in `current-system.md`). |
| **E — Step unimplemented** | A pointer's target was removed or the symbol no longer exists at all. | Replace the pointer with `[UNIMPLEMENTED]` + file `arra_learn` tagged `#drift + #unimplemented + flow:<slug> + step:<n>`. Queue W4. |
| **F — Strength downgrade** | ≥ 50% of a flow's steps now carry `[DRIFT]` or `[UNIMPLEMENTED]` from this pass **or** the accumulated unresolved backlog. | Downgrade the flow doc header from S1/S2 to S4; add `[RATIFICATION_PENDING:<new-threadId>]` in the header (a fresh ratification thread); file `arra_learn` tagged `#flow-strength-downgrade`; handoff to schedule a W8 revision. Do **not** attempt ratification in this pass — W9 is fast-fix, not re-ratification. |

**Rules:**

- Classes A and B are *fast-fix* and are the vast majority of W9 outcomes on a steady-state repo. Don't over-classify to C when the semantics genuinely didn't change.
- C and E both feed W4 queue; do not attempt to fix the doc text in W9 beyond adding the marker.
- D always opens a thread; never silently add steps to a flow diagram in W9 (that's authoring = W8).
- F is rare and serious; prefer calling W8 revision today over claiming W9 can re-ratify.

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

Insert `[RATIFICATION_PENDING:<threadId>]` in the flow doc header. File `arra_handoff` scheduling the W8 revision pass. Do not attempt to revise the flow body now — W8 will.

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

### Step 8 — Commit + PR (3 min)

Branch: `docs/flow-track-<flows-baseline-short>-<new-short>`.

Commit message:

```
docs(flows): track <flows-baseline-short>..<new-short> — <N flows affected>

- <A> pointer refreshes (hash bumps)
- <B> line relocations
- <C> step drifts queued for W4 (see #drift #flow-drift learnings)
- <D> undocumented-step threads opened
- <E> unimplemented steps queued for W4
- <F> strength-downgrade W8 revisions handed off
- docs/flows/.baseline bumped to <new-short>

No flow spec changes (new steps / ratification) — those go through W8.
No code behavior changes.
```

PR body lists the affected flows, each touched flow's outcome, links every new `arra_learn`, and includes the literal line **"I will not merge this PR. Awaiting human review."**

### Step 9 — Retrospective (3 min)

`rrr` to `~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_flow-track-<short>.md`.

**AI Diary** must cover:

- Commit range; affected flow count; per-class outcome counts (A/B/C/D/E/F).
- Whether the pass was a bootstrap (first W9 run) or a steady-state pass.
- Any flow that reached the 50% step-drift threshold (F) — name it + handoff target date.
- Any thread opened (D or F) — ids.

**Honest Feedback**:

- Was the fast-fix threshold the right line, or did it blur into W8-revision territory?
- Are `// impl:` pointers granular enough to decide A vs B vs C reliably? If you had to guess, the pointer may be too coarse.
- Did the file→flow map produce false positives (files touched but no semantic relationship to the flow step)? If yes, the pointer's line number may be drifting from the real "contract line".

---

## Definition of Done

- [ ] `docs/flows/.baseline` bumped to new HEAD **only if** no deferrals block the bump; otherwise left at prior hash with deferral noted in retro.
- [ ] Every affected `// impl:` pointer is either refreshed (A/B), marked with `[DRIFT]`/`[UNIMPLEMENTED]` (C/E), carries a `[UNDOCUMENTED-STEP:<threadId>]` (D), or belongs to a flow now carrying `[RATIFICATION_PENDING]` (F).
- [ ] Every `[DRIFT]` / `[UNIMPLEMENTED]` has a matching `#drift + #flow-drift` learning with `source: docs/flows/<slug>.md` and per-finding child trace under W9_TRACE.
- [ ] Every `[UNDOCUMENTED-STEP]` and `[RATIFICATION_PENDING]` anchored in this pass has a paired `arra_thread` open in `status="pending"`.
- [ ] One `#flow-track` learning landed per affected flow (or one `#no-drift-found` if the pass was clean).
- [ ] W9 root trace (Step 2b) opened with `queryType="evolution"` + all commits in range. `arra_trace_link` to prior W2/W9 head called (unless bootstrap).
- [ ] Per-finding child traces (Step 5b) for every C/E with `parentTraceId=W9_TRACE`.
- [ ] Cross-repo sibling check (Step 2c) ran: linked to bank-bot W2 trace (+ `#cross-repo-sync` learning), or explicitly recorded no cross-repo signal, or deferred with note. "Forgot to check" is not legal.
- [ ] Step 0 ran to completion: Pass 1 left zero `answered`-status markers in pg-writer territory; Pass 2 returned zero unfiled orphans.
- [ ] **Anchor discipline**: every `arra_thread(...)` in this pass (D and F classes) inserted a paired `[UNDOCUMENTED-STEP:<id>]` or `[RATIFICATION_PENDING:<id>]` marker into the relevant flow doc in the same PR. Orphan thread count = 0.
- [ ] No code files changed. No `docs/current-system.md` changes. No new `docs/flows/<slug>.md` files created (those are W8). Diff is exclusively pointer refreshes + marker insertions + baseline bump + `#drift`/`#flow-track` learnings.
- [ ] Branch pushed; PR opened; **not merged**.
- [ ] Retrospective written with AI Diary + Honest Feedback.
- [ ] `arra_handoff` with PR pointer, W8 revision handoffs (if F), open thread ids.
- [ ] Vault audit clean: `bash $(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/scripts/verify.sh | grep -A 3 frontmatter` shows `✅ no double-wrap` + `✅ every indexed doc has a title:`.

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

---

## Escalation

- **Security-sensitive change** (auth, JWT, RBAC, callbacks, MDR, OTP, signature validation) with drift in a flow that covers it → file `#drift` + CC `security_auditor` via `arra_inbox`. Do not ship the W9 PR's pointer refreshes publicly until `security_auditor` has acknowledged the drift.
- **Financial-behavior change** (wallet ops, fees, settlements, payouts) with drift in covering flow → CC `code_reviewer` on the PR.
- **Strength downgrade (F) on > 2 flows in one pass** → the code has drifted substantially from intent across the portfolio. Halt before Step 6 (do not bump baseline), handoff to human with the three offending flows and the commit range. Human decides whether this is a code regression or an intentional redirection that the flows should be re-ratified around.
- **`[UNDOCUMENTED-STEP]` threads > 3 in one pass** → the code has accumulated undeclared actor-crossings faster than W9 can triage. Handoff to `system_architect` and schedule a coordinated W8 + W9 session instead of filing all threads individually.
- **Bootstrap + first pass finds > 30% drift** → the oldest-pointer baseline is covering a huge historical range. Split the pass: bump `.baseline` to a recent commit, file a `#bootstrap-coverage-gap` learning naming the skipped range, and plan a W8 re-authoring pass for flows whose pointers are > 6 months stale.

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
