# Workflow 2 — cleanup-requirements

> Hygiene + prose-cleanup pass over everything `docs/requirements/` produces in W1. **Primary goal: make every story readable by a non-engineer stakeholder in one sitting** — drop programming jargon, variable names, SQL fragments, and incidental technical detail from story bodies; keep the meaning intact; move the technical specifics into the Sources block where engineers click through. Secondary goal: mechanical hygiene — ≤ 250-line files, mandatory Sources / trust label / G-W-T, MDX-safe markup, no orphan `[AWAITING_THREAD]` anchors, INDEX + glossary in sync. **The pass never changes behavior** — every edit is a word-level refinement that preserves the same product promise.

**Inputs (priority order):**

1. `docs/requirements/*.md` — every file in the dir (epic, INDEX, glossary, README, revision-log, cross-repo).
2. `forum_threads` table via Oracle MCP — to classify anchored `[AWAITING_THREAD:N]` markers (pending vs closed).
3. Prior W1 retros (`arra_search query="<epic-slug> author-requirement" type=retro`) — pattern context for what the last pass left dirty.
4. ADR + design files (`docs/adr.md`, `docs/design/`) — read-only; cited only to verify Sources blocks. Cleanup never amends architectural sources.

**Output:** one PR per cleanup category (size / MDX-safety / Sources / INDEX-glossary-sync / orphan-anchor sweep), each ≤ 250 lines diff, plus revision-log entries + one `arra_learn` summarising what was cleaned and why.

---

## Steps

### Step 0 — Source-of-truth pre-flight

```
arra_search query="soul-brews-core next-product-writer" type=principle limit=10
arra_stats                                                    # confirm Oracle healthy
arra_search query="<epic-slug> revision" type=retro limit=5   # last passes' open debts
```

If `arra_stats` shows degraded vector or stale FTS, **stop**: hand off to `brew-ops`. A cleanup pass that runs against a broken index will see false orphan-anchor + false fabrication signals.

Read the most recent retro for the epic being cleaned. The retro's `Honest Feedback` section usually names the cleanup target directly (file size, orphan flags, archive overdue, glossary terms missing).

### Step 1 — Inventory pass (read-only)

