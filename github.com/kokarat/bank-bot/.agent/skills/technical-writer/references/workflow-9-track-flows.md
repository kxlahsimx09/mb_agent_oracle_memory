# Workflow 9 — Track commits against flow map (bank-bot side)

> Reference document for the `technical-writer` instance operating inside `github.com/kokarat/bank-bot`.
> Read this file before running the workflow. Do not skim.

W9 is the intent-level counterpart of W2. Where W2 keeps `docs/current-system.md` aligned with code as commits land, W9 keeps the **flow portfolio** under `docs/flows/*.md` aligned with code as commits land. The unit of verification is not the doc section (as in W2) but the `// impl:` pointer per numbered flow step.

Output of a successful W9 pass: every flow doc whose `// impl:` pointers reference a file in the new commit range has been re-verified; stale pointers bumped or relocated; semantic drifts tagged `[DRIFT]` with paired learnings queued for W4; new or removed code surfaces triggering an `arra_thread` or a learning; `docs/flows/.baseline` advanced to the new HEAD; a W9 trace linked into the evolution chain.

W9 **never** edits code, never edits `current-system.md` (that's W2), never authors a new flow (that's W8). W9 refreshes pointers and reports drifts.

Bot-side W9 differs from the mobiz-side sibling in three ways:

1. **Every bot flow is cross-repo by construction** (per the bot W8 Design notes on decomposition asymmetry). A W9 drift-finding on a bot flow often has implications the mobiz side needs to know about — the reciprocal `#cross-repo-sync + #flow-drift` discipline in Step 5e is mandatory in more cases than on the mobiz side.
2. **The sibling trace lookup direction flips.** Mobiz W9 Step 2c looks for a recent bank-bot W2 trace to chain into. Bot W9 Step 2c looks for a recent **mobiz W2** trace.
3. **Stack + actors differ.** Node.js + Playwright + Cheerio + bank portals vs Go + Fiber + MongoDB. Class D undocumented-step examples are bot-flavored (new Playwright navigations, new OTP endpoints, new scraper selectors) rather than new HTTP handlers.

---

## When to run this workflow

Run when **all** of the following are true:

- `docs/flows/.baseline` exists (W8 has initialized it at least once — the first bot W8 pass on 2026-04-19 seeded it at commit `466d56e`).
- `git log <flows-baseline>..HEAD --stat` shows commits that touched at least one file referenced by any `// impl:` pointer in `docs/flows/`.
- The commit range does **not** exceed the fast-fix thresholds below.

Do **not** run this workflow:

- When `docs/flows/.baseline` is missing **and** no `docs/flows/*.md` files exist — there is nothing to track; W8 must run first to author a flow, which will seed `.baseline` in its Step 9a.
- When the commit range involves files in a brand-new top-level surface that no flow currently references — W2 covers it; W9 has nothing to do.
- As a replacement for a full W8 re-authoring pass when a flow's `Claim strength` needs to downgrade — W9 detects the downgrade and **spawns** a W8 revision; W9 does not re-ratify on its own.
- For commits that only touch code which is not yet covered by any flow doc — that's an uncovered-surface handoff, not a W9 pass.

### Fast-fix thresholds (escalate if exceeded)

- More than **5** flow docs are affected by the commit range → split the pass or escalate. (Bank-bot portfolio as of 2026-04-19 has 1 flow, so this threshold is not close to binding; revisit as the portfolio grows.)
- More than **50%** of any single flow's numbered steps are affected → escalate to a W8 revision for that flow (the flow as a whole needs re-ratification, not pointer nudges).
- `app.js`-equivalent churn: if `app.js` or `core/api.js` changed by more than ~50 LOC of behavior **and** it's referenced by any flow → escalate to W2 first, then W9 picks up the relocated pointers.

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
5. Every `docs/flows/*.md` — for building the file→flow mapping via `// impl:` extraction.
6. Oracle:
   - `arra_search query="flow-track flow-drift technical-writer repo:bank-bot" type=all limit=10` — prior bot-side W9 work.
   - `arra_search query="cross-repo-sync flow:<slug>" type=learning` — mobiz-side breadcrumbs that might predict what the bot side should look for.
   - `arra_trace_list query="flow track-commit" queryType="evolution" limit=5` — the last bot W9 chain head.
7. The PR description(s) via `gh pr view` — intent signal; code still wins (P-004).

---

## Outputs you will produce

Required:

- Updated `// impl:` pointers in every affected flow doc, each carrying the new `@<short>`.
- `docs/flows/.baseline` bumped to the new HEAD (two-line format, matches `docs/.baseline`).
- At least one `arra_learn` tagged `#flow-track + repo:bank-bot` per affected flow **or** a pass-level `#no-drift-found` learning if the scan was clean.
- W9 root trace (Step 2b) with `queryType="evolution"`, `scope="project"`, all commits in range in `foundCommits`, and `arra_trace_link` to the prior W9/W8 head if one exists.

Conditionally produced:

