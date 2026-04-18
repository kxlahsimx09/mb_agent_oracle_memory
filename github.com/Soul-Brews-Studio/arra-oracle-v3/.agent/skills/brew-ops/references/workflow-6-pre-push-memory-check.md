---
description: Pre-push/pre-commit hygiene check for uncommitted memory files — frontmatter validity, tag compliance, retro structure, path safety. Blocks bad memory before it lands in the vault.
owner: brew-ops
autonomy: read-only (no file modifications; only reads staged/untracked files and reports)
cadence: every commit/push (via git hook), or ad-hoc
---

# Workflow 6 — Pre-push Memory Check

A small, fast workflow that runs **before** memory files enter the shared vault via commit or push. Catches the garbage before it propagates to peers via `soul-sync`.

> **"If it's not good enough to read, it's not good enough to share."**

## Scope

Targets **uncommitted** vault changes only:

- Untracked files (new) under `**/ψ/memory/{learnings,retrospectives}/*.md`
- Modified files under same paths
- Staged files (if running as pre-commit hook) under same paths

**Not in scope:**
- Already-committed files (that's workflow-5's job)
- Handoff files (`ψ/inbox/handoff/`) — intentionally looser; not indexed
- Code files, scripts, or anything outside `ψ/memory/`

## Checks

Eight checks per file, grouped by severity:

### FAIL (blocks push unless `--allow-warn` escape-hatch... wait, no — FAIL always blocks)

| # | Check | Why it blocks |
|---|---|---|
| 1 | Frontmatter parseable (YAML-ish delimited by `---`) | Indexer will skip or misparse; row never lands in DB correctly |
| 2 | Required fields present: `title`, `tags`, `project`, `created` | Agent search returns incomplete metadata; cross-refs break |
| 3 | `project:` free of `<`, `>`, spaces, quotes | Causes on-disk path corruption (see `gotcha-stray-in-project-frontmatter-corru.md`) |
| 4 | Retro files (`retrospectives/**/*.md`) contain both "AI Diary" and "Honest Feedback" sections (case-insensitive) | Charter §5 mandates; retros missing these are treated as void |

### WARN (informational; blocks only if `--strict`)

| # | Check | Why it's just a warning |
|---|---|---|
| 5 | `title:` not truncated mid-word (heuristic: doesn't end with whitespace after a word fragment, doesn't dangle a single letter like "arra_learn n") | Usually cosmetic but sometimes a real signal of paste truncation |
| 6 | 3-layer tag presence: `repo:<name>`, at least one system-domain tag (memory/indexer/fleet/...), at least one role tag (brew-ops/pg-writer/...) | Convention per charter §7a; missing means search-by-tag won't find it, but content still useful |
| 7 | `source:` citation contains at least one of: commit hash (`[0-9a-f]{7,40}`), `file.ext:NN` line ref, PR number (`#[0-9]+`), ISO date, or URL | Without grounding, learning is hearsay — but still sometimes valid for pure decisions |
| 8 | Retro `related:` and learning `related:` fields reference files that exist on disk (skip external URLs) | Broken links reduce navigability; not all refs need to exist (future work, deleted-by-supersede) |

## Behavior

**Default mode: block on FAIL, pass on WARN.**

- 0 issues → exit 0, output "All N files pass"
- WARNs only → exit 0 (informational report)
- Any FAIL → exit 1, print blocking report, **push is aborted** (if running as git hook)

**With `--strict`:**
- WARN is upgraded to FAIL behavior (blocks on WARN too)

**With `--allow-warn`:**
- Explicit acknowledgment that WARNs are ok (useful as escape hatch if `--strict` is set elsewhere as default — currently redundant, but preserved for forward-compat)

## Usage

**Manual (recommended first — see what you'd be pushing):**

```bash
# From within the vault repo OR any repo with ψ/ symlinked
bash .agent/skills/brew-ops/references/scripts/pre-push-memory-check.sh

# Strict mode — WARNs block too
bash .agent/skills/brew-ops/references/scripts/pre-push-memory-check.sh --strict
```

**As git pre-push hook (block auto-push):**

```bash
# Install (symlinks the hook into .git/hooks/pre-push)
bash .agent/skills/brew-ops/references/scripts/install-pre-push-hook.sh

# Uninstall
rm .git/hooks/pre-push
```

**As pre-commit hook (block at commit, earlier than push):**

```bash
# Edit the installer's TARGET variable or manually symlink
ln -s "$(pwd)/.agent/skills/brew-ops/references/scripts/pre-push-memory-check.sh" .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Sample output

```
=== Pre-push memory check — 2026-04-18 14:45 GMT+7 ===
Mode: default (FAIL blocks, WARN informational)
Scope: 5 uncommitted memory files in /.../mb_agent_oracle_memory

  ✅ ψ/memory/learnings/2026-04-18_pattern-brew-ops-workflow-5-memory-audit-estab.md
  ✅ ψ/memory/learnings/2026-04-18_decision-2026-04-18-gmt7-normalize-vault-dir.md
  ⚠️  ψ/memory/learnings/2026-04-18_gotcha-xyz.md
       WARN #6: missing system-domain tag (got: [brew-ops, repo:cross, current])
       WARN #7: source: citation has no commit hash, file ref, or PR#
  🔴 ψ/memory/retrospectives/2026-04/18/15.00_foo.md
       FAIL #4: retro missing 'Honest Feedback' section
  🔴 ψ/memory/learnings/2026-04-18_bad.md
       FAIL #3: project: contains '<' — '"github.com/foo/bar<"'

Summary: 2 PASS | 1 WARN | 2 FAIL
Exit: 1 (FAIL present — push blocked)
```

## Severity rationale

The check is **deliberately strict on FAIL** because once memory is committed and `soul-sync` runs, the bad file propagates to every peer node in the mesh. Fixing it after the fact requires a coordinated supersede on every peer — expensive and often incomplete. Blocking at the source is cheap.

WARNs are loose because:
- Some are heuristics that can false-positive (title truncation detection is imperfect)
- Some are conventions that have exceptions (pure decisions may lack file:line citations)
- The cost of a WARN false-positive blocking auto-commit is higher than the benefit — we want the check to be trusted, not worked around

## Integration with auto-commit

The vault auto-commit hook (observed producing commits like `2ea1b16 updated`) should call this script before pushing. If this script exits 1, auto-commit should:

1. Not push
2. Report the failures to the human (Slack/notification/log)
3. Leave files uncommitted — let the human or agent fix and retry

If the auto-commit hook ignores the check exit code, this workflow's value is diminished to manual-only.

## What this workflow is NOT

- Not a replacement for workflow-5 (the full audit). workflow-5 runs on already-committed state; this runs on uncommitted state.
- Not a linter for the learning content itself — we don't grade writing quality or insight depth.
- Not a security scanner — secrets detection belongs to a separate tool (trufflehog, gitleaks).
- Not run on peer-synced files after `soul-sync` (those are by definition already committed on the peer).

## Escalation

If the check repeatedly fails on peer-synced content, that's a signal the **upstream peer's writing workflow** is broken. File an `arra_handoff` to the owning role (e.g., pg-writer-oracle if the failing files came from that peer) with the specific FAIL reasons. Do not try to fix peer content — that's their domain.

---

**Created:** 2026-04-18 (GMT+7)
**Owner:** brew-ops
**Scripts:**
- `scripts/pre-push-memory-check.sh` — main checker (bash wrapper + python)
- `scripts/install-pre-push-hook.sh` — installs as git pre-push hook
