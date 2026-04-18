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

1. `arra_thread_read(threadId=<id>)` → inspect `status` + last message.
2. Dispatch on status:

| `status` | Action |
|---|---|
| `active` | No-op. Thread still awaits human. Leave marker. |
| `pending` | No-op. Human triaging. Leave marker. |
| `answered` | **Run the 4-step resolution block below.** This is the reason Pass 1 exists. |
| `closed` | **Orphan marker**: the thread was closed elsewhere but the doc still references it. Strip the marker in the same commit; file a one-line `#workflow-bug + #orphan-marker` learning naming the file + commit that introduced the marker. |

### The 4-step resolution block (for `status=answered`)

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

   ```
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

### Pass 2 — Safety-net orphan scan

After Pass 1 resolves everything grep'd from docs, cross-check:

```
arra_threads(status="answered", limit=50)
```

For each returned thread whose id was **not** seen in Pass 1's grep output:

1. Check whether its title or message body suggests pg-writer territory (mentions `flow:`, `current-system`, `bank-bot`, `scheduler`, `deposit`, etc.).
2. If it does → **this is a workflow bug** (an earlier pass opened a thread but forgot to anchor it in a doc). File `#workflow-bug + #thread-orphan` learning naming the thread id + opening commit + guess at which workflow leaked it. Escalate via `arra_inbox` so a human can triage (anchor or close).
3. If it's clearly another agent's territory (e.g., title starts with `test:`, `security:`, mentions `target-system`) → leave it; not ours.

Pass 2 is a **safety-net**, not a primary mechanism. In a healthy steady state, Pass 2 should find zero pg-writer threads without anchors. Repeated Pass-2 hits = prior workflows are leaking → investigate the anchor-discipline DoD check.

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
- **Stripping a marker without closing the thread.** Thread stays `answered` and gets re-processed every session as an orphan warning. Always close after stripping.
- **Treating "looks good" as ratification.** Reverse-engineered W8 flows require explicit engagement with the spec, not a rubber-stamp. Downgrade to insufficient.
- **Resolving a thread that belongs to another agent's territory.** If the marker lives outside pg-writer's territory map (e.g., in `RBAC_GUIDE.md` with `#security-auditor` tag), stop. File a note that another agent's marker was observed; do not strip.
- **Opening a new thread without a doc anchor.** The DoD of every main workflow now rejects this. If you need to ask a question but the answer will not land in a specific doc, use `arra_inbox` instead — threads are for doc-anchored claims.

---

## Change log

- 2026-04-17 — Initial version. Doc-anchored scoping (grep-based). Pass 1 + Pass 2 structure. 4-step resolution block. Cross-repo known-gap documented. Created alongside the "thread resolution is blocking" rule in SKILL.md and Step 0 adoption in W1/W2/W4/W8.
- 2026-04-17 (later) — Extended the recognised-marker family to include `[UNDOCUMENTED-STEP:<id>]` (introduced by W9). Pass 1 grep regex widened. Resolution table gained two rows for the UNDOCUMENTED-STEP lifecycle (human says "real step" → spawn W8 revision; human says "internal helper" → file `#undocumented-step-benign` learning so the next W9 scan doesn't re-flag). Step 0 now applies to W9 passes as well.
- 2026-04-17 (later) — **Calibration from W9 first-run retro** (`ψ/memory/retrospectives/2026-04/17/23.19_flow-track-349b1e5-90425ba.md`): Pass 1 dedupe bug fixed. Naive `sort -u` dedupes line strings not ids, so a thread id mentioned in both the doc header and the §Change log was at risk of being processed twice. New procedure: extract just the id with a `sed` pass, `sort -u` the ids, then for each unique id locate the **load-bearing anchor** (first/top-most occurrence in the doc). Subsequent mentions in §Change log or inline narrative are informational and stay as-is (historical record per P-001). Added a practical heuristic for where each marker's load-bearing anchor lives (`[RATIFICATION_PENDING]` → header; `[AWAITING_THREAD]` → inline claim; `[UNDOCUMENTED-STEP]` → §Implementation pointers).
- 2026-04-18 — **Added `[RATIFICATION_LAPSED:<id>]` to the recognised marker family** as part of the W8 calibration bundle. Terminal/historical marker written by W8 Step 7's decay rule when a ratification thread ages past 60 days without a human answer. Intentionally excluded from Pass 1 grep — reprocessing a terminal marker every session would be noise. Documents stay readable/usable with the marker; next W8 revision either re-opens a fresh ratification thread or accepts the lapsed state by downgrading claim strength in the header.
