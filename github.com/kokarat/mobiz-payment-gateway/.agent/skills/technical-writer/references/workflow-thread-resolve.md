# Workflow procedure — Thread Resolution

> Shared sub-procedure referenced from every main workflow (W1, W2, W4, W8).
> **Not** a full workflow. Runs at Step 0 of every pass and whenever an
> answered thread is discovered mid-pass. Also runs when a doc marker
> (`[AWAITING_THREAD:<id>]` / `[RATIFICATION_PENDING:<id>]`) is touched.

---

## Why this exists

`arra_thread` is async. Humans answer on their own time via Studio `/forum`. Without a forcing function, answered threads become zombies: the agent sees them listed in the wake-up ritual but never acts on them, and the doc keeps the stale `[AWAITING_THREAD:<id>]` marker forever.

This procedure turns "answered thread" from a **passive signal** into **blocking work** that every main workflow must clear before opening new tasks.

---

## Scoping rule — "my threads" is doc-anchored, not title-anchored

A thread is **mine** (this instance's responsibility) if and only if a doc I own currently contains a recognised marker referencing its id. The recognised marker family is:

- `[AWAITING_THREAD:<id>]` — generic "I asked a question about this claim" (W1/W2/W4/W8).
- `[RATIFICATION_PENDING:<id>]` — "I reverse-engineered this flow; human must ratify" (W8, and downgrades triggered by W9 class F). Subject to a **decay rule** — see W8 Step 7: 7d bump, 30d `#missing-ratification` learning, 60d lapse.
- `[RATIFICATION_LAPSED:<id>]` — "This flow's ratification thread went unanswered for > 60 days and has been closed as lapsed" (W8 decay terminal state). The doc is still readable/usable, just carrying an explicit "never-ratified" label. **Informational, not blocking** — Pass 1 does not reprocess these; they survive as historical record per P-001.
- `[UNDOCUMENTED-STEP:<id>]` — "W9 noticed a new actor-crossing in code the flow doesn't cover; human must decide new-step vs internal-helper" (W9 only).

Title prefixes (`flow:<slug>`, `drift:<area>`) are **hints for humans**, not scoping. They collide across agents and survive renames. Doc anchors are load-bearing; titles are not.

Implication for every `arra_thread()` call inside a workflow:

- You **must** immediately insert the paired marker into the doc being produced in the same PR. A thread with no doc anchor is a workflow bug, not a thread.
- When you resolve a thread, you either update the marker in place (`[AWAITING_THREAD:<id>]` → `// verified-via-thread:<id>`), strip it (`[RATIFICATION_PENDING]` in header → add `// ratified-via-thread:<id>` on its own line), or transform it based on the human's answer (`[UNDOCUMENTED-STEP]` → either becomes a real step via spawned W8 revision, or is deleted with a `#undocumented-step-benign` learning if the human says "internal helper"), **in the same commit** that closes the thread. Marker removal/transformation and `status="closed"` happen together.

---

## Territory map (pg-writer)

Pass 1 (doc-anchored grep) runs against **these paths only**. Files outside this list are not pg-writer's territory and their markers — if any — belong to another agent or are stale debris.

```
docs/current-system.md
docs/data-model.md
docs/schedulers.md
docs/bank-bot.md
docs/flows/
docs/runbooks/
docs/releases/
docs/migration-notes.md      # co-owned with next-writer; process only if marker has #current tag
docs/adr/                    # pg-writer does not author ADRs; scan but never strip a marker — flag orphan
README.md
CLAUDE.md
```

Files **not** in pg-writer's territory (skip):

- `docs/target-system.md`, `docs/data-model-target.md` (next-writer's territory when it exists)
- `docs/flows/` on the target side (when next-writer gains W8)
- Anything under bank-bot's tree (`bank-bot/docs/` — bot-writer's territory)
- `RBAC_GUIDE.md` when the marker carries `#security-auditor` (co-owned; security_auditor resolves)

---

## Procedure

### Pass 1 — Doc-anchored (primary, authoritative)

```bash
grep -rEn '\[(AWAITING_THREAD|RATIFICATION_PENDING|UNDOCUMENTED_STEP|UNDOCUMENTED-STEP):([A-Za-z0-9_-]+)\]' \
  docs/current-system.md docs/data-model.md docs/schedulers.md \
  docs/bank-bot.md docs/flows docs/runbooks docs/releases \
  docs/migration-notes.md docs/adr README.md CLAUDE.md \
  2>/dev/null
```

(The regex accepts both `UNDOCUMENTED-STEP` and `UNDOCUMENTED_STEP` for forward-compatibility with earlier drafts of W9; normalise new markers to the hyphen form. `[RATIFICATION_LAPSED:<id>]` is **intentionally excluded** from Pass 1 — it is a terminal/historical marker, not a live one, and reprocessing it every session would be noise.)

Expected output per line: `<file>:<line>:[<MARKER>:<id>]`.

**Dedupe by id, not by line.** One thread id can legitimately appear multiple times in a single doc:

- **Line-by-line `sort -u` is wrong** — it dedupes identical `<file>:<line>:[<MARKER>:<id>]` strings, not identical `<id>`s. Two different lines referencing the same id survive, causing `arra_thread_read(<id>)` to fire twice and the id to be processed twice.
- **Dedupe by id**: extract the `<id>` with a second pass, keep only unique ids, then for each unique id locate its *load-bearing anchor* (the first/top-most occurrence) using the original grep output.

```bash
# Pipe the raw grep output through an awk/sed that extracts the id and dedupes:
raw=$(grep -rEn '\[(AWAITING_THREAD|RATIFICATION_PENDING|UNDOCUMENTED-STEP):[A-Za-z0-9_-]+\]' <territory> 2>/dev/null)
echo "$raw" | sed -E 's/.*\[(AWAITING_THREAD|RATIFICATION_PENDING|UNDOCUMENTED-STEP):([A-Za-z0-9_-]+)\].*/\2/' | sort -u
# → unique ids to process

# For each unique id, the load-bearing anchor is the first matching line in `raw`:
for id in <unique-ids>; do
  echo "$raw" | grep -F "[$MARKER:$id]" | head -1   # file:line of the anchor
done
```

**Which occurrence is load-bearing?** The **first / top-most** occurrence in the doc. Subsequent mentions — typically in `§Change log`, `§Resolved questions`, or inline narrative prose — are **informational** references to the thread, not live markers awaiting resolution. Only the load-bearing anchor is subject to the "update/strip marker + close thread + `arra_thread_update(status='closed')`" transform; the informational mentions stay as-is (they are a historical record per P-001).

Practical heuristic: the load-bearing anchor for `[RATIFICATION_PENDING]` lives in the doc **header** (first 10 lines); for `[AWAITING_THREAD]` and `[UNDOCUMENTED-STEP]` it lives inline on the specific claim or in the §Implementation pointers section. A mention further down the doc in §Change log is informational.

For each unique `<id>`:

1. `arra_thread_read(threadId=<id>)` → inspect **both** `status` **and** `last_message.role`.
2. Dispatch on the pair `(status, last-message role)`:

| `status` | last message role | Action |
|---|---|---|
| `active` | any | No-op. Thread still awaits human. Leave marker. |
| `pending` | `claude` | No-op. Genuinely waiting for human. Leave marker. |
| `pending` | `human` | **Run the 4-step resolution block.** Human has replied; Oracle's deployment does not auto-transition `pending` → `answered` when a human message lands (see §"Oracle status lifecycle" below). This is the **most common case** that actually fires in practice. |
| `answered` | any | **Run the 4-step resolution block.** Normal case when / if Oracle auto-transitions in a future deployment. |
| `closed` | any | **Orphan-closed marker.** Run the **orphan-close resolution block** (§below) before stripping — the closer may have landed a code fix without posting a closing-message citation, and a plain marker-strip risks hiding a real resolution (see originating incident `2026-04-20_workflow-bug-orphan-marker-thread-16-closed-without-answer`). |

### Oracle status lifecycle — deployment quirk (read this once, understand forever)

In this Oracle deployment, thread status transitions are **not** fully automatic. Specifically:

- Opening a thread: status starts as `pending`.
- Human writes a reply (via Studio `/forum` UI): status **stays `pending`**. The human message is appended to the thread's `messages` array, but no status transition fires.
- Only explicit calls to `arra_thread_update(threadId, status=...)` change status.

This means `arra_threads(status="answered", limit=50)` returns **0 results** on a working system where humans have actually replied — because nobody ever called `arra_thread_update(status="answered")`. The workflow originally assumed auto-transition and filtered only by `status="answered"`; that spec was broken on contact with reality (observed during the 2026-04-17 bot-writer W1 session — thread #3 had a human reply but Pass 2 found zero).

**The fix embedded in the dispatch table above:** Pass 1 classifies by **(status, last-message role)** not by status alone. A thread with `status="pending"` whose most recent message came from a human is treated as effectively-answered and runs the 4-step resolution block. This is deployment-agnostic: if/when Oracle auto-transitions in the future, the `status="answered"` branch fires; until then, the `pending + human` branch carries the load.

**Side effect on status semantics:** `answered` and `pending + human last-message` are operationally equivalent to this workflow. `pending + claude last-message` is the only genuinely-waiting state.

### The 4-step resolution block (for answered-effective threads)

1. **Read the answer.** `arra_thread_read(threadId=<id>)`. Read every message since you opened it, not just the latest — humans sometimes answer the original question in message 3 and correct themselves in message 5.
2. **Classify the answer.**

   | Classification | Test | Next step |
   |---|---|---|
   | Sufficient + unambiguous | The answer lets you write a definite doc claim with no guessing. | Proceed to step 3. |
   | Sufficient but partial | Answers the literal question but exposes a new ambiguity. | Update the doc for the part that was answered; open a follow-up via `arra_thread(threadId=<id>, message=…)` for the new ambiguity; re-anchor under a new `[AWAITING_THREAD]` marker if needed. Do **not** close yet. |
   | Insufficient / vague | You'd still be guessing. | `arra_thread(threadId=<id>, message=…)` asking the disambiguating question. Do **not** close. Leave marker. |
   | Says "I don't know, ask <other-role>" | Human is punting to someone else. | Do **not** close. `arra_inbox` to the named role; leave marker; note in retro. |

   **Ratification threads specifically** (opened from W8 `[RATIFICATION_PENDING]`): the answer must be an affirmative confirmation. A neutral "looks fine" or "sure" without engagement with the spec is **insufficient**. Downgrade to insufficient and follow up asking the human to confirm specific steps they reviewed.

3. **Update the doc + strip/transform the marker.**

   Same commit as step 4. Never split.

   | Original marker | Becomes | Added annotation |
   |---|---|---|
   | `[AWAITING_THREAD:<id>]` inline on a claim | (marker removed) | `// verified-via-thread:<id>` |
   | `[AWAITING_THREAD:<id>]` standalone (e.g., under "Open questions") | entry moved to "Resolved questions" or deleted if trivial | `// verified-via-thread:<id>` next to the ratified statement |
   | `[RATIFICATION_PENDING:<id>]` in doc header | (marker removed) | header gains `// ratified-via-thread:<id>` on its own line |
   | `[UNDOCUMENTED-STEP:<id>]` — human answered "yes, real step" | (marker removed; spawn W8 revision handoff) | leave a `// pending-w8-revision-from-thread:<id>` note in §Implementation pointers until W8 runs |
   | `[UNDOCUMENTED-STEP:<id>]` — human answered "no, internal helper" | (marker removed, entry deleted) | file `arra_learn` tagged `#undocumented-step-benign + flow:<slug> + thread:<id>` so the scan doesn't re-flag next pass |

   If the doc section was tentatively written while the thread was open and the answer changed the semantics, rewrite the section. The thread answer is now the load-bearing claim — cite it with `// verified-via-thread:<id>`.

4. **Close the thread + chain the trace.**

   **Required: post a closing message to the thread BEFORE updating status to `closed`.** The message must cite (a) the fix-commit short-sha if the resolution was a code fix, OR (b) the doc-update commit + ratification path if the resolution was a doc decision, OR (c) the explicit not-a-bug / deferred / wont-fix classification. Without this, the next agent (especially across repos — see §Cross-repo threads) reads `status="closed"` with no provenance and is forced to either guess or treat the marker as orphan-on-faith. The 2026-04-20 thread #16 incident (`learning_2026-04-20_workflow-bug-orphan-marker-thread-16-closed-without-answer`) was caused by exactly this gap: the closer updated status without posting a closing message, leaving 4 markers stranded across `bank-bot/docs/flows/ktb-single-transfer-withdrawal.md` for 2 days until PR #89's Step 0 sweep caught them.

   ```
   arra_thread(threadId=<id>, message="Resolved by <short-sha> (<one-line semantics>). Closing.")
   arra_thread_update(threadId=<id>, status="closed")
   ```

   Then, if this pass touched a trace (W1/W8 root trace, W2 evolution chain, W4 resolution trace), add a child trace recording the resolution:

   ```
   arra_trace(
     query="thread <id> resolved — <one-line semantics of the answer>",
     queryType="pattern",
     scope="project",
     project="github.com/kokarat/mobiz-payment-gateway",
     parentTraceId=<current pass's root trace, if any>
   )
   ```

   If no pass-scoped trace is open (Step 0 of a fresh workflow before the root trace exists), record the `arra_thread_update` call in the retro instead of creating an orphan trace.

5. **Supersede sweep (added 2026-04-22, brew-ops).**

   If this pass filed a `ruled-*`, `resolution-*`, `fix-*`, or `followup-*` learning as part of the resolution, verify that every drift-discovery learning cited in its `source:` frontmatter has a matching `superseded_by` pointer. Missing pointers → call `arra_supersede(oldId, newId, reason)` in the same pass per `workflow-8-flow-map.md` §Step 5 "When filing ruled-/resolution-/followup- learnings".

   ```
   arra_read(id="<old-discovery-id>")   # confirm superseded_by is set
   # if null:
   arra_supersede(oldId="<old-discovery-id>", newId="<new-ruled-id>", reason="<thread-n> resolution")
   arra_read(id="<old-discovery-id>")   # re-verify
   ```

   Without this, the discovery sits as `superseded_by: null` in the DB and `arra_search` surfaces both claims as current — the replacement semantics of P-001 are defeated by implicit-only chaining. See handoff `ψ/inbox/handoff/2026-04-22_12-57_brew-ops_workflow-gaps-memory-drift-session-2026-04-22.md` §Gap 2 for originating incidents.

### Orphan-close resolution block (added 2026-04-22, brew-ops — Gap 3)

Runs when Pass 1's dispatch table hits the `closed | any` row, and also when Pass 2 discovers an un-anchored closed-without-answer thread in territory.

The plain marker-strip that applied before 2026-04-22 was a silent-loss risk: a closer who landed a code fix without posting a closing-message citation (the §Step 4 rule added 2026-04-21) would see their fix disappear from the evidence chain. The 2026-04-20 thread #16 incident captured the class — bank-bot `3359d08` fixed the waiting_to_review drift the same day W9 stripped the marker as orphan. No ruled-drift learning, no supersede, fix invisible to search. See `ψ/memory/learnings/2026-04-20_workflow-bug-orphan-marker-thread-16-closed-without-answer.md` and handoff `ψ/inbox/handoff/2026-04-22_12-57_brew-ops_workflow-gaps-memory-drift-session-2026-04-22.md` §Gap 3 for the full trail.

For each closed-without-answer thread (no human answer + no fix-commit citation in the final message):

1. **Extract code areas** cited in `t.messages[0]`. File paths + line ranges, e.g. `scheduler/withdrawal_dispatcher.go:788`, `app.js:1244-1260`. Also note any drift-discovery learning the opener links via `source:` or inline.

2. **Grep current HEAD** for those areas across the relevant repos:
   - Primary repo (pg-writer: mobiz-payment-gateway; bot-writer: bank-bot).
   - Sibling repo if the thread's code area is cross-repo (a mobiz thread about bank-bot behavior → grep bank-bot HEAD too, and vice versa).
   - Locate candidate fix commits with `git log --format=%H -S "<drift keyword>" --after=<drift date> -- <file>` (the `-S` pickaxe catches added/removed strings; widen the keyword or drop `-S` and use `--after` alone if the pickaxe misses).

3. **If code has changed materially since the drift was filed** — the closer landed a fix, just didn't cite it:
   - File a `#ruled-drift + flow:<slug>` (or equivalent resolution) learning citing the fix commit + verifying the new behavior at current HEAD.
   - Call `arra_supersede(oldId=<original-drift-discovery>, newId=<new-ruled-drift>, reason="thread-<id> resolved by commit <sha>")` per the `workflow-8-flow-map.md` §Step 5 supersede-pairing rule (Gap 2 discipline).
   - Strip the anchor marker from the flow doc with a `[RESOLVED:YYYY-MM-DD]` annotation citing the fix commit.
   - Optionally post a post-hoc closing message to the thread citing the fix commit so the trail is complete per §Step 4 (thread stays `closed`; message is for provenance).

4. **If code is unchanged** — the close was premature or erroneous:
   - File the `#workflow-bug + #thread-orphan` learning (the pre-2026-04-22 behavior) naming the thread id + opening commit + guess at which workflow leaked the close.
   - **Re-open** the thread via `arra_thread(threadId=<id>, message="Bump: grep at HEAD <sha> shows <file>:<lines> unchanged since drift filed — reopening for human answer. See ψ/memory/learnings/<workflow-bug learning>.md.")` and **do not** re-strip the marker. The marker stays live until the thread is answered-effective.

The previous single-action rule ("strip marker + file workflow-bug learning") is preserved as the step-4 fallback; step 3 is the new branch that catches silent-resolution cases.

### Pass 2 — Safety-net orphan scan

After Pass 1 resolves everything grep'd from docs, cross-check against the thread list. Because of the Oracle status-lifecycle quirk (see §"Oracle status lifecycle" above), scanning only `status="answered"` misses every thread where a human actually replied. Pass 2 must scan **both** `pending` and `answered`, then filter by last-message role the same way Pass 1 does:

```
pending  = arra_threads(status="pending",  limit=50)
answered = arra_threads(status="answered", limit=50)   # kept for forward-compat
candidates = pending ∪ answered
```

For each thread `t` in `candidates` whose id was **not** seen in Pass 1's grep output:

1. **Filter by effective state.** Only proceed if `t` is in an answered-effective state — i.e., `t.status == "answered"` **or** (`t.status == "pending"` **and** `t.last_message.role == "human"`). A `pending + claude-last-message` thread is genuinely still waiting and is not an orphan candidate; skip it.
2. **Territory check.** Look at `t.title` and the body of `t.messages[0]`. If they mention this instance's territory (pg-writer: `flow:`, `current-system`, `scheduler`, `deposit`, `bank-bot` (as referenced from mobiz side); bot-writer: `bank-bot`, `scb`, `ktb`, `selector`, `otp`, `session-reuse`, etc.) → continue to step 3. Otherwise it's clearly another agent's territory (titles starting with `test:`, `security:`, mentioning `target-system` before `next-writer` exists, etc.) — leave it; not ours.
3. **File as orphan.** This is a **workflow bug** — an earlier pass opened a thread but forgot to anchor it in a doc. File a `#workflow-bug + #thread-orphan` learning naming the thread id + opening commit + guess at which workflow leaked it. Escalate via `arra_inbox` so a human can triage (anchor after-the-fact or close). Do **not** run the 4-step resolution block on the orphan directly — without a doc to update, closing the thread would lose the human's answer.

Pass 2 is a **safety-net**, not a primary mechanism. In a healthy steady state, Pass 2 should find zero in-territory orphans. Repeated Pass-2 hits = prior workflows are leaking → investigate the anchor-discipline DoD check that the main workflows inherited (see W1/W2/W4/W8/W9 DoD).

---

## Cross-repo threads (known gap)

Threads tagged `#repo:cross` (shared contract, migration map, payment semantics shared with bank-bot) don't fit the single-instance doc-anchor model: pg-writer's grep won't see bot-writer's docs and vice versa.

**Current convention (until a shared anchor doc exists):** cross-repo threads are anchored in **both** instances' docs. The opening writer must insert a marker into a doc in their own repo *and* file an `arra_learn` tagged `#repo:cross + #thread-anchor` with the thread id + instruction to the sibling instance to mirror the anchor.

**Known limitation:** if pg-writer opens a cross-repo thread and bot-writer hasn't run since, bot-writer's docs won't contain the mirror anchor. The thread is only visible from mobiz-side grep until bot-writer runs W1 or W2 and picks up the mirror-instruction learning. Tracked in retro when it happens.

A future dedicated `docs/cross-repo-questions.md` in each repo would close this gap; until then, the workaround lives in learnings.

---

## When to invoke this procedure

1. **Step 0 of every main workflow** (W1, W2, W4, W8, W9). Mandatory. "No answered threads in territory" is a Step 0 gate — Step 1 does not start until Pass 1 = 0 and Pass 2 orphan list = 0.
2. **Mid-pass, opportunistically** — when you encounter a marker while reading a doc, check its status inline rather than deferring.
3. **During session wake-up ritual** — SKILL.md §Session-start checks already calls `arra_threads(status="answered")`. If count > 0, treat the session as being in thread-resolution mode: finish Pass 1 before opening any workflow.

---

## Anti-patterns

- **Closing a thread without touching the doc.** Creates silent drift: the doc still says `[AWAITING_THREAD]` but Oracle shows the thread closed. If the next session strips the marker on orphan-detection, the answer is lost forever. Always step 3 + step 4 in the same commit.
- **Closing a thread without posting a closing message** (introduced as explicit rule 2026-04-21 after the thread #16 incident). Without a message citing the fix-commit / decision / classification, the next agent reading `status="closed"` has no provenance and falls into one of two failure modes: (a) strip the marker on faith without verifying — risks orphaning a still-broken claim if the close was premature; (b) re-open / re-investigate from scratch — wastes attention and may re-derive the wrong answer. Always post the message before `arra_thread_update(status="closed")`. Cross-repo close-without-message is especially dangerous because the doc owner cannot reach the closer's commit history easily.
- **Stripping a marker without closing the thread.** Thread stays `answered` and gets re-processed every session as an orphan warning. Always close after stripping.
- **Treating "looks good" as ratification.** Reverse-engineered W8 flows require explicit engagement with the spec, not a rubber-stamp. Downgrade to insufficient.
- **Resolving a thread that belongs to another agent's territory.** If the marker lives outside pg-writer's territory map (e.g., in `RBAC_GUIDE.md` with `#security-auditor` tag), stop. File a note that another agent's marker was observed; do not strip.
- **Opening a new thread without a doc anchor.** The DoD of every main workflow now rejects this. If you need to ask a question but the answer will not land in a specific doc, use `arra_inbox` instead — threads are for doc-anchored claims.

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

## Change log

- 2026-04-17 — Initial version. Doc-anchored scoping (grep-based). Pass 1 + Pass 2 structure. 4-step resolution block. Cross-repo known-gap documented. Created alongside the "thread resolution is blocking" rule in SKILL.md and Step 0 adoption in W1/W2/W4/W8.
- 2026-04-17 (later) — Extended the recognised-marker family to include `[UNDOCUMENTED-STEP:<id>]` (introduced by W9). Pass 1 grep regex widened. Resolution table gained two rows for the UNDOCUMENTED-STEP lifecycle (human says "real step" → spawn W8 revision; human says "internal helper" → file `#undocumented-step-benign` learning so the next W9 scan doesn't re-flag). Step 0 now applies to W9 passes as well.
- 2026-04-17 (later) — **Calibration from W9 first-run retro** (`ψ/memory/retrospectives/2026-04/17/23.19_flow-track-349b1e5-90425ba.md`): Pass 1 dedupe bug fixed. Naive `sort -u` dedupes line strings not ids, so a thread id mentioned in both the doc header and the §Change log was at risk of being processed twice. New procedure: extract just the id with a `sed` pass, `sort -u` the ids, then for each unique id locate the **load-bearing anchor** (first/top-most occurrence in the doc). Subsequent mentions in §Change log or inline narrative are informational and stay as-is (historical record per P-001). Added a practical heuristic for where each marker's load-bearing anchor lives (`[RATIFICATION_PENDING]` → header; `[AWAITING_THREAD]` → inline claim; `[UNDOCUMENTED-STEP]` → §Implementation pointers).
- 2026-04-18 — **Added `[RATIFICATION_LAPSED:<id>]` to the recognised marker family** as part of the W8 calibration bundle. Terminal/historical marker written by W8 Step 7's decay rule when a ratification thread ages past 60 days without a human answer. Intentionally excluded from Pass 1 grep — reprocessing a terminal marker every session would be noise. Documents stay readable/usable with the marker; next W8 revision either re-opens a fresh ratification thread or accepts the lapsed state by downgrading claim strength in the header.
- 2026-04-18 (later) — **Oracle status-lifecycle fix (Pass 1 + Pass 2).** Observed concretely via thread #3 (`bank-bot .env.example BOT_SECRET`): human had answered `ถาม dev มาแล้ว เค้าบอกว่า เป็นแค่ place_holder` on 2026-04-17 but the thread's `status` stayed `pending` — Oracle does not auto-transition `pending` → `answered` when a human reply lands. Pass 1 was classifying by `status` alone and missed every human-answered thread; Pass 2's `arra_threads(status="answered")` always returned 0. Fix: Pass 1 now dispatches on the **pair** `(status, last-message role)` — `pending + human-last-message` is operationally equivalent to `answered` and runs the 4-step resolution block. Pass 2 now scans both `pending` and `answered` thread lists, then filters by the same role rule. Added a §"Oracle status lifecycle" explainer so future agents understand why the rule looks unusual. Deployment-agnostic: if/when Oracle auto-transitions in the future, the old code path (`status=answered`) still works in parallel.
- 2026-04-21 (brew-ops) — **Step 4 closing-message rule + matching anti-pattern bullet added.** Driven by the 2026-04-20 thread #16 incident: thread closed via `arra_thread_update(status="closed")` with zero messages beyond the opener (`message_count=1`). Result: 4 `[AWAITING_THREAD:16]` markers stranded across `bank-bot/docs/flows/ktb-single-transfer-withdrawal.md` for 2 days because pg-writer's mobiz-side W9 sweep (which would normally strip on close) had no fix-evidence to cite, and bot-writer (who actually landed the fix in commit `3359d08`, W9 PR #87) closed the thread without posting a citation. Cross-repo amplifier: the doc owner (bot-writer) and the marker filer (pg-writer via thread #13) live in different repos, so the closer's local commit history was not reachable. The W9 spec also got a Step 4b (section-level marker reconciliation) the same session to make the doc-side cleanup mandatory; this thread-resolve change makes the closer's side mandatory too — both sides of the loop now have a discipline. Sibling-synced; bank-bot copy gets identical change.
- 2026-04-22 (brew-ops, Gap 2 fix from handoff `2026-04-22_12-57`) — **Step 5 supersede-sweep added to the 4-step resolution block.** When a thread's resolution files a `ruled-*` / `resolution-*` / `fix-*` / `followup-*` learning, verify every drift-discovery cited in its `source:` has `superseded_by` set; call `arra_supersede` if missing. Paired with `workflow-8-flow-map.md` §Step 5 "When filing ruled-/resolution-/followup- learnings" edit from the same pass. Sibling-synced to bank-bot copy. Same root cause: two 2026-04-19 drift-discoveries stayed `superseded_by: null` for 3–4 days because their `ruled-` replacements cited via `source:` only, never called the tool.
- 2026-04-22 (brew-ops, Gap 3 fix from handoff `2026-04-22_12-57`) — **Orphan-close resolution block added; Pass 1 `closed | any` dispatch now routes through it.** Before 2026-04-22 the rule was a single action (strip marker + file `#workflow-bug + #orphan-marker` learning), which silently lost real resolutions when the closer had landed a code fix but failed the §Step 4 closing-message rule. New 4-step procedure: extract code areas from thread opener → grep current HEAD across primary + sibling repos → if code changed, file ruled-drift + `arra_supersede` (per workflow-8 §Step 5 Gap-2 rule) + strip marker with `[RESOLVED:YYYY-MM-DD]`; if unchanged, fall back to the old workflow-bug filing **and** re-open the thread with a bump message citing grep evidence (do not re-strip). Sibling-synced to bank-bot copy. Driven by 2026-04-20 thread #16 incident: bank-bot `3359d08` fixed drift #2 the same day W9 stripped the marker as orphan — this sweep would have detected the fix.
