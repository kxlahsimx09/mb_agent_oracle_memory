---
description: Periodic health audit of Oracle memory system — verify P-001..P-004 compliance, catch bloat/orphans/drift, synthesize signals from peer retros
owner: brew-ops
autonomy: read-only
cadence: daily-or-weekly, on-request, or after major fleet/indexer changes
---

# Workflow 5 — Memory Audit

This is brew-ops' periodic health check for the Oracle memory system. It answers one question per run:

> **"Is every agent using Oracle memory the way upstream designed it to be used, and is the pipeline still healthy?"**

No writes to the vault except `arra_learn` of findings and (if urgent) an `arra_thread` to flag the issue for a specific role. Nothing is re-indexed, no files moved, no DB rows modified. The workflow **observes and reports** — fixes are separate, human-approved follow-ups.

## How this workflow gets triggered

Three trigger paths, all converge on the same workflow body. The trigger context is recorded in §15 report header (`trigger: <ad-hoc | handoff #<filename> | scheduled>`) and surfaces in the §17 Telegram message so the operator knows whether to expect a scoped or full-portfolio audit.

### A — Ad-hoc by human

Operator invokes brew-ops manually for an unscheduled check (e.g., after seeing weird search results in Studio, after a major fleet/indexer change, before/after a release):

```bash
maw wake brew-ops --fresh "รัน workflow-5 audit เต็มรูปแบบ. ส่ง Telegram report เมื่อจบ (Step 17)."
```

### B — Escalated handoff from another workflow

Any workflow that hits memory/search/trace/insert anomalies it cannot resolve in scope drops a handoff at:

```
$(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/ψ/inbox/handoff/<YYYY-MM-DD>_<HH-MM>_brew-ops_<topic>.md
```

Handoff frontmatter (mandatory):

```yaml
---
to: brew-ops
from: <calling-role>           # pg-writer / bot-writer / tester / etc.
severity: P0|P1|P2
source-workflow: <name>         # workflow-2-track-commit / workflow-9-track-flows / etc.
related-thread-ids: [<id>...]   # optional, if applicable
related-trace-ids: [<id>...]    # optional, if applicable
related-pr: <url>               # optional, if applicable
created: <YYYY-MM-DD>T<HH:MM>+07:00
---

## Symptom
<one paragraph: what the calling agent observed that doesn't match expectations>

## What was tried
- <bullet: tool / query / search the calling agent ran + result>
- ...

## Evidence
- <file paths, commit hashes, search log entries, doc IDs, etc.>

## Expected outcome
<what brew-ops should produce: investigation only? a fix-PR? a workflow-spec change? an arra_thread to a role?>

## Scope hint (optional)
<which §steps of workflow-5 are most relevant — e.g., "§3 vector + §4 path corruption", "§13c orphan markers only">
```

**Format scope clarification.** This structured frontmatter is **brew-ops-specific** — required only for `to: brew-ops` escalations so the fresh-wake claude can parse trigger context, severity, and scope hints reliably. Pre-existing handoffs in `ψ/inbox/handoff/closed/` use a different, free-form markdown convention for agent-to-agent project status updates (e.g., "PR #N opened, here's context") — that convention remains valid for non-brew-ops handoffs. Don't retrofit old ones; do enforce this frontmatter on every new brew-ops escalation.

**Non-blocking contract.** Filing this handoff does NOT block the calling workflow. The writer/tester/thread-resolve pass that files the handoff finishes its own Step N normally (retro, commit, PR) and does NOT wait on brew-ops to process. brew-ops picks up asynchronously on next fresh wake. No `[AWAITING_...]` anchor is used for handoffs — the handoff file itself is the durable record, and this directory is where brew-ops looks on every startup.

To trigger brew-ops to pick up the handoff in a fresh wake:

```bash
maw wake brew-ops --fresh "อ่าน handoff ใหม่ใน \$(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/ψ/inbox/handoff/ ที่ to:brew-ops แล้วยังไม่ถูก process. รัน workflow-5 audit ตามบริบทของ handoff: ถ้า scope hint ระบุ §steps แคบ ให้ scope ตามนั้น; ถ้าไม่ระบุ ให้รันเต็ม. ส่ง Telegram report (Step 17) ทุกครั้ง พร้อม cite handoff filename ใน trigger field."
```

