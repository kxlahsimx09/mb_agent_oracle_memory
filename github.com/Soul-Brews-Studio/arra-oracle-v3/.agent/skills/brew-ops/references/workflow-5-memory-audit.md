---
description: Periodic health audit of Oracle memory system — verify P-001..P-004 compliance, catch bloat/orphans/drift, synthesize signals from peer retros
owner: brew-ops
autonomy: read-only
cadence: weekly, on-request, or after major fleet/indexer changes
---

# Workflow 5 — Memory Audit

This is brew-ops' periodic health check for the Oracle memory system. It answers one question per run:

> **"Is every agent using Oracle memory the way upstream designed it to be used, and is the pipeline still healthy?"**

No writes to the vault except `arra_learn` of findings and (if urgent) `arra_handoff`. Nothing is re-indexed, no files moved, no DB rows modified. The workflow **observes and reports** — fixes are separate, human-approved follow-ups.

## Scope & rules

- **Read-only on vault files, DB, and all services.** Use `arra_search`, `sqlite3` / `bun:sqlite`, `curl` to the HTTP API, and `find` on disk.
- **Writes allowed (findings only):**
  - `arra_learn` with the audit summary, tagged `#brew-ops #memory #audit`.
  - `arra_handoff` if P0 issues need immediate attention.
- **Writes forbidden:** no `bun run index`, no `bun src/scripts/index-model.ts`, no `arra_supersede`, no file moves, no `git push`, no config changes.
- **Principle wins.** If a check conflicts with a principle in Oracle (P-001..P-004), the principle wins — describe the drift, don't delete.
- **One audit, one learning.** Every completed audit produces at least one `arra_learn` entry so the next audit can see what changed.

## Prerequisites

Before running, confirm:

1. Oracle HTTP server is running on `:47778`. If not, stop and report — audit cannot proceed without a live server.
2. You are on a recent commit of `arra-oracle-v3`. If the working tree is dirty with indexer changes, flag but continue.
3. You have read `.agent/AGENTS.md` in the current session.

## Step 0 — Principle grounding (mandatory)

Every audit starts here. No exceptions.

```
arra_search query="soul-brews-core" type=principle limit=20
```

Confirm the 4 root principles are present and indexed:

- P-001 Nothing is Deleted
- P-002 Patterns Over Intentions
- P-003 External Brain, Not Commander
- P-004 Code is Truth, Documents are Claims

If any principle is missing, **stop and file P0 immediately** — the ecosystem's ethical spine is broken.

Also run:

```
arra_search query="brew-ops audit" type=learning limit=5
```

Read prior audit findings. Don't re-investigate issues another audit already flagged unless evidence suggests they recurred.

## Step 0.5 — Preflight indexing check (non-blocking)

Before running the structural audit, check whether disk has files the DB hasn't seen yet. Peer workflows (pg-writer, bot-writer, etc.) write retros/learnings to disk, and `soul-sync` can pull peer content in — but **none of these trigger the indexer automatically**. Files sit on disk until someone runs `bun run index`.

The audit's §13 (retro synthesis) and §14 (coherence sampling) read from disk directly, so they work regardless. But §2 (Disk↔DB sync) will legitimately flag unindexed files as drift — which is useful **signal** but may not be **actionable** if the files arrived 2 minutes ago from soul-sync.

```bash
VAULT=~/Code/github.com/kxlahsimx09/mb_agent_oracle_memory
DB=~/.arra-oracle-v2/oracle.db

# Count files on disk not in DB
bun --eval '
const db = new (require("bun:sqlite").Database)(require("os").homedir() + "/.arra-oracle-v2/oracle.db");
const { execSync } = require("child_process");
const vault = require("os").homedir() + "/Code/github.com/kxlahsimx09/mb_agent_oracle_memory";
const found = execSync(`find ${vault} -path "*/ψ/memory/*" -name "*.md"`, {encoding:"utf8"})
  .trim().split("\n").map(p => p.replace(vault + "/", ""));
const dbSet = new Set(db.query("SELECT DISTINCT source_file FROM oracle_documents").all().map(r => r.source_file));
const unindexed = found.filter(p => !dbSet.has(p));
console.log("Disk files:", found.length, "| DB files:", dbSet.size, "| Unindexed:", unindexed.length);
if (unindexed.length > 0 && unindexed.length <= 10) unindexed.forEach(p => console.log("  •", p.slice(-80)));
'
```