- One or more `#drift + #flow-drift` learnings per (flow, step) with a `[DRIFT]` or `[UNIMPLEMENTED]` inline marker — fed to W4 queue.
- `arra_thread` + `[UNDOCUMENTED-STEP:<threadId>]` marker for every new actor-crossing code path the range introduced that no flow covers at the step-within-flow level.
- A handoff scheduling a **W8 revision** for any flow whose `Claim strength` downgrades below S2.
- `#cross-repo-sync + #flow-drift` learning (Step 5e) **whenever a drift is found in a flow whose boundary crosses into mobiz territory** — which is most bot flows. This is the primary mechanism by which bot-side drift reaches mobiz's W4 queue.

Never produced in this workflow:

- A new flow doc (that's W8).
- Re-ratification of a flow (that's a W8 revision pass).
- Code changes.
- A bumped `docs/.baseline` (that's W1 or W2).

---

## Bootstrap (first-ever W9 run)

If `docs/flows/.baseline` does not exist but at least one `docs/flows/*.md` exists with `// impl:` pointers, W9 self-seeds:

```bash
# Find the OLDEST `@<short>` across all `// impl:` pointers inside the
# `## Implementation pointers` sections. This is the floor — everything older
# has already been covered by the W8 pass that wrote it.
for flow in docs/flows/*.md; do
  awk '/^## Implementation pointers/{f=1;next} /^## /{f=0} f' "$flow" \
    | grep -oE '`[^@`]+@[a-f0-9]{7,12}`'
done | sed -E 's/^`//; s/`$//' | awk -F '@' '{print $2}' \
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

**As of 2026-04-19, bank-bot's `docs/flows/.baseline` already exists** (seeded by the first bot W8 at `466d56e`), so bootstrap is unlikely to apply here. It's documented for resilience — if the file is ever lost (accidental `git clean`, fresh clone predating the seed), bootstrap gives a recovery path.

---

## Steps

### Step 0 — Resolve answered threads in territory (blocking, 3–10 min)

Run `references/workflow-thread-resolve.md` (Pass 1 + Pass 2). Pay special attention to `[AWAITING_THREAD:<id>]` anchored inside `docs/flows/*.md` — those are typically questions from prior W8/W9 passes that may resolve items in today's drift queue. `[UNDOCUMENTED-STEP:<threadId>]` markers (W9-specific, see Step 5c below) are also surfaced by this pass.

**Gate:** Step 1 does not start until Pass 1 = 0 remaining answered markers and Pass 2 = 0 unfiled orphans. On a daily-cron schedule, skipping Step 0 ages zombie threads by 24h per cycle.

### Step 1 — Grounding (3 min)

```
arra_search query="flow-track flow-drift technical-writer repo:bank-bot" type=all limit=10
arra_trace_list query="flow track-commit" queryType="evolution" limit=5
```

Look for: prior `#flow-drift` still open on the affected flows; the last bot W9 chain head; any handoff from bot W8 revision work that expected a W9 follow-up; mobiz-side `#cross-repo-sync + #flow-track` learnings (if recent, they may name flows the bot side should double-check).

If Oracle is unreachable, note it in the retro and continue.

### Step 2 — Define the commit range (2 min)

```bash
flows_baseline=$(awk -F': *' '/^flows-baseline/{print $2}' docs/flows/.baseline)
git log ${flows_baseline}..HEAD --oneline --stat
```

Reject the fast path (escalate, see §Fast-fix thresholds) if:

- More than 5 flow docs are affected (computed after Step 3, but you can estimate from touched-file count + flow density).
- `app.js` or `core/api.js` had > 50 LOC behavior change.
- A new top-level directory appeared (`banks/<new>/`, `integrations/<new>/`, `scheduler/<new>/`) referenced by any flow.

### Step 2b — Open the W9 trace + chain to prior (1 min)

Each bot W9 pass is a follow-up on the most recent W1 baseline, prior W9 pass, or prior W8 revision for this project. It belongs in the **same horizontal evolution chain** that W2 uses for `current-system.md`.

```
arra_trace(
  query="track-flows — <flows-baseline-short>..<new-short> (<N> commits)",
  queryType="evolution",
  scope="project",
  project="github.com/kokarat/bank-bot",
  foundCommits=[ ...each commit in the range as { hash, shortHash, date, message } ]
)
# store returned trace_id as W9_TRACE_BOT

arra_trace_list(project="github.com/kokarat/bank-bot",
                queryType=["project","evolution"], depth=0, limit=5)
# pick the most recent entry — that's the chain head (probably a W2, W8, or prior W9)
arra_trace_link(prevTraceId="<head>", nextTraceId=W9_TRACE_BOT)
```

If no prior project/evolution trace exists (bootstrap only), skip `arra_trace_link` and note it in the retro.

### Step 2c — Cross-repo sibling link (1–2 min, conditional)

When the commit range touches a shared-contract file (any `banks/*/statement.js` that feeds `/bot/bank-statements`, the `BotBackendAPI` HTTP client, the `X-Bot-Secret` handshake, OTP endpoint contracts) **and** at least one affected flow crosses into mobiz territory, look up the most recent **mobiz W2** trace within 24h and link:

```
arra_trace_list(project="github.com/kokarat/mobiz-payment-gateway",
                queryType=["project","evolution"], depth=0, limit=5)
# 24h window; older siblings = older concern
arra_trace_link(prevTraceId="<mobiz sibling>", nextTraceId=W9_TRACE_BOT)
```

File `arra_learn` tagged `#cross-repo-sync + #flow-track + repo:cross` naming both traces + the shared concept. If no matching mobiz trace exists, defer (mobiz's next W2 will back-link).

Direction note: on the mobiz side, W9 Step 2c looks for a **bank-bot W2** trace. Here it's the mirror. The `arra_trace_link` prev/next slot is a linked list — use the intra-repo chain (Step 2b) for the trace's `prev_trace_id`, and capture the cross-repo sibling in the `#cross-repo-sync` learning's body. See bank-bot W8 §Cross-repo-sync discipline for the slot-contention rationale.

### Step 3 — Build the file → flow map (5 min)

**The stable anchor is the backtick-wrapped `` `<path>[:<line>[-<range>]]@<shorthash>` `` token** inside a flow doc's `## Implementation pointers` section. W8 authors optionally annotate steps with ``​`// impl: <description>`​`` comments, but the `// impl:` annotation is not the extraction anchor — it is free-form prose, appears on some lines and not others (sub-points and shared annotations are common), and has been observed on both sides of the pointer. Anchoring extraction on `// impl:` will miss real pointers. Anchor on the pointer token itself.

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

Each output line parses as `(flow_doc, path_with_optional_line, shorthash)`. Derive `target_file` by stripping `:<line>[-<range>]`:

```bash
# Given: "core/api.js:72@abc1234" → target_file="core/api.js", target_line="72", target_short="abc1234"
# Use the derived target_file for the commit-range intersection; keep target_line for Step 4 A-vs-B.
```

Intersect this map with the list of files touched in the commit range (`git log ${flows_baseline}..HEAD --name-only | sort -u`). The intersection is the **affected pointer set**.

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

If the intersection is empty (pointer count > 0 but no touched file maps to any pointer's target): record that in the retro, bump `.baseline` in Step 6, emit one `#flow-track + #no-drift-found` learning with the commit range, skip Steps 4–5.

### Step 4 — Per-pointer triage (5–15 min per pointer)

For each (flow, step, target_file, target_line, target_short) in the affected pointer set, open the file at HEAD and at `${flows_baseline}` and compare. Classify into exactly one of:

| Class | Test | Action |
|---|---|---|
| **A — Hash refresh** | The file was touched somewhere in the range, but **the specific line the pointer targets did not shift** and the named symbol at that line is semantically unchanged. Only `@<short>` moves forward. | Update the pointer's `@<short>` to the newest commit that touched the file. No drift. |
| **B — Line relocation** | **The pointer's target line number shifted** (lines inserted/removed above) but the named symbol at the new line has the same semantics. | Update `path:<new-line>@<new-short>`. No drift. |
| **C — Step drift** | Target line still exists, same symbol, but **behavior changed** (e.g., selector string changed, retry count changed, OTP phase order flipped, reference-code field renamed). | Insert `[DRIFT]` inline next to the flow step + file `arra_learn` tagged `#drift + #flow-drift + flow:<slug> + step:<n>`. Queue for W4. Leave pointer at old `@<short>` so the drift shows the exact verification gap. |
| **D — Undocumented step** | The commit introduced a new actor-crossing call **inside code territory an existing flow's pointer set already covers** — i.e., the new call sits near or between numbered steps in that flow's diagram. The flow now has a step gap. | Insert `[UNDOCUMENTED-STEP:<threadId>]` in the flow's §Implementation pointers with a one-line description of what the new call does. Open `arra_thread` asking the human: genuine new step (→ queue W8 revision) or internal helper (→ ignore for flows, may belong in `current-system.md`). |
| **E — Step unimplemented** | A pointer's target was removed or the symbol no longer exists at all (bank-bot examples: selector no longer matches — bank updated their portal; a `banks/<bank>/*.js` file was deleted; an OTP phase was removed). | Replace the pointer with `[UNIMPLEMENTED]` + file `arra_learn` tagged `#drift + #unimplemented + flow:<slug> + step:<n>`. Queue W4. |
| **F — Strength downgrade** | ≥ 50% of a flow's steps now carry `[DRIFT]` or `[UNIMPLEMENTED]` from this pass **or** the accumulated unresolved backlog. | Downgrade the flow doc header from S1/S2 to S4; add `[RATIFICATION_PENDING:<new-threadId>]` in the header (a fresh ratification thread); file `arra_learn` tagged `#flow-strength-downgrade`; handoff to schedule a W8 revision. Do **not** attempt ratification in this pass — W9 is fast-fix, not re-ratification. |

**Rules:**

- Classes A and B are *fast-fix* and should be the vast majority of W9 outcomes on a steady-state repo.
- **A vs B decision tool**: "did the *specific* line my pointer points to get displaced?" If lines were inserted *above* the pointer's target line and pushed it to a new line number → **B**. If lines were inserted *elsewhere* in the file (below the pointer's target, or in another function entirely) and the pointer's line number is still correct → **A**. `@<short>` bumps in both cases; the line number only bumps in B.
- C and E both feed W4 queue; do not attempt to fix the doc text in W9 beyond adding the marker.
- D always opens a thread; never silently add steps to a flow diagram in W9 (that's authoring = W8).
- **D vs "uncovered surface"**: D applies **only** when the new actor-crossing sits inside code territory an existing flow's pointer set already covers (near or between numbered steps). If the commit introduces a brand-new scraper for a new bank, a new OTP provider integration, or a new scheduled cron that **no** current flow covers, it is **not** D — it is an **uncovered surface**. For uncovered surfaces, do not open a thread; instead file an `arra_learn` tagged `#w8-handoff + #uncovered-surface + flow:<proposed-slug>` naming the new code + suggesting a W8 authoring pass. The next W8 consumer picks it up.
- F is rare and serious; prefer calling W8 revision today over claiming W9 can re-ratify.

### Step 5 — Apply actions per class (10–30 min)

Apply the per-class action recorded in Step 4. Practical notes:

**Step 5a — A/B pointer refresh (batch).** Edit the flow doc's §Implementation pointers section in one pass per flow. Keep the edits minimal; don't restructure the section.

**Step 5b — C/E drift markers + learnings.** For each `[DRIFT]` / `[UNIMPLEMENTED]`:

```
arra_learn(
  pattern="Flow `<slug>` step <n> drift: <one-line>. Code is now at <path:line@new-short>; flow claim was <path:line@old-short>. <What specifically changed>.",
  concepts=["technical-writer", "repo:bank-bot", "current", "drift", "flow-drift", "flow:<slug>", "step:<n>"],
  source="docs/flows/<slug>.md",
  project="github.com/kokarat/bank-bot"
)
```

Also open a per-finding child trace under `W9_TRACE_BOT` (`parentTraceId=W9_TRACE_BOT`) with `queryType="pattern"`, `foundFiles` listing the changed source file + the flow doc, `foundCommits` listing the commit that introduced the drift.

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

Insert `[RATIFICATION_PENDING:<threadId>]` in the flow doc header. The W8 revision is triggered on the next W8 Step 0 sweep when the thread is answered.

**Step 5e — Cross-repo sync (applies to most bot flows).** If any affected flow is cross-repo (by construction, nearly all bot flows are), file the `#cross-repo-sync + #flow-drift + repo:cross` learning naming both W9 and mobiz's W2 traces + the shared concept + **the specific drifted steps that cross the boundary**. The body should explicitly name:

- Which bot steps are affected (e.g., "steps 5, 8, 8a").
- Which mobiz `// ext: kokarat/bank-bot` step on the sibling flow this maps to (per the decomposition-asymmetry pattern — one mobiz marker typically expands to several bot steps).
- The expected counterpart slug on the mobiz side.
- Whether this drift is visible from the mobiz side's W9 or not (usually not — mobiz's `// ext:` marker is opaque; mobiz W9 cannot detect drift that happens entirely inside bot territory).

This is the primary mechanism by which bot-side drift reaches mobiz's awareness. Without it, mobiz never learns the bot's side of the flow drifted, because mobiz's W9 scans only mobiz code and mobiz's `// ext:` marker is a black box to mobiz.

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
  concepts=["technical-writer", "repo:bank-bot", "current", "flow-track", "flow:<slug>"],
  source="docs/flows/<slug>.md",
  project="github.com/kokarat/bank-bot"
)
```

If the whole pass produced zero affected flows, file **one** pass-level learning tagged `#flow-track + #no-drift-found + repo:bank-bot` with the commit range and a note that the scan was clean.

### Step 7b — Vault audit hard gate (mandatory pre-commit, 1 min)

W9 writes `arra_learn` at up to **five** call sites per pass — Step 5b (C/E drift markers), Step 5d (F strength downgrade), Step 5e (cross-repo sync — fires on most bot passes), §4 note (uncovered-surface handoff), Step 7 (per-flow session summary or `#no-drift-found`). Every single one carries a `project` field susceptible to the same recurring `<` typo pattern that hit the bot W8 on 2026-04-19 (`github.com/kokarat/bank-bot<` in the `scb-dual-control-withdrawal` first pass). See `learning_2026-04-19_recurring-pattern-stray-character-appears-in` for the pattern writeup.

Make it a hard gate — run before the Step 8 commit, not after as a retro-time afterthought:

```bash
VAULT=$(ghq list -p kxlahsimx09/mb_agent_oracle_memory)
bash $VAULT/scripts/verify.sh | tee /tmp/w9-bot-verify.txt
grep -E "(✅ no double-wrap|✅ every indexed doc has a title:)" /tmp/w9-bot-verify.txt || {
  echo "FAIL: verify.sh frontmatter checks did not pass — fix before Step 8"
  exit 1
}
```

**Acceptance:** both `✅ no double-wrap` and `✅ every indexed doc has a title:` lines appear. If either is missing, one of this pass's `arra_learn` calls produced a corrupt frontmatter — the typical offender is a stray `<` in the `project` field that bled through from a template. Fix at the source (re-run the offending `arra_learn` with corrected inputs, then `arra_supersede` the corrupt row per P-001), then re-run the gate. Do not proceed to Step 8 until both checks pass.

Cost asymmetry (same rationale as mobiz W9 Step 7b): catching the typo here is a 1-minute re-run. Catching it post-commit means the corrupt row is already indexed and must be superseded — a 5–10 minute P-001-compliant cleanup every time. Until a server-side validator lands on the `arra_learn` MCP tool, the per-workflow pre-commit gate is the mitigation.

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

Commit message — **template varies by class-count fired this pass** (same taxonomy as mobiz W9 Step 8):

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
- <X> cross-repo-sync learnings filed (mobiz-facing)
- docs/flows/.baseline bumped to <new-short>

No flow spec changes (new steps / ratification) — those go through W8.
No code behavior changes.
```

**Single-class (exactly 1 non-zero class):** collapse to a single descriptive line.

```
docs(flows): track <flows-baseline-short>..<new-short> — 1 pointer updated (<short human-readable>)

- <flow-slug> step <n>: <path>:<old-line>@<old-short> → <path>:<new-line>@<new-short>
  (class B — <1-line reason the line shifted>)
- docs/flows/.baseline bumped to <new-short>

No flow spec changes, no code behavior changes.
```

**Zero-drift pass** (no affected flows):

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
- Whether the pass was a bootstrap (first bot W9 run) or a steady-state pass.
- Any flow that reached the 50% step-drift threshold (F) — name it + handoff target date.
- Any thread opened (D or F) — ids.
- Step 5e cross-repo-sync learnings filed — count + mobiz-side expected recipients.

**Honest Feedback**:

- Was the fast-fix threshold the right line, or did it blur into W8-revision territory?
- Are `// impl:` pointers granular enough to decide A vs B vs C reliably? If you had to guess, the pointer may be too coarse.
- Did the file→flow map produce false positives (files touched but no semantic relationship to the flow step)? If yes, the pointer's line number may be drifting from the real "contract line".
- For Step 5e: does the cross-repo-sync learning feel actionable to mobiz's next W4 pass, or just informational? If the latter, the boundary description in the breadcrumb body needs to be sharper.

**After writing, verify no stray landed in the project tree:**

```bash
SLUG="<slug-you-used>"  # e.g., 14.37_flow-track-90425ba-b886cc4
# This MUST return empty — any hit = stray leak, follow recovery in §The ψ/ trap.
find ~/Code/github.com/kokarat/bank-bot \
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

A **stray `ψ/` directory at the root of this project repo** (`bank-bot/ψ/`) would look identical to a vault path but:

1. **Not indexed by Oracle** — `arra_search` can't find it.
2. **Invisible to other agents** — defeats the "shared memory" design.
3. **May get git-tracked accidentally** — `ψ/` is NOT in this repo's `.gitignore` as of 2026-04-19. Once `git add` catches it, it enters the bank-bot product repo's permanent history.

Historical incidents (cross-repo — same trap shape applies here):
- **21 files** committed to `mobiz-payment-gateway` git history from this trap, across three failed cleanup attempts. Bank-bot has not been bitten yet but the path-shape is identical.
- **2026-04-19 15:06**: a mobiz W2 run wrote its retro to `mobiz-payment-gateway/ψ/memory/retrospectives/2026-04/19/15.06_w2-track-commit-admin-cancel-payout.md` (stray) instead of the canonical vault path. Recovered by manually moving + re-indexing. The same trap applies to bank-bot W9 — only mobiz W2 was bitten that day because bank-bot W9 had not run.

Step 9's pre-write symlink check + post-write stray-find is the fix. Both must pass. Retro is not "done" until the stray check returns empty.

---

## Cross-repo-sync discipline (why Step 5e exists)

Bot flows are cross-repo by construction (per bot W8 Design notes on decomposition asymmetry). Drift inside a bot flow's code territory is invisible to mobiz's W9 because mobiz sees the bot side as `// ext: kokarat/bank-bot` — one opaque marker. If bot W9 doesn't explicitly surface the drift to mobiz via a `#cross-repo-sync + #flow-drift` learning (Step 5e), mobiz's W4 queue never receives the signal and mobiz's sibling flow doc stays at a claim strength the reality no longer supports.

The discipline is simple:

- Every bot W9 pass that files a C, E, or F class learning asks: *does this drift affect the boundary with mobiz?*
- If yes (the drifted pointer is inside territory reachable via a mobiz `// ext:` marker on the sibling flow), the learning gets an additional `#cross-repo-sync + repo:cross` tag set and names the mobiz sibling slug + mobiz W2 trace id in the body.
- The body explicitly addresses visibility: "this drift is NOT detectable by mobiz W9 because mobiz's code did not change; it is only surfaced via this breadcrumb."

Symmetric discipline for mobiz W9 Step 5e is weaker (mobiz flows are mostly single-repo), which is why bot W9's version is more prominent in this spec. See mobiz W9 §Step 5e for the complementary direction (when mobiz drift affects bot's view of the shared contract).

---

## Definition of Done

- [ ] `docs/flows/.baseline` bumped to new HEAD **only if** no deferrals block the bump; otherwise left at prior hash with deferral noted in retro.
- [ ] Every affected `// impl:` pointer is either refreshed (A/B), marked with `[DRIFT]`/`[UNIMPLEMENTED]` (C/E), carries a `[UNDOCUMENTED-STEP:<threadId>]` (D), or belongs to a flow now carrying `[RATIFICATION_PENDING]` (F).
- [ ] Every `[DRIFT]` / `[UNIMPLEMENTED]` has a matching `#drift + #flow-drift` learning with `source: docs/flows/<slug>.md` and per-finding child trace under `W9_TRACE_BOT`.
- [ ] Every `[UNDOCUMENTED-STEP]` and `[RATIFICATION_PENDING]` anchored in this pass has a paired `arra_thread` open in `status="pending"`.
- [ ] One `#flow-track` learning landed per affected flow (or one `#no-drift-found` if the pass was clean).
- [ ] Every uncovered surface discovered this pass has a `#w8-handoff + #uncovered-surface + flow:<proposed-slug>` learning.
- [ ] **Step 5e cross-repo-sync learning filed** for every affected bot flow whose drift touches the mobiz boundary. (Most bot passes should fire Step 5e — if a pass affects a flow but doesn't, the retro must justify why the drift stays internal to bot territory.)
- [ ] W9 root trace (Step 2b) opened with `queryType="evolution"` + all commits in range. `arra_trace_link` to prior W2/W9 head called (unless bootstrap).
- [ ] Per-finding child traces (Step 5b) for every C/E with `parentTraceId=W9_TRACE_BOT`.
- [ ] Cross-repo sibling check (Step 2c) ran: linked to mobiz W2 trace (+ `#cross-repo-sync` learning), or explicitly recorded no cross-repo signal, or deferred with note. "Forgot to check" is not legal.
- [ ] Step 0 ran to completion: Pass 1 left zero `answered`-status markers in bank-bot territory; Pass 2 returned zero unfiled orphans.
- [ ] **Anchor discipline**: every `arra_thread(...)` in this pass (D and F classes) inserted a paired `[UNDOCUMENTED-STEP:<id>]` or `[RATIFICATION_PENDING:<id>]` marker into the relevant flow doc in the same PR. Orphan thread count = 0.
- [ ] **Vault audit hard gate passed (Step 7b)** — `verify.sh` ran **before** the Step 8 commit (not after, not as a retro-time afterthought); both `✅ no double-wrap` and `✅ every indexed doc has a title:` present. Any `arra_learn` call this pass produced that carried a corrupt `project` field was fixed at the source + old row superseded per P-001 before PR opens.
- [ ] **One open W9 PR per repo:** Step 8.0 ran (`gh pr list --search "head:docs/flow-track- state:open" --author "@me"`). If non-empty → this pass took 8.A (amend); if empty → 8.B (new). At end of pass, count of open `docs/flow-track-*` PRs by `@me` on this repo ≤ 1. Independent of the W2 PR gate (different branch prefix).
- [ ] **Retro path discipline (pre-write):** Step 9 ran the `readlink ~/.arra-oracle-v2/ψ` check; the canonical vault symlink resolved; retro written via the absolute `~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/...` path (NOT a relative `ψ/memory/...` path).
- [ ] **Stray-check passed (post-write):** `find ~/Code/github.com/kokarat/bank-bot -path '*/ψ/memory/*' -name "*<slug>*" -not -path '*/.agent/*'` returned empty. The retro is NOT leaking into the bank-bot product repo's working tree.
- [ ] No code files changed. No `docs/current-system.md` changes. No new `docs/flows/<slug>.md` files created (those are W8). Diff is exclusively pointer refreshes + marker insertions + baseline bump + `#drift`/`#flow-track`/`#cross-repo-sync` learnings.
- [ ] Branch pushed; PR opened; **not merged**.
- [ ] Retrospective written with AI Diary + Honest Feedback.
- [ ] Retro is the state carrier; no separate handoff step. Open thread ids + ratification-pending thread ids are listed in the PR body and anchored in the flow doc(s) via `[AWAITING_THREAD:<id>]` / `[RATIFICATION_PENDING:<id>]` — W8/W9 Step 0 picks them up on resolution.

---

## Common pitfalls

- **Classifying A/B as C.** A line number shift or a variable rename is not a semantic drift. If the flow step's claim still holds, it's A or B. Over-classifying inflates the W4 queue.
- **Classifying C as A.** Worse direction. If a selector changed (bank portal updated its UI) but the flow doc still describes the old selector, the flow is lying — `[DRIFT]`. Never silently rewrite the flow text to match new code.
- **Editing the flow body in W9.** W9 edits pointers and markers only. Touching §Purpose / §Actors / §Success criteria / §Error paths / §Postconditions / the sequence diagram steps turns W9 into W8 without the ratification discipline.
- **Skipping Step 5e when drift is cross-repo.** The default assumption for bot flows is that drift IS cross-repo; assume it until proven otherwise. A drift inside bot code that the mobiz side won't see via its own W9 stays undiscovered unless Step 5e fires.
- **Bumping `.baseline` with deferrals outstanding.** If an undocumented-step thread (D) was opened but the human hasn't answered, the commit range is not fully processed. Leave `.baseline` at prior hash; retro explains why.
- **Scanning only touched files, not also their callers.** A scraper helper in `helpers/` may be called from a `banks/*/statement.js` the flow's step 2 pointer targets. If the helper's behavior changed, the caller's behavior changed too — same drift surface.
- **Forgetting that W9 is read-only against code.** W9 never edits `.js` / `.ts` files. If a drift appears to warrant a code fix, the fix is *outside* W9's scope; the `#drift` learning is its only output.
- **Not chaining W9 passes.** Like W2, W9 forms an evolution chain. A W9 pass that didn't call `arra_trace_link(prev=<head>, next=W9_TRACE_BOT)` will fork the chain and lose the narrative. Step 2b's link is mandatory except on bootstrap.
- **`arra_learn(pattern=...)` expects prose, not a pre-wrapped markdown doc.** arra_learn wraps its own `---\ntitle: ...\n---` around whatever you pass as `pattern`. Passing a document that already contains a frontmatter block (e.g. an earlier arra_learn output, or hand-authored markdown starting with `---\ntitle: ...`) produces the nested **double-wrap** bug: filename begins `_title-*`, outer `title: ---`, two frontmatter blocks, `verify.sh` flags it (Step 7b hard gate). Bot W9 fires `arra_learn` at up to 5 call sites per pass (Step 5b drift markers, Step 5d strength downgrade, Step 5e cross-repo sync, §4 uncovered-surface handoff, Step 7 per-flow summary) — each carries the same exposure. A tool-side strip-and-warn guard (`stripFrontmatterWrap` in Soul-Brews-Studio/arra-oracle-v3 `src/tools/learn.ts`, landed in arra-oracle-v3 commit `b816ca0` on `local/all-prs` 2026-04-20) catches it, but keep `pattern` as 1–2 paragraphs of plain prose and rely on the guard only as a safety net. Pass metadata via the separate `concepts`, `source`, and `project` arguments; the first line of `pattern` seeds both the title and the filename slug.

---

## Escalation

- **Security-sensitive change** (BOT_SECRET handshake, OTP endpoint contracts, credential storage, session cookie format, X-Bot-Secret verification) with drift in a flow that covers it → file `#drift` + CC `security_auditor` via `arra_inbox`. Do not ship the W9 PR's pointer refreshes publicly until `security_auditor` has acknowledged the drift.
- **Financial-behavior change** (transfer submission, approval OTP, withdrawal dispatch semantics) with drift in covering flow → CC `code_reviewer` on the PR.
- **Bank-portal behaviour change** (bank updates their UI, scraper broke, new CAPTCHA class) → this is ops-level; file an `arra_inbox` to ops describing the observed break, record the pre-change state as `[DRIFT]`, continue the W9 pass documenting the state reality reached.
- **Strength downgrade (F) on > 2 flows in one pass** → the code has drifted substantially from intent across the portfolio. Halt before Step 6 (do not bump baseline), handoff to human with the three offending flows and the commit range.
- **`[UNDOCUMENTED-STEP]` threads > 3 in one pass** → the code has accumulated undeclared actor-crossings faster than W9 can triage. Handoff to `system_architect` and schedule a coordinated W8 + W9 session instead of filing all threads individually.
- **Mobiz-side breadcrumb contradicts bot code** → file `#drift` against whichever side diverges from the ratified claim; let W4 resolve.
- **Bootstrap + first pass finds > 30% drift** → the oldest-pointer baseline is covering a huge historical range. Split the pass: bump `.baseline` to a recent commit, file a `#bootstrap-coverage-gap` learning naming the skipped range, and plan a W8 re-authoring pass for flows whose pointers are > 6 months stale.

---

## Relationship to other workflows

- **Before W9**: W8 must have authored at least one flow and seeded `docs/flows/.baseline` in its Step 9a (or this is a bootstrap pass — see §Bootstrap). For bank-bot as of 2026-04-19 the first W8 was `scb-dual-control-withdrawal` at commit `466d56e`.
- **W9 output feeds W4**: every `[DRIFT]` and `[UNIMPLEMENTED]` goes to W4 the same way `#drift` learnings from W2 do; W4 does not distinguish flow-level from code-level drift at triage time.
- **W9 output spawns W8 revisions**: class F always hands off to W8. Class D may hand off if the human answers "yes this is a real step."
- **W9 runs parallel to W2**: the daily cron runs both. A single commit range can appear in two traces (one W2, one W9); `arra_trace_link` chains them into the same evolution line.
- **W9 output propagates to mobiz**: Step 5e's `#cross-repo-sync + #flow-drift` learning is the primary mechanism by which bot-side drift reaches mobiz's W4 queue. Mobiz's W9 cannot see bot code directly; the breadcrumb is the channel.
- **W9 is not W2**: W2 verifies that `current-system.md` reflects the code's structure; W9 verifies that `flows/*.md` reflects the code's *behavior through actor-crossings*.
- **W9 is not W8**: W8 authors + ratifies intent; W9 refreshes pointers and reports. A single W9 pass may produce zero flow-body edits.

---

## Change log for this workflow file

- 2026-04-19 — Initial version. Scoped to `technical-writer` instance in `github.com/kokarat/bank-bot`. Mirrors mobiz-side W9 structure (daily cron alongside W2, pointer-level verification unit, six outcome classes A/B/C/D/E/F, fast-fix thresholds ≤5 flows / ≤50% per-flow step drift, global `docs/flows/.baseline`, bootstrap via oldest `// impl:` hash). Inherits three corrections landed on the mobiz side within the last 48 hours: (a) Step 3 extractor regex anchors on backtick-wrapped `` `<path>@<hash>` `` tokens inside `## Implementation pointers` sections with mandatory regex self-test (2026-04-19 brew-ops audit fix); (b) Step 7b verify.sh hard gate against recurring `<` typo in `project` field (2026-04-19 post-W8 calibration); (c) tag convention uses prefixed `flow:<slug>` form (2026-04-19 workflow-9 standardization). Three bot-specific adaptations: (1) Step 2c flips direction — looks for mobiz W2 traces to chain into, not bank-bot W2 like the mobiz side does. (2) Step 5e cross-repo-sync learning is mandatory on most bot passes because bot flows are cross-repo by construction (per bot W8 Design notes on decomposition asymmetry — one mobiz `// ext: kokarat/bank-bot` marker typically expands to 5-10 bot steps, so a drift inside those steps is invisible to mobiz W9 without an explicit breadcrumb). §Cross-repo-sync discipline section added after §Steps to document this primary bot-to-mobiz drift propagation channel. (3) Examples are bot-flavored — selector changes, OTP phase reordering, bank-portal UI breaks, scraper cursor resets — rather than the Go/MongoDB examples on the mobiz side. Expected usage: bank-bot flow portfolio is 1 as of this writing (`scb-dual-control-withdrawal` at `466d56e`); W9 passes will mostly be zero-drift no-ops until the portfolio grows. First real W9 pass on bank-bot is expected when code commits after `466d56e` touch files referenced by the flow's pointer set.
- 2026-04-20 (brew-ops, W9 audit cross-cutting sync) — **Three sibling-synced fixes propagated from W2's 2026-04-19→20 evolution into W9** (mobiz + bank-bot identical changes):
  1. **§Common pitfalls: `arra_learn(pattern=...)` prose-only rule added** — W9 fires arra_learn at up to 5 sites per pass (same exposure as W4/W8 which got this rule on 2026-04-19); the bullet was missing here. Tool-side `stripFrontmatterWrap` guard (arra-oracle-v3 `b816ca0`) catches violations, but spec-side prose-only discipline keeps agents from relying on the guard.
  2. **Step 9 path discipline + §The ψ/ trap section added** — port from W2's 2026-04-19 fix after the live retro-leak incident at `mobiz-payment-gateway/ψ/memory/retrospectives/2026-04/19/15.06_w2-track-commit-admin-cancel-payout.md`. Step 9 now mandates pre-write `readlink` check + absolute-path-via-symlink + post-write stray-find + recovery recipe. New §The ψ/ trap section (inserted between Step 9 and §Cross-repo-sync discipline) explains the topology + cites historical incidents — bank-bot has not been bitten yet but the path shape is identical, so the discipline is preemptive. DoD adds two lines (pre-write check passed, post-write stray-check empty).
  3. **Step 8 split into 8.0 (detect) → 8.A (amend) / 8.B (new), with a new DoD line "one open W9 PR per repo".** Mirrors W2 Step 8.0/8.A/8.B (mb_agent_oracle_memory `0357769`) using the `docs/flow-track-` branch prefix. Independent gate from W2's `docs/track-` PR gate. Important caveat: the daily W9 cron infrastructure does NOT yet exist (P2 follow-up flagged in the 2026-04-19 brew-ops audit, learning `2026-04-19_pattern-w9-step3-extractor-regex-fix`); when it lands, this Step 8 split prevents the same overnight stack-up that hit W2. Until then, manual W9 runs benefit from the same gate when humans run W9 multiple times in a day.