The fresh-wake claude reads the handoff(s) → scopes the audit → reports back via Telegram (§17) AND files an `arra_learn` summary (§16). The handoff file is moved to `ψ/inbox/handoff/done/<YYYY-MM-DD>/` after processing (per inbox protocol).

### C — Scheduled (cron / launchd)

Future: a launchd timer runs the same `maw wake brew-ops --fresh "..."` command at daily cadence. Documented here for completeness; infrastructure not yet in place. When it lands, the §17 Telegram report becomes the human's primary signal of overnight memory health.

## How OTHER workflows escalate to brew-ops

Brief reference for cross-workflow authors. If your workflow (W2/W4/W8/W9/tester/etc.) encounters one of these patterns, file a handoff per §B above:

| Symptom in your workflow | Why escalate to brew-ops |
|---|---|
| `arra_search` returned 0 for content you know exists | possible FTS5 / vector / tokenizer drift |
| `arra_learn` succeeded but search can't find the new entry | possible indexer / vector connect race |
| `arra_trace` succeeded but `arra_trace_get` returns missing fields | possible trace tool bug (e.g., 2026-04-21 trace project-corrupt incident) |
| `arra_supersede` says success but old doc still appears un-flagged | possible supersede chain breakage |
| Closed thread leaves `[AWAITING_THREAD:N]` markers stranded across repos | cross-repo orphan — see §13c |
| `verify.sh` fails with new pattern not covered by existing fixes | possible new corruption class |
| Path-typo files (`bank-bot<`, `pure-bot`, etc.) keep recurring | input-validation or pattern that escaped the existing typo guard |

If you're unsure whether to escalate: file a P2 handoff with `expected outcome: investigation only`. brew-ops can downgrade to "no action needed" cheaply; a missed real signal is more expensive.

## Scope & rules

- **Read-only on vault files, DB, and all services.** Use `arra_search`, `sqlite3` / `bun:sqlite`, `curl` to the HTTP API, and `find` on disk.
- **Writes allowed (findings only):**
  - `arra_learn` with the audit summary, tagged `#brew-ops #memory #audit`.
  - `arra_thread` to flag a specific role when P0 issues need their attention (anchor with `[AWAITING_THREAD:<id>]` if anchored in a doc).
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

Python audit (handles ψ paths correctly + both frontmatter tag forms):

> **Note (2026-04-20 fix):** earlier versions of this script only matched the inline `tags: [a, b, c]` form. YAML-list form `tags:\n  - a\n  - b` was treated as "no tags" — both forms are valid YAML frontmatter, and ~31% of the vault uses the list form (mostly `technical-writer` retros). Pre-fix audits reported 31.6% no_tags (FAIL); post-fix they report ~0.7% (PASS). The two forms are equivalent; the script now tries inline first, falls back to list, and only counts a doc as no-tags when neither matches. See learning `2026-04-20_workflow-5-step5-tag-extractor-regex-fix` for the audit run that surfaced this.

