# Workflow 10 — Constraint Harvest (external, hard-to-change)

> Reference document for the `pg-writer-oracle` instance of `technical_writer`.
> Read this file before running the workflow. Do not skim.

W10 is **re-runnable**, **dedup-aware**, and **cross-repo in scope**. Its job
is to extract the *external, hard-to-change constraints* that the current
system (mobiz-payment-gateway + bank-bot) operates under, catalogue them in
a single register (`docs/constraints.md`), and feed that register into any
future target-system design (W3, ADRs, migration-notes).

A "constraint" here is something the system does not choose — something
imposed by a bank portal, a browser engine, a regulator, a 3rd-party
partner, an OS behavior, a queue / network fact, or any other external
factor that would survive a rewrite. The canonical seed example: **"SCB /
KTB bank portals silently log a session out if it sits idle too long — the
bot must keep the session warm or re-authenticate (which re-triggers OTP)."**
We do not own that behavior. A new system would still face it.

W10 is **not** about documenting code (that is W1/W2) or documenting intent
(that is W8). It is about documenting *what reality forces on us*.

---

## Why this workflow exists

Target-system design decisions (W3, ADR-authoring, migration planning)
repeatedly re-discover the same hard limits one at a time, mid-design,
when it is expensive to pivot. A written constraint register front-loads
that pain: before the architect opens an ADR, they can read the full
list of externally-imposed facts and design around them.

The register is also the empirical antidote to a common failure mode:
assuming a greenfield rewrite "fixes" a limitation that was never ours
to fix. Every W10 entry exists to stop someone from writing "the new
system will not have this problem" about a constraint that is imposed
from outside.

---

## When to run this workflow

Run when **any one** of:

