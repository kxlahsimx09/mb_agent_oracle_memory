# Workflow 4 — Reconcile Drift

> Reference document for the `technical_writer` agent.
> Read this file before running the workflow. Do not skim.

This workflow is how open `#drift` learnings get **closed**. A drift is any place where code and documentation disagree — they were flagged (by Workflow 1, Workflow 2, or another agent) and queued in the Oracle vault tagged `#drift`, with `[DRIFT: …]` markers left inline in the affected docs. Workflow 4 processes that queue one drift at a time: reads both sides, decides which one moves, applies the move, and leaves a resolution trail back to the original learning.

This workflow is **not** where drift is discovered — that happens inside Workflows 1, 2, and 3. Workflow 4 is the cleanup pass. Running it once a week or once every 10–20 open drift items keeps the doc tree honest without blocking faster workflows.

---

## When to run this workflow

Run when **any** of the following is true:

- `arra_search query="drift technical-writer repo:mobiz-payment-gateway current" type=learning` returns **≥ 5 open** `#drift` entries without `#resolution` successors.
- `docs/current-system.md` §9 "Known drift" table has grown for two consecutive baselines without shrinking.
- A human explicitly asks to "reconcile drift," "fix the drift queue," "เคลียร์ drift."
- Workflow 1 or 2 finished with `[DRIFT]` markers you chose **not** to resolve inline (they are parked here now).
- A sibling agent (`tester`, `security_auditor`, etc.) filed a `#drift` learning addressed to `technical_writer` via `arra_inbox`.

Do **not** run this workflow:

- To discover new drift — use Workflow 1 (full baseline) or Workflow 2 (commit-range fast fix).
- To fix **code** — the writer never changes production code. If a drift turns out to be "code is wrong," the outcome of Workflow 4 for that item is a GitHub issue + handoff, not a patch.
- During an active feature PR — drift reconciliation on a busy branch confuses commit history. Use its own branch.
- When the vault's `#drift` queue is < 3 items *and* no human asked — just let Workflow 2 pick them up as it passes through.

---

## Preconditions

- [ ] `git status --porcelain` is empty.
- [ ] `git fetch origin && git status -sb` shows no `behind`.
- [ ] `docs/.baseline` exists and is parsable.
- [ ] Oracle is reachable (`curl -sf http://localhost:47778/api/stats` returns 200). This workflow **requires** Oracle — the drift queue lives there. If unreachable, halt; do not proceed.
- [ ] You have at least **45 minutes** of focused time. Each drift item is 5–10 min; batching is fine, but do not leave half-resolved items in a PR.

---

## Inputs you will read

In approximate order:

1. The open drift queue from Oracle:

   ```
   arra_search query="drift repo:mobiz-payment-gateway current technical-writer" type=learning limit=30
   ```

   For each hit, note: `id`, `source` (the doc + code citation it carries), `created` date, and whether a matching `#resolution` or `superseded_by` pointer already exists. Items that already have a successor do not belong on this pass's queue.

