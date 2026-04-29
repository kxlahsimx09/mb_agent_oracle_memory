# Workflow 1 — Refine the ADR

> Reference document for the `system-architect` agent.
> Read this file before running the workflow. Do not skim.

This workflow iteratively refines `docs/adr.md` — the single consolidated architecture-decision document for `mb-next-payment-gateway`. Each run picks **one focus theme**, gathers evidence from the five canonical inputs, and improves that aspect of the ADR. The workflow is **repeatable indefinitely**; successive passes compound into a progressively better document.

The ADR file is intentionally a single `docs/adr.md` (not a per-decision `docs/adr/NNNN-*.md` tree) for this stage of the project. The document holds the whole current architectural picture; per-decision files may split off later if sections grow past ~400 lines.

---

## When to run this workflow

Run when **any** of the following is true:

- `docs/adr.md` does not exist (first run — generates the skeleton; see §Baseline vs refine below).
- A focus theme has surfaced from Oracle memory, human conversation, or current-system drift that the ADR does not yet address.
- An answered thread resolves an architectural question previously marked `[AWAITING_THREAD]` or `[RATIFICATION_PENDING]` in the ADR.
- A human explicitly asks for a "refine pass" or names a specific area ("let's sharpen the withdrawal queue section," "revisit the OTP relay trade-offs").
- It has been more than **14 days** since the last refine pass on any section (passive decay — prior-art in mobiz/bank-bot may have moved).

Do **not** run this workflow for:

- Scaffolding code (future `backend-developer` job).
- Writing public-facing docs (future `technical-writer` once spawned in this repo).
- Resolving drift between next-system design and *code that doesn't exist yet* (there is no next-system code — P-004 inverts for greenfield; see AGENTS.md §8).

---

## Baseline vs refine

The first-ever run is a **baseline generation** pass. Subsequent runs are **refinement** passes. The difference:

| Aspect | Baseline (run 1) | Refine (run 2+) |
|---|---|---|
| Scope | Full 5-source sweep; generates skeleton covering all known subsystems at high level. | Single focus theme; deep dive into one section. |
| Duration | 2-4 hours. | 60-120 min. |
| Output | `docs/adr.md` created from template below + `## Revision log` seeded. | Modified section + new `## Revision log` entry. |
| Thread activity | Expect many `[AWAITING_THREAD]` anchors — designing in the fog. | Fewer new threads; mostly closes existing ones. |

Running workflow 1 always **chooses** between baseline and refine based on whether `docs/adr.md` exists. The step sequence is the same; the scope of Step 2 (focus theme) expands to "all sections at skeleton depth" on baseline and narrows to "one section in depth" on refine.

---

## Preconditions

Before Step 0:

- [ ] The repo is clean (`git status --porcelain` is empty). If not, stash or abort — refinement must start from a clean commit.
- [ ] `main` is up to date (`git fetch origin && git status -sb` shows no `behind`).
- [ ] Oracle is reachable (`curl -sf http://localhost:47778/api/stats` returns 200). Hard prerequisite — the workflow cannot run without Oracle because Oracle is the primary input (source #1 + #2 + #3 access flow through `arra_search`).
- [ ] You have at least **90 minutes** of focused time. A rushed refine is worse than no refine.
- [ ] You can answer "what is the focus theme for this pass?" in one sentence before Step 1. If you cannot, run `arra_search` on candidate themes first, pick one, then start.

---

## Territory (what paths this role touches)

Pass 1 (doc-anchored thread grep) runs against **these paths only**:

```
docs/adr.md
docs/design/                # subsystem design docs (future; empty at W1 seed time)
docs/migration-map.md       # when it exists
docs/api/                   # when it exists
docs/data-model.md          # when it exists
```

Files **not** in system-architect's territory (skip):

- Anything in `kokarat/mobiz-payment-gateway` or `kokarat/bank-bot` — those are the `technical-writer` instances' territory. System-architect reads their published learnings via Oracle; it does not edit their files.
- `docs/constraints.md` in mobiz — owned by `pg-writer`. Read via Oracle, never patch.
- The central memory repo's `.agent/` files — those are meta-workflow edits owned by `brew-ops`.

---

## Inputs you will read (priority order — cheap to expensive)

Each input answers a different question. Prefer the cheaper source first; escalate only when the cheaper source is insufficient.

### Input 1 — Oracle memory (cheapest, broadest)

`arra_search` across learnings, retros, threads, and traces. Most current-system facts the architect needs are already memorialized by `pg-writer` and `bot-writer`.

Recommended baseline queries per focus theme (adjust the theme token):

```
arra_search query="<theme> current"                       type=all      limit=20
arra_search query="<theme> flow"                          type=learning limit=10
arra_search query="<theme> drift"                         type=learning limit=5
arra_search query="<theme> constraint"                    type=learning limit=10
arra_search query="<theme> decision"                      type=learning limit=10
arra_search query="system-architect <theme>"              type=all      limit=10   # my own prior art
```

Also scan unresolved threads tagged for the theme:

```
arra_threads(status="pending", limit=50)                  # filter by title mentioning the theme
arra_threads(status="answered", limit=50)                 # same
```

### Input 2 — Current-system `docs/current-system.md` (via Oracle preferred)

Both `kokarat/mobiz-payment-gateway/docs/current-system.md` and `kokarat/bank-bot/docs/current-system.md` are the authoritative descriptions of the current stack. Prefer accessing them via the learnings their writers published (cheaper and already curated):

```
arra_search query="current-system <theme> mobiz"          type=learning limit=10
arra_search query="current-system <theme> bank-bot"       type=learning limit=10
```

Direct file read is allowed when a specific claim in a learning cites a file:line and you need the surrounding context. Use `Read` (read-only); never modify these files.

### Input 3 — Current-system flow maps (`docs/flows/*.md`)

Flow maps in both repos are `technical-writer` W8 output: intent-level sequence diagrams per user flow with per-step `// impl:` pointers. These are the highest-signal source for how a subsystem actually behaves end-to-end.

```
arra_search query="flow:<theme>"                          type=all      limit=20
arra_search query="<theme> sequence"                      type=learning limit=10
arra_search query="flow cross-repo <theme>"               type=learning limit=10
```

For bot-side flows, also check `#cross-repo-sync` learnings — they index the mobiz↔bank-bot contract surfaces the architect must inherit or intentionally redesign.

### Input 4 — Current-system constraints (`docs/constraints.md`)

`pg-writer` W10 (`workflow-10-constraint-harvest`) harvests externally-imposed, hard-to-change facts: bank portals, regulators, 3rd-parties, browser/OS quirks. These are the **inheritance-surface** for the next system — they apply unchanged unless a business-level change negotiates them away.

```
arra_search query="constraint <theme>"                    type=learning limit=20
arra_search query="constraints register"                  type=learning limit=5
```

Constraints learnings carry the `#w10` and `#constraint` tags and live under `kokarat/mobiz-payment-gateway/ψ/memory/learnings/`. Read them; cite them by id in the ADR; treat them as load-bearing.

### Input 5 — Current-system code (most expensive, last resort)

Only when:

- A claim in a learning/flow/constraint is ambiguous and no thread is open on it.
- The architect needs to verify a specific invariant the writer did not cite explicitly.
- A design decision hinges on a low-level detail (concurrency model, retry budget, specific error enum).

Read current-system code **read-only** via the `Read` tool at the ghq paths:

```
~/Code/github.com/kokarat/mobiz-payment-gateway/    # Go + MongoDB
~/Code/github.com/kokarat/bank-bot/                 # Node.js + Playwright
```

Cite as `file.go:42@<commit-sha>` in the ADR. Pin the commit — the claim is frozen in time.

**When direct code reading is required, always file an `arra_learn` tagged `#system-architect #prior-art #repo:cross` capturing the finding, so the next architect run doesn't repeat the read.** This is how expensive source becomes cheap source.

---

## Outputs you will produce

Required:

- **`docs/adr.md`** — the primary artifact. Modified in place. Follow the template in §Template below.
- **New `## Revision log` entry** at the bottom of `docs/adr.md` — exact format:

  ```markdown
  ### <YYYY-MM-DD> — <focus theme> (pass <N>)

  **Focus:** <one-sentence scope>.

  **Delta:**
  - <bullet of what changed in the body>
  - <bullet>
  - ...

  **Sources cited this pass:**
  - learning:<id> (<one-line summary>)
  - flow:<slug>@<repo> (<one-line summary>)
  - constraint:<id> (<one-line summary>)
  - code:<path>@<commit> (<one-line summary>)
  - thread:<id> (<status at pass time>)

  **Threads opened:** <list of ids with one-line question> — or "none".
  **Threads closed:** <list of ids with one-line resolution> — or "none".

  **Learning id:** `learning_<slug>` (filed this pass).
  **Commit:** `<short-sha>` (<branch>).
  ```

- **One `arra_learn` entry** summarizing the pass. Minimum tags: `#system-architect`, `#repo:mb-next-payment-gateway`, `#next`, `#adr`, `#refinement`, plus the focus-theme tag (`#withdrawal-queue`, `#otp`, `#wallet`, …).

Optional (only when conditions are met):

- **New threads** via `arra_thread` — one per architecturally-significant confirmation the human must give. Each thread must be anchored in the ADR with a `[AWAITING_THREAD:<id>]` marker at the specific claim or section it governs.
- **Migration-map delta** in `docs/migration-map.md` — when the refinement defines a current→next mapping. Tag the learning `#migration-map` and `#repo:cross`.

(Note: `arra_trace` was previously listed here as conditional. As of 2026-04-29 it is **mandatory** in Step 8 — every pass produces a trace, every chain candidate produces a link. See Step 8 + Change log.)

Never produced in this workflow:

- Production code, CI configs, infrastructure files (not system-architect's role).
- Edits to files in `mobiz-payment-gateway` or `bank-bot` (not territory).
- Edits to `.agent/` files (meta-workflow; route to `brew-ops`).

---

## Steps

### Step 0 — Thread sweep (blocking, 3–10 min)

Before opening any new design work, clear answered threads in territory. Follow the shared `workflow-thread-resolve.md` procedure (once authored in `references/`; until then, use the inline version below).

**Pass 1 — doc-anchored:**

```bash
grep -rEn '\[(AWAITING_THREAD|RATIFICATION_PENDING):([A-Za-z0-9_-]+)\]' \
  docs/adr.md docs/design docs/migration-map.md docs/api docs/data-model.md 2>/dev/null
```

For each unique id found: `arra_thread_read(<id>)`, dispatch on `(status, last-message role)`:

- `active` or `pending + claude-last` → no-op, thread still waiting.
- `pending + human-last` or `answered` → **run the 4-step resolution block** (read answer → classify → update ADR + strip/transform marker → post closing message + `arra_thread_update status="closed"`).
- `closed` with surviving marker → **orphan-close resolution**: extract the claim the marker anchored, re-grep current state against cited evidence, and either post-hoc cite the resolution (if the answer was captured elsewhere) or re-open the thread with a bump message.

**Pass 2 — safety-net:**

```
arra_threads(status="pending",  limit=50)
arra_threads(status="answered", limit=50)
```

Any thread with `last-message role == "human"` AND title/body in system-architect territory (mentions of `design`, `adr`, `next-system`, specific subsystem slugs) AND not seen in Pass 1 = orphan. File `#workflow-bug + #thread-orphan` learning and `arra_inbox` for human triage.

**Gate:** Step 1 does not start until Pass 1 = 0 pending-effective-answered markers and Pass 2 = 0 in-territory orphans.

### Step 1 — Grounding (5–15 min)

```
arra_stats                                                        # memory health
arra_search query="system-architect refinement" type=learning limit=10
arra_search query="soul-brews-core system-architect" type=principle limit=20
```

Read the current `docs/adr.md` end-to-end **if it exists** (budget 10 min on baseline, 5 min on refine). On refine runs, also read the **last two entries** of `## Revision log` — they tell you what the previous passes already sharpened, so you don't re-chew solved problems.

If `docs/adr.md` does not exist: skip the current-state read; you are on the baseline branch. Go to Step 2 with scope = "all subsystems at skeleton depth."

### Step 2 — Pick the focus theme (5 min, binding)

Write the theme down in one sentence. Good themes are:

- A **subsystem**: "withdrawal queue dispatch and claim."
- A **cross-cutting concern**: "authentication and session model."
- A **decision axis**: "monolith vs. modular-monolith vs. services for the first milestone."
- An **open thread**: "ratify the data-model-target.md proposal thread #42."

Bad themes (too vague, reject and re-scope):

- "make the ADR better"
- "think about architecture"
- "refine everything"

**Baseline special case:** on run 1, the theme is "all subsystems at skeleton depth" — scope is broad but depth is shallow. Normal refine passes are the inverse (narrow scope, deep depth). Do not mix modes.

Record the theme in a working note (a scratch learning, or in your local notes); it anchors every subsequent step. **Do not deviate mid-pass.** If a sharper theme appears while researching, finish the current one and queue the new theme as the next pass.

### Step 3 — Evidence sweep (15–45 min)

Run the five-input sweep in the order listed in §Inputs. For each input, record:

- What you searched.
- Top ≤ 5 results that bear on the theme.
- A one-line summary of what each contributes.

You are building the **evidence bundle** that the refinement will cite. Every claim that lands in the ADR must trace back to at least one piece of this bundle. Claims without evidence = `[PROVISIONAL]` tag + candidate for a new thread.

Budget per input:

| Input | Baseline budget | Refine budget |
|---|---|---|
| 1. Oracle memory | 15 min | 10 min |
| 2. current-system docs | 15 min | 10 min |
| 3. flow maps | 10 min | 10 min |
| 4. constraints | 10 min | 5 min |
| 5. code | 30 min (only if baseline reveals gaps) | 10 min (only if Inputs 1–4 leave a crucial ambiguity) |

**Stop at Input 4 if the theme is adequately evidenced.** Reading current-system code is expensive and the cost-benefit rarely favors it on a refine pass.

### Step 4 — Draft the refinement (20–60 min)

Open `docs/adr.md`. Locate the section the focus theme targets (create it if missing; §Template shows the canonical section shape).

For each claim you intend to add, modify, or strengthen:

1. **Write the claim** in imperative, decision-shaped prose. Not "we think X might be good" — "We choose X because Y" or "Open: X vs Y; see §Trade-offs."
2. **Cite the evidence** inline as `// source: learning:<id>` or `// prior-art: flow:<slug>@<repo>` or `// constraint: <id>` or `// code: <path>@<sha>`.
3. **Tag gaps** with `[AWAITING_THREAD:<id-will-be-filled>]` where the claim needs human ratification. Leave the id blank until Step 5.

Every non-trivial section must include:

- **Context:** what problem this section addresses.
- **Decision (or Proposal):** the chosen (or proposed) approach.
- **Consequences:** positive + negative, named explicitly.
- **Trade-offs:** alternatives considered, rejection criteria, revisit triggers.
- **Prior art:** citations to current-system learnings (`#repo:mobiz-payment-gateway` or `#repo:bank-bot`). A section without prior-art citations is suspect — you either missed a source or the claim is a pure-design invention. The second case is legal (greenfield is allowed to diverge) but must be explicit.

**Do not delete old content in place.** If the refinement supersedes an earlier claim, mark the old text `[SUPERSEDED YYYY-MM-DD — see §X]` and write the new claim adjacent, then `arra_supersede` the old learning to the new one in Step 8. This preserves history per P-001.

### Step 5 — Open threads for unresolved architectural questions (5–15 min)

For every `[AWAITING_THREAD:?]` marker left in Step 4, open a thread:

```
arra_thread(
  title="design: <theme> — <specific question in one line>",
  message="<full context: what claim, what alternatives, what the architect needs from the human>",
  tags=["system-architect", "repo:mb-next-payment-gateway", "next", "<theme>"]
)
```

Replace the `?` in the marker with the returned id. Example: `[AWAITING_THREAD:84]`.

Threads opened in this pass fall into three classes:

| Class | Example | Ratification depth needed |
|---|---|---|
| **Ratification** — architect proposes, human confirms | "We plan to use PostgreSQL for the wallet ledger; confirm." | Affirmative engagement with the specifics, not rubber-stamp. |
| **Disambiguation** — two readings of current behavior | "Does mobiz's callback signature require ordering stability across retries? Code is unclear, flow map says yes." | Explicit "yes" or "no" + pointer to evidence. |
| **Scope / strategy** — business-shaped question | "First milestone: parity with current MDR rules, or redesign?" | Human decides; architect does not propose. |

**Security-sensitive** themes (auth, OTP, credentials, PII, RBAC) bypass the async-thread convention — halt the pass and ping the human directly before continuing. Tag the eventual learning `#security-sensitive #system-architect #decision`.

### Step 6 — Write the revision log entry (5 min)

Append a new entry to `## Revision log` at the bottom of `docs/adr.md`. Use the format in §Outputs. Fill every field honestly — "Sources cited this pass: none" is a legitimate (if rare) outcome, but it must then be explained in the retro.

### Step 7 — Commit and push (5–10 min)

Per AGENTS.md §9 safety rules:

```bash
git checkout -b architect/w1-refine-adr-<theme-slug>-<YYYY-MM-DD>
git add docs/adr.md
# if migration-map was touched: git add docs/migration-map.md
git commit -m "architect: W1 refine — <theme> (pass <N>)"
git push -u origin HEAD
gh pr create --title "architect: W1 refine — <theme> (pass <N>)" --body "$(cat <<'EOF'
## Summary
<one paragraph — what was refined and why>

## Focus theme
<copy from revision log>

## Sources cited
<bullet list from revision log>

## Threads
Opened: <list with links>
Closed: <list with links>

## Learning
<arra_learn id + one-line summary>

## Revisit triggers
<what would make us re-open this section>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**Do not merge.** AGENTS.md §9: "Never merge PRs without explicit user approval." Provide the PR URL, wait.

### Step 8 — File the `arra_learn` entry (3 min)

Body content (plain markdown — **do not** embed frontmatter; see SKILL.md §7b rule 1):

```
arra_learn(
  pattern="W1 refine pass <N> — <theme>.\n\n<two paragraphs: what was refined, what the evidence bundle concluded, what open questions remain>\n\nKey deltas:\n- <bullet>\n- <bullet>\n\nThreads opened: <ids>. Threads closed: <ids>. Commit: <short-sha>. Next pass candidate: <theme-for-next-run>.",
  concepts=["system-architect", "repo:mb-next-payment-gateway", "next", "adr", "refinement", "<theme>", "<optional:decision>", "<optional:migration-map>"],
  project="github.com/kxlahsimx09/mb-next-payment-gateway",
  source="docs/adr.md@<short-sha> + evidence bundle cited in §Revision log"
)
```

If this pass superseded any prior learning (a previous refine pass that this one replaces wholesale), call `arra_supersede(oldId, newId, reason="W1 refine pass <N> — <theme>")` after the `arra_learn` returns.

**Then trace the pass into the chain (mandatory, in the same response before commit):**

```
arra_trace(
  query="W1 refine pass <N> — <theme>",
  queryType="evolution",
  scope="project",
  project="github.com/kxlahsimx09/mb-next-payment-gateway",
  foundLearnings=["<source_file from arra_learn response>"],
  foundRetrospectives=["<retro path if already drafted, else omit>"]
)
```

`arra_trace` returns a `trace_id` (UUID) — record it.

If this pass chains to a prior in-territory trace (the baseline this ratifies, a sibling pass on the same subsystem, a current-system drift this closes), find the prior `trace_id` via `arra_trace_list query="<prior pass theme>"` and link:

```
arra_trace_link(
  prevTraceId="<prior_uuid>",
  nextTraceId="<this_pass_uuid>"
)
```

If no chain candidate exists for this pass, record `"no chain candidate — first in subsystem"` (or equivalent reason) in the retrospective's §Pass metadata. Silence is not a valid state — every pass either chains or explicitly declares "no candidate."

**Why mandatory, not optional:** every W1 pass connects ≥ 2 of the five canonical inputs by construction (oracle memory + current docs + flow maps + constraints + code). The earlier framing of `arra_trace` as conditional ("when ≥ 2 evidence") made the call look situational when it should fire on every pass. Without `arra_trace`, the pass produces a learning + supersede chain but no navigable session record — `arra_trace_link` becomes impossible (no UUIDs to chain), and the chain context fades by retro time. See thread #54 + brew-ops PR `arra_learn` trace-link hint for the recurring-miss pattern this addresses.

### Step 9 — Retrospective (10–15 min)

Write a retro at `ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_w1-refine-<theme>.md`. AI Diary and Honest Feedback are mandatory (per AGENTS.md §7). Minimum sections:

- **Pass metadata** — theme, duration, source used (which of the 5 inputs, which not).
- **Delta summary** — what the ADR gained.
- **Open questions** — what threads remain unresolved and why.
- **AI Diary** — first-person narrative of the session experience.
- **Honest Feedback** — what worked, what didn't, what would make the next pass cheaper.
- **Next-pass candidate theme** — one sentence.

---

## Template — `docs/adr.md` (baseline skeleton)

Used only when `docs/adr.md` does not exist (run 1, baseline mode). Populated by walking every known subsystem at skeleton depth.

```markdown
# Architecture Decision Record — mb-next-payment-gateway

> The consolidated architecture-decision document for the next-generation Mobiz payment gateway.
> Maintained by `system-architect` via `.agent/skills/system-architect/references/workflow-1-refine-adr.md`.
> **Editable surface for this role only.** Cross-referenced by ADR id; claims cite evidence inline.

**Created:** <YYYY-MM-DD> (GMT+7)
**Last refined:** <YYYY-MM-DD> (pass <N>)
**Current system (prior art):** `kokarat/mobiz-payment-gateway` (Go + Fiber + MongoDB) + `kokarat/bank-bot` (Node.js + Playwright).
**Migration stance:** code-only; no data migration; target starts with a fresh database.

---

## 1. System-level context

### 1.1 Goals
- <bullets — drawn from human conversation + requirement threads>

### 1.2 Non-goals
- <bullets — what we are explicitly not building>

### 1.3 Inheritance surface (from current system)
- <list of constraints and contracts that must carry over; cite `#constraint` learnings>

### 1.4 Departure surface (from current system)
- <list of areas where the next system intentionally diverges; cite `#decision` learnings>

---

## 2. High-level architecture

### 2.1 Component sketch
<mermaid diagram OR ASCII sketch — ≤ 9 top-level boxes>

### 2.2 Runtime shape
<one paragraph: process model, deployment unit, scaling axis>

### 2.3 Data plane
<one paragraph: primary datastore(s), cache layer, queue/event backbone>

### 2.4 Control plane
<one paragraph: auth, tenancy, config, feature flags>

---

## 3. Subsystems

One subsection per bounded context. Initial baseline lists the subsystems; refine passes go deep on one at a time.

### 3.1 <subsystem name>
**Context.** <what problem>
**Decision / Proposal.** <what approach>
**Consequences.** <pos + neg>
**Trade-offs.** <alternatives, rejection, revisit>
**Prior art.** <citations>
**Open questions.** <list with [AWAITING_THREAD:id] anchors>

---

## 4. Cross-cutting concerns

### 4.1 Authentication and authorization
### 4.2 Observability
### 4.3 Error handling and retries
### 4.4 Secret management
### 4.5 Testing strategy (NFR — owned by future qa-engineer)

Same §Context/§Decision/§Consequences/§Trade-offs/§Prior art/§Open questions shape as §3.

---

## 5. Migration map (current → next)

Reference to `docs/migration-map.md` (when it exists). Top-level summary table here:

| Feature / subsystem | Current repo & tag | Next strategy | Owner thread |
|---|---|---|---|
| <row> | <mobiz or bank-bot + #current> | <port / redesign / drop> | <thread id or —> |

---

## 6. Scale and reliability targets

### 6.1 Load estimation
### 6.2 Scaling axis
### 6.3 Availability + failover
### 6.4 Monitoring + alerting

---

## 7. Revisit triggers (the "what would change this doc" list)

Bullet list of assumption-bound decisions that deserve re-evaluation when the assumption changes. Each bullet names (a) the decision, (b) the assumption, (c) the trigger event.

Example:
- **Decision 3.2 (PostgreSQL for ledger):** assumes ≤ 10k TPS and single-region deploy. Revisit when either crosses threshold.

---

## Revision log

Ordered newest-first. Each refine pass appends a single entry here using the format in `.agent/skills/system-architect/references/workflow-1-refine-adr.md` §Outputs.

<entries>
```

---

## Anti-patterns

- **Rewriting the ADR top-to-bottom in one pass.** This is not a refine — it's a baseline. Distinguish explicitly. Multi-hour top-to-bottom rewrites without evidence gathering produce aspirational text that will not survive the first implementation-agent reality check.
- **Claiming without citing.** Every non-trivial claim in the ADR must trace to the evidence bundle. If you cannot cite, tag `[PROVISIONAL]` + open a thread. Aspirational writing goes in `docs/design/` drafts, not in the ADR.
- **Silently deleting superseded text.** P-001 violation. Mark `[SUPERSEDED YYYY-MM-DD — see §X]` + `arra_supersede` the learning chain. The history is the record.
- **Opening threads without anchors.** Every thread must have a matching `[AWAITING_THREAD:<id>]` in `docs/adr.md` (or the targeted design doc) in the **same commit** that opens it. A thread with no anchor is a workflow bug.
- **Closing threads without posting a citation.** Per the fleet's thread-resolve discipline: before `arra_thread_update(status="closed")`, post a message citing the commit (doc-update or code-fix) that resolved the question. Cross-repo closers are especially vulnerable to this — the closer's local commit history isn't reachable from the other instance.
- **Designing without current-system prior art.** For any subsystem that has a mobiz or bank-bot analogue, §Prior art must not be empty. If it's empty, you skipped Input 2 or 3. Go back.
- **Committing straight to `main`.** AGENTS.md §9. Always branch → PR → wait for human approval before merge.
- **Over-scoping the focus theme.** If the pass takes more than 2 hours, the theme was too broad. Split next time. Record the split in the retro's "what would make the next pass cheaper" section.
- **Reading current-system code on every pass.** Input 5 is a last resort. If your recent passes cite code repeatedly on the same file, that's a signal to ask `pg-writer` or `bot-writer` to publish a learning on it (via `arra_inbox`) so the next pass gets the fact at Input 1 cost.
- **Chaining speculative threads.** When a thread's answer triggers three new threads, step back. The subsystem is too loosely specified — propose splitting the design into phases instead.

---

## Definition of Done (per pass)

All must hold:

- [ ] `docs/adr.md` modified; diff shows surgical change to the themed section (not the whole file).
- [ ] New `## Revision log` entry at the bottom, all fields filled.
- [ ] Every new `[AWAITING_THREAD:<id>]` marker has a matching `arra_thread` call in the session.
- [ ] Every resolved thread has both a marker-strip in `docs/adr.md` and a closing message posted before `arra_thread_update(status="closed")`.
- [ ] One `arra_learn` entry filed with 3-layer tags + focus-theme tag.
- [ ] `arra_supersede` called for any prior learning this pass replaced (not just cited; replaced).
- [ ] `arra_trace` filed for this pass with `foundLearnings=[<source_file>]` (Step 8).
- [ ] `arra_trace_link` filed to chain to prior trace **OR** retro records `"no chain candidate"` with one-line reason (Step 8).
- [ ] PR opened (not merged); URL reported back to the human.
- [ ] Retrospective written at `ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_w1-refine-<theme>.md` with AI Diary + Honest Feedback.

If any checkbox fails, the pass is incomplete. Do not mark the session done in the retro.

---

## Change log

- 2026-04-22 — Initial version. Defines baseline vs refine modes, five-input priority order (Oracle memory → current-system docs → flow maps → constraints → current-system code), Step 0 thread sweep shared with the fleet, Step 2 focus-theme discipline, `docs/adr.md` skeleton template, revision-log format, definition-of-done checklist. Paired with `system-architect` activation (central commit `5d28531`) and brew-ops inventory update (central commit `4c3911c`).
- 2026-04-29 — Promote `arra_trace` from "Optional" (old line 194 — conditional on "≥ 2 evidence sources") into Step 8 main flow as a mandatory call after `arra_learn`/`arra_supersede`. Add `arra_trace_link` as the chain primitive when a prior trace exists. Add 2 Definition-of-Done checkboxes (`arra_trace` filed; `arra_trace_link` filed OR `"no chain candidate"` declared in retro). Trigger: thread #54 — brew-ops surfaced that `mb-next-payment-gateway` had 0 traces in 30 days, so 8+ retros flagging "missed `arra_trace_link`" actually meant `arra_trace` itself was never called. Old "≥ 2 evidence" trigger framed the call as conditional when W1's structure satisfies it by default — fixed framing here. Companion: `arra_learn` MCP response now includes `trace_link_hint` field at learn-time (PRs #14 + #15 in `Soul-Brews-Studio/arra-oracle-v3`, merged via `feat/all-prs-rebased`).