**Decision tree:**

| Unindexed count | Action |
|---|---|
| 0 | ✅ proceed to §1 |
| 1-3 | ⚠️ proceed — §2 will flag, acceptable drift |
| 4+ | 🛑 **stop and ask the user**: "N files unindexed. Run `bun run index` first (recommended) or continue with known drift?" |

If the user says "continue", note the count in the final report §15 under "Known drift at audit start: N unindexed files". Do **NOT** run the indexer yourself — that masks the drift from this audit and hides whatever pattern caused the accumulation.

**Why this isn't auto-fixing:** silently running `bun run index` at audit start would turn every audit into a PASS for §2, even when peer sync is broken. The whole point of a read-only audit is to see reality, not to fix it.

---

## Step 1 — Git sync

```bash
VAULT=~/Code/github.com/kxlahsimx09/mb_agent_oracle_memory
git -C $VAULT fetch origin
git -C $VAULT status --porcelain | head -20
git -C $VAULT rev-list --left-right --count origin/main...HEAD
```

**Acceptance:**

| State | Severity |
|---|---|
| Clean + local == origin | PASS |
| Uncommitted vault files | WARN (P2) — memory pending propagation |
| Local ahead of origin by 1-2 commits | PASS (auto-commit cadence) |
| Local behind origin | WARN (P1) — may miss peer-synced learnings |
| Conflicts / detached HEAD | FAIL (P0) |

## Step 2 — Disk ↔ DB sync

```bash
DB=~/.arra-oracle-v2/oracle.db

# Disk files in ψ/memory/ (handoffs and inbox not indexed)
DISK=$(find $VAULT -path '*/ψ/memory/*' -name '*.md' | wc -l | tr -d ' ')

bun --eval '
const db = new (require("bun:sqlite").Database)(require("os").homedir() + "/.arra-oracle-v2/oracle.db");
const docs = db.query("SELECT COUNT(DISTINCT source_file) as n FROM oracle_documents").get();
const fts = db.query("SELECT COUNT(*) as n FROM oracle_fts").get();
const ftsUniq = db.query("SELECT COUNT(DISTINCT id) as n FROM oracle_fts").get();
const orphans = db.query("SELECT COUNT(*) as n FROM oracle_fts WHERE id NOT IN (SELECT id FROM oracle_documents)").get();
console.log("docs:", docs.n, "fts:", fts.n, "ftsUniq:", ftsUniq.n, "orphans:", orphans.n);
'
```

**Acceptance:**

| Metric | PASS | WARN | FAIL |
|---|---|---|---|
| disk_files == db_unique_source_files | ✓ | ±1-2 | >5 diff |
| fts_rows / docs | 1.00-1.05 | 1.05-1.5 | >1.5 (bloat — P1) |
| fts_orphans | 0-2 | 3-20 | >20 (P1 — stale rows) |

**Known-good baseline (2026-04-18):** 598 docs, 598 fts, 0 orphans, ratio 1.000.

If bloat detected: reference the fix in `local/all-prs` → `fix/indexer-fts5-dedupe-and-wal` (commit 47a3289). Do not re-index here — flag only.

## Step 3 — Vector search health

```bash
# HTTP path (fresh server connection)
curl -s 'http://localhost:47778/api/search?q=flow+deposit&mode=vector&limit=3' \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print('total:', d.get('total'), 'results:', len(d.get('results',[])))"

# MCP path (whatever MCP instance this session has)
arra_search query="flow deposit" mode=vector limit=3
```

**Acceptance:**

