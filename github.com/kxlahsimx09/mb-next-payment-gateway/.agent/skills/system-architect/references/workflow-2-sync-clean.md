# Workflow 2 — Sync-Clean: Export a reader-ready architecture snapshot

> Reference document for the `system-architect` agent.
> Read this file before running the workflow. Do not skim.

This workflow produces `docs/architecture.md` — a clean, human-readable snapshot of all ratified architecture decisions — by stripping process artifacts from the working document `docs/adr.md`.

`docs/adr.md` is a **working document**: it accumulates revision logs, inline citations, ratification markers, thread anchors, pass metadata, and provisional sections. That noise is essential for W1 (refine-adr) but creates friction for anyone who just needs to understand the architecture.

`docs/architecture.md` is a **derived document**: generated on demand, overwritten each run, never edited directly. It is the version you hand to implementation agents, reviewers, or any reader who should not care how the decisions were reached.

---

## When to run this workflow

Run when **any** of the following is true:

- One or more ADR sections just promoted from `#provisional` → `#decision` (a ratification pass completed).
- A human asks for a "clean", "readable", or "shareable" version of the architecture.
- Preparing to hand off to an implementation agent who needs the architecture without process trail.
- `docs/architecture.md` is stale by more than **7 days** relative to `docs/adr.md`'s last commit.

Do **not** run this workflow to:

- Resolve open threads or ratify design decisions — that is W1 territory.
- Modify `docs/adr.md` — this workflow is read-only on the source.
- Backfill historical decisions — produce what is ratified now; history lives in `docs/adr.md` and its revision-log archive.

---

## Source and output

| File | Role | Editable by this workflow |
|---|---|---|
| `docs/adr.md` | Working document (W1 output) | **Read-only** |
| `docs/adr/revision-log-archive-YYYY-MM.md` | Historical revision log archives | **Read-only** |
| `docs/architecture.md` | Clean snapshot (W2 output) | **Owned — overwrite each run** |

`docs/architecture.md` must carry a generation header (see §Template) so readers know it is derived and where to find the authoritative source.

---

## What to strip (explicit rules)

Apply every rule below. Rules are non-negotiable — do not "preserve just this one" without a noted exception in the retro.

### Rule 1 — Remove the entire Revision log section

Everything from the `## Revision log` heading (or `### Revision log`) to the end of the file. This includes archived-entry references like `#### Earlier entries — archived to [...]`.

### Rule 2 — Simplify ADR section titles

Source titles carry process metadata. Strip it to the architectural statement only.

| Before (source) | After (clean) |
|---|---|
| `ADR-4a: Withdrawal Dispatch … (ratified \`#decision\`, 2026-04-22 GMT+7)` | `ADR-4a: Withdrawal Dispatch …` |
| `ADR-4c: … TTL Terminal … (\`#provisional\` \[RATIFICATION_PENDING:55\])` | `ADR-4c: … TTL Terminal … *(under design)*` |
| `ADR-6: Bank Bot Architecture (refined 2026-04-23 pass 1; design-doc extraction 2026-04-27)` | `ADR-6: Bank Bot Architecture` |

Strip from titles: `(ratified \`#decision\` ...)`, `(refined YYYY-MM-DD pass N; ...)`, `\`#provisional\``, `\`#decision\``, `[RATIFICATION_PENDING:N]`, `[AWAITING_THREAD:N]`, thread references, pass references.

### Rule 3 — Strip inline evidence citations

Remove lines or inline comments that are evidence-trail bookkeeping, not architecture:

- `// source: learning:<id>` — remove
- `// prior-art: flow:<slug>@<repo>` — remove
- `// prior-art: learning:<id>` — remove
- `// verified: <path>@<sha>` — remove
- `// code: <path>@<sha>` — remove
- `// verified:` anywhere — remove
- Any parenthetical like `(source: learning_YYYY-MM-DD_...)` — remove

If a sentence becomes grammatically incomplete after removing a citation, rewrite the sentence to stand alone while preserving its meaning.

### Rule 4 — Strip ratification and thread markers

Remove in-body markers completely:

- `[RATIFICATION_PENDING:N]` — remove (the section title already says `*(under design)*`)
- `[AWAITING_THREAD:N]` — convert to a clean **Open question:** bullet (see Rule 8)
- `[SUPERSEDED YYYY-MM-DD — see §X]` — remove the annotation; remove the superseded text block entirely if it is clearly replaced elsewhere; keep it as a plain paragraph if the superseded context is still informative (judgment call — note the decision in the retro)
- `[PROVISIONAL]` — remove

### Rule 5 — Strip update-wrapper blocks, keep the content

`docs/adr.md` uses blockquotes to record in-place amendments:

```
> **Update (pass N, YYYY-MM-DD GMT+7; ratified via thread #NN):** <content>
```

Strip the wrapper (`> **Update (...):*`). Keep the content as a plain paragraph. The amendment is now part of the decision body as-is; the "when and why it changed" history lives in the revision log that you already stripped.

### Rule 6 — Strip ratification-tracking paragraphs

Remove paragraphs whose entire purpose is to record the ratification process, not the architecture. Signals:

