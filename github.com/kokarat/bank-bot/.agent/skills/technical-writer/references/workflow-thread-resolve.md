# Workflow procedure — Thread Resolution

> Shared sub-procedure referenced from every main workflow (W1, W2, W4).
> **Not** a full workflow. Runs at Step 0 of every pass and whenever an
> answered thread is discovered mid-pass. Also runs when a doc marker
> (`[AWAITING_THREAD:<id>]` / `[RATIFICATION_PENDING:<id>]`) is touched.

---

## Why this exists

`arra_thread` is async. Humans answer on their own time via Studio `/forum`. Without a forcing function, answered threads become zombies: the agent sees them listed in the wake-up ritual but never acts on them, and the doc keeps the stale `[AWAITING_THREAD:<id>]` marker forever.

This procedure turns "answered thread" from a **passive signal** into **blocking work** that every main workflow must clear before opening new tasks.

---

## Scoping rule — "my threads" is doc-anchored, not title-anchored

A thread is **mine** (this instance's responsibility) if and only if a doc I own currently contains a `[AWAITING_THREAD:<id>]` or `[RATIFICATION_PENDING:<id>]` marker referencing its id.

Title prefixes (`flow:<slug>`, `drift:<area>`) are **hints for humans**, not scoping. They collide across agents and survive renames. Doc anchors are load-bearing; titles are not.

Implication for every `arra_thread()` call inside a workflow:

- You **must** immediately insert the paired marker into the doc being produced in the same PR. A thread with no doc anchor is a workflow bug, not a thread.
- When you resolve a thread, you either update the marker in place (`[AWAITING_THREAD:<id>]` → `// verified-via-thread:<id>`) or strip it (ratification marker) in the same commit that closes the thread. Marker removal and `status="closed"` happen together.

---

## Territory map (bot-writer)

Pass 1 (doc-anchored grep) runs against **these paths only**. Files outside this list are not bot-writer's territory and their markers — if any — belong to another agent or are stale debris.

```
docs/current-system.md
workflow/                    # narrative docs per bank (workflow/scb-*.md, etc.)
README.md
CLAUDE.md
```

Files **not** in bot-writer's territory (skip):

- Anything under the mobiz-payment-gateway repo (`github.com/kokarat/mobiz-payment-gateway/**`) — bot-writer's territory.
- `node_modules/**` — vendor.
- `data/`, `data-*/` — runtime state.
- The legacy in-repo `ψ/**` directory — not canonical memory.
- Future bot-next-writer files (do not exist yet).

---

## Procedure

### Pass 1 — Doc-anchored (primary, authoritative)

```bash
grep -rEn '\[(AWAITING_THREAD|RATIFICATION_PENDING):([A-Za-z0-9_-]+)\]' \
  docs/current-system.md workflow README.md CLAUDE.md \
  2>/dev/null
```

Expected output per line: `<file>:<line>:[<MARKER>:<id>]`.

**Dedupe by id, not by line.** One thread id can legitimately appear multiple times in a single doc (header + change log + resolved-questions section). Naive `sort -u` dedupes identical `<file>:<line>:[<MARKER>:<id>]` strings, not identical `<id>`s — so two different lines referencing the same id survive and the id is processed twice.

```bash
raw=$(grep -rEn '\[(AWAITING_THREAD|RATIFICATION_PENDING):[A-Za-z0-9_-]+\]' <territory> 2>/dev/null)
echo "$raw" | sed -E 's/.*\[(AWAITING_THREAD|RATIFICATION_PENDING):([A-Za-z0-9_-]+)\].*/\2/' | sort -u
# → unique ids to process

# For each unique id, the load-bearing anchor is the first matching line:
for id in <unique-ids>; do
  echo "$raw" | grep -F "[$MARKER:$id]" | head -1
done
```

**Which occurrence is load-bearing?** The **first / top-most** occurrence in the doc. Subsequent mentions — typically in `§Change log` or inline narrative prose — are **informational** references to the thread, not live markers awaiting resolution. Only the load-bearing anchor is subject to the "update/strip marker + close thread + `arra_thread_update(status='closed')`" transform; informational mentions stay as-is (historical record per P-001).

Practical heuristic: `[RATIFICATION_PENDING]` load-bearing anchor lives in the doc **header** (first 10 lines); `[AWAITING_THREAD]` lives inline on the specific claim. A mention further down the doc in §Change log is informational.

For each unique `<id>`:

1. `arra_thread_read(threadId=<id>)` → inspect **both** `status` **and** `last_message.role`.
2. Dispatch on the pair `(status, last-message role)`:

| `status` | last message role | Action |
|---|---|---|
| `active` | any | No-op. Thread still awaits human. Leave marker. |
| `pending` | `claude` | No-op. Genuinely waiting for human. Leave marker. |
| `pending` | `human` | **Run the 4-step resolution block.** Human has replied; Oracle's deployment does not auto-transition `pending` → `answered` when a human message lands (see §"Oracle status lifecycle" below). This is the **most common case** that actually fires in practice. |
| `answered` | any | **Run the 4-step resolution block.** Normal case when / if Oracle auto-transitions in a future deployment. |
| `closed` | any | **Orphan marker**: the thread was closed elsewhere but the doc still references it. Strip the marker in the same commit; file a one-line `#workflow-bug + #orphan-marker` learning naming the file + commit that introduced the marker. |

### Oracle status lifecycle — deployment quirk (read this once, understand forever)

In this Oracle deployment, thread status transitions are **not** fully automatic:

- Opening a thread: status starts as `pending`.
- Human writes a reply via Studio `/forum` UI: status **stays `pending`**. The human message is appended to the thread's `messages` array, but no status transition fires.
- Only explicit calls to `arra_thread_update(threadId, status=...)` change status.

`arra_threads(status="answered", limit=50)` therefore returns **0 results** on a working system where humans have actually replied — because nobody ever called `arra_thread_update(status="answered")`. Observed concretely: thread #3 (`bank-bot .env.example BOT_SECRET`) had a human reply on 2026-04-17 but stayed `pending`, so Pass 2 filtered on `status="answered"` found zero.

**The fix embedded in the dispatch table above:** Pass 1 classifies by **(status, last-message role)** not by status alone. A thread with `status="pending"` whose most recent message came from a human is treated as effectively-answered and runs the 4-step resolution block. Deployment-agnostic: if/when Oracle auto-transitions in the future, the `status="answered"` branch fires; until then, the `pending + human` branch carries the load.

### The 4-step resolution block (for answered-effective threads)

1. **Read the answer.** `arra_thread_read(threadId=<id>)`. Read every message since you opened it, not just the latest — humans sometimes answer the original question in message 3 and correct themselves in message 5.
2. **Classify the answer.**

   | Classification | Test | Next step |
   |---|---|---|
   | Sufficient + unambiguous | The answer lets you write a definite doc claim with no guessing. | Proceed to step 3. |
   | Sufficient but partial | Answers the literal question but exposes a new ambiguity. | Update the doc for the part that was answered; open a follow-up via `arra_thread(threadId=<id>, message=…)` for the new ambiguity; re-anchor under a new `[AWAITING_THREAD]` marker if needed. Do **not** close yet. |
   | Insufficient / vague | You'd still be guessing. | `arra_thread(threadId=<id>, message=…)` asking the disambiguating question. Do **not** close. Leave marker. |
   | Says "I don't know, ask <other-role>" | Human is punting to someone else. | Do **not** close. `arra_inbox` to the named role; leave marker; note in retro. |

   **Ratification threads** (`[RATIFICATION_PENDING:<id>]` markers): the answer must be an affirmative confirmation. A neutral "looks fine" or "sure" without engagement with the spec is **insufficient**. Downgrade to insufficient and follow up asking the human to confirm specific parts they reviewed. Bot-writer does not yet author reverse-engineered specs (W8 is mobiz-only in the current pilot), so `[RATIFICATION_PENDING]` markers in bank-bot territory should be rare — if one appears, it was probably created manually or migrated; still apply the stricter test.

3. **Update the doc + strip/transform the marker.**

   Same commit as step 4. Never split.

   | Original marker | Becomes | Added annotation |
   |---|---|---|
   | `[AWAITING_THREAD:<id>]` inline on a claim | (marker removed) | `// verified-via-thread:<id>` |
   | `[AWAITING_THREAD:<id>]` standalone (e.g., under "Open questions") | entry moved to "Resolved questions" or deleted if trivial | `// verified-via-thread:<id>` next to the ratified statement |
   | `[RATIFICATION_PENDING:<id>]` in doc header | (marker removed) | header gains `// ratified-via-thread:<id>` on its own line |

   If the doc section was tentatively written while the thread was open and the answer changed the semantics, rewrite the section. The thread answer is now the load-bearing claim — cite it with `// verified-via-thread:<id>`.

4. **Close the thread + chain the trace.**

   ```
   arra_thread_update(threadId=<id>, status="closed")
   ```

   Then, if this pass touched a trace (W1 root trace, W2 evolution chain, W4 resolution trace), add a child trace recording the resolution:

   ```
   arra_trace(
     query="thread <id> resolved — <one-line semantics of the answer>",
     queryType="pattern",
     scope="project",
     project="github.com/kokarat/bank-bot",
     parentTraceId=<current pass's root trace, if any>
   )
   ```

   If no pass-scoped trace is open (Step 0 of a fresh workflow before the root trace exists), record the `arra_thread_update` call in the retro instead of creating an orphan trace.

### Pass 2 — Safety-net orphan scan

After Pass 1 resolves everything grep'd from docs, cross-check against the thread list. Because of the Oracle status-lifecycle quirk (see §"Oracle status lifecycle" above), scanning only `status="answered"` misses every thread where a human actually replied. Pass 2 must scan **both** `pending` and `answered`, then filter by last-message role the same way Pass 1 does:

```
pending  = arra_threads(status="pending",  limit=50)
answered = arra_threads(status="answered", limit=50)   # kept for forward-compat
candidates = pending ∪ answered
```

For each thread `t` in `candidates` whose id was **not** seen in Pass 1's grep output:

1. **Filter by effective state.** Only proceed if `t` is in an answered-effective state — i.e., `t.status == "answered"` **or** (`t.status == "pending"` **and** `t.last_message.role == "human"`). A `pending + claude-last-message` thread is genuinely still waiting and is not an orphan candidate; skip it.
2. **Territory check.** Look at `t.title` and the body of `t.messages[0]`. If the title / first message mentions bot-writer territory (`bank-bot`, `scb`, `ktb`, `kbank`, `bbl`, `otp`, `selector`, `session-reuse`, `approver`, `dispatcher`, `sse`, `.env.example`, etc.) → continue to step 3. Otherwise it's clearly another agent's territory (e.g. titles mentioning `mobiz-payment-gateway`, `flow:`, `current-system` in the mobiz-side sense) — leave it; not ours.
3. **File as orphan.** This is a **workflow bug** — an earlier pass opened a thread but forgot to anchor it in a doc. File a `#workflow-bug + #thread-orphan` learning naming the thread id + opening commit + guess at which workflow leaked it. Escalate via `arra_inbox` so a human can triage (anchor after-the-fact or close). Do **not** run the 4-step resolution block on the orphan directly — without a doc to update, closing the thread would lose the human's answer.

Pass 2 is a **safety-net**, not a primary mechanism. In a healthy steady state, Pass 2 should find zero bot-writer threads without anchors. Repeated Pass-2 hits = prior workflows are leaking → investigate the anchor-discipline DoD check that the main workflows inherited (see W1/W2/W4 DoD).

---

## Cross-repo threads (known gap)

Threads tagged `#repo:cross` (shared contract, migration map, payment semantics shared with bank-bot) don't fit the single-instance doc-anchor model: bot-writer's grep won't see bot-writer's docs and vice versa.

**Current convention (until a shared anchor doc exists):** cross-repo threads are anchored in **both** instances' docs. The opening writer must insert a marker into a doc in their own repo *and* file an `arra_learn` tagged `#repo:cross + #thread-anchor` with the thread id + instruction to the sibling instance to mirror the anchor.

**Known limitation:** if bot-writer opens a cross-repo thread and bot-writer hasn't run since, bot-writer's docs won't contain the mirror anchor. The thread is only visible from mobiz-side grep until bot-writer runs W1 or W2 and picks up the mirror-instruction learning. Tracked in retro when it happens.

A future dedicated `docs/cross-repo-questions.md` in each repo would close this gap; until then, the workaround lives in learnings.

---

## When to invoke this procedure

1. **Step 0 of every main workflow** (W1, W2, W4). Mandatory. "No answered threads in territory" is a Step 0 gate — Step 1 does not start until Pass 1 = 0 and Pass 2 orphan list = 0.
2. **Mid-pass, opportunistically** — when you encounter a marker while reading a doc, check its status inline rather than deferring.
3. **During session wake-up ritual** — SKILL.md §Session-start checks already calls `arra_threads(status="answered")`. If count > 0, treat the session as being in thread-resolution mode: finish Pass 1 before opening any workflow.

---

## Anti-patterns

- **Closing a thread without touching the doc.** Creates silent drift: the doc still says `[AWAITING_THREAD]` but Oracle shows the thread closed. If the next session strips the marker on orphan-detection, the answer is lost forever. Always step 3 + step 4 in the same commit.
- **Stripping a marker without closing the thread.** Thread stays `answered` and gets re-processed every session as an orphan warning. Always close after stripping.
- **Treating "looks good" as ratification.** If a `[RATIFICATION_PENDING]` marker surfaces, require explicit engagement with the spec, not a rubber-stamp. Downgrade to insufficient.
- **Resolving a thread that belongs to another agent's territory.** If the marker lives outside bot-writer's territory map (e.g., in `RBAC_GUIDE.md` with `#security-auditor` tag), stop. File a note that another agent's marker was observed; do not strip.
- **Opening a new thread without a doc anchor.** The DoD of every main workflow now rejects this. If you need to ask a question but the answer will not land in a specific doc, use `arra_inbox` instead — threads are for doc-anchored claims.

---

## Change log

- 2026-04-17 — Initial version, mirrored from pg-writer (mobiz) with territory map narrowed to bot-writer's files (`docs/current-system.md`, `workflow/`, `README.md`, `CLAUDE.md`). W8 language pruned — bot-writer does not have W8 yet in the current pilot. Project field set to `github.com/kokarat/bank-bot`. Created alongside "thread resolution is blocking" rule in SKILL.md and Step 0 adoption in W1/W2/W4.
- 2026-04-17 (later) — **Calibration from pg-writer's W9 first-run retro** (bug applies to both instances): Pass 1 dedupe fixed — extract id with `sed`, `sort -u` the ids (not the `<file>:<line>:<marker>` strings), then for each unique id locate the load-bearing anchor (first/top-most occurrence). Prior `sort -u` would double-process an id mentioned in both header and §Change log. Added practical heuristic for where each marker's anchor lives.
- 2026-04-18 — **Oracle status-lifecycle fix (Pass 1 + Pass 2).** Observed via thread #3 (`bank-bot .env.example BOT_SECRET`) from bot-writer's W1 first-run retro (16.58): human answered on 2026-04-17 (`ถาม dev มาแล้ว เค้าบอกว่า เป็นแค่ place_holder`) but thread `status` stayed `pending` — Oracle does not auto-transition `pending` → `answered` on human reply. Pass 1 and Pass 2 now dispatch on `(status, last-message role)` pair instead of status alone. `pending + human-last-message` is treated as answered-effective and runs the 4-step resolution block. Pass 2 scans both `pending` and `answered` lists then filters by role. Added §"Oracle status lifecycle" explainer. Mirrored from pg-writer's copy; no bot-specific adjustments beyond territory keywords.