- A human explicitly asks ("หา constraint ของระบบ", "list what we can't
  change", "ก่อนออกแบบระบบใหม่ขอ constraint ก่อน").
- Before any target-system ADR is opened (W3 or migration-notes.md edit
  that changes architecture).
- Quarterly cadence — the register goes stale as new learnings and commits
  land. A run with zero new entries is still valuable: it stamps the
  current list as "re-verified at <date>".
- A W2 / W8 / W9 pass surfaces a drift note that smells like a constraint
  (e.g. a commit message that says "SCB changed OTP flow — we had to
  add X"; the added-X part is *our* reaction, the SCB change is the
  constraint).

Do **not** run:

- To catalogue our *design choices* — those are ADRs, not constraints.
  A constraint is what forces the design choice, not the choice itself.
- To generate a greenfield wishlist. W10 is descriptive of reality, not
  prescriptive of the next system. The "target-system implication"
  field per entry points at next-system concerns; the workflow does not
  author next-system design.
- Inside a release freeze without explicit request — W10 produces doc
  churn and should not stack onto release windows.

---

## Preconditions

- [ ] `git status --porcelain` empty.
- [ ] `docs/.baseline` exists and is parseable (W1 ran at least once).
- [ ] Oracle reachable (`arra_search`, `arra_learn`, `arra_trace` required).
- [ ] Access to both mobiz-payment-gateway and bank-bot repos for `git log`
      reads. If bank-bot worktree is not checked out locally, clone or
      `ghq get kokarat/bank-bot` before starting.
- [ ] You can state, in one sentence, what the current system *does not
      control*. If you cannot, read `docs/current-system.md §Bank-bot`
      and `docs/bank-bot.md` first.
- [ ] At least **45 min** for a first run (building the register), **25 min**
      for a maintenance run (appending to an existing register).

---

## Inputs you will read

1. `docs/constraints.md` — the register itself. Absent on first run; the
   workflow creates it. Present on subsequent runs — its `known-ids` list
   and per-entry `Keywords:` fields are the dedup fingerprint.
2. `docs/.constraints-cursor` — two-line file with the scan cursor (see
   §Cursor format below). Created on first run.
3. Oracle vault via `arra_search` — every repo, every type. Recommended
   theme-by-theme sweep (see §Theme wheel below).
4. `git log <cursor>..HEAD` on both mobiz-payment-gateway and bank-bot.
   Filter for commit messages that mention external forcing:
   `git log --grep='bank\|portal\|session\|OTP\|SCB\|KTB\|rate limit\|detection\|forced\|required\|cannot\|workaround\|mandated'`.
5. `gh pr list --state merged --search "updated:>=<cursor-date>"` on both
   repos. Read the PR body, not just the title — constraints get explained
   in prose, not headers.
6. `.agent/AGENTS.md §9 "Safety rules"` — hard halts often encode
   constraints (destructive action bans, credential rules). Cross-read
   against both the mobiz and bank-bot AGENTS.md; they diverge where
   repo reality diverges.
7. `docs/current-system.md` + `docs/bank-bot.md` — scan for any paragraph
   that describes *why* a design is shaped a certain way (as opposed to
   *what* the design is).
8. For any `[UNVERIFIED]` constraint candidate, a matching `arra_thread`
   must be opened in the same pass — never a silent invention.

---

## Outputs you will produce

Required:

- `docs/constraints.md` created or updated. Append-only for new entries
  (§Append-only rule); extension blocks for existing entries that gained
  new evidence.
- `docs/.constraints-cursor` updated to the new scan bounds (§Cursor
  format).
- W10 root trace opened at Step 2 with `queryType="pattern"` and
  `scope="project"`. Per-entry child traces only for NEW entries (extensions
  re-use the original entry's trace via `arra_trace_link`).
- At least one `arra_learn` tagged
  `#constraint #repo:cross #technical-writer #current`, listing the
  delta for this pass (new-entry IDs + extended-entry IDs). One learning
  per pass, not per entry — the register is the per-entry truth.
- A cross-link added to `docs/current-system.md §Bank-bot` and
  `docs/migration-notes.md §Preamble`: `**See also:** [Constraints register](constraints.md)`.

Conditionally produced:

- `arra_thread` for each `[UNVERIFIED]` constraint candidate. Anchor it
  in the entry's `Evidence:` field as `[AWAITING_THREAD:<id>]`.
- `#cross-repo-sync` learning naming any bank-bot-side learnings that
  the bot-writer sibling should mirror into their own constraint
  surface (if/when bot-writer gets a parallel W10 — see §Cross-repo
  below).
- `arra_supersede` against a prior constraint entry if this pass
  invalidates it (rare; constraints do not change often). Mark the old
  entry with a `[SUPERSEDED_BY:<new-id>]` block — never delete.

Never produced:

- Code changes. W10 is doc-only.
- Target-system design. The `Target-system implication:` field per entry
  is a *pointer* for W3 / ADR authors, not a design. One sentence max,
  phrased as a concern, not a solution.
- A merged PR. Open the PR, stop.

---

## Document structure (`docs/constraints.md`)

```markdown
# Constraints register — mobiz-payment-gateway + bank-bot

**Purpose:** Externally-imposed facts the current system operates under.
Feeds any target-system design decision (W3, ADRs, migration-notes).

**Tier definitions:**
- **hard** — imposed by a party we cannot negotiate with (bank portal,
  browser engine, regulator, OS). Survives any rewrite.
- **soft** — imposed by a party we can negotiate with (3rd-party partner,
  SLA, vendor contract). A rewrite could renegotiate, but at cost.
- **leaky** — partly ours (a legacy process, an ops habit, a data-shape
  choice locked in by historical data). A rewrite can dissolve it if
  historical data is not carried over — consistent with "target system
  starts empty" (SKILL.md principle 4).

**Last pass:** <ISO date, GMT+7>
**Cursor:** see `docs/.constraints-cursor`
**Known-id count:** <N>

## How to read

Each entry is stable by ID (C-NNN). Entries are append-only — a constraint
that evolves gets a new `[UPDATED <date>]` block under the existing ID,
never a silent edit. A constraint that is invalidated gets a
`[SUPERSEDED_BY:<new-id>]` block and the replacement entry is appended
with a new ID.

The `Keywords:` field per entry is the dedup fingerprint for the next W10
pass. If you are adding a new entry by hand, include at least 4 keywords
that a future `arra_search` would surface.

## Theme coverage

<one-line-per-theme summary of how many entries cover each theme — see
§Theme wheel in workflow-10>

## Entries

### C-001 — <one-sentence statement>
- **Tier:** hard | soft | leaky
- **Source:** <external party — e.g. "SCB corporate banking portal">
- **Statement:** <one paragraph, neutral, no editorializing>
- **Evidence:**
  - <citation 1: file:line@commit, or ψ/memory/learnings/... path>
  - <citation 2>
- **Consequence:** <one paragraph — what this forces us to do>
- **Keywords:** <4+ keywords, lowercase, comma-separated>
- **Target-system implication:** <one sentence — a concern the next-system
  designer must handle, phrased as a question or constraint, not a solution>
- **Known workaround:** <null | short phrase>
- **First seen:** <ISO date, pass ID>

### C-002 — …
```

Entry ordering: by first-seen date ascending. Never re-sort. The first
run seeds C-001..C-NNN; subsequent runs append C-(NNN+1) onwards.

Keep the whole file under ~500 lines. When it approaches that limit,
split into `docs/constraints/` with an index — but not before; premature
split hurts scan-ability.

---

## Cursor format (`docs/.constraints-cursor`)

```
last-pass-at:           <ISO date, GMT+7>
mobiz-commit-head:      <hash>
bank-bot-commit-head:   <hash>
memory-cursor:          <arra_search bge-m3 pass ISO, used for theme-sweep timestamp>
last-constraint-id:     C-<NNN>
themes-covered-this-pass: <comma-separated theme IDs from §Theme wheel>
```

The `last-constraint-id` is the autoincrement source. Never reuse an ID,
even for a superseded entry — "Nothing is Deleted" (P-001).

---

## Theme wheel (exploration coverage)

A pass should rotate through themes so the register does not over-index
on whatever the last incident made salient. Maintain a rough per-theme
coverage count in the register's `## Theme coverage` section.

1. **portal-auth** — bank-portal login, session token, re-auth cycle.
2. **portal-ui** — selector stability, DOM drift, field-clear behavior,
   iframes.
3. **portal-ratelimit** — request pacing, anti-bot classification,
   captcha, IP reputation.
4. **portal-otp** — OTP delivery channel, TTL, retry, dual-control
   (maker-checker) sequencing.
5. **portal-transaction** — ordering guarantees, idempotency, receipt
   formats, reference-number conventions.
6. **regulatory** — MDR, KYC, AML, data-retention, PDPA, BOT circulars.
7. **partner-sla** — 3rd-party payment partners, settlement windows,
   reconciliation cadence, chargeback timelines.
8. **data-sovereignty** — where data must reside, what leaves the country,
   what can/can't be logged.
9. **scheduler-timing** — cron cadence bounded by external fact (e.g.
   statement-matcher can only run as fast as the bank surfaces the row).
10. **browser-playwright** — viewport, user-agent, humanDelay, headless
    fingerprints (the anti-detection constants are load-bearing —
    see `ψ/memory/learnings/2026-04-17_name-gotcha-anti-detection-ranges-and-viewp.md`).
11. **network-tls** — TLS pinning, DNS caching, VPN requirements, static
    egress IPs.
12. **currency-rounding** — THB minor-unit handling, bank-imposed rounding
    rules, fee splits.
13. **credentials-storage** — credential rotation, vault model, what the
    bank lets us store client-side vs what must be server-side.
14. **callback-webhook** — merchant callback contracts, retry semantics,
    signature models we did not design (merchant-imposed).
15. **queue-idempotency** — replayability guarantees we inherit from
    upstream systems (bank statement polling, external wallet events).

One pass does not need to cover all 15 themes. Cover the 3–5 least-covered
themes (by count in `## Theme coverage`) plus any theme the current wave
of learnings / commits points at.

---

## Append-only rule

- A new constraint gets a new ID, appended at the bottom.
- An existing constraint that gains evidence (a new `#drift` learning, a
  new bank portal behavior change) gets a new `[UPDATED <ISO>]` block
  appended within its entry. The original `Statement:` line is never
  overwritten; the update block says "as of <date>, the statement now
  reads: …" with the delta.
- An invalidated constraint gets a `[SUPERSEDED_BY:<new-id>]` marker at
  the top of its entry; the replacement is appended as a new ID.
- Entries are never renumbered. IDs are stable references for ADRs and
  issue bodies that cite them.

Rationale: P-001 "Nothing is Deleted" applied at the doc layer. A reader
who returns after six months can reconstruct *when* we knew *what*.

---

## Steps

### Step 0 — Session-start ritual

Run the `technical-writer` session-start block from SKILL.md §Memory
discipline, including the `arra_threads status="answered"` check. If
answered threads exist, resolve them first (they may contain prior
constraint ratifications).

### Step 1 — Read the register and cursor

```bash
cat docs/constraints.md 2>/dev/null | head -50
cat docs/.constraints-cursor 2>/dev/null
```

If both absent: first run. Initialize the register skeleton (header +
empty `## Entries`) and the cursor file with `last-constraint-id: C-000`.

Build an in-session dedup set:

- `known_ids` — all `### C-NNN` IDs present.
- `known_keywords` — union of all `Keywords:` lines, lowercased, comma-split.
- `known_sources` — the `Source:` line from each entry.

### Step 2 — Open W10 root trace

```
arra_trace(
  query="W10 constraint-harvest pass <ISO>",
  queryType="pattern",
  scope="project"
)
```

Record the returned `trace_id`. Chain backward to the previous W10 trace
(if any) via `arra_trace_link(prev, this)`. If the previous W10 trace
already has a `next` link (unlikely — W10 is low cadence), skip the link
per the pg-writer convention recorded in W2 retros.

### Step 3 — Pass A: memory sweep (by theme)

For each selected theme (see §Theme wheel selection rule above), run:

```
arra_search(
  query="<theme keywords> constraint OR forced OR required OR cannot OR mandated",
  type="all",
  limit=10
)
```

Plus a second, broader call:

```
arra_search(
  query="<theme keywords> bank OR portal OR scb OR ktb",
  type="learning",
  limit=10
)
```

For each hit, extract candidate constraints. A candidate passes the filter
if it names *a thing the system does not control*. A candidate fails if it
describes *our reaction* to a thing (that is a design choice, not a
constraint). The line is subtle — when in doubt, write the candidate down
and decide in Step 6.

Log each candidate as a row: `(theme, source, one-line-statement, citation)`.

### Step 4 — Pass B: git log scan

Bounded by the cursor:

```bash
# mobiz side
git -C <mobiz-repo> log <mobiz-commit-head-from-cursor>..HEAD \
  --format='%h %s' \
  --grep='bank\|portal\|session\|OTP\|SCB\|KTB\|rate\|detection\|forced\|required\|cannot\|workaround\|mandated\|captcha\|timeout\|block' \
  -i

# bank-bot side
git -C <bank-bot-repo> log <bank-bot-commit-head-from-cursor>..HEAD \
  --format='%h %s' \
  --grep='<same regex>' \
  -i
```

For each hit, read the commit body (`git show <hash>`) — the constraint is
usually in the body, not the subject. Extract candidates as in Step 3.

### Step 5 — Pass C: merged PR bodies

```bash
gh -R kokarat/mobiz-payment-gateway pr list \
  --state merged --search "merged:>=<cursor-date>" \
  --json number,title,body -L 50

gh -R kokarat/bank-bot pr list \
  --state merged --search "merged:>=<cursor-date>" \
  --json number,title,body -L 50
```

Read each PR body for "because the bank does X" / "SCB requires Y" / "had
to add Z to survive the portal change" language. Extract candidates.

### Step 6 — Pass D: AGENTS.md §9 + doc prose

Cross-read `<mobiz>/.agent/AGENTS.md §9` and `<bank-bot>/.agent/AGENTS.md`
equivalent. Any "never do X" rule that is there *because an external party
punishes X* is a constraint. Any "never do X" that is there for our own
discipline is not.

Also skim the "why" paragraphs in:

- `docs/current-system.md §Bank-bot`
- `docs/bank-bot.md` (root)
- `docs/schedulers.md` (cadence fields — the cadence is often bank-imposed)

### Step 7 — Classify candidates

For each candidate from Passes A–D:

1. **MATCH** — candidate statement is covered by an existing entry. Skip,
   unless the candidate adds new evidence → in which case, EXTEND.
2. **EXTEND** — candidate is about an existing entry but the evidence or
   statement has a new dimension. Append an `[UPDATED <ISO>]` block to
   the existing entry with the new citation and delta.
3. **NEW** — candidate is not covered. Mint the next C-NNN, write a full
   entry using the template in §Document structure. Open a child trace
   under the W10 root for the entry: `arra_trace_link(root, child)`.
4. **NOISE** — candidate does not survive scrutiny (was a design choice
   masquerading as a constraint, or was already superseded). Drop.
5. **UNVERIFIED** — candidate smells like a real constraint but the
   evidence is weak. Mint the C-NNN but mark `Evidence:` with
   `[AWAITING_THREAD:<id>]` and open an `arra_thread` titled
   `constraint:<slug>` asking the human to ratify.

Dedup heuristic: if a candidate's core statement shares ≥ 2 keywords with
an existing entry's `Keywords:` line, default to EXTEND and re-assess only
if the tier or source differs.

### Step 8 — Write register updates

Apply the NEW, EXTEND, and SUPERSEDED edits to `docs/constraints.md`.
Respect the append-only rule. Update the top-of-file `Last pass` and
`Known-id count` fields. Recompute the `## Theme coverage` summary.

### Step 9 — Update cursor

Write `docs/.constraints-cursor` with:

- `last-pass-at:` now (GMT+7 ISO)
- `mobiz-commit-head:` `git -C <mobiz> rev-parse HEAD`
- `bank-bot-commit-head:` `git -C <bank-bot> rev-parse HEAD`
- `memory-cursor:` the ISO from Step 3's first `arra_search` call
- `last-constraint-id:` highest C-NNN now present
- `themes-covered-this-pass:` the theme IDs visited in Step 3

### Step 10 — File the W10 learning

One learning per pass, prose-only body (no frontmatter inside the
`pattern` arg — see `.agent/AGENTS.md §7 Rule 1`). Write the file
directly to `ψ/memory/learnings/YYYY-MM-DD_w10-constraint-harvest-<slug>.md`
with full frontmatter:

```yaml
title: W10 pass <ISO> — <N> new + <M> extended constraints
tags:
  - technical-writer
  - repo:cross
  - current
  - constraint
  - workflow-10
source: docs/constraints.md @ <new-head>, W10 trace <trace_id>
project: github.com/kokarat/mobiz-payment-gateway
```

Body: the delta (new IDs, extended IDs, superseded IDs), each with a
one-line statement and the theme it lands on. Link the trace id.

### Step 11 — Cross-links

Ensure these lines exist (add if missing, no-op if present):

- `docs/current-system.md §Bank-bot` footer: `**See also:** [Constraints register](constraints.md)`
- `docs/migration-notes.md §Preamble` footer: same

### Step 12 — Commit, PR, stop

Branch: `docs/w10-constraint-pass-<ISO-date>`. Commit message:

```
docs(w10): constraint register pass <date> — +<N> new, ~<M> extended

- New: C-<a>, C-<b>, ...
- Extended: C-<c>, C-<d>, ...
- Themes covered: portal-otp, scheduler-timing, ...
- Trace: <trace_id>
```

Open PR. Do not merge. Hand off to human review per `.agent/AGENTS.md §9`.

### Step 13 — Retrospective

`rrr` to `~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_w10-constraint-pass-<slug>.md`
with mandatory AI Diary + Honest Feedback sections. Cite the trace id and
the PR number.

---

## Classification heuristics (the "is this a constraint?" test)

A candidate qualifies as a constraint if **all** of:

1. **Externally sourced.** The source is not a team we can convene. Banks,
   browser vendors, regulators, OS kernels, network middleboxes,
   3rd-party partners with whom renegotiation is out of scope. (Partners
   with whom renegotiation is in scope are `soft` tier.)
2. **Not our reaction.** The candidate describes the external fact, not
   our code's adaptation. "SCB logs us out after 5 min idle" is a
   constraint. "We added keep-alive polling every 4 min" is a design
   choice that responds to the constraint; it is not itself the
   constraint.
3. **Survives a rewrite.** If a greenfield system in a different language
   with a different datastore would still face this fact, it is a
   constraint. If the fact would evaporate under rewrite, it is a
   design choice or a data-shape quirk.
4. **Cite-able.** Either a file:line@commit pointer, a `ψ/memory/...`
   learning, a PR body quote, an `AGENTS.md` §9 line, or an
   `[AWAITING_THREAD:<id>]` marker with the thread opened this pass.

If any of these fail, it is not a constraint *at this time*. Open an
`arra_thread` if uncertain — the doc-anchor rule applies (SKILL.md
§"Asking Oracle").

---

## Cross-repo scope

W10 is written for `pg-writer-oracle` (this repo). The register at
`docs/constraints.md` intentionally covers **both** mobiz and bank-bot,
because:

- Most constraints route through bank-bot (it is the only surface that
  touches bank portals directly) but *bind on mobiz design* (scheduler
  cadence, retry semantics, wallet-refund timing).
- Duplicating the register on both sides creates sibling drift — the
  exact failure mode this SKILL's §"Two-instance deployment" rule tries
  to prevent.

The register lives in this repo. The `bot-writer-oracle` sibling (bank-bot
side) does **not** mirror the register. If/when bot-writer gets a W10
(future decision), this workflow will evolve to a cross-repo owned doc
under `mb_agent_oracle_memory` with both instances as co-authors — filed
as a `#drift #repo:cross #workflow-10` learning when the time comes.

Until then: pg-writer is the sole W10 author; bot-writer feeds in via
its normal `arra_learn` stream (which pg-writer reads in Step 3's memory
sweep).

---

## Definition of Done

- `docs/constraints.md` reflects a completed pass; `Last pass` line
  updated.
- `docs/.constraints-cursor` points at the correct heads and memory
  timestamp.
- Every NEW entry has: tier, source, statement, ≥ 1 citation or
  `[AWAITING_THREAD:<id>]`, ≥ 4 keywords, target-system implication
  (one sentence, phrased as a concern), first-seen date.
- Every EXTEND has an `[UPDATED <ISO>]` block with the delta and new
  citation.
- W10 root trace opened; one child trace per NEW entry, chained.
- One `arra_learn` filed for the pass.
- Cross-links in `current-system.md` and `migration-notes.md` present.
- PR opened, not merged.
- Retro filed at the correct vault path (not the project repo `ψ/`).

---

## Failure modes (observed, to avoid on first real run)

- **Constraint-vs-choice confusion.** The single most common failure is
  recording a design choice ("we use PromptPay callbacks") as a
  constraint. Apply the 4-test in §Classification heuristics strictly.
- **Duplicate entries under slightly different wording.** Run a keyword
  intersection against every existing entry before minting a new ID.
- **Evidence-free entries.** An entry without a citation or an
  `[AWAITING_THREAD:<id>]` is not a W10 entry; it is a guess. Delete
  before opening the PR, or open the thread and land the anchor in the
  same commit.
- **Register bloat.** If a pass produces > 20 new entries, pause at
  Step 7 and ask: is the register actually capturing constraints, or
  has the classifier drifted? A healthy register grows ~2–5 entries per
  run.
- **Theme monoculture.** If three consecutive passes only touch
  `portal-*` themes, force a non-portal theme next run even if it
  yields zero new entries. Coverage uniformity matters more than
  short-term yield.
- **Cursor drift.** Always update the cursor *after* writing the
  register, not before. A cursor pointing past a register write that
  failed midway loses constraints on the next run.

---

## What W10 is not

- It is not a risk register. Risks are probabilities of bad outcomes; a
  constraint is a fact. A risk might reference a constraint, but the two
  documents answer different questions.
- It is not a requirements doc. Requirements are what we are going to
  build; constraints are what the world forces on us no matter what
  we build.
- It is not a list of bugs. A bug is a gap between code and intent; a
  constraint is an external fact that intent must conform to.
- It is not versioned against a specific target architecture. Entries
  should be written to survive any reasonable rewrite. If an entry only
  makes sense given a specific target stack, it belongs in that stack's
  ADR, not here.

---

**Created:** 2026-04-22 (GMT+7) · seed from brew-ops session
**Owner:** `technical_writer` / `pg-writer-oracle` instance
**Status:** draft — first run will be the validation pass