- Starts with `**Implementation:**` and describes when the section was ratified or what pass it was done in.
- Ends with `ratified via thread #N` as its main point.
- Primarily lists thread IDs, learning IDs, trace IDs, commit SHAs.

Keep any paragraph that describes implementation guidance, consequences, or trade-offs — even if it incidentally mentions a thread or commit.

### Rule 7 — Exclude `#provisional` sections (with visibility marker)

If an ADR section is still `#provisional` (marked in the title or body as not yet ratified), do not strip it — include it with a clear callout at the top of the section:

```markdown
> **⚠ Under design — not yet ratified. Contents may change.**
```

This gives readers signal without hiding in-progress decisions entirely.

### Rule 8 — Convert active thread anchors to open questions

For `[AWAITING_THREAD:N]` markers that survive into non-provisional sections (i.e., an active open question inside a mostly-ratified ADR):

Replace with a clean bullet under a `**Open questions:**` heading:

```markdown
**Open questions:**
- *Thread #N:* <one-line description of what is being decided> — awaiting ratification.
```

If the thread is already closed but the marker was not stripped in W1 (an orphan marker), remove it entirely and note it in the retro as a W1 cleanup item.

---

## What to keep (explicit)

- All ADR section bodies after stripping: Context, Decision, Options considered, Consequences, Trade-offs, and any diagrams (mermaid / ASCII).
- Cross-references between ADR sections (`§ADR-4a`, `§ADR-4b`, etc.) — these are architectural, not process.
- Extracted design doc references (`docs/design/<subsystem>/`) — these are architecture pointers.
- `**Open questions:**` bullets produced by Rule 8.
- The `*(under design)*` marker on provisional section titles (Rule 2).
- The `> ⚠ Under design` callout block on provisional section bodies (Rule 7).

---

## Template — `docs/architecture.md` header

Every generated output must begin with this header (fill in the blanks):

```markdown
# Architecture — mb-next-payment-gateway

> **Source of truth:** [`docs/adr.md`](adr.md) — maintained by `system-architect` via W1 refine-adr.
> **This file is derived.** Generated by W2 sync-clean on <YYYY-MM-DD GMT+7>. Do not edit directly.
> **ADR sections:** <N> ratified `#decision` / <M> under design `#provisional` / <K> `[AWAITING_THREAD]` open questions.

---
```

Followed immediately by the cleaned ADR content.

---

## Steps

### Step 0 — Verify source freshness (2 min)

```bash
git log --oneline -3 -- docs/adr.md
git log --oneline -1 -- docs/architecture.md 2>/dev/null || echo "architecture.md does not exist yet"
```

Confirm `docs/adr.md` is at the latest commit on `main`. If `docs/architecture.md` already exists, note its age. If it was generated today and `docs/adr.md` has not changed since, this workflow is a no-op — report that and stop.

### Step 1 — Read `docs/adr.md` end-to-end (10–15 min)

Full read. Do not skim. Build a mental inventory:

- How many ADR sections exist?
- Which are `#decision`, which are `#provisional`?
- How many `[AWAITING_THREAD:N]` markers remain in non-provisional sections?
- Where does the `## Revision log` begin?

Record the counts — they go into the generation header (§Template).

### Step 2 — Apply strip rules and build clean output (20–40 min)

Working section by section, apply all 8 rules in order. Produce the full clean text in one pass.

Ordering guidance:

1. Open `docs/adr.md` (Read tool).
2. Find the `## Revision log` (or `### Revision log`) heading — note its line number. Everything from that line to end of file is removed (Rule 1).
3. Walk every ADR section heading — apply Rule 2 (title simplification).
4. Walk the body — apply Rules 3–8 in sequence.
5. Prepend the generation header (§Template).

**Do not edit `docs/adr.md`.** All edits go into the new `docs/architecture.md`.

If applying a rule requires a judgment call (e.g., Rule 4 superseded-text retention), make the call, keep the cleaner version, and log the judgment in the retro's §Strip decisions section.

### Step 3 — Write `docs/architecture.md` (2 min)

Write the clean output to `docs/architecture.md` (overwrite if exists).

### Step 4 — Sanity check (5 min)

Read `docs/architecture.md` top-to-bottom. Verify:

- [ ] Generation header present with accurate counts.
- [ ] No `[RATIFICATION_PENDING`, `[AWAITING_THREAD`, `[SUPERSEDED` raw markers remain.
- [ ] No `// source:`, `// prior-art:`, `// verified:`, `// code:` inline citations remain.
- [ ] No `## Revision log` heading or revision-log entries remain.
- [ ] Provisional sections have the `> ⚠ Under design` callout.
- [ ] No raw `#decision`, `#provisional` tag labels remain in body text.
- [ ] Document reads coherently as standalone architecture prose.

If any check fails, fix before committing.

### Step 5 — Commit and push (5 min)