| Condition | Severity |
|---|---|
| Both HTTP and MCP return vector hits | PASS |
| HTTP works, MCP empty | WARN (P1) — stale MCP handle in current session; new sessions will work |
| HTTP empty, stats says `vector_status: connected` | FAIL (P0) — LanceDB path drift; see learning `2026-04-14_arra-oracle-indexer-server-lancedb-drift` |
| Both empty + `vector_status: disconnected` | FAIL (P0) — Ollama down or LanceDB dir missing |

**Known drift pattern:** MCP (`src/index.ts`) uses `CHROMADB_DIR=~/.chromadb`, server (`src/server.ts` via `getVectorStoreByModel`) uses `LANCEDB_DIR=~/.arra-oracle-v2/lancedb`. Check both dirs have recent-enough `oracle_knowledge*.lance` collections.

## Step 4 — Path corruption

```bash
bun --eval '
const db = new (require("bun:sqlite").Database)(require("os").homedir() + "/.arra-oracle-v2/oracle.db");
const bad = db.query(`
  SELECT id, source_file, project FROM oracle_documents
  WHERE source_file LIKE "%<%" OR source_file LIKE "%>%" OR source_file LIKE "% %"
     OR project LIKE "%<%" OR project LIKE "%>%" OR project LIKE "% %"
  LIMIT 10
`).all();
console.log("corrupt rows:", bad.length);
bad.forEach(r => console.log(" ", r.id.slice(-80)));
'
```

**Acceptance:**

| Count | Severity |
|---|---|
| 0 corrupt + no corrupt superseded rows | PASS |
| >0 **active** (non-superseded) corrupt rows | FAIL (P0) — agent will see bad results |
| Corrupt rows all `superseded_at IS NOT NULL` | PASS — preserved per P-001 |

**Precedent (fixed 2026-04-18):** `github.com/kokarat/bank-bot<` — literal `<` in directory name and project tag. Fixed via `git mv` + frontmatter edit + re-index + supersede of old rows.

## Step 5 — 3-layer tag compliance

Charter §7a mandates three tag layers on every vault write:

- Layer 1 (repo scope): `repo:<name>` or `repo:cross`
- Layer 2 (system domain): e.g. `memory`, `indexer`, `fleet`, `federation`
- Layer 3 (role): e.g. `brew-ops`, `pg-writer`, `bot-writer`

Python audit (handles ψ paths correctly):

```python
import os, re
vault = os.path.expanduser('~/Code/github.com/kxlahsimx09/mb_agent_oracle_memory')
REPO_RE = re.compile(r'repo:(arra-oracle-v\d|maw-js|oracle-studio|cross|bank-bot|mobiz-payment-gateway)')
ROLES = {'brew-ops','pg-writer','pg-tester','bot-writer','technical-writer','tester'}

stats = {'total':0, 'missing_repo':0, 'missing_role':0, 'no_tags':0}
for root, _, files in os.walk(vault):
    if '.git' in root: continue
    if '/ψ/memory/' not in root: continue   # handoffs excluded
    for f in files:
        if not f.endswith('.md'): continue
        stats['total'] += 1
        with open(os.path.join(root,f), errors='ignore') as fd: c = fd.read()
        m = re.search(r'^tags:\s*\[(.*?)\]', c, re.MULTILINE)
        if not m: stats['no_tags'] += 1; continue
        tstr = m.group(1)
        if not REPO_RE.search(tstr): stats['missing_repo'] += 1
        if not any(r in tstr for r in ROLES): stats['missing_role'] += 1
print(stats)
```

**Acceptance:**

| Metric | PASS | WARN | FAIL |
|---|---|---|---|
| `no_tags / total` | <1% | 1-5% | >5% |
| `missing_repo / total` | <5% (principles ok) | 5-10% | >10% |
| `missing_role / total` | <5% | 5-10% | >10% |

**Note:** Principles (`ψ/memory/resonance/*`) are ecosystem-wide and legitimately lack `repo:` / `role:` tags — exclude from percentages if feasible.

## Step 6 — Retro quality

Charter mandates **AI Diary + Honest Feedback** on every retro.

