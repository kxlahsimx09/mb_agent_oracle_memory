---
title: Workflow-5 Step 5 tag-extractor regex fix — handle YAML-list form alongside inli
tags: [repo:cross, memory, audit, brew-ops, workflow-5, tag-convention, regex-fix, false-positive, P-002, yaml-frontmatter]
created: 2026-04-20
source: brew-ops session 2026-04-20 GMT+7 — workflow-5 first complete run since 2026-04-18; bug surfaced empirically + fixed in same session
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Workflow-5 Step 5 tag-extractor regex fix — handle YAML-list form alongside inli

Workflow-5 Step 5 tag-extractor regex fix — handle YAML-list form alongside inline.

The audit script in workflow-5-memory-audit.md Step 5 (3-layer tag compliance) used a single regex `^tags:\s*\[(.*?)\]` that matched only the inline frontmatter form `tags: [a, b, c]`. YAML frontmatter also accepts the list form `tags:\n  - a\n  - b`, used predominantly by `technical-writer` retros for readability with long tag lists. The list-form docs were silently counted as `no_tags` — false positives.

Empirical impact (2026-04-20 audit run on 269 non-resonance ψ/memory docs):
- 184 docs use inline form
- 83 docs use YAML-list form (these were counted as no-tags by the old regex)
- 2 docs are truly tag-less (overnight bot-writer retros: 2026-04-20/02.40_bot-track-b5ed22c.md, 2026-04-19/19.37_bot-track-0ea0e80.md — both also caught by Step 6 as missing AI Diary + Honest Feedback, indicating the bot-writer wakeup template skipped frontmatter authoring for these runs)

Old regex result: 85/269 = 31.6% no_tags → reported as FAIL (>5% threshold)
New regex result: 2/269 = 0.7% no_tags → PASS (<1% threshold)

Pre-fix audits cycled through "FAIL on tags, investigate, find false-positive, ignore" — wasted attention on every audit run. Fix lives in commit on mb_agent_oracle_memory main (workflow-5-memory-audit.md). The script now defines extract_tag_string() that tries inline first, falls back to list, returns None only when neither matches. Also adds principles_excluded counter (resonance/ files legitimately omit repo:/role: tags) and surfaces missing_repo / missing_role percentages in output.

Secondary improvement bundled in the same fix: REPO_RE now includes `mb_agent_oracle_memory` (the central memory repo itself, which has its own learnings + retros — was previously triggering missing_repo false positives for self-referential brew-ops audit notes).

Workflow-5 spec change rationale: per P-002 (patterns over intentions), the audit should reflect what agents are actually writing. 30%+ of writers used the YAML-list form because it's more readable for long tag lists — the spec should accommodate the reality, not declare the writers wrong. The inline note in Step 5 of the workflow file explains the dual-form handling so future readers understand the regex complexity.

Discovered during the 2026-04-20 11:50 GMT+7 brew-ops audit (workflow-5 first complete run since 2026-04-18 calibration). Audit result with the bug present: P0 1, P1 3, P2 3. After investigating and fixing the script: P0 0, P1 2 (no_tags moved out of P1 because the underlying issue was the audit script, not the vault). The 2 truly tag-less retros remain a smaller P2 issue — bot-writer wakeup template needs review.

---
*Added via Oracle Learn*