```python
import os, re
vault = os.path.expanduser('~/Code/github.com/kxlahsimx09/mb_agent_oracle_memory')
REPO_RE = re.compile(r'repo:(arra-oracle-v\d|maw-js|oracle-studio|cross|bank-bot|mobiz-payment-gateway|mb_agent_oracle_memory)')
ROLES = {'brew-ops','pg-writer','pg-tester','bot-writer','technical-writer','tester'}

# Match either:
#   inline:    tags: [a, b, c]
#   YAML-list: tags:
#                - a
#                - b
INLINE_RE = re.compile(r'^tags:\s*\[(.*?)\]', re.MULTILINE)
LIST_RE   = re.compile(r'^tags:\s*\n((?:\s*-\s+.+\n?)+)', re.MULTILINE)

def extract_tag_string(content: str) -> str | None:
    m = INLINE_RE.search(content)
    if m: return m.group(1)
    m = LIST_RE.search(content)
    if m:
        # Flatten "  - tag1\n  - tag2" into "tag1, tag2" for downstream regex.
        items = [line.strip().lstrip('- ').strip().strip('"\'') for line in m.group(1).split('\n') if line.strip()]
        return ', '.join(items) if items else None
    return None

stats = {'total':0, 'missing_repo':0, 'missing_role':0, 'no_tags':0, 'principles_excluded':0}
for root, _, files in os.walk(vault):
    if '.git' in root: continue
    if '/ψ/memory/' not in root: continue   # handoffs excluded
    is_principle = '/resonance/' in root    # principles legitimately lack repo:/role: tags
    for f in files:
        if not f.endswith('.md'): continue
        if is_principle:
            stats['principles_excluded'] += 1
            continue
        stats['total'] += 1
        with open(os.path.join(root,f), errors='ignore') as fd: c = fd.read()
        tstr = extract_tag_string(c)
        if tstr is None:
            stats['no_tags'] += 1
            continue
        if not REPO_RE.search(tstr): stats['missing_repo'] += 1
        if not any(r in tstr for r in ROLES): stats['missing_role'] += 1
print(stats)
print(f'no_tags pct:      {stats["no_tags"]*100/max(stats["total"],1):.1f}%')
print(f'missing_repo pct: {stats["missing_repo"]*100/max(stats["total"],1):.1f}%')
print(f'missing_role pct: {stats["missing_role"]*100/max(stats["total"],1):.1f}%')
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

## Step 13b — Knowledge gap analysis (demand side)

§13 extracts signals from **what agents wrote** (retros). This step looks at the complement: **what agents tried to find and couldn't**. The Oracle logs every `arra_search` call in `search_log` with `results_count`. Rows where `results_count = 0` are *demand the vault didn't satisfy*.

The oracle-studio UI surfaces this on the Activity page as the "⚠️ Knowledge Gaps" card (`searches.filter(s => s.results_count === 0)`). Workflow-5 should analyze the same signal but with more depth — classify gaps, not just count them.

### 13b.1 Pull recent zero-result searches

```bash
bun --eval '
const db = new (require("bun:sqlite").Database)(require("os").homedir() + "/.arra-oracle-v2/oracle.db");
const since = Date.now() - 14 * 24 * 3600 * 1000;
const rows = db.query(`
  SELECT query, mode, project, COUNT(*) as n, MAX(created_at) as last_at
  FROM search_log
  WHERE results_count = 0 AND created_at > ?
  GROUP BY LOWER(TRIM(query))
  ORDER BY n DESC, last_at DESC
`).all(since);
console.log("Zero-result queries (past 14d, grouped):", rows.length);
rows.forEach(r => console.log("  " + r.n + "× [" + r.mode + "] " + r.query.slice(0, 70)
  + (r.project ? " (project=" + r.project.slice(-20) + ")" : "")));
'
```

### 13b.2 Classify each recurring query

For each query appearing ≥2 times (or ≥1 if the tester count is low), classify:

| Category | Signal | Check |
|---|---|---|
| **real-gap** | Query mentions a real concept; no doc or learning covers it | `find $VAULT -path '*/ψ/memory/*' -exec grep -l "<term>" {} \;` returns empty |
| **recall-issue** | Content exists but FTS missed it — query used synonyms / different phrasing | grep finds hits but `arra_search` returned 0 → FTS tokenization / stop-word issue |
| **vector-drift** | Multiple recent queries fail while vault grew — check §3 results; if vector was down during the window, these are false gaps | Cross-reference with §3 findings |
| **test-noise** | Debugging by brew-ops or the human (recognize your own patterns) | Compare to known audit probe queries; exclude from actionable list |
| **typo / bad-craft** | Obvious typo (`thaibank` → `thai-bank` / `ktb` / etc.) | Unrelated single-word query with no plausible content match |

### 13b.3 Acceptance

| Recurring real-gaps (past 14d) | Severity |
|---|---|
| 0 | PASS |
| 1-3 | WARN (P2) — surface in report; no blocking action |
| 4-10 | WARN (P1) — suggests vault has a coverage blind spot |
| >10 OR concentrated on one topic | FAIL (P0) — real knowledge gap or severe FTS/vector degradation |

Vector-drift gaps should not fire the severity (those are P0-1 territory, not P2).

### 13b.4 Remediation (read-only discipline)

- **real-gap**: open `arra_thread(title="knowledge gap: <query>", message="<count>× in past 14d; suggestion: write a learning covering <topic>")` addressed to the role that would know (e.g. query about SCB scraper → bot-writer). The role picks it up on their next session.
- **recall-issue**: file `arra_learn` with a note + the missing synonym list under a `concepts:` field so next agent's search hits it. This is one of the few writes workflow-5 is allowed (informational, not fixing code).
- **vector-drift**: escalate as P0-1 via §3 — do not categorize as a knowledge gap.
- **test-noise / typo**: ignore, note in report under "Excluded".

### 13b.5 Output (feeds §15 report)

```markdown
## Knowledge gaps (§13b)

