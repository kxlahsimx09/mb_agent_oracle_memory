# Workflow 2 — Document a New/Changed Feature (Track Commit)

> Reference document for the `technical_writer` agent.
> Read this file before running the workflow. Do not skim.

This workflow is the **fast follow-up** to Workflow 1 (baseline). Where Workflow 1 is a slow, grounding pass over the whole system, Workflow 2 is a surgical update triggered by a specific commit range or PR that has touched a surface the writer owns. It keeps `docs/current-system.md` (and sibling docs) in step with `main` without re-reading the entire system.

Output of a successful Workflow 2 pass: updated doc sections with fresh `// verified:` citations, a bumped `docs/.baseline`, any new `arra_learn` entries required, and — if any commit was too large to cover in a fast fix — one or more `#drift` learnings queued for Workflow 4.

---

## When to run this workflow

Run when **all** of the following are true:

- `docs/.baseline` exists (Workflow 1 has been executed at least once).
- `git log <baseline>..HEAD --stat` shows commits that touch files the writer owns (see §Territory map below).
- The commits to cover do **not** together exceed ~10 files or ~500 LOC of behavior change. If they do, run Workflow 1 (full re-baseline) instead.

Do **not** run this workflow:

- When `docs/.baseline` is missing — run Workflow 1 first.
- For a refactor that touches > 10 files or renames a top-level concept — run Workflow 1.
- For a new top-level feature area (new collection, new scheduler, new bot adapter) — run Workflow 1 so the baseline anchors re-set cleanly.
- To describe target-system changes — that is Workflow 3.

---

## Preconditions

- [ ] `git status --porcelain` is empty (clean tree). If not, stash or abort. A Workflow 2 pass against a dirty tree cannot be cited honestly.
- [ ] `git fetch origin && git status -sb` shows no `behind` on the branch being documented.
- [ ] `docs/.baseline` exists and is parsable (two lines: `current-system-baseline:` + `last-verified-at:`).
- [ ] Oracle is reachable (`curl -sf http://localhost:47778/api/stats` returns 200). If unreachable, you can still run this workflow — note the gap in the retro and skip `arra_search` grounding in Step 1.
- [ ] You have at least **30 minutes** of focused time. A rushed Workflow 2 produces a stale `.baseline` pointer and silent drift.

---

## Inputs you will read

In approximate order:

1. `docs/.baseline` — the anchor commit.
2. `git log <baseline>..HEAD --stat` — the commit range this run covers.
3. For each commit, `git show --stat <sha>` and `git show <sha> -- <file>` for each touched file in territory.
4. The current versions of files touched in the commit range (not just the diff — the post-change state is what the doc describes).
5. The existing doc sections that describe each touched file (see §Territory map).
6. Oracle vault — `arra_search` for any prior `#drift` learning on the same area; these may already describe what changed.
7. The PR description (if any) — via `gh pr view <number>`. Useful for intent, but P-004 applies: the PR body is a claim; the code is truth.

---

## Outputs you will produce

Required:

- Updated doc section(s) with new `// verified: <path>@<short-hash>` citations against the new HEAD.
- `docs/.baseline` bumped to the new HEAD (same two-line format Workflow 1 specifies).
- At least one `arra_learn` entry per durable fact uncovered. If the only change was a cosmetic rename, no learning is needed — but document that in the retro.

Conditionally produced:

- One or more `#drift` learnings — when a commit revealed that the *prior* doc text contradicted the code that was already there (not the commit's own change). These go into Workflow 4's queue.
- A **scope-overrun note** in the retro — if you discover mid-workflow that the commit range is larger than expected. Stop the fast-fix pass and escalate to Workflow 1.

Never produced in this workflow:

- A full re-read of the system (that is Workflow 1).
- A new top-level doc file (new files belong in Workflow 1 or a dedicated PR).
- ADRs (Workflow 5).
- Runbooks (Workflow 6).

---

## Territory map (which doc owns which source)

Used by Step 3 to decide whether a touched file is in-territory for this workflow:

| Source pattern | Owning doc section | Fast-fix threshold |
|---|---|---|
| `controllers/*.go` | `docs/current-system.md` §3 API surface | 1–3 endpoints changed |
| `routes/*.go` | `docs/current-system.md` §3 API surface | 1–5 routes changed |
| `models/*.go` | `docs/data-model.md` (or §4 if inline) | 1–2 fields added/renamed |
| `middlewares/*.go` | `docs/current-system.md` §3, §7 Security | 1 middleware touched |
| `scheduler/*.go` | `docs/schedulers.md` (or §5 if inline) | 1 scheduler, no cadence change |
| `services/*.go` | `docs/current-system.md` §6 | 1 service, narrow surface |
| `helpers/*.go` | `docs/current-system.md` §7 Security | 1 helper, no signature change |
| `bank-bot/**` | `docs/bank-bot.md` | 1 adapter file |
| `swagger_simple.json` | `docs/current-system.md` §3 | re-check endpoints referenced |
| `db/mongo.go`, `db/redis.go` | `docs/current-system.md` §1 Stack, §4 Data model | connection config change |

Files **outside** this table are out-of-territory for Workflow 2. Either they belong to another role (e.g. `integration-tests/` → `qa_engineer`, `.github/workflows/` → `devops_engineer`) or they are infrastructure the writer does not document (vendored code, build artifacts).

---

## Steps

### Step 1 — Grounding (3 min)

```
arra_search query="<feature-keyword> technical-writer current" type=all limit=5
arra_search query="drift technical-writer" type=learning limit=5
```

Look for: prior `#drift` on the same area (your change may already be flagged); the latest handoff from the sibling `next-writer` instance (cross-repo implications); open unanswered questions from previous retros.

If Oracle is unreachable, note `[GROUNDING SKIPPED — Oracle unreachable at <timestamp>]` and continue. Do not block.

### Step 2 — Define the commit range (2 min)

```
baseline=$(awk -F': *' '/^current-system-baseline/{print $2}' docs/.baseline)
git log ${baseline}..HEAD --oneline --stat
```

Record:

- Prior baseline commit (short hash).
- New HEAD commit (short hash).
- Count of commits in range.
- Files touched (broken down by territory column from §Territory map).

If the range is empty, Workflow 2 is a no-op — update `last-verified-at` in `docs/.baseline` and exit. Note this in the retro.

### Step 2b — Open the W2 trace + chain to prior (1 min)

Each W2 pass is a follow-up on the most recent baseline (W1) or the most recent W2. It belongs in a **horizontal chain** (prev → next) so a future agent running `arra_trace_chain(<any-node>)` sees the evolution over time: W1 baseline → W2₁ → W2₂ → W2₃ …

```
arra_trace(
  query="track-commit — <prior-short>..<new-short> (<N> commits)",
  queryType="evolution",                    # this is change-over-time, not structural
  scope="project",
  project="github.com/kokarat/mobiz-payment-gateway",
  foundCommits=[ ...each commit in the range as { hash, shortHash, date, message } ]
)
# store returned trace_id as W2_TRACE
```

Find the chain head (most recent baseline root or last W2 trace) and link:

```
arra_trace_list(project="github.com/kokarat/mobiz-payment-gateway",
                queryType=["project","evolution"], depth=0, limit=5)
# pick the most recent entry — that's the chain head to extend
arra_trace_link(prevTraceId="<head>", nextTraceId=W2_TRACE)
```

### Step 2c — Cross-repo sibling link (1–2 min, conditional)

Daily W2 cron runs across mobiz + bank-bot frequently touch **related** code (shared contract, callback URL shape, signature format, OTP flow). When both repos changed in the same 24h window for the same reason, chain the two W2 traces together so `arra_trace_chain(<either-W2>)` surfaces the sibling.

**Detect the cross-repo signal.** Any one of these is enough:

- A commit message in the range references the other repo by name (`bank-bot`, `mobiz-payment-gateway`) or by a ticket id known to span both.
- A file in the range is part of the shared contract: OpenAPI spec, proto, shared DTO, callback payload struct, signature/verify helper, MDR schema.
- The PR description links the other repo's PR.
- A commit message mentions a shared concept (webhook version bump, callback header change, OTP endpoint rename, MDR code rename).

If **no signal**, skip the rest of this step. Do not speculate.

**Look up the other repo's recent W2 trace.**

```
arra_trace_list(
  project="github.com/kokarat/bank-bot",
  queryType=["project","evolution"], depth=0, limit=5
)
# keep only traces whose created_at is within the last 24h
# pick the most recent one that covers commits landing on the same day or the day before
```

**Decide and link:**

- If a matching other-repo trace exists → `arra_trace_link(prevTraceId=<other-W2>, nextTraceId=W2_TRACE)` (the older of the two is always prev).
- If no trace yet (you ran before bank-bot's W2 today) → **defer**. Do not force a parent trace. Bank-bot's W2 will list mobiz traces on its pass and link backward to you. Note the defer in the retro so the human can spot-check that the back-link landed.
- If more than one plausible other-repo trace exists → pick the most recent and file a one-line note in the retro explaining why. Ambiguity here is a signal to talk to the human via `arra_thread`.

**Always, when you link:** file an `arra_learn` tagged `#cross-repo-sync` that names both traces + the shared concept (e.g., "mobiz callback v2 ↔ bank-bot adapter selectors update"). This is the semantic record; the `arra_trace_link` is the navigation record.

**Caveat to keep in mind.** `arra_trace_link` is directional (prev → next) and was designed for temporal evolution. Here we're using it for a sibling-in-time relationship. Readers of `arra_trace_chain` will see the siblings in chronological order but should not over-read "prev → next" as a causal arrow across repos. The `#cross-repo-sync` learning is the authoritative description of *what the two W2 passes have in common*; the link is just the thread that keeps them findable.

If no prior trace exists → skip the link (agents before this one didn't record traces; accept the gap, don't invent a phantom predecessor).

### Step 3 — Classify each touched file (5 min)

For each file in the range, assign one of:

- **In territory, fast-fix-eligible**: within the threshold in §Territory map → proceed to Step 4.
- **In territory, over threshold**: too large for a fast fix → file `#drift` with `decision_required` tag and add to Workflow 4 queue. Skip in this run.
- **Out of territory**: record in the retro that it was observed but not updated; mention which role owns it.

If > 50% of in-territory files fall into "over threshold", **stop** — the delta is big enough that a full Workflow 1 re-baseline is cheaper than many Workflow-2 fast fixes. Escalate.

### Step 4 — Read the post-change file (10–20 min, scales with file count)

For each fast-fix file:

1. Read the **current** file (post-change state), not just the diff. The doc describes what the system does now, not what a patch added.
2. Open the controller/service/model being updated.
3. Re-verify every claim in the owning doc section against the new file. For each:
   - **Claim still correct** — update the citation hash: `// verified: <path>@<new-short>`.
   - **Claim is now wrong** — rewrite the claim. Mark the old one `SUPERSEDED (<new-short>, see <new section>)` per SKILL §5. Do not silently delete.
   - **New claim needed** — add it with citation.
4. If a change touches the API surface (new/removed endpoint, changed middleware, changed response shape), update the matching `swagger_simple.json` reference column and note in §9 Known drift if the swagger file lags.

### Step 5 — Ask before inventing (continuous)

If the commit introduces behavior that cannot be unambiguously read from the code (e.g. two plausible status transitions, a feature-flag check with no flag found), stop and:

1. Mark the claim `[UNVERIFIED — ambiguous; see commit <short>]` inline.
2. Open an `arra_inbox` item to the role most likely to know — usually `requirement-writer` or the human.
3. Continue with other files. Do not block the whole pass on one ambiguity.

### Step 6 — Log learnings (5 min)

For each **durable fact** uncovered (not cosmetic changes), write an `arra_learn` with the 3-layer tag set from `.agent/AGENTS.md` §7a:

```yaml
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - <feature>                 # e.g. bank-bot, deposit, scheduler
  - <special>                 # drift / decision / handoff — only if applicable
source: <path>@<new-short-hash>
related:
  - <prior-learning-id-if-any>
project: github.com/kokarat/mobiz-payment-gateway
```

Typical Workflow 2 learnings:

- A new enum value added to an existing status convention.
- A new callback target or signature format.
- A scheduler cadence change.
- A permission gate that moved from per-route to middleware (or vice versa).

Do **not** file an `arra_learn` for:

- Typo fixes in comments.
- Reformatting / linting commits.
- Dependency bumps with no behavior change.

Aim for **1–5 learnings** per Workflow 2 pass. Zero learnings on a non-cosmetic commit range is a yellow flag — you may have skimmed.

### Step 7 — Bump `docs/.baseline` (1 min)

Overwrite, exact format:

```
current-system-baseline: <40-char commit hash of new HEAD>
last-verified-at:        <ISO 8601, GMT+7>
```

Rule: bump **only** when Steps 3–6 are complete. A partial Workflow 2 (e.g. 3 of 5 files updated, 2 deferred to Workflow 4) does **not** bump `.baseline` — the anchor must cite a commit where every in-territory file has been reconciled. Instead, leave `.baseline` at the old hash and note the deferrals in the retro + drift learnings.

### Step 8 — Commit + PR (3 min)

Branch: `docs/track-<short-hash>` (e.g. `docs/track-c8a91f2`).

Commit message:

```
docs: track commits <old-short>..<new-short>

Updated sections:
- <doc path> §<anchor>
- <doc path> §<anchor>

Filed <N> arra_learn entries.
Filed <M> #drift learnings (see Workflow 4 queue).

No code behavior changes.

Closes #<issue if one exists>
```

PR body:

- List the commits covered (link each).
- List the doc sections updated.
- Link any `#drift` learnings filed.
- Include the standard line: **"I will not merge this PR. Awaiting human review."**

Per `.agent/AGENTS.md` §9, **never** `gh pr merge`.

### Step 9 — Retrospective (3 min)

Run `rrr`. A Workflow 2 retro is shorter than a Workflow 1 retro but the mandatory sections are the same: Outcome, What went well, What went slowly, Surprises, Honest Feedback, AI Diary, Next unanswered question.

Retro must capture:

- The commit range covered.
- Which files were fast-fixed vs deferred to Workflow 4.
- Any `[UNVERIFIED]` left in the docs and why.
- The next expected Workflow 2 trigger (next PR, expected area of change).

---

## The fast-fix vs full-pass decision (anti-pitfall)

This is the most frequent mis-call in Workflow 2. Use these heuristics:

**Fast-fix (stay in Workflow 2):**

- Single controller, ≤ 3 endpoints, no new model fields.
- Single model field added, no enum collision.
- Single middleware swap with same request/response shape.
- Scheduler internal change with unchanged cadence and unchanged side effects.

**Full-pass (escalate to Workflow 4 drift reconciliation, or Workflow 1 re-baseline):**

- A rename of an entity or enum that ripples through multiple files.
- A new top-level concept (new collection, new scheduler, new service).
- Cross-cutting change (e.g. every controller gained audit-trail middleware) — file one `#drift` for the theme, queue Workflow 4.
- Any change in `helpers/security.go`, `helpers/signature.go`, `helpers/jwt.go` — these are fast-fix-disqualified because security-sensitive. Escalate and CC `security_auditor`.

When in doubt, escalate. A deferred fast-fix costs one extra Workflow 4 pass; a wrong fast-fix costs silent drift.

---

## Definition of Done

This workflow is complete **only** when all are true:

- [ ] Every in-territory file in the commit range is either updated-and-cited or deferred with a `#drift` learning.
- [ ] Every updated doc section carries fresh `// verified: <path>@<new-short>` markers.
- [ ] Superseded claims are marked `SUPERSEDED` with a pointer (never deleted — P-001).
- [ ] `[UNVERIFIED]` markers added are < 5% of affected section's claims.
- [ ] `docs/.baseline` bumped **only** if no in-territory file was deferred; otherwise left at prior hash with deferral noted in retro.
- [ ] At least one `arra_learn` entry filed per durable fact (or an explicit retro note that the range had no durable facts).
- [ ] Git branch pushed; PR opened; **not merged**.
- [ ] Retrospective written at `ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_slug.md` with AI Diary + Honest Feedback.
- [ ] `arra_handoff` entry written with a pointer to the PR and the next expected Workflow 2 trigger.
- [ ] Vault audit clean: `bash $(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/scripts/verify.sh | grep -A 3 frontmatter` shows `✅ no double-wrap` + `✅ every indexed doc has a title:`.
- [ ] W2 trace (Step 2b) opened with `queryType="evolution"` and every commit in the range in `foundCommits`. If a prior baseline/W2 trace exists for this project, `arra_trace_link(prevTraceId=<head>, nextTraceId=W2_TRACE)` was called so the horizontal chain extends instead of forking.
- [ ] Cross-repo sibling check (Step 2c) ran: you either looked for a bank-bot W2 trace in the last 24h and linked (+ filed `#cross-repo-sync` learning), **or** you recorded in the retro that no cross-repo signal was found, **or** you deferred because you ran first and noted the expected back-link. "Forgot to check" is not one of the options.

---

## Common pitfalls (learn from each one, file a learning if new)

- **Reading the diff instead of the post-change file.** The diff is a delta; the doc describes the destination state. If you only read the diff, you will miss interactions with pre-existing code that the diff assumes.
- **Bumping `.baseline` with deferrals outstanding.** If even one in-territory file was deferred, the baseline still lies about what's verified. Leave it at the prior hash.
- **Trusting the PR body.** PR descriptions are claim-ful (P-004). Verify against the code, not the narrative. Commit messages are first-draft claims too.
- **Not asking about ambiguity.** If the code has two plausible readings, mark `[UNVERIFIED]` and ask. Inventing a plausible-sounding semantics is the fastest way to make a doc silently wrong.
- **Skipping the retro on "small" passes.** A 10-minute Workflow 2 still has a retro — without it, the next writer (or future-you) has no signal on whether anything was missed.
- **Running Workflow 2 on a dirty tree.** A fast fix cited against a tree that isn't in git is a lie. Stash or abort.

---

## Escalation

- Security-sensitive change (auth, RBAC, callbacks, MDR, OTP, signature validation) → stop the fast-fix. File `#drift` + CC `security_auditor` via `arra_inbox`. Do not update docs in public until acknowledged.
- Financial-behavior change (wallet ops, fees, settlements, payout expiry) → CC `code_reviewer` in the PR description. Fast-fix still allowed if purely documentation, but flag in retro.
- Commit range reveals that a prior baseline claim was wrong (not the commit's fault — the baseline missed it) → file `#drift` with the original Workflow 1 commit as the provenance, not the current commit. This is P-004 in action.
- Commit touches both current and target systems (shared code) → stop. That contradicts SKILL §3 ("Current and Target, never mixed"). Human decision needed before proceeding.

---

## Relationship to other workflows

- **Before you run Workflow 2**: Workflow 1 must have produced a valid `docs/.baseline`.
- **After you run Workflow 2**: if you deferred anything, Workflow 4 has new items in its queue.
- **When Workflow 2 fails the escalation test**: Workflow 1 is the fallback for "too much changed"; Workflow 4 is the fallback for "found a drift that predates the commit range".
- **When the commit introduced a decision that the human approved**: file a tiny `arra_learn` with `#decision` tag in Workflow 2, and schedule Workflow 5 (ADR) as a separate follow-up — do not bundle ADR writing into Workflow 2.

---

## Change log for this workflow file

- 2026-04-16 — Initial draft by a Claude Code assistant during a debugging session for arra-oracle-v3. Written from the SKILL.md commit-tracking contract (§Commit tracking contract) and by mirroring Workflow 1's structure. **Not yet reviewed by the `technical_writer` agent** — treat as draft until the next `pg-writer-oracle` session ratifies it.
- 2026-04-17 — Added Step 2b (open a W2 trace with `queryType="evolution"`, then `arra_trace_link` to the prior baseline/W2 chain head). Each W2 pass is now a node in a horizontal chain that shows evolution over time: W1-baseline → W2₁ → W2₂ → … Future agents reconstruct the sequence with `arra_trace_chain(<any-node>)`. DoD tightened to require the trace and the link. Findings inside the pass (`#drift`, `[UNVERIFIED]`, deferrals) are still filed as `arra_learn` — not as child traces — because W2 work units are typically smaller than W1 and the per-finding child pattern there would be noise. If a single W2 pass grows large enough that per-finding children help, fall back to the W1 pattern and note it in the retro.
- 2026-04-17 — Added Step 2c (cross-repo sibling link). Motivation: daily W2 cron runs in mobiz + bank-bot often cover related commits (shared contract, callback shape, signature helper, OTP endpoint). When that happens, the two W2 traces chain to each other via `arra_trace_link` and a paired `arra_learn` tagged `#cross-repo-sync` records the semantic reason. Link direction is temporal (older = prev); readers should not over-interpret it as causal. If you run first and no other-repo trace exists yet, defer — the other repo's W2 will link back. DoD added a check that refuses "forgot to look."