```bash
DOCS=~/Code/github.com/<owner>/mb-next-payment-gateway/docs/requirements
wc -l $DOCS/*.md | sort -n                                          # line-count budget
grep -rnE '\[(AWAITING_THREAD|RATIFICATION_PENDING):[0-9]+\]' $DOCS  # anchored markers
grep -rnE '\{#[a-z0-9-]+\}' $DOCS                                   # kramdown trap
# Bare {a, b} outside backticks/code-fence — MDX trap. Skip ```fenced``` regions + `inline-code` spans
# before matching `(?<![\\`])\{[^}`\n]+\}` and printing the first hit per file/line.
# Stories missing Sources block — awk: for each `### EPIC-NNN` heading, fail if no `**Sources:` within 40 lines.
```

Write the inventory into a scratchpad. Cleanup is dispatched per category; the inventory tells you which categories actually need a pass.

### Step 2 — Category triage

For each inventory hit, decide **fix now / defer / no-op**:

| Category | Signal | Action |
|---|---|---|
| **Jargon in story body** | grep hits for SQL keywords (`SELECT`, `BETWEEN`, `GROUP BY`), function-call shapes (`foo()`, `bar.baz`), variable-style identifiers (`snake_case_with_underscores`), schema names (`ts_deposits`, `bank_statements`), date-arithmetic (`now() +`, `expires_at - createdAt`), HTTP-header literals (`X-Header-Name`), middleware terms (`advisory lock`, `pg_cron`, `RPC`, `HMAC`), or any backtick-wrapped technical noun outside a Sources block | **Step 3c — the load-bearing W2 step.** Rewrite to plain English; move the technical detail to the Sources block or wrap as a backtick proper-noun if it really is the product-facing name a stakeholder will hear from sales/support. |
| **File > 250 lines** | line-count budget | If dominated by revision log → archive (Step 3a). If dominated by stories → propose cluster-split (Step 3b — DOES NOT auto-execute). |
| **kramdown `{#id}`** | grep hit in story body | Replace with `<a id="..."/>` above the heading, or rely on Nextra auto-slug. |
| **Bare `{a, b}`** | python scanner hit outside backticks | Wrap in backticks. Re-run scanner after fix. |
| **Missing Sources block** | awk heuristic hit | Open the story — if it really has no Sources, this is a W1 violation; **do not silently invent**. File `arra_thread` to writer for re-authoring. Cleanup does not write Sources from scratch. |
| **Missing trust label** | story heading has no `[S2/S3/S4 ...]` | Same: file thread; do not invent trust. |
| **Orphan `[AWAITING_THREAD:N]`** | thread.status='closed' for the cited id | Step 4 sweep. |
| **Stale revision-log entry** | entries > ~1 month in `epic-*-revision-log.md` | Archive (Step 3a). |
| **INDEX out of sync** | story id present in epic file but not in `INDEX.md` (or vice versa) | Add / remove. |
| **Glossary term used but not linked** | first-occurrence of a domain term without `[term](glossary.md#term)` | Either link it or add the glossary entry. |

### Step 3a — Revision-log archival (precedent: `docs/adr/revision-log-archive-2026-05.md`)

When a per-epic revision log carries entries older than ~30 days:

1. Create `docs/requirements/epic-<slug>-revision-log-archive-YYYY-MM.md` if not already present.
2. Move stable entries verbatim (P-001 — never paraphrase). Keep month boundary as the archival cut so a reader can find any month's worth.
3. Leave a pointer in `epic-<slug>-revision-log.md` §Archive section: `Entries from <month> moved to [archive file].`
4. The migration is **structural only** — no semantic change, no body edit, no AC change.

### Step 3b — File cluster-split (proposal only)

If `epic-<slug>.md` is over budget *after* revision-log archive:

- **Do not auto-execute the split.** A cluster decision (e.g. `epic-deposit-auto.md` + `epic-deposit-slip.md` + `epic-deposit-admin.md`) is a scope call that affects every downstream consumer (INDEX, cross-repo, search).
- Produce a written proposal in the cleanup PR's description: line counts, proposed cluster boundaries, which stories go where, and what each cluster's "Why this matters" paragraph would say.
- Open `arra_thread` to the human for sign-off before splitting. The thread doubles as the audit trail when the split lands later.

### Step 3c — Plain-English prose cleanup (the core W2 step)

Walk every story body top-to-bottom. For each sentence that fails the **stakeholder-on-their-phone** test (W1 §3 "Plain-English discipline"), apply one of four moves — in this order:

1. **Move to Sources block.** A SQL filter, column-name list, function name, or commit hash belongs in `old:code` / `old:data` / `new:learning`. Cut from body; paste into Sources with a `→` arrow citing what it was supporting in the body. Body sentence keeps the *outcome* in plain English.
2. **Backtick as proper noun.** If the term is the product-facing name a stakeholder will say out loud (`Idempotency-Key` header on the public API, `bank-bot` as the named system component, `MDR` as the term in invoices), keep it inline in backticks. The test: would a non-engineer end up saying this term in a meeting? Yes → keep. No → demote.
3. **Paraphrase to plain English.** A long technical phrase often has a short English equivalent: `expires_at = now() + the calling client's configured expiry duration` → "a deadline set from the client's configured window"; `compound SQL join` → "the admin queue joins the two tables to surface the row"; `pg_cron 1-min sweep` → "a once-a-minute background sweep". The Sources block keeps the precise version for engineers.
4. **Drop entirely.** Incidental detail that does not change the story's promise — implementation footnotes that crept into the body, commit hashes inline, "verified count: …" parentheticals that interrupt prose. Move to Sources or delete. If deleted, the revision-log entry names what was dropped so a reader of the diff can verify nothing semantic disappeared.

**P-001 discipline.** Every move preserves meaning at the *story* level. The acceptance criteria (G/W/T) and the user-journey numbered steps **must not** change semantically — only their wording. Before/after for each rewritten sentence goes into the PR description so the reviewer can check meaning preservation in one pass. If a rewrite ends up changing meaning (even slightly), it is not a cleanup — it is an amendment, and amendments are W1 / W3, not W2.

**Fabrication co-detection.** While walking the prose, also flag suspicious specifics that have no Sources line covering them: exact percentages, "verified count: N", commit hashes referenced from body, "p50 ≈ …ms" without a `dpay MCP` or `arra_search` cite. **Do not silently rewrite the number** — the writer either adds the missing Sources line (cheap fix; pair with the prose move) or revisits the claim (more expensive; open a thread). Pattern observed historically: writer wrote plausible-sounding numbers from a small sample, architect later did the exhaustive audit and corrected. See `2026-05-13_epic-deposit-phase-1-close-session-retro-2026-05` (production-audit-corrects-writer-framing pattern, instance #1).

### Step 4 — Orphan `[AWAITING_THREAD]` / `[RATIFICATION_PENDING]` sweep

Mirrors `brew-ops` workflow-5 §13c at smaller scale. For every marker `[AWAITING_THREAD:N]` or `[RATIFICATION_PENDING:N]` found in `docs/requirements/`:

```
arra_thread_read threadId=<N>
```

| Thread status | Action |
|---|---|
| `pending` | **Leave the marker** — it is valid; the writer is genuinely waiting. |
| `closed` + ratified the claim as-is | Strip the marker; flip any "currently pending" tense to declarative. Add a one-line revision-log entry citing the close commit / thread id. |
| `closed` + ratification revised the claim | Update prose to the ratified version; replace marker with `[RATIFIED:N <YYYY-MM-DD>]` and cite the ratification source in the Sources block. |
| `closed` + wont-fix / historical | Annotate `<!-- permanent-historical-marker:thread-N -->` so future sweeps grep-skip; revision-log entry explains why. |

Per P-001: **never silently delete prose** that surrounds the marker. The pre-strip text was a true claim about the then-state of the doc; the post-strip text is a NEW claim. Both stay reachable via git history.

### Step 5 — INDEX + glossary sync

```bash
# Story ids in epic files
grep -rohE '^## (DEPOSIT|PAYOUT|WALLET|BOT|SETTLE|AUTH|MDR|OTP)-[0-9]+' $DOCS/epic-*.md \
  | sed 's/^## //' | sort -u > /tmp/epic-ids
# Story ids in INDEX
grep -ohE '\b(DEPOSIT|PAYOUT|WALLET|BOT|SETTLE|AUTH|MDR|OTP)-[0-9]+' $DOCS/INDEX.md \
  | sort -u > /tmp/index-ids
diff /tmp/epic-ids /tmp/index-ids
# Glossary terms — every first-occurrence of a defined term in epic files must link to glossary
grep -ohE '^### [a-z][^(]+' $DOCS/glossary.md | sed 's/^### //; s/ *$//' > /tmp/glossary-terms
# For each term, check it has at least one `[term](glossary.md#anchor)` link somewhere
```

Discrepancies: add the missing INDEX line / glossary entry / link. Do **not** auto-delete an INDEX line whose story body is missing — that signals a deletion the writer made without updating INDEX; surface as a question, not a fix.

### Step 6 — Cross-repo coordination check

If any story body mentions another next-* repo (today: bankbot v2; future: more) without a row in `docs/requirements/cross-repo.md`, flag it. The writer is expected to add the row themselves; cleanup just surfaces the gap.

If `cross-repo.md` row exists but cites a closed thread that has been superseded, follow Step 4's `[RATIFIED:N]` annotation pattern.

### Step 7 — Apply fixes (one PR per category)

One PR per category from Step 2, not all-in-one. Reviewers can grok one concern at a time, and the trust-mix of risk stays concentrated:

- `cleanup/plain-english-<epic>` (Step 3c — the load-bearing one; before/after table in PR description)
- `cleanup/revision-log-archive-<epic>-YYYY-MM` (Step 3a — structural-only)
- `cleanup/mdx-safety-<epic>` (Step 2 — `{#id}` + bare braces)
- `cleanup/orphan-thread-sweep-<epic>` (Step 4 — strip + ratify per matrix)
- `cleanup/index-glossary-sync-<epic>` (Step 5)
- `cleanup/cluster-split-proposal-<epic>` (Step 3b — proposal, not the split itself)

Each PR description cites the inventory output from Step 1 + the category triage from Step 2.

### Step 8 — Revision-log + `arra_learn`

For each PR that lands, append a one-bullet revision-log entry in `epic-<slug>-revision-log.md`:

```markdown
- **<YYYY-MM-DD> (cleanup — <category>).** <what was changed> <why> No semantic change to any story body, ACs, or sources — purely structural. Pattern: <observation if any>.
```

File one `arra_learn` per cleanup pass:

```
cleanup pass — epic-<slug> — <categories applied>

Inventory snapshot (pre): line-count budget exceeded by Nlines on epic-<slug>.md / Morphan markers / Kkramdown traps / Jbraces.
Actions: <category 1>, <category 2>, ...
PRs: #<n1>, #<n2>, ...
File: docs/requirements/epic-<slug>.md@<commit-after-PR-merges>
```

Tags (3-layer per SKILL.md "Memory discipline"):

```yaml
tags:
  - next-product-writer
  - repo:mb-next-payment-gateway
  - next
  - cleanup
  - hygiene
  - <epic-slug>
  - <category>     # revision-log-archive, mdx-safety, orphan-sweep, index-sync, cluster-split-proposal
```

### Step 9 — Retro

Close with `rrr`. Retro path: `ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_w2-cleanup-<epic>.md`. Mandatory AI Diary + Honest Feedback. Specifically capture:

- Which inventory category was loudest? (file-size vs orphan-sweep vs MDX-safety) — surfaces the W1 discipline drift to fix at write-time.
- Did any fabrication-scan hit fire? If yes, was it a real fabrication or a missing-Sources-line?
- Did the cluster-split proposal land? If yes, by what cluster boundaries? (Inform the next pass.)
- Was any cleanup PR rejected by the human? (Pattern check: cleanup that surprises the human is cleanup that should have been a thread first.)

---

## Anti-patterns (binding don'ts)

- **Don't invent Sources blocks.** If a story is missing its block, the story is broken — open a thread; do not paper over with plausible cites.
- **Don't invent trust labels.** Same shape. Cleanup never promotes `[S4]` to `[S2]`; ratification belongs to W1.
- **Don't strip an `[AWAITING_THREAD:N]` when thread N is still `pending`.** Verify status with `arra_thread_read` first; the anchor is load-bearing by design.
- **Don't silently rewrite prose** during MDX-safety fixes. Replacing `{#anchor}` with `<a id="..."/>` preserves the anchor; rewriting the heading does not.
- **Don't auto-execute a cluster-split.** The cluster boundary is a scope decision; bring the proposal to the human via thread + Step 3b PR description first.
- **Don't combine cleanup with new-story authoring** in one PR. The trust-shape of a cleanup PR is "structural-only / no semantic change"; mixing in new stories breaks that contract and makes review harder.
- **Don't archive a revision-log entry** that references a still-active drift (`#drift` learning still open, supersede chain unfinished). The live revision log is the writer's working memory; archive only stable entries.
- **Don't run cleanup against a degraded Oracle index.** Step 0 stops; brew-ops fixes; cleanup resumes.
- **Don't paraphrase ratified ADR prose** while cleaning. You may move it, reformat it (within MDX limits), or split it across files; you may not edit its meaning. ADR text is `[S2 ratified]` for a reason.
- **Don't strip a technical term that the API consumer will literally see.** `Idempotency-Key` is a header name a client developer types in their code; `MDR` appears on customer invoices. These stay (in backticks, but inline) — Step 3c's plain-English pass demotes engineering jargon, not product-facing vocabulary. The test: would a stakeholder say this term in a meeting or read it on a screen? Yes → keep.
- **Don't combine the plain-English pass with a Sources-block reshuffle.** Moving content from body → Sources is fine and expected; *rewriting* Sources entries (re-citing different ADRs, dropping a learning id) is a W1 concern, not a W2 one. Cleanup adds Sources lines when prose demoted technical detail to them; cleanup does not retire existing Sources lines.
- **Don't ship a Step 3c PR without a before/after table** in the description. The reviewer must see every rewritten sentence side-by-side — that table IS the meaning-preservation audit. Skip the table → reviewer cannot verify meaning preservation → the PR is unreviewable.

---

## Worked-example skeleton (for reference)

Inventory output from Step 1 on epic-deposit, 2026-05-13:

```
559 docs/requirements/epic-deposit.md           ← over budget by 309
 47 docs/requirements/epic-deposit-revision-log-archive-2026-05.md
 33 docs/requirements/epic-deposit-revision-log.md
 81 docs/requirements/glossary.md
 20 docs/requirements/INDEX.md
 88 docs/requirements/README.md

# orphan markers
(none — all 4 prior flags ratified in PR #85 + #83)

# kramdown traps
(none)

# bare {a, b} outside backticks
(none)

# missing Sources
(none)
```

Triage: Step 3c (plain-English) + Step 3b (cluster-split proposal) both fire. The plain-English pass is the higher-priority — the body is dense with engineering specifics that a non-engineer reader would skip past.

Sample before/after table for the Step 3c PR description (DEPOSIT-001 user-journey step 3):

| Before | After | Source line added |
|---|---|---|
| "The gateway computes a deadline (`expires_at = now() + the calling client's configured expiry duration` — server-derived, **not** client-supplied per request), saves a pending deposit record (including a server-generated request id that the matcher uses to disambiguate same-amount, same-destination deposits internally; the idempotency key is stored alongside it)…" | "The gateway sets a deadline from the client's configured window — the client cannot override it per request — and records the pending deposit with a server-generated reference the matcher will use later if two end-users happen to pay the same amount to the same account." | `old:data ts_deposits {expires_at, request_id, idempotency_key} — server-derived, sourced from clients.expired_deposit_time` |
| "Pool rotation has per-bank exclusion rules. … intra-bank (KTB → KTB) transfers disable the recipient-name field that statement reconciliation depends on (mobiz PR #160 + same-class payout incident 2026-04-11)." | "If the client asks for a specific destination bank, the gateway skips any system bank of that same bank — same-bank transfers strip the sender name from the statement and the matcher cannot reconcile them." | `old:code mobiz services/bankRotation.go SelectBankForDeposit(excludeBankCode) — PR #160` (already in Sources; widen the cite scope) |

Acceptance: every G/W/T criterion in DEPOSIT-001 reads identically before/after (verified word-for-word in the PR description). The Step 3b cluster-split proposal goes separately, filed as `arra_thread` to the human first.

---

**Created:** 2026-05-14 (GMT+7) — codified from prior ad-hoc housekeeping passes recorded in `epic-deposit-revision-log.md` (2026-05-11 archival pass + 2026-05-12 edge/open-question split + 2026-05-13 orphan-anchor strips). Activation context: brew-ops handoff naming W2 as `cleanup-requirements` (previously TBD in SKILL.md as `refresh-on-amendment` — that shape moves to W3 when first amendment lands post-Phase-1).
**Owner:** maintained by `next-product-writer`; changes require a commit on `mb_agent_oracle_memory`.