Recurring zero-result queries (past 14 days):
- **N× real-gap**: "query text" — no content covers it; suggested handoff to <role>
- **M× recall-issue**: "query text" — content exists under different terms (list); filing arra_learn with synonym bridge
- **K× excluded**: test-noise / typos (list at end)

Severity: <PASS|WARN|FAIL>
```

---

## Step 13c — Cross-repo orphan-marker sweep

Pattern that triggered this step: 2026-04-21 thread #16 incident. Marker filed in `bank-bot/docs/flows/ktb-single-transfer-withdrawal.md` (4 locations); fix landed in same repo via commit `3359d08` (W9 PR #87); thread closed without a closing message; pg-writer's mobiz-side W9 sweep stripped its own sibling marker but couldn't reach bank-bot's KTB doc; bot-writer's W9 PR #87 only updated the §Implementation pointer (line 133), not the §Purpose/§Error paths/§Postconditions prose markers (lines 16, 92, 108, 109). Result: 4 markers stranded for 2 days until PR #89's Step 0 grep happened to catch them; PR #90 stripped.

The W9 spec got a Step 4b (section-level marker reconciliation, sibling-synced 2026-04-21) and the workflow-thread-resolve spec got a closing-message rule (same session). Both are agent-side disciplines that catch the next case at write-time. Step 13c is the **observer-side safety net**: a periodic global sweep that catches whatever slipped past the write-time disciplines.

### 13c.1 Pull recently-closed threads

```bash
bun --eval '
const db = new (require("bun:sqlite").Database)(require("os").homedir() + "/.arra-oracle-v2/oracle.db");
const since = Date.now() - 14 * 24 * 3600 * 1000;
// Threads closed in the past 14d. Note: forum_threads has no closed_at column;
// derive close-time from updated_at + status filter.
const rows = db.query(`
  SELECT id, title, status, project, updated_at,
         (SELECT COUNT(*) FROM forum_messages WHERE thread_id = ft.id) AS message_count,
         (SELECT MAX(role)  FROM forum_messages WHERE thread_id = ft.id ORDER BY created_at DESC LIMIT 1) AS last_role
  FROM forum_threads ft
  WHERE status = "closed"
    AND updated_at > ?
  ORDER BY updated_at DESC
`).all(since);
console.log("Recently-closed threads (past 14d):", rows.length);
for (const r of rows) console.log(`  #${r.id} ${r.status} msgs=${r.message_count} last=${r.last_role || "(none)"} closed≈${new Date(r.updated_at).toISOString().slice(0,10)} — ${r.title.slice(0,70)}`);
'
```

### 13c.2 For each closed thread, grep ALL flow docs across known repos

```bash
KNOWN_REPOS=(
  "$HOME/Code/github.com/kokarat/mobiz-payment-gateway"
  "$HOME/Code/github.com/kokarat/bank-bot"
)

for tid in <list of thread ids from 13c.1>; do
  for repo in "${KNOWN_REPOS[@]}"; do
    grep -rnE "\[(AWAITING_THREAD|RATIFICATION_PENDING|UNDOCUMENTED-STEP):${tid}\]" \
      "$repo/docs/" 2>/dev/null
  done