2. The cited doc section — open the markdown file and read the surrounding paragraph, not just the flagged line.
3. The cited code — open the Go / Node source at the cited `:line` and read the full function, not just the cited line.
4. The commit that introduced the drift (usually captured in the learning's `source:` field). Use `git show <sha>` to understand intent; `git log -S '<symbol>'` if the learning does not cite a commit.
5. `docs/.baseline` — confirm the doc is being reconciled against a known anchor. If the drift was logged before the current baseline, it may already be resolved by a later Workflow 1 run; re-verify before changing anything.
6. Related learnings — the `related:` list on the drift. Often a second drift on the same surface lets you close two items with one edit.

---

## Outputs you will produce

Per drift item, **one** of these three outcomes. Every item ends in exactly one of these — "skipped with no note" is not allowed.

| Outcome | When | Artifacts |
|---|---|---|
| **(A) Fix doc** (most common) | Code is right; doc is stale | Edited doc section + new `// verified: <path>@<short>` citation + removed `[DRIFT]` marker + follow-up `arra_learn` tagged `#resolution` pointing at the original drift via `supersedes:`; call `arra_supersede(oldId, newId)` |
| **(B) Fix code** — escalate | Doc encodes a stated invariant the code violates | **No doc edit.** GitHub issue filed (`gh issue create` with title `regression-candidate: <invariant>`). Follow-up `arra_learn` tagged `#regression-candidate` that references the drift via `related:` (NOT `supersedes:` — the drift stays open until code is fixed). Open `arra_thread(title="regression-candidate: <invariant>", message="<issue URL> + <drift id>")` and insert `[AWAITING_THREAD:<id>]` at the drift row in §9 — `backend_developer` or `code_reviewer` resolves on the thread; next W4 Step 0 sweeps it when answered |
| **(C) Obsolete / duplicate** | Drift references a deleted surface, a since-renamed file, a duplicate of another drift, or a feature that has been intentionally removed | Follow-up `arra_learn` tagged `#resolution` with `reason: obsolete \| duplicate-of:<id> \| feature-removed` ; `arra_supersede(oldId, newId)`. The `[DRIFT]` marker is removed from the doc if the doc section still exists, or the whole section is removed if the feature was removed |

Required artifacts regardless of outcome:

- A commit on branch `docs/reconcile-drift-<short-baseline-hash>` containing all doc edits (never mixed with code edits).
- A PR body linking every resolved drift learning, every new resolution learning, and every GitHub issue opened.
- `docs/current-system.md` §9 "Known drift" table shrunk accordingly (resolved rows removed; outcome-B rows kept with a new column linking the GH issue).

Never produced in this workflow:

- Code edits. Ever.
- New top-level doc files.
- ADRs (Workflow 5).
- Retroactive rewrites of closed drift learnings (P-001 — Nothing is Deleted; use `arra_supersede` not file edits).

---

## Steps

### Step 0 — Resolve answered threads in territory (blocking, 3–10 min)

Before fetching the drift queue, run `references/workflow-thread-resolve.md` (Pass 1 + Pass 2) to completion. W4 is especially sensitive to stale threads: many B-class escalations open threads (`arra_thread`), and prior W1/W2/W8 passes may have opened threads that resolve *exactly* a drift item you're about to triage — a `[AWAITING_THREAD:<id>]` whose thread has since been answered may have already been resolved by the human, making its associated `#drift` learning obsolete. Miss that, and you either spend W4 effort on a drift that's already been answered or — worse — contradict the human's answer.

- **Pass 1 (primary)**: `grep -rEn '\[(AWAITING_THREAD|RATIFICATION_PENDING):([A-Za-z0-9_-]+)\]'` across pg-writer territory. For each `answered` id, run the 4-step resolution block; the doc update may dissolve a drift item on the queue you're about to process.
- **Pass 2 (safety-net)**: `arra_threads(status="answered", limit=50)` → any pg-writer id not found in Pass 1 = workflow bug, file `#workflow-bug + #thread-orphan`.

**Gate:** Step 1 does not start until Pass 1 = 0 remaining and Pass 2 = 0 unfiled. Drifts that resolve via thread don't belong in the W4 queue — they belong in a closed thread + an updated doc.

### Step 1 — Fetch the queue (5 min)

```
arra_search query="drift repo:mobiz-payment-gateway current technical-writer" type=learning limit=30
arra_reflect
```

Write each hit to a scratch list in this format (keep the scratch — you will paste it into the retrospective at the end):

```
[ ] <learning-id>  |  <feature-tag>  |  <one-line summary>  |  source: <doc>:<line> + <code>:<line>@<short>
```

Drop from the list:

- Items that already have a `#resolution` or `superseded_by` successor.
- Items tagged `#regression-candidate` without a `#resolution` — those are **code team's** queue, not yours. Do not re-open.
- Items older than **6 months** without a `related:` trace — these are archaeological and need the human to decide whether they are still meaningful. Park them separately; do not resolve blindly.

### Step 2 — Triage (10 min)

For each remaining item, read **both** sides — doc and code — and classify as (A) / (B) / (C) per the outcome table above.

Heuristics that usually work:

- If the code was changed in a commit **after** the drift was filed → almost always (A).
- If the doc cites an invariant like "balance is never negative" and the code path in question does not guard against negative balance → investigate carefully; this may be (B).
- If the cited file has been **deleted** → (C) obsolete.
- If the drift's `source:` cites a file that was **renamed** → read the git-log of the rename and follow it; the drift may be live at the new path.
- If two drift items share the same code file and same feature tag → check if they are the same thing with different wordings; one resolution may close both → (C) duplicate for the second.

Do not skip triage. A reconciliation done without triage mislabels (B) cases as (A) and silently "fixes" documentation that was correctly describing a code bug.

### Step 3 — Resolve (A)-class items: fix the doc (15 min per 5 items)

For each (A) item:

1. Open the cited doc section. Read the surrounding 20–30 lines, not just the `[DRIFT]` line — the fix often affects an adjacent sentence.
2. Re-read the cited code at HEAD. Confirm the current behavior is what you are about to describe.
3. Rewrite the doc section so it matches the code at `HEAD`. Update the `// verified: <path>@<short>` to the current short hash.
4. Remove the `[DRIFT]` marker.
5. If the drift item also carries an `[UNVERIFIED]` sibling marker in the same section, decide whether the rewrite verifies it too — if yes, remove that marker too and note it in the learning.
6. Add the fix to the working tree; do not commit yet (batch all drift resolutions into one commit at Step 6).

### Step 4 — Resolve (B)-class items: escalate code bug (15 min per item)

For each (B) item:

1. **Do not edit the doc.** The doc is describing the intended invariant — it is the spec. The code is wrong.
2. Open a GitHub issue:

   ```
   gh issue create \
     --title "regression-candidate: <one-line invariant violation>" \
     --body "$(cat <<EOF
   ## Evidence
   - Invariant stated in: <doc path + section anchor>
   - Code violating invariant: <source path + line>
   - Oracle drift learning: <learning-id>
   - First filed: <created date>

   ## Expected (per doc)
   <short summary>

   ## Actual (per code)
   <short summary>

   ## Next step
   Assigned to backend_developer team for fix. Writer will close the drift learning **only after** the code change lands and re-verification passes.
   EOF
   )"
   ```

3. File a follow-up `arra_learn`:

   ```yaml
   tags:
     - technical-writer
     - repo:mobiz-payment-gateway
     - current
     - <feature>
     - regression-candidate
   related:
     - <drift-learning-id>        # still open; do not supersede
   source: <doc path>:<line> + <code path>:<line>@<short>
   project: github.com/kokarat/mobiz-payment-gateway
   ```

   Content: issue URL, summary of the invariant, the exact line(s) in code that violate it, and a statement that the drift remains **open** until code is fixed.

4. `arra_thread(title="regression-candidate: <topic>", message="<summary + issue URL + drift id>")` + insert `[AWAITING_THREAD:<id>]` at the drift row in `docs/current-system.md §9`. Threads are searchable, persist per P-001, and the next W4 Step 0 sweeps them on `status="answered"`. (Prior version used `arra_handoff`, which currently has no subscriber model — the thread discipline replaces it; see the `decision-technical-writer-workflow-2` learning from 2026-04-18.)

5. Do **not** call `arra_supersede` on the drift item. Leave it open.

### Step 5 — Resolve (C)-class items: close as obsolete/duplicate (5 min per item)

For each (C) item:

1. If the drift references a feature still present in the doc (but the feature was removed from code) → delete the doc section describing it; per P-001 the deletion is tracked in git history, and the originating learning stays in the vault forever.
2. If the drift is a **duplicate** of another drift that was already resolved → call `arra_supersede(oldId, duplicate_of_id)` with a one-line `reason: "duplicate of <id>; closed as part of that resolution"`.
3. If the cited file or section is simply gone and the drift cannot be reconstructed → file a one-line `#resolution` learning with `reason: "obsolete — <why> at <commit>"` and `arra_supersede(oldId, newId)`.

No doc edit is required for pure-obsolete items beyond removing a now-empty `[DRIFT]` marker if one still lingers in a doc.

### Step 6 — Update §9 "Known drift" (5 min)

Open `docs/current-system.md` §9. For each row:

- (A) and (C) resolutions: **remove the row**.
- (B) regression candidates: **keep the row, add a column** linking the GitHub issue; change status to `ESCALATED: #<issue-number>`.

Bump the doc's `// verified:` citation on any section you touched in Step 3.

### Step 7 — Write `arra_learn` resolutions + link with `arra_supersede` (5 min)

This step has **two halves**. The `arra_supersede` call is non-negotiable for (A) and (C) — without it the old drift learning has no machine-readable pointer to its successor, and `/api/search` / `arra_search` cannot surface the `superseded_by` flag to future readers.

#### 7a. Write the resolution learning (one per A and C; one per B per Step 4)

Template for (A) and (C):

```yaml
title: "resolution — <feature>/<topic> drift closed"
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - <feature>
  - resolution
source: <doc-path>:<line>@<new-short> + <code-path>:<line>@<new-short>
supersedes:
  - <original-drift-learning-id>
related:
  - <any sibling drift learnings resolved in the same edit>
project: github.com/kokarat/mobiz-payment-gateway
---

## Drift class (original)
<verbatim copy of the original drift's description, one paragraph>

## Resolution path (taken)
(A) fix-doc | (B) fix-code-escalated | (C) obsolete-or-duplicate

## What changed
- Doc: <section heading> rewritten to match code at <short-hash>.
- Code: unchanged. (Always, for A/C. For B: see linked issue and the regression-candidate learning.)

## How I verified
<2–3 sentences — which file I read, which specific line numbers, what the new `// verified:` cite points at>

## Residual risk
<one sentence — any sibling drift still open, any doc section with a new [UNVERIFIED] because of this change, or "none">
```

The `supersedes:` frontmatter field is informational (human-readable); the actual machine-readable link lives in the `oracle_documents.superseded_by` column, populated by the `arra_supersede` call in 7c.

#### 7b. Verify the resolution learning is indexed

`arra_supersede` requires both `oldId` and `newId` to exist in `oracle_documents`. If Oracle has inline embedding (`arra_learn` post-PR #754 writes directly to DB), the new row is available immediately. On older Oracle builds the indexer is batched — the file may not be queryable for up to a few minutes.

Quick check before calling supersede:

```bash
sqlite3 ~/.arra-oracle-v2/oracle.db "SELECT id FROM oracle_documents WHERE id = 'learning_<YYYY-MM-DD>_resolution-<slug>';"
```

- If the row exists → proceed to 7c.
- If not → either wait for the next indexer pass (check `sqlite3 … "SELECT last_indexed FROM indexing_status;"`), or force: `bun src/indexer/cli.ts`.
- If the indexer is unreachable / offline → **defer supersede to a follow-up session**: leave the resolution learning filed (it stands on its own), add a `#pending-supersede` tag to it, and `arra_inbox` a handoff for the next session to complete the supersede. **Do not block the PR on indexer availability.**

#### 7c. Call `arra_supersede` — one call per (A) and per (C)

```
arra_supersede(
  oldId="<original-drift-learning-id>",
  newId="<resolution-learning-id>",
  reason="<one short sentence — the root cause of the drift or why now obsolete>"
)
```

- **(A) fix-doc:** `reason` is typically "Doc aligned to code at @<short>" or similar.
- **(C) obsolete:** `reason` is `"obsolete — <why>"` or `"duplicate-of:<other-id>"`.
- **(B) regression-candidate:** **do NOT call supersede.** The drift stays open (the code is still wrong); the `#regression-candidate` learning is filed via `related:` pointer only.

#### 7d. Verify supersede landed

One-shot DB check — should return the `newId`:

```bash
sqlite3 ~/.arra-oracle-v2/oracle.db "SELECT superseded_by FROM oracle_documents WHERE id = '<original-drift-learning-id>';"
```

If empty → supersede didn't commit (check error output). If correct → done. Record the verification (one line per drift) in the retro so the chain is auditable even if the DB is later rebuilt.

#### 7e. Record the resolution as an `arra_trace` + chain it

Per-drift resolution is a mini investigation: read old drift → find commit → verify behavior → write resolution. That *is* a trace. Record it so future agents can `arra_trace_chain(<any>)` and see the narrative of this session's reconcile pass.

For **each** resolved drift (A or C):

```
# create a trace capturing this drift's resolution
arra_trace(
  query="resolution — <drift summary>",
  queryType="evolution",            # doc/code drift evolved to matching state
  scope="project",
  project="github.com/kokarat/mobiz-payment-gateway",
  foundCommits=[{ hash, shortHash, date, message }],   # the commit that introduced or resolved the drift
  foundFiles=[{ path: <doc>, type: 'other', matchReason: '<section updated>', confidence: 'high' }],
  foundLearnings=["<original drift learning source_file>", "<new resolution learning source_file>"]
)
# store returned trace_id
```

Then **chain it to the previous trace of this session** (building a narrative chain of "what I fixed today"):

```
arra_trace_link(
  prevTraceId="<previous drift's trace_id>",   # or the session's first trace if this is #2
  nextTraceId="<this drift's trace_id>"
)
```

The **first** trace in the session has no prevTraceId — it's the head of the chain. The **last** trace will have awakening potential (see §Distillation in SKILL) once the reviewer weighs in.

Skip Step 7e entirely for (B) regression-candidates — the drift stays open, no resolution narrative exists yet. A future session that actually closes the code bug will create the trace then.

At session end, `arra_trace_chain(<first trace id>)` returns the full chain. Paste it into the retro as the narrative of "this W4 session closed N drifts in sequence."

### Step 8 — Commit + PR (5 min)

Branch: `docs/reconcile-drift-<short-hash-of-current-baseline>`.

Commit message:

```
docs: reconcile drift queue — <N> items closed

- <N_A> doc-rewrites (class A)
- <N_B> regression-candidates escalated (class B) — see linked issues
- <N_C> obsolete/duplicate closures (class C)

Every resolution has a supersedes link (A/C) or related link (B) back
to the originating #drift learning. §9 of docs/current-system.md
updated. docs/.baseline unchanged.

No code behavior changes.
```

PR body includes:

- The scratch list from Step 1 with each item's final outcome (A/B/C) and its learning-id.
- Links to all new `#resolution` and `#regression-candidate` learnings.
- Links to all GitHub issues opened in Step 4.
- The usual "**I will not merge this PR. Awaiting human review.**" line (per `.agent/AGENTS.md` §9).

Per `.agent/AGENTS.md` §9 (safety rules), **never** `gh pr merge`.

### Step 9 — Retrospective (5 min)

Run `rrr` per `.agent/AGENTS.md` §7. AI Diary + Honest Feedback mandatory.

Specific things this workflow's retro **must** cover:

- How many items landed in each class. If (B) is > 30% of items, that is a signal the code is drifting from invariants faster than baselines are catching — raise it.
- Any drift item that was harder than 10 minutes to triage — those usually point at genuinely ambiguous code that may need an ADR (hand off to Workflow 5).
- Any drift older than 3 months. Long-lived drift is usually a smell of an orphaned subsystem; name it so the next retro can pick up the thread.

---

## Template for a resolved §9 "Known drift" row removal

Before:

```markdown
| Deposit FIFO matching | controllers/Deposit.go:241 | doc says FIFO, code does amount-first | [learning:2026-04-15_drift-deposit-fifo] | open |
```

After the resolution lands the row is **removed entirely**. The audit trail lives in: the git diff of the doc, the `#resolution` learning, and (via `supersedes`) the original drift learning's `superseded_by` pointer. Readers who need history click through; readers who need current state see a clean table.

For a (B) escalation the row stays but changes:

```markdown
| Deposit FIFO matching | controllers/Deposit.go:241 | doc says FIFO, code does amount-first | [learning:2026-04-15_drift-deposit-fifo] | **ESCALATED: #412** |
```

Once issue #412 is closed and the code is re-verified, a later Workflow 4 pass will complete the close as a (A)-class resolution.

---

## Definition of Done

This workflow is complete **only** when all are true:

- [ ] Every item from Step 1's scratch list has exactly one of the outcomes (A)/(B)/(C) recorded.
- [ ] Every (A) and (C) has a `#resolution` learning **AND** `arra_supersede(oldId, newId, reason)` **was called** **AND** the supersede landed (7d verify query returned the `newId`). If indexer lag forced supersede to defer → the resolution learning carries `#pending-supersede`; next W4 Step 1 grounding search for `#pending-supersede` picks it up and completes it.
- [ ] Every (B) has a `#regression-candidate` learning, an `arra_thread` with `[AWAITING_THREAD:<id>]` anchor at §9, and a linked GitHub issue. **No `arra_supersede` call for (B)** — drift stays open.
- [ ] `docs/current-system.md` §9 reflects the new state (resolved rows gone; (B) rows marked ESCALATED with issue number).
- [ ] All `[DRIFT]` inline markers touched in this pass are either removed (A/C) or left in place with an `[ESCALATED: #issue]` annotation (B).
- [ ] Git branch pushed; PR opened; **not merged**.
- [ ] Retrospective written under `ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_slug.md`, including AI Diary + Honest Feedback.
- [ ] Retro carries total counts by class and any residual items the human should know about. No separate handoff step; PR body lists open `arra_thread` ids for (B) items.
- [ ] Vault audit clean: `bash $(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/scripts/verify.sh | grep -A 3 frontmatter` shows `✅ no double-wrap` + `✅ every indexed doc has a title:`.
- [ ] Step 0 ran to completion: Pass 1 (doc-anchored grep) left zero `answered`-status markers in pg-writer territory; Pass 2 (orphan scan) returned zero pg-writer-territory threads not in Pass 1. If Step 0 dissolved items that were otherwise on the Step 1 queue (thread answer pre-resolved them), those items were removed from the scratch list and noted in the retro — they are not a "closed" (A)/(B)/(C) outcome; they are "pre-resolved via thread".
- [ ] **Anchor discipline**: every `arra_thread(...)` call made in this pass (typically B-class escalations to request human decision) inserted a paired `[AWAITING_THREAD:<id>]` marker into either §9 "Known drift" row or the resolution learning's `related:` list in the same PR. Orphan thread count = 0.

`docs/.baseline` is **not** bumped by this workflow — reconciling drift does not re-verify the whole system. A baseline bump is Workflow 1's job.

---

## Common pitfalls (learned the hard way)

- **Silent doc rewrites.** Editing a doc to match the code without logging a `#resolution` learning breaks the audit trail and violates P-004. A reader in 6 months cannot tell whether the doc is correct because the code was always this way, or because someone aligned it after a drift. Always write the learning; always call `arra_supersede`.
- **Mass-closing drifts in one learning.** One resolution per original drift. Batching them into a "closed 12 drifts today" entry makes each individual drift unsearchable and breaks the `supersedes:` pointer. Patient, not efficient, is the rule here.
- **Calling (B) an (A).** The commonest mistake — a drift says "doc claims X, code does Y." Reflex: rewrite doc to describe Y. But if X was a stated invariant (P-004: documents are also claims about what we *meant*), rewriting the doc silently erases the intent and lets a real bug live. Check whether the doc's X was an invariant or a description.
- **Reconciling drift during a feature PR.** Mixing `docs:` commits with code changes makes the reconciliation invisible in `git log` and risks the code change being blamed for the doc edit. Always its own branch.
- **Skipping triage because the queue is big.** A 30-item drift queue tempts "mark all (A), move on." Don't. The worst time to lose triage discipline is when the queue is long — it's when (B) cases hide.
- **Forgetting to update §9.** The doc's own "Known drift" table is the public-facing state. If you close 5 drift learnings but leave the table untouched, the next agent sees an inconsistent vault and either re-opens the same drift or panics. Always sync.
- **Using `#drift` tag on the resolution.** The resolution learning is tagged `#resolution`, not `#drift`. Re-using `#drift` doubles the queue size on the next pass.
- **Reconciling archaeological drift without the human.** Drift items > 6 months old may reference code, conventions, or features the current team does not remember. Park them; ask the human.
- **Skipping `arra_supersede` because "the resolution learning explains it".** The resolution learning is prose; `superseded_by` is machine-readable. `arra_search` and `/api/search` surface the `superseded_by` / `superseded_at` / `superseded_reason` fields to callers, but only if `arra_supersede` was actually called. Without the call, old drift learnings look open to future agents and may be re-opened or re-resolved. This was the #1 gap observed in the first live Workflow 4 run (2026-04-16) — workflow prose prescribed supersede but indexer lag blocked it, and the operator didn't treat "defer supersede" as a pending task.
- **Calling `arra_supersede` before the resolution learning is indexed.** The MCP tool rejects unknown `newId`. With PR #754 (inline vector embedding + direct INSERT) the new learning is available immediately; without PR #754 the indexer may lag. Always run the 7b verify query before 7c. On old Oracle builds, fall back to a `#pending-supersede` tag + handoff.
- **Filing standalone `arra_trace` per drift without chaining.** A W4 session that closes N drifts but leaves N disconnected traces loses the session narrative. Next agent `arra_trace_list` sees N root-depth raw traces with no indication they're from one session. Always run Step 7e's `arra_trace_link(prev, next)` to build a chain. Session's first trace is the chain head; paste `arra_trace_chain(head)` into the retro.

---

## Escalation

- **(B) count > 30% of the queue** — the code is drifting from invariants. Halt after finishing the current item, open `arra_thread(title="W4 halt: (B) count >30%", message="<count> + top-3 offending surfaces")` and anchor it in the retro's §"Session map". Do not start another Workflow 4 run until a code pass has happened.
- **Drift in a security-sensitive area** (auth, JWT, RBAC, rate limit, callback) — before publishing the resolution PR, CC `security_auditor` in the PR description. Do not resolve drift in this area silently.
- **Drift that depends on a decision not yet made** — the code and doc disagree because the feature is mid-design. Park the drift (do not close as obsolete), file a `handoff` to `system_architect` / `requirement_writer`, and move on to the next item.
- **Drift in a file this role does not own** (e.g. `integration-tests/`, `bank-bot/src/…` selectors) — leave it for `tester`. Add `#out-of-territory` to the drift's `related:` list and skip. Do not resolve drift outside territory.

---

## Change log for this workflow file

- 2026-04-16 — Initial version, written during `tester` activation. Drafted against the integration-test-writer→tester supersession as a working example of how resolutions get filed; shape follows workflow-1 and workflow-2 conventions (same preamble, DoD, pitfalls, escalation blocks). Awaiting first live run by `pg-writer-oracle` for real-world refinement.
- 2026-04-17 — Step 7 expanded to 7a/7b/7c/7d after the first live run (`ψ/memory/retrospectives/2026-04/16/17.00_workflow-4-first-live-run.md`) observed that `arra_supersede` was silently deferred due to indexer lag, leaving drift learnings without machine-readable successor pointers. New sub-steps make the verify/call/confirm cycle explicit, add a `#pending-supersede` escape hatch for indexer outages, and add two pitfalls (skipping supersede because the prose explains it; calling supersede before the resolution is indexed). DoD checklist tightened to require the 7d verify query to return the `newId` before the box is checked.
- 2026-04-17 (later) — Added Step 7e (arra_trace + arra_trace_link) so per-drift resolutions form a **session chain** instead of disconnected traces. Without the chain, a future agent running `arra_trace_list` sees N raw traces with no indication they're from one session. With the chain, `arra_trace_chain(<head>)` returns the narrative of the session's reconcile pass — pasteable into retro. New pitfall entry.
- 2026-04-17 (later) — Added **Step 0 (Resolve answered threads in territory)** as a blocking gate before Step 1. Motivation for W4 specifically: a `[AWAITING_THREAD:<id>]` whose thread is now answered may pre-resolve a queued drift — miss that and you either do redundant W4 work or contradict the human's answer. Scoping via doc-anchored grep. See `workflow-thread-resolve.md`. DoD added: Step 0 clears to zero, and thread anchors opened during this pass (B-class escalations) must live in §9 or the resolution learning's `related:` field in the same PR.