```bash
missing=0; total=0
for retro in $(find $VAULT -path '*/ψ/memory/retrospectives/*.md'); do
  total=$((total+1))
  d=$(grep -ci "diary" "$retro")
  f=$(grep -ci "honest feedback\|feedback" "$retro")
  if [ "$d" = "0" ] || [ "$f" = "0" ]; then
    missing=$((missing+1))
    echo "⚠️ $(basename $retro): diary=$d feedback=$f"
  fi
done
echo "$missing / $total retros missing required sections"
```

**Acceptance:**

| Rate | Severity |
|---|---|
| 0 missing | PASS |
| 1-5% missing | WARN (P2) — remind owning agent |
| >5% missing | FAIL (P1) — role discipline drift |

## Step 7 — Cross-reference validity

```python
import os, re
vault = os.path.expanduser('~/Code/github.com/kxlahsimx09/mb_agent_oracle_memory')
by_basename = {}
for root,_,files in os.walk(vault):
    if '.git' in root: continue
    for f in files:
        if f.endswith('.md'): by_basename.setdefault(f[:-3], []).append(os.path.join(root,f))

valid=0; broken=0; ext=0; placeholder=0
for paths in by_basename.values():
    for fp in paths:
        if '/ψ/memory/' not in fp: continue
        with open(fp, errors='ignore') as fd: c = fd.read()
        m = re.search(r'^related:\s*\n((?:\s*-\s+.+\n?)+)', c, re.MULTILINE)
        if not m: continue
        for line in m.group(1).split('\n'):
            ref = line.strip().lstrip('- ').strip().strip('"\'')
            if not ref: continue
            if ref.startswith('<') or ref.startswith('http'):
                (placeholder if ref.startswith('<') else ext).__iadd__  # count pointer
                if ref.startswith('http'): ext += 1
                else: placeholder += 1
                continue
            key = ref[:-3] if ref.endswith('.md') else ref
            key = os.path.basename(key)
            if key in by_basename: valid += 1
            else: broken += 1
print(f'valid={valid} broken={broken} external={ext} placeholder={placeholder}')
```

**Acceptance:**

| Metric | PASS | WARN | FAIL |
|---|---|---|---|
| `broken / (valid+broken)` | <2% | 2-10% | >10% |
| `placeholder` (literal `<prior...>` etc.) | 0 in ψ/memory | any | — |

External URLs (GitHub issues, etc.) are expected — don't count as broken.

## Step 8 — Supersede chain integrity

```bash
bun --eval '
const db = new (require("bun:sqlite").Database)(require("os").homedir() + "/.arra-oracle-v2/oracle.db");

// Superseded docs whose superseded_by target does not exist
const dangling = db.query(`
  SELECT id, superseded_by FROM oracle_documents
  WHERE superseded_at IS NOT NULL
    AND superseded_by IS NOT NULL
    AND superseded_by NOT IN (SELECT id FROM oracle_documents)
`).all();
console.log("dangling supersedes:", dangling.length);
dangling.slice(0,5).forEach(d => console.log("  " + d.id.slice(-60) + " → " + d.superseded_by.slice(-60)));

// supersede_log without matching doc
const orphanLog = db.query(`
  SELECT COUNT(*) as n FROM supersede_log sl
  WHERE sl.old_id NOT IN (SELECT id FROM oracle_documents)
`).get();
console.log("supersede_log with missing old_id:", orphanLog.n);
'
```

**Acceptance:**

| Count | Severity |
|---|---|
| 0 dangling, 0 orphan log entries | PASS |
| 1-5 dangling | WARN (P1) — supersede pointing nowhere |
| >5 dangling or many orphan log entries | FAIL (P0) — P-001 integrity at risk |

## Step 9 — Trace chains