done
```

Add new repos to `KNOWN_REPOS` as the fleet grows. Future enhancement: derive from `oracle_documents.project DISTINCT` rather than a hardcoded list.

### 13c.3 Classify each surviving marker

For each `(thread_id, repo, file:line)` triplet:

| Pattern | Likely cause | Severity hint |
|---|---|---|
| Closed ≥ 7d, repo had W9/W2 pass since close, no `[DRIFT-N RESOLVED]` annotation nearby | Step 4b not running (or pre-Step-4b spec) | **P0** |
| Closed ≥ 7d, repo had no W9/W2 pass since close | Agent inactive on this territory | **P0** (agent gap) |
| Closed 3-7d, repo had no W9/W2 pass since close | Overdue but explainable | **P1** |
| Closed 3-7d, repo had W9/W2 pass since close, single missed marker | Step 4b missed it (the 2026-04-21 case shape) | **P1** |
| Closed < 3d, any state | Within natural cadence — give Step 4b / next pass a chance | **P2** (informational) |
| Closed without human message (`message_count == 1` or `last_role == 'claude'`) | Close-without-fix anti-pattern (workflow-thread-resolve.md) | bump severity 1 level |

The 7-day P0 threshold assumes daily audit cadence + agents running W9 at least every 2-3 days. If audit drops to weekly cadence, loosen to 14-day P0 to avoid false-positive noise from agents that just happened to skip a sweep cycle.

To check if owning agent ran W9/W2 since close:

```bash
# Timestamp of last W9 retro for owning agent's territory
LAST_W9=$(find ~/.arra-oracle-v2/ψ/memory/retrospectives -path "*flow-track*" \
  -newer <(date -j -f "%s" "$close_unix" "+%Y-%m-%d %H:%M:%S" --) | head -1)
# If empty → no W9 ran since close → P0/P1 per the matrix above
```

### 13c.4 Severity dispatch + remediation suggestion

For each P0/P1 finding, generate a **strip suggestion** (do NOT execute — read-only workflow):

```markdown
**Suggested fix (manual, by owning agent):**

