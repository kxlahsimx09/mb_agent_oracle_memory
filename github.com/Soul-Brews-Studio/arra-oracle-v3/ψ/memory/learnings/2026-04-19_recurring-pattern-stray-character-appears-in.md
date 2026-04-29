---
title: Recurring pattern: stray `<` character appears in `arra_learn` `project` field, 
tags: [brew-ops, memory, vault, drift, workflow-bug, path-corruption, recurring, project-field-typo, arra_learn, verify.sh, repo:cross, 2026-04-19]
created: 2026-04-19
source: 2026-04-18 audit §4 path corruption finding + 2026-04-19 bot-writer W8 retro §Honest Feedback
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Recurring pattern: stray `<` character appears in `arra_learn` `project` field, 

Recurring pattern: stray `<` character appears in `arra_learn` `project` field, producing corrupt `source_file` paths in the vault (`github.com/<owner>/<repo></ψ/memory/...` with the literal `<` in the directory name). Observed at least twice in 14 days across different roles on different sessions:

## Evidence

1. **2026-04-18 (mobiz audit §4 finding).** Vault DB contained a row with `source_file = "github.com/kokarat/bank-bot</ψ/memory/learnings/..."` — literal `<` character in the directory name between `bank-bot` and `/ψ`. Audit §4 (path corruption check) classified it as an active-superseded case per P-001 — the old row was superseded by a repath + re-index after the human caught it. Not retagged retroactively; left in history.

2. **2026-04-19 (bot-writer W8 first pass, retro 09.55).** While filing the primary flow learning for `scb-dual-control-withdrawal`, the writer's `arra_learn(project="...")` arg carried a stray `</this>`-like suffix that serialised into the YAML frontmatter as `project: github.com/kokarat/bank-bot<` (with the trailing `<` and no trace of `</this>`). The document file landed on disk at the corrupt-path form, indexed with the bad source_file. Writer caught it in the retro's §Honest Feedback by running `verify.sh` after commit — too late to prevent indexing; mitigation is `arra_supersede` of the corrupt row.

## Root-cause hypothesis (not yet confirmed)

`</this>`, `</that>`, `</pattern>`-style placeholder tokens are common in templates / examples / prompt content. When a writer (or another agent) copies a template containing an unresolved placeholder and passes it through to `arra_learn`, the `<` survives the MCP round-trip because nothing in the path validates that `project` matches the canonical `github.com/<owner>/<repo>` shape — it's a freeform string. `verify.sh`'s frontmatter check catches it *after* the write lands on disk; nothing catches it *before* the `arra_learn` call persists.

## What makes the pattern recurring, not one-off

- Both incidents used templates or example snippets as the source of the typo.
- Both incidents were discovered via `verify.sh` rather than at write time.
- Both fell into the same mitigation path (supersede the corrupt row per P-001, re-write with corrected project, keep history).
- At least two different role instances on different days → not a single-operator habit.
- Likely to recur because nothing on the write path has been changed between the two incidents.

## Mitigations layered by the W8 specs 2026-04-19

- **Bot-side W8 Step 9d** (added this session) runs `verify.sh` as a mandatory pre-Step-10 gate. Fails the pass if `✅ no double-wrap` or `✅ every indexed doc has a title:` is missing. Catches the typo before a PR commits the corrupt state.
- **Mobiz-side W8 Step 9b** (added this session) mirrors the gate for mobiz W8 passes.
- Both specs now cite this pattern learning by name in the Step 9b/9d body so future agents understand *why* the gate is non-optional.

## What would close the pattern upstream (not done, not in scope)

A server-side validator on the `arra_learn` MCP tool rejecting `project` fields that don't match `^github\.com/[a-z0-9-]+/[a-z0-9-]+$` would prevent the corrupt row from ever being written. That is an Oracle-core change, not a workflow-spec change — tracked separately as a follow-up. Until it lands, the per-workflow pre-commit gate is the only defence.

## How to recognise a recurrence

`arra_search query="cross-repo-sync <slug>" type=learning` or any similar query that returns a hit whose `source_file` contains `<` or `>` — or whose `project` field displays with a trailing `<` — is the signal. Two follow-ups: (a) `arra_supersede` the corrupt row with a clean version. (b) Add the incident to this learning's thread for pattern tracking.

Tags: brew-ops, memory, vault, drift, workflow-bug, path-corruption, recurring, project-field-typo, arra_learn, verify.sh, repo:cross

---
*Added via Oracle Learn*
