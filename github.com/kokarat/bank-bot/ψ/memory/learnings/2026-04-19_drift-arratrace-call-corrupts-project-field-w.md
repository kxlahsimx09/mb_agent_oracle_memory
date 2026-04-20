---
title: drift — arra_trace call corrupts `project` field when `foundFiles` array is pass
tags: [technical-writer, repo:bank-bot, repo:cross, drift, workflow-bug, arra_trace, arra_learn, path-corruption, mcp-parameter-parsing, w8-self-test, flow:deposit-auto-match-from-statement]
created: 2026-04-19
source: arra_trace call during W8 bank-bot pass 2026-04-19; corrupt trace 1cfc65ab-7964-4872-9c46-d3edb0c903f4 superseded in chain by 4ade448c-93e8-4753-bf3a-59e4a843aad1
project: github.com/kokarat/bank-bot
---

# drift — arra_trace call corrupts `project` field when `foundFiles` array is pass

drift — arra_trace call corrupts `project` field when `foundFiles` array is passed as a newline-formatted JSON block inside a `<parameter>` tag that contains nested `<parameter>` tags for other params.

Repro 2026-04-19 (W8 bank-bot for flow:deposit-auto-match-from-statement):
- Intent: `arra_trace(project="github.com/kokarat/bank-bot", foundFiles=[...])`
- What shipped: `project` = literal `"github.com/kokarat/bank-bot</parameter>\n<parameter name=\"foundFiles\">[..."` — entire foundFiles XML block concatenated into project string.
- Side effect: trace `1cfc65ab-7964-4872-9c46-d3edb0c903f4` landed with empty `found_files: []` + corrupt project.
- Fix at the call site: pass foundFiles JSON as a SINGLE-LINE string inside the parameter tag, not multi-line. Refiled as trace `4ade448c-93e8-4753-bf3a-59e4a843aad1` with 10 dig points.

**Why:** This is a new failure mode of the same `<` path-corruption class documented in `learning_2026-04-19_recurring-pattern-stray-character-appears-in`. Previously seen in `arra_learn` `project` fields (literal `<` typo); this version is multi-line JSON breaking XML parameter delimiters. The Step 9d `verify.sh` gate catches the downstream corruption in learning source_file paths but not in trace project fields — trace_get returned the corrupt value directly.

**How to apply:**
1. When calling any arra_* MCP tool with a JSON array/object parameter, format as single-line JSON (no newlines inside the parameter tag).
2. Before Step 9c trace attachment check, call `arra_trace_get <trace_id>` and grep the returned `project` field for `<` or `parameter` to catch this class of corruption early.
3. Consider extending Step 9d `verify.sh` or a pre-commit script to also scan trace table rows for corrupt project values.

---
*Added via Oracle Learn*