```bash
# Fetch first — never trust local main (AGENTS.md §3d / thread #199).
# `git checkout -b architect/...` alone branches off the primary's last-pulled
# SHA which can be days stale (the wt-48 / PR #215 stale-base trap).
git fetch origin --quiet
git switch -c architect/w2-sync-clean-<YYYY-MM-DD> origin/main
git add docs/architecture.md
git commit -m "architect: W2 sync-clean — generate architecture.md snapshot (<YYYY-MM-DD>)"
git push -u origin HEAD
gh pr create \
  --title "architect: W2 sync-clean — architecture snapshot <YYYY-MM-DD>" \
  --body "$(cat <<'EOF'
## Summary
Regenerate \`docs/architecture.md\` — the clean, reader-ready snapshot of all ratified ADR decisions.

## Source
\`docs/adr.md\` at <short-sha>.

## ADR coverage
- Ratified (#decision): <N> sections
- Under design (#provisional): <M> sections
- Open questions ([AWAITING_THREAD] in non-provisional sections): <K>

## What was stripped
- Revision log (<line count> lines removed)
- Inline citations (// source / // prior-art / // verified / // code)
- Process markers ([RATIFICATION_PENDING] / [AWAITING_THREAD] → Open questions / [SUPERSEDED])
- Update-wrapper blockquotes (content preserved as plain prose)
- Ratification-tracking paragraphs

## What was preserved
- All #decision section bodies (Context / Decision / Consequences / Trade-offs / Diagrams)
- #provisional sections with ⚠ callout
- Cross-references between ADR sections
- Design doc pointers (docs/design/<subsystem>/)

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**Do not merge.** Provide the PR URL and wait for human approval.

### Step 6 — File `arra_learn` + `arra_trace` (3 min)

```
arra_learn(
  pattern="W2 sync-clean — architecture.md regenerated <YYYY-MM-DD>.\n\nSnapshot covers <N> ratified ADR sections, <M> provisional, <K> open questions. Stripped: revision log, inline citations, process markers. Source: docs/adr.md@<short-sha>.\n\nNext regeneration trigger: next ratification pass or >7 days.",
  concepts=["system-architect", "repo:mb-next-payment-gateway", "next", "adr", "sync-clean", "architecture-snapshot"],
  project="github.com/kxlahsimx09/mb-next-payment-gateway",
  source="docs/architecture.md@<short-sha>"
)
```

Then trace:

```
arra_trace(
  query="W2 sync-clean — architecture.md snapshot <YYYY-MM-DD>",
  queryType="general",
  scope="project",
  project="github.com/kxlahsimx09/mb-next-payment-gateway",
  foundLearnings=["<source_file from arra_learn response>"]
)
```

No `arra_trace_link` expected for sync-clean passes — this workflow does not refine the architecture, so there is no evolutionary chain to link. If you choose to link to the most recent W1 trace (documenting "clean snapshot after this ratification"), that is allowed but not required.

### Step 7 — Retrospective (5–10 min)

Write a short retro at `ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_w2-sync-clean.md`. Required sections:

- **Source commit** — `docs/adr.md` SHA used.
- **ADR counts** — ratified / provisional / open questions.
- **Strip decisions** — any judgment calls made when a rule required interpretation (Rule 4 superseded-text, Rule 8 orphan-marker). Log "none" if rules applied cleanly.
- **AI Diary** — brief first-person note on the pass.
- **Honest Feedback** — anything that should improve these strip rules for next time.

---

## Definition of Done

All must hold before marking the session complete:

- [ ] `docs/architecture.md` written and passes the §Step 4 sanity check.
- [ ] Generation header accurate (counts, date).
- [ ] `docs/adr.md` unmodified (confirm with `git diff docs/adr.md` = empty).
- [ ] PR opened (not merged); URL reported.
- [ ] `arra_learn` filed.
- [ ] `arra_trace` filed.
- [ ] Retrospective written with Strip decisions section.

---

## Anti-patterns

- **Editing `docs/adr.md` during this workflow.** `docs/adr.md` is read-only for W2. If you find a W1 cleanup item (orphan marker, stale superseded block), log it in the retro and file an `arra_learn` tagged `#w1-cleanup` for the next W1 pass to fix.
- **Merging the PR yourself.** AGENTS.md §9. Never merge without explicit user approval.
- **Stripping open questions.** Active `[AWAITING_THREAD:N]` markers in ratified sections must become clean `**Open questions:**` bullets (Rule 8), not disappear silently.
- **Keeping revision-log entries "because they're informative".** They are not part of the architecture snapshot. Every revision-log line goes. The human can read `docs/adr.md` or the archive for history.
- **Running W2 instead of W1 when a design question surfaces.** W2 is a read-only export pass. If reading `docs/adr.md` reveals a design gap or stale provisional section, queue it for W1 and note it in the retro — do not address it mid-W2.
- **Editing `docs/architecture.md` by hand between regenerations.** The file is derived. Manual edits will be overwritten on the next W2 run. Any real architecture content must land in `docs/adr.md` first via W1.

---

## Change log

- 2026-04-30 — Initial version. Authored by `brew-ops` on behalf of `system-architect` fleet. Trigger: user request for a clean, as-is ADR snapshot separate from the W1 working document. Defines 8 strip rules, 7-step workflow, DoD checklist, and `docs/architecture.md` as the canonical output path. Paired with SKILL.md update adding W2 to the workflows table.