```bash
bun --eval '
const db = new (require("bun:sqlite").Database)(require("os").homedir() + "/.arra-oracle-v2/oracle.db");
const total = db.query("SELECT COUNT(*) as n FROM trace_log").get().n;
const linked = db.query("SELECT COUNT(*) as n FROM trace_log WHERE parent_trace_id IS NOT NULL OR prev_trace_id IS NOT NULL OR next_trace_id IS NOT NULL").get().n;
const raw = db.query("SELECT COUNT(*) as n FROM trace_log WHERE status = \"raw\"").get().n;
const oldRaw = db.query("SELECT COUNT(*) as n FROM trace_log WHERE status = \"raw\" AND created_at < ?").get(Date.now() - 14*24*3600*1000).n;
const dangling = db.query(`
  SELECT trace_id, parent_trace_id FROM trace_log
  WHERE parent_trace_id IS NOT NULL AND parent_trace_id NOT IN (SELECT trace_id FROM trace_log)
`).all();
console.log("total:", total, "linked:", linked, "raw:", raw, "raw_older_14d:", oldRaw);
console.log("dangling parent links:", dangling.length);
'
```

**Acceptance:**

| Metric | PASS | WARN | FAIL |
|---|---|---|---|
| Dangling parent/prev/next links | 0 | 1-3 | >3 |
| `status='raw'` older than 14 days | <50% of raw | 50-80% | >80% (distillation debt) |

## Step 10 — Handoff inbox

```bash
# Age distribution of pending handoffs
find $VAULT -path '*/ψ/inbox/handoff/*.md' -exec stat -f "%m %N" {} \; \
  | sort -n | awk -v now=$(date +%s) '{
      age=(now-$1)/86400
      if (age > 14) print "STALE("int(age)"d):", $2
      else if (age > 3) print "AGING("int(age)"d):", $2
    }' | head -20
echo "---"
find $VAULT -path '*/ψ/inbox/handoff/*.md' | wc -l | tr -d ' '
echo "total pending handoffs"
```

**Acceptance:**

| Metric | PASS | WARN | FAIL |
|---|---|---|---|
| Handoffs stale >14d | 0 | 1-3 | >3 |
| Total pending | <20 | 20-50 | >50 (inbox drowning) |

If a stale handoff references a completed task, flag for cleanup (target role should `arra_learn` the outcome and archive).

## Step 11 — arra_learn vs indexer balance

```bash
bun --eval '
const db = new (require("bun:sqlite").Database)(require("os").homedir() + "/.arra-oracle-v2/oracle.db");
const r = db.query("SELECT COALESCE(created_by,\"(null)\") as cb, COUNT(*) as n FROM oracle_documents GROUP BY cb").all();
r.forEach(x => console.log(" ", x.cb+":", x.n));

// arra_learn docs whose source file no longer exists
const fs = require("fs"), path = require("path");
const vault = process.env.HOME + "/Code/github.com/kxlahsimx09/mb_agent_oracle_memory";
const learns = db.query("SELECT id, source_file FROM oracle_documents WHERE created_by = \"arra_learn\"").all();
const missing = learns.filter(l => !fs.existsSync(path.join(vault, l.source_file)));
console.log("arra_learn with missing source file:", missing.length);
missing.slice(0,5).forEach(m => console.log(" ", m.id.slice(-60)));
'
```

**Acceptance:**

| Metric | PASS | WARN | FAIL |
|---|---|---|---|
| arra_learn / indexer ratio | 5-20% | 20-40% | >40% or <2% |
| arra_learn with missing file | 0 | 1-2 | >2 (P-001 concern — investigate) |

A very low arra_learn ratio means agents aren't capturing durable facts — remind them to use `arra_learn` more. A very high ratio means the indexer isn't running / files not making it to disk.

## Step 12 — Duplicate-indexing quantified

**By design**, a file written via `arra_learn` gets both:
- 1 root row with short-ID (`learning_<date>_<slug>`, `created_by=arra_learn`)
- N chunk rows with path-ID (`learning_<path>/<slug>_0/_1/...`, `created_by=indexer`)

This is provenance, not a bug. But track the ratio — if it trends upward without reason, investigate.

