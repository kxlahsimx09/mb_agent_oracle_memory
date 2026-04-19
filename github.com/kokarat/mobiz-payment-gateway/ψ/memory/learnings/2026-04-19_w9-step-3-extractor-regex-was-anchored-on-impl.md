---
title: W9 Step 3 extractor regex was anchored on `// impl:` as a *prefix* of the pointe
tags: [["brew-ops", "workflow-edit", "workflow-9", "technical-writer", "regex-fix", "w9-extractor-regression", "silent-drift", "pattern", "repo:cross", "2026-04-19"]]
created: 2026-04-19
source: 2026-04-19 brew-ops audit session, vault commit pending, workflow-9-track-flows.md Step 3 rewrite
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 Step 3 extractor regex was anchored on `// impl:` as a *prefix* of the pointe

W9 Step 3 extractor regex was anchored on `// impl:` as a *prefix* of the pointer, but W8 authoring in practice places the pointer *before* `// impl:` (backtick-wrapped `path@hash`, then `·`, then optionally a second backtick-wrapped `// impl: description`). Empirical check across the 6-flow portfolio on 2026-04-19 confirmed the drift: the prior regex returned 0 hits; the new anchor-on-pointer regex returns 109 pointer tokens scoped to `## Implementation pointers` sections (79 distinct flow-step pointers when deduplicated at the step level).

The prior W9 passes (2026-04-17/23.19 and 2026-04-18/14.37) did not actually run the literal spec regex — both retros describe the file→flow intersection in prose ("one file — `routes/bot.go`") without quoting command output, and the intersection was correct in both cases. This is consistent with an agent reading the `## Implementation pointers` section by eye and classifying from there. The spec regex sat in the workflow doc for 2 days unverified because the agent executing the workflow was smart enough to work around it.

## What changed in the spec

`workflow-9-track-flows.md` Step 3 rewritten:

1. Extraction now anchors on the backtick-wrapped `` `<path>[:<line>]@<shorthash>` `` token, not on the `// impl:` annotation. The `// impl:` annotation is explicitly described as free-form prose that is not the extraction anchor (observed on either side of the pointer across authored docs; also absent on sub-point lines).
2. Extraction is section-scoped to `## Implementation pointers` via awk flag, stopping at the next `## ` heading. This excludes inline `@<hash>` prose citations in §Purpose / §Actors / §Preconditions / §Error paths that are anchored references but not W9 verification targets.
3. Added a mandatory regex self-test block: if the extractor returns 0 pointer tokens on a non-empty portfolio, the pass halts with a `#workflow-bug + #w9-extractor-regression` learning rather than emitting the usual `#no-drift-found` result. This means future authoring-format drift surfaces as a visible halt instead of a silent cron-friendly false pass.
4. Output format is now explicit: one line per pointer, pipe-delimited `flow_doc|path_with_optional_line|shorthash`, with portable BSD-awk + GNU-grep + sed pipeline (no gawk-only features).

## Pattern worth naming: silent spec-vs-reality drift protected by smart agents

A workflow spec can stay wrong for N passes as long as the agents running it are clever enough to "do what the spec meant, not what it said." The failure mode is latent: the day you automate the workflow with a literal cron runner, or hand it to a smaller agent, the silent drift becomes a silent false-negative. The regex self-test added in this fix is a generalizable pattern for this class of risk: any workflow step that pattern-matches against content that other roles author should verify pattern presence before trusting an empty match-set.

## Out of scope for this pass (tracked as P2, not fixed)

1. **Tag convention drift.** W8 Step 9 final `arra_learn` uses bare `"<slug>"`; W8 Step 5 drift/unimplemented learnings use `"flow:<slug>"`; W9 Step 5b/7 uses `"flow:<slug>"`. `arra_search query="deposit-qr-request"` and `arra_search query="flow:deposit-qr-request"` return different subsets of the same flow's lifecycle — requires two queries to capture the full arc. Fix is to standardize on `"flow:<slug>"` in W8 Step 9 too.
2. **Missing cron infrastructure.** W9 spec references "daily cron" but no `.github/workflows/`, `maw schedule`, or other scheduler triggers W9 currently. Both W9 retros were human-initiated. Without a real cron, Step 0's zombie-thread-age exposure calculation (24h per skipped cycle) is aspirational.
3. **W8 Step 5 example format mismatch.** The example pointer in W8 Step 5 (`routes/main.go:142@abc1234` // impl: POST /pay route) has `// impl:` as a bare inline comment, not backtick-wrapped. Real W8 authoring produces `` `routes/main.go:142@abc1234` · `// impl: POST /pay route` ``. The example could be updated to match real-doc style.

## How to apply (for next W9 pass)

Run the extractor block in Step 3 verbatim. Verify `pointer_count > 0` before concluding a clean pass. If a flow's pointer format legitimately evolves (e.g., W8 adopts a new anchor convention), update the regex in Step 3 **and** re-run the self-test — a 2-line spec drift protected by the self-test should produce a visible workflow-bug halt within the first W9 cron that runs after the authoring change.

Tags: brew-ops, repo:cross, memory, workflow-edit, workflow-9, technical-writer, regex-fix, w9-extractor-regression, silent-drift, pattern

---
*Added via Oracle Learn*