Branch: `docs/strip-orphan-thread-<id>-<short-slug>` (in <owning-repo>)
Files: <list of file:line>
Action: replace `[AWAITING_THREAD:<id>]` with `[DRIFT-<id> RESOLVED via <fix-commit-short>]`
       (matching convention from W2/W9 prior strips, e.g., bank-bot PR #90)
Per P-001: retain surrounding prose; flip tense if it would be left as a stale
"currently lost" / "currently unreachable" claim.
```

If the closer was a different agent than the doc owner, the suggestion is routed via `arra_thread` to the owning role rather than executed by brew-ops.

### 13c.5 Output (feeds §15 report)

```markdown
## Cross-repo orphan markers (§13c)

Closed threads with surviving markers (past 14d):

P0 (>7d stale, agent inactive or sweep broken):
- thread #<id> — closed YYYY-MM-DD (<N> day(s) ago, <message_count> message(s), last role <role>)
  - <repo>/<file>:<line>[,<line>...]
  - Owning agent: <role>; last W9/W2: <date> (<N> day(s) before close / no run since close)
  - Suggested fix: <strip-PR template per §13c.4>

P1 (3-7d stale OR single missed sweep):
- (entries follow same shape)

P2 (<3d, informational — within natural cadence):
- (entries follow same shape, no remediation suggested)
```

### 13c.6 Acceptance

| Recurring P0 markers | Severity for whole audit |
|---|---|
| 0 P0 + 0 P1 | PASS |
| 0 P0 + 1-2 P1 | WARN |
| 0 P0 + 3+ P1 | WARN (escalate) |
| 1+ P0 | FAIL — orphan markers indicate the agent-side sweeps (W9 Step 4b, thread-resolve closing-message rule) are not running or not reaching this territory. Trace which discipline failed and surface in the audit report's Recommendations. |

### 13c.7 Limitations (be honest about what this doesn't catch)

- Markers in non-flow docs (`current-system.md`, runbooks) — V1 scope is `docs/flows/*.md` only. Extend to other paths if a real incident appears outside flow docs.
- File rename / move since marker was filed — grep hits old path miss the new location. Future: integrate `git log --follow` for renames. V1 punts.
- Multi-thread interactions (one marker depends on 2+ threads) — V1 treats each thread independently. Rare in practice.
- Markers in commit messages, code comments, or retros — out of scope. Doc-level markers only.
- Closed-and-genuinely-not-strippable cases (e.g., `wont-fix` decisions where the marker should remain as historical narrative). V1 surfaces as P2 informational; closer is expected to add a `// permanent-historical-marker:thread-<id>` annotation that future Step 13c runs grep-skip.

---

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
- Suggested thread: <one-liner ready to paste into `arra_thread(title=..., message=...)`>
```

### 14f. Remediation

Do **NOT** auto-fix threads. Instead:

- For a `Fragmented`/`Incomplete` thread → open `arra_thread(title="coverage gap: <topic>", message="missing pieces: ...; recommended structure: ...; problem statement: ...")` addressed to the owning role (e.g. `technical-writer` for flow gaps). Let the owning agent close the gap next session.
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

## Cross-repo orphan markers (§13c)

<P0/P1/P2 entries per §13c.5 template; or "No orphan markers found" if clean>

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

- `arra_thread` addressed to the role(s) whose area has the P0, e.g. if indexer bug → `arra_thread(title="P0 indexer: <symptom>", message="<reproduction + proposed fix or PR intent>")`. Audit reports link the thread id so the recipient can find context.
- `arra_thread` to start a discussion if the issue is architectural.

**Do NOT:**
- Open PRs yourself during this workflow (that's a separate `gogogo` task the human approves).
- Modify vault files to "fix" issues inline.
- Run the indexer — even if it would fix something, a fresh indexer run may hide drift from the next audit.

## Step 17 — Telegram report (mandatory)

Send a Thai-language summary to the brew-ops alert channel after every workflow-5 run. The audience is non-technical operators who want to know "ปกติไหม?" without opening Studio. The report is brief, easy-to-read, and surfaces P0/P1/P2 counts + top 3 findings.

**Tool**: `mcp__brew-ops-telegram__telegram_send` (registered via `claude mcp add brew-ops-telegram` at user/local scope; bot identity = `brew_ops_alert_bot`, separate from the writer-fleet `telegram` MCP). Token + default chat_id live in `~/.claude.json` env vars (`TELEGRAM_BOT_TOKEN`, `TELEGRAM_DEFAULT_CHAT_ID=2002026175`); spec stays token-free.

**Template (Thai, easy-to-read)**

Use `parse_mode: "HTML"` (the MCP supports `<b>`, `<i>`, `<code>`, `<a href="">link</a>`). One emoji per section header (🔔 / ✅ / ⚠️ / 🚨 / 📝). Hard cap ~700 chars.

For an audit with **0 P0/P1/P2** (clean):

```html
<b>🔔 Oracle Audit — {YYYY-MM-DD HH:MM} GMT+7</b>
trigger: {ad-hoc | handoff #&lt;filename&gt; | scheduled}

✅ ทุกอย่างปกติ — ไม่พบปัญหาที่ต้องแก้

<b>Metrics snapshot</b>
docs={N} · FTS ratio={ratio} · vector={connected|degraded} · superseded={N}
```

For an audit with findings:

```html
<b>🔔 Oracle Audit — {YYYY-MM-DD HH:MM} GMT+7</b>
trigger: {ad-hoc | handoff #&lt;filename&gt; | scheduled}

<b>สรุป</b>
✅ ผ่าน: {N} sections
⚠️ เตือน: {N} P1
🚨 ด่วน: {N} P0

<b>ที่พบ (top 3)</b>
1. {one-line, plain-language explanation of P0 or top P1}
2. {...}
3. {...}

<b>Metrics</b>
docs={N} · FTS ratio={ratio} · orphans={N} · superseded={N}

📝 รายละเอียดเต็ม: <code>{retro filename}</code>
```

Plain-language guidance for the "ที่พบ" lines: avoid Oracle-internal vocabulary (UUIDs, trace ids, raw SQL). Use phrases an operator understands:

- ❌ "9 path-corrupt rows in oracle_documents survived earlier supersede sweep with `learning_<short>_N` id pattern"
- ✅ "พบ 9 row หลงเหลือใน index ที่ pattern เก่า — แก้แล้วใน audit นี้"

If a finding is technical and unavoidable (e.g., "Oracle thread #16 closed without resolution message"), give a one-liner consequence the operator cares about: *"thread #16 ปิดโดยไม่มีคำตอบ → 4 markers ค้าง 2 วันใน bank-bot KTB doc"*.

**Tool call**

```
mcp__brew-ops-telegram__telegram_send(
  text: "<composed HTML from template above>",
  parse_mode: "HTML",
  disable_web_page_preview: true
)
```

`chat_id` is omitted — the MCP uses `TELEGRAM_DEFAULT_CHAT_ID=2002026175` from its env. If you need to override (e.g., for a P0 critical alert that should also go to a different channel), pass `chat_id` explicitly.

**Acceptance**

- `telegram_send` returned `{ ok: true, message_id: <N>, chat_id: <ID> }`.
- `message_id` captured in the §16 retro body so the message is traceable for edits/replies.
- For zero-findings runs (the green-path), still send the short clean note — the channel cadence is part of the operator's "is it running?" signal. No send = the operator can't tell if the audit ran or skipped.

**Fallback (Telegram unreachable)**

If the MCP returns `{ ok: false, error: ... }` or the tool isn't loaded (fresh wake before MCP is registered):

1. Do **not** block the workflow; the §16 `arra_learn` is the durable record.
2. File one `arra_learn` tagged `#telegram-failed + #workflow-bug + brew-ops` with the intended HTML body (full, unescaped) + the error string. Next session can re-send from there.
3. Note the failure in the §15 report under "Recommendations".

**Why a separate bot from the writer-fleet `telegram` MCP**

The writer-fleet bot (`mcp-telegram` registered at mobiz scope) sends W2/W8 narrative summaries. brew-ops audits are operationally distinct:

- Different cadence (writer fleet fires on commits; brew-ops fires daily/handoff)
- Different audience expectation (writer fleet = "what landed today"; brew-ops = "is the system healthy")
- Different escalation severity (writer fleet rarely P0; brew-ops can hit P0 on indexer drift, P-001 violations, etc.)
- Different bot identity in the same group chat helps the operator triage at a glance ("who's pinging me?")

Same chat (`2002026175`), different bot — both surface in the same operator inbox.

## Escalation matrix

| Condition | Action |
|---|---|
| Missing root principle (P-001..P-004) | **STOP.** Tell human immediately. Don't continue audit. |
| Active path corruption (non-superseded) | P0 file in report + `arra_thread(title="P0 path corruption: <path>", message="<proposed fix>")` (addressed to brew-ops / human) |
| Supersede chain broken | P0 + explain the P-001 risk |
| Vector search degraded + server fresh | P0 + cite learning `2026-04-14_arra-oracle-indexer-server-lancedb-drift` |
| >3 stale handoffs older than 14d | P1 + suggest archival pass to each owning role |
| Retro synthesis reveals repeated "tool failure" | P0 — Oracle API / MCP stability issue — trace immediately |
| Retro synthesis reveals P-001 violation (overwriting) | P0 + flag the offending role to human |

## Acceptance (whole workflow)

The audit is **complete** when:

- [ ] All 15 steps executed (or explicitly skipped with reason). Step 13c (cross-repo orphan-marker sweep) is mandatory whenever the audit runs at daily cadence; on weekly or on-request runs it may be skipped if and only if Step 0 surfaced 0 closed-this-week threads (no orphan-candidate cohort to scan).
- [ ] **Step 17 (Telegram report) sent** — `telegram_send` returned `{ ok: true, message_id }` and the message_id is captured in the §16 retro body. For zero-findings runs, the clean-note still sent. If the MCP failed: `#telegram-failed` learning filed with the intended HTML body + error string + a §15 Recommendations entry telling the operator to investigate the alert channel.
- [ ] **Trigger context recorded** — §15 report header has `trigger: <ad-hoc | handoff #<filename> | scheduled>`. For handoff-triggered runs, the handoff filename is cited and the file is moved to `ψ/inbox/handoff/done/<YYYY-MM-DD>/` after processing.
- [ ] Report written with P0/P1/P2 sections + retro synthesis + metrics table.
- [ ] At least 1 `arra_learn` filed with `#brew-ops #audit` tags.
- [ ] If any P0 found: `arra_thread` opened addressed to the owning role (brew-ops, technical-writer, etc.) with reproduction + proposed fix; thread id listed in the audit report.
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