```bash
bun --eval '
const db = new (require("bun:sqlite").Database)(require("os").homedir() + "/.arra-oracle-v2/oracle.db");
const dup = db.query(`
  SELECT COUNT(*) as n FROM (
    SELECT source_file FROM oracle_documents
    WHERE type="learning"
    GROUP BY source_file
    HAVING SUM(CASE WHEN id LIKE "learning_github.com/%" THEN 1 ELSE 0 END) > 0
       AND SUM(CASE WHEN id NOT LIKE "learning_github.com/%" AND id NOT LIKE "retro_%" AND id NOT LIKE "resonance_%" THEN 1 ELSE 0 END) > 0
  )
`).get();
const total = db.query("SELECT COUNT(DISTINCT source_file) as n FROM oracle_documents WHERE type=\"learning\"").get();
console.log("files with both root+chunks:", dup.n, "/", total.n, "(", (dup.n*100/total.n).toFixed(1)+"%)");
'
```

**Acceptance:**

| Metric | Interpretation |
|---|---|
| 0-30% | PASS — most arra_learn files are small enough to not need chunking |
| 30-60% | WARN — normal for active role, but search will show duplicates; recommend client-side dedup |
| >60% | WARN — consider arra_learn writing smaller, atomic learnings |

## Step 13 — Retro synthesis (cross-agent signals)

**Scope:** retros from past 14 days, all roles, **max 15 per role**.

```bash
# List retros from past 14 days
find $VAULT -path '*/ψ/memory/retrospectives/*.md' -newermt "$(date -v-14d +%Y-%m-%d)" \
  | head -50
```

For each retro, extract:

- Title
- Date
- Role (from tags or path)
- **Honest Feedback** section content
- **AI Diary** section — look specifically for lines mentioning Oracle tools: `arra_search`, `arra_learn`, `arra_trace*`, `arra_handoff`, "FTS", "vector", "indexer", "memory"

Categorize signals:

| Signal | Example phrasing | Action |
|---|---|---|
| **Memory friction** | "arra_search didn't find X", "had to search 3 times", "vector returned nothing" | Trace → file as brew-ops issue |
| **Tagging drift** | "forgot to tag", "didn't know which tag to use" | Charter section may need clarification |
| **Supersede avoidance** | "just overwrote", "deleted the old one" | P-001 violation — escalate |
| **Workflow confusion** | "didn't know whether to arra_learn or handoff" | Workflow doc may need update |
| **Tool failure** | "arra_trace threw error", "Oracle server was down" | Urgent — investigate |
| **Positive pattern** | "search found exactly what I needed from prev session" | Worth noting — healthy signal |

**Output:** a ≤200-word synthesis paragraph grouping signals by category, with retro IDs cited (e.g., `retro@20.35_flow-deposit-qr-request-ratification`).

## Step 14 — Narrative coherence sampling

Structural checks (§2–§8) verify that data is *consistent*. This step asks a different question:

> **"If a fresh agent read these memory entries sequentially, would they understand the story?"**

Coherence is **sampled, not exhaustive** — reading every learning is too expensive. Pick 3–5 threads, read them as a new agent would, score them.

### 14a. Pick threads

Two sources:

1. **Recency-based** (default): top 3 topics by retro+learning count in past 14 days.
2. **User-specified** (if audit was triggered by a topic, e.g. `--topic <keyword>`): search and cluster by filename.

Example clusters surfaced in the first real audit (2026-04-18):
- `deposit-qr-request` (cross-repo, 2 retros + 4 learnings)
- `scb-approver` (3 learnings, bank-bot, no retro bridge)
- `vault-case-rename` (major infra change — coverage check)

### 14b. Per-thread sequential read

```bash
# List files chronologically (combine learnings + retros + handoffs for the topic)
find $VAULT -path '*/ψ/memory/*' -name "*<keyword>*" | xargs ls -tr
```

Read each file's frontmatter + first ~200 words (not full content — keep cost bounded). Assess **6 dimensions**:

| Dimension | PASS signal | FAIL signal |
|---|---|---|
| **Title integrity** | Full descriptive sentence | Truncated mid-word (e.g. `"Verifying that arra_learn n"`) |
| **Chronological chain** | `related:` back-links + `superseded_by` forward-links intact | Orphan files; no cross-references |
| **Source citation** | commit hash + file:line + PR# | "this session" / "conversation" only |
| **Outcome stated** | Current state described; decision ratified | Plan-only / TODO / no conclusion |
| **Cross-repo breadcrumb** | Spans repos? each side has a pointer to the other | Isolated — other repo has no record |
| **Stand-alone readable** | Fresh agent understands w/o external context | Needs 3+ other files to decode |

