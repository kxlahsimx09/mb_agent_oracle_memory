---
title: Oracle Memory Audit run — 2026-04-20 11:50 GMT+7 (workflow-5, brew-ops, second c
tags: [brew-ops, repo:cross, memory, audit, 2026-04-20, workflow-5, P-001, P-002, audit-self-regression, no-tags-false-positive, path-corruption-cleanup]
created: 2026-04-20
source: brew-ops session 2026-04-20 11:50 GMT+7 — workflow-5-memory-audit second complete run; baseline = 2026-04-18 16:19 GMT+7 audit
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Oracle Memory Audit run — 2026-04-20 11:50 GMT+7 (workflow-5, brew-ops, second c

Oracle Memory Audit run — 2026-04-20 11:50 GMT+7 (workflow-5, brew-ops, second complete run since 2026-04-18 calibration baseline).

Vault state at audit start: commit a6cd6ba on main, 4 commits ahead of origin (W9 + arra_search learnings from earlier this session). Oracle DB: 1155 docs, 1155 FTS rows (ratio 1.000), vector connected (1154 bge-m3 embeddings). All 4 root principles surfaced via search ✅ — ethical spine intact.

Findings before in-session fixes: P0 1, P1 3, P2 3. Findings after: P0 0, P1 2, P2 4 (audit-script bug moved to P2 + got fixed same session). Net improvement.

P0 fixed in-session (commit 1669ef8 lineage, sweep happened earlier): 9 surviving path-corrupt index rows from the 2026-04-19 W2/W8 typo-project bugs (cbank-bot, bank-bot<, kokarat/kokarat). Earlier same-session DELETE caught the `learning_github.com/...` prefix variants but missed 9 short-form chunk variants with `_0`-`_6` suffixes. Second sweep deleted both oracle_documents + oracle_fts rows. Anomaly project state now: all 4 surviving rows superseded, 0 active. Total docs 1155 → 1146.

P1 — investigated and resolved (this session): Step 5 audit script flagged 31.6% no_tags FAIL. Investigation revealed regex `^tags:\s*\[(.*?)\]` matched only inline form, missing YAML-list form used by ~31% of docs (mostly technical-writer retros). Real no_tags rate is 0.7% (PASS). Script fixed in commit 1669ef8 with extract_tag_string() helper that tries both forms. See learning learning_2026-04-20_workflow-5-step-5-tag-extractor-regex-fix-handle.

P1 — open: 1 phantom DB entry (bank-bot< sse-intake learning, indexed but file moved at recovery time); 3× recurring zero-result query "SCB approver matching strategy" past 14 days suggesting bot-side flow doc coverage gap.

P2 — open: 4/108 broken cross-refs (3.7%); 2 retros from overnight W2 wake template missing frontmatter + diary + feedback (2026-04-20/02.40 and 2026-04-19/19.37 bot-track-* — same files appeared in both Step 5 truly-no-tags and Step 6 missing-sections checks, indicating the bot-writer wake template skipped retro authoring); duplicate-indexing 57.6% (borderline WARN, normal for active vault).

Trends vs 2026-04-18 baseline: arra_learn ratio up 7.5% → 14.8% (healthy capture growth); FTS bloat ratio stable at 1.000 (excellent); duplicate-indexing up 27% → 57.6% (more chunked content, expected); session-capture ratio 6 learnings+retros for 17 commits = 35% (above 1/3 PASS threshold).

Honest meta-observation: this audit ran AT THE END OF a 6-hour brew-ops session that itself caused the P0 (incomplete supersede sweep earlier in same session). The audit catching its own session's regressions validates the workflow-5 design — read-only observation surfaced what the session's own actor missed. Counterweight: the audit script bug (no_tags 31.6% false positive) had been silently failing every prior audit run; first complete W5 run that investigated rather than just reported the FAIL caught it.

Open follow-ups for next session: (1) arra_thread to bot-writer for "SCB approver matching strategy" knowledge gap; (2) arra_thread to bot-writer for the 2 untemplated overnight retros + investigate W2 wake template; (3) investigate 4 broken `related:` cross-refs.

---
*Added via Oracle Learn*
