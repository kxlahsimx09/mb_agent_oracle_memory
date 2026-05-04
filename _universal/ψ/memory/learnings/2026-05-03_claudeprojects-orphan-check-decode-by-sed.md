---
title: ## ~/.claude/projects orphan-check: decode-by-sed is unsafe; use cwd from JSONL
tags: []
created: 2026-05-03
source: Oracle Learn
---

# ## ~/.claude/projects orphan-check: decode-by-sed is unsafe; use cwd from JSONL

## ~/.claude/projects orphan-check: decode-by-sed is unsafe; use cwd from JSONL

**Context:** Fleet cleanup audits frequently want to identify orphaned `~/.claude/projects/<encoded>/` JSONL dirs (project dirs whose cwd no longer exists on disk) so they can be evicted as operational state.

**Common-but-wrong pattern (seen in brew-ops fleet audit msg 131 of thread #64, 2026-05-03):**
```sh
for d in ~/.claude/projects/*; do
  encoded=$(basename "$d")
  decoded=$(echo "$encoded" | sed 's|^-||; s|-|/|g')
  test -d "/$decoded" && echo ALIVE || echo ORPHAN
done
```

**Why it's broken:** Claude Code's project-dir encoding is **lossy**. Both `/` and `.` (and any literal `-` already in path components) collapse to a single `-` in the encoded form. The sed only inverts `/` → so `/.claude/worktrees/X` paths get decoded as `claude/worktrees/X` (missing the dot), and the `test -d` reports them as ORPHAN even though the live dir exists. Concretely: `vigilant-almeida-1f523b` at `…/arra-oracle-v3/.claude/worktrees/vigilant-almeida-1f523b` was misclassified as orphan despite hosting 9 unpushed commits + 2 dirty files.

**Robust pattern — read cwd from any JSONL record in the project dir:**
```sh
for d in ~/.claude/projects/*/; do
  cwd=$(grep -hoE '"cwd":"[^"]*"' "$d"/*.jsonl 2>/dev/null | head -1 | sed 's/^"cwd":"//; s/"$//')
  [ -z "$cwd" ] && { echo "UNCLASSIFIED: $d"; continue; }
  [ -d "$cwd" ] && echo "ALIVE: $d" || echo "ORPHAN: $d"
done
```

The `cwd` field is recorded by Claude Code on tool-call records (not always on the very first record — use any record in the file). Empty/header-only JSONLs land in UNCLASSIFIED — usually safe to manual-review.

**Calibration on real fleet (2026-05-03 18:35 GMT+7, 144 project dirs):**
- sed-decode loop: 37 `--claude-worktrees-*` flagged orphan, but ALL 37 marked orphan including the live `vigilant-almeida-1f523b`.
- cwd-from-JSONL loop: alive=25, orphan=118, unclassified=1 (an empty `…naughty-yalow` JSONL dir).

**When to use:** Any fleet-cleanup workflow that wants to delete `~/.claude/projects/<encoded>/` entries. Especially before any `rm -ri` over the result.</pattern>
<concepts>["claude-code", "fleet-cleanup", "operational-state", "orphan-detection", "encoding"]</concepts>
<source>thread-64 fleet audit, orchestrator follow-up (wt-13-inbox-1777807711)</source>
<project>github.com/Soul-Brews-Studio/arra-oracle-v3</project>
</invoke>

---
*Added via Oracle Learn*