### 14c. Thread score

| Score | Criteria |
|---|---|
| **Excellent** | 5–6 dimensions PASS |
| **Good** | 4 dimensions PASS |
| **Fragmented** | 2–3 dimensions PASS — partial story |
| **Incomplete** | 0–1 dimension PASS — major capture gap |

### 14d. Current-session capture check (P-001 safety net)

This catches the most dangerous gap: **an active session making durable changes without writing them down**.

```bash
SESSION_START="4 hours ago"   # or the ISO date when the audit-triggering session began

# Git activity in the session window
VAULT_COMMITS=$(git -C $VAULT log --since="$SESSION_START" --oneline | wc -l | tr -d ' ')
PROJ_COMMITS=$(git -C ~/Code/github.com/Soul-Brews-Studio/arra-oracle-v3 log --since="$SESSION_START" --oneline | wc -l | tr -d ' ')

# Memory activity in the same window
LEARNS=$(find $VAULT -path '*/ψ/memory/learnings/*' -newermt "$SESSION_START" | wc -l | tr -d ' ')
RETROS=$(find $VAULT -path '*/ψ/memory/retrospectives/*' -newermt "$SESSION_START" | wc -l | tr -d ' ')

echo "commits: vault=$VAULT_COMMITS proj=$PROJ_COMMITS | learnings=$LEARNS retros=$RETROS"
```

**Acceptance:**

| Gap | Severity |
|---|---|
| `commits == 0` | PASS — nothing to capture |
| `learnings + retros >= (commits / 3)` | PASS — reasonable capture ratio |
| `commits > 0`, `learnings + retros == 0` | **FAIL (P0)** — P-001 violation risk; capture NOW |
| `commits > 0`, non-trivial work, <2 learnings | WARN (P1) — propose handoff listing uncaptured topics |

### 14e. Output (feeds §15 report)

```markdown
## Narrative coherence (§16)

### Thread 1: <topic>
- Files: N learnings, M retros, K handoffs
- Chain integrity: <one-liner>
- Sample issue (if any): "<quote>"
- Score: <Excellent|Good|Fragmented|Incomplete>
- Fix: <suggested arra_learn or retro to file, or handoff target>

### Thread N: ...

### Current session capture
- Git commits (session window): N
- Learnings written: M | Retros written: K
- **Uncaptured changes:** <bullet list>
- Severity: <P0|P1|P2>
- Suggested handoff: <one-liner ready to paste into arra_handoff>
```

### 14f. Remediation

Do **NOT** auto-fix threads. Instead:

- For a `Fragmented`/`Incomplete` thread → file `arra_handoff` to the owning role (e.g., `technical-writer` for flow gaps) with: missing pieces, recommended structure, 2–3 line problem statement. Let the owning agent close the gap next session.
- For a **P0 session-capture gap** (16d) → brew-ops writes the missing learnings + retro **before ending the audit session**. This is the one case where this read-only workflow is allowed to write more than an audit summary, because the alternative is losing durable state to P-001 erosion.

---

## Step 15 — Report output

Produce a single markdown report with this structure:

```markdown
# Oracle Memory Audit — YYYY-MM-DD HH:MM GMT+7

**Vault:** commit `<short-sha>` on `<branch>`
**Oracle DB:** N docs, M FTS rows, vector=<status>
**Auditor:** brew-ops
**Last audit:** <date> (if findable via arra_search)

## Summary

- **P0 (urgent):** N issues — <one-liner>
- **P1 (important):** N issues — <one-liner>
- **P2 (cosmetic):** N issues — <one-liner>
- ✅ <N sections passed>

## Findings

### P0
1. **<title>** — <description, metric, evidence file/commit>
   - Fix recommendation: <reference existing learning or suggest new PR>
   - Reference: <prior-audit-learning-id if applicable>

### P1
(same format)

### P2
(same format)

## Retro synthesis (§13)

<200-word cross-agent signals summary>

## Recommendations (ordered)

1. <most-urgent action>
2. ...

## Metrics snapshot

| Check | Value | PASS/WARN/FAIL |
|---|---|---|
| fts_ratio | 1.00 | PASS |
| vector_http | 598 matches | PASS |
| ...
```

## Step 16 — Persist findings

**Required:**

```
arra_learn pattern="<concise audit summary, ≤400 words>" \
  concepts=["brew-ops", "memory", "audit", "<YYYY-MM-DD>"] \
  project="github.com/Soul-Brews-Studio/arra-oracle-v3"
```

Frontmatter tags must include:

```yaml
tags:
  - brew-ops
  - repo:cross
  - memory
  - audit
  - <findings-keywords e.g. fts-bloat, vector-drift>
```

**Optional (if P0 found):**

- `arra_handoff` to the role(s) whose area has the P0, e.g., if indexer bug → `arra_handoff` with `to: brew-ops` (self) + note to open PR.
- `arra_thread` to start a discussion if the issue is architectural.

**Do NOT:**
- Open PRs yourself during this workflow (that's a separate `gogogo` task the human approves).
- Modify vault files to "fix" issues inline.
- Run the indexer — even if it would fix something, a fresh indexer run may hide drift from the next audit.

## Escalation matrix

| Condition | Action |
|---|---|
| Missing root principle (P-001..P-004) | **STOP.** Tell human immediately. Don't continue audit. |
| Active path corruption (non-superseded) | P0 file in report + `arra_handoff` to self with proposed fix |
| Supersede chain broken | P0 + explain the P-001 risk |
| Vector search degraded + server fresh | P0 + cite learning `2026-04-14_arra-oracle-indexer-server-lancedb-drift` |
| >3 stale handoffs older than 14d | P1 + suggest archival pass to each owning role |
| Retro synthesis reveals repeated "tool failure" | P0 — Oracle API / MCP stability issue — trace immediately |
| Retro synthesis reveals P-001 violation (overwriting) | P0 + flag the offending role to human |

## Acceptance (whole workflow)

The audit is **complete** when:

- [ ] All 15 steps executed (or explicitly skipped with reason).
- [ ] Report written with P0/P1/P2 sections + retro synthesis + metrics table.
- [ ] At least 1 `arra_learn` filed with `#brew-ops #audit` tags.
- [ ] If any P0 found: `arra_handoff` filed.
- [ ] No vault writes beyond the learning + handoff.

## Known-good baseline (2026-04-18)

For calibration — these numbers came from the first real audit run:

| Metric | Value |
|---|---|
| Total learning docs | 444 |
| Total retros | 113 chunks / 16 files |
| Total principles | 41 |
| FTS rows | 598 (ratio 1.00) |
| FTS orphans | 0 |
| Vector HTTP matches (test queries) | 598 total |
| Retros missing diary/feedback | 0 / 16 |
| Cross-refs broken | 0 / 72 |
| Dangling supersedes | 0 |
| Path corruption (active) | 0 (1 superseded per P-001) |
| Stale handoffs >14d | 0 |
| arra_learn ratio | 45 / 598 ≈ 7.5% |
| Duplicate-indexing | 24 / 88 files ≈ 27% (by design) |

Future audits should trend within ±20% of these baselines; sudden shifts warrant investigation.

---

**Created:** 2026-04-18 (GMT+7)
**Owner:** brew-ops
**References:**
- `.agent/AGENTS.md` §7 (memory sync protocol), §7a (tagging convention)
- Oracle vault: `ψ/memory/resonance/2026-04-14_principle-*` (P-001..P-004)
- Oracle vault: `ψ/memory/learnings/2026-04-14_arra-oracle-indexer-server-lancedb-drift.md`
- Local branch (as of this writing): `local/all-prs` commit `3c8f55b` has the FTS5 dedupe fix
