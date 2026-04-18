---
title: Pattern — brew-ops workflow-5 adds §13b Knowledge gap analysis (demand side)
tags: [brew-ops, memory, audit, workflow-5, knowledge-gaps, search-log, demand-side, repo:arra-oracle-v3, pattern]
created: 2026-04-18
source: 2026-04-18 brew-ops session, triggered by user pointing at studio Activity page ⚠️ 7 Knowledge Gaps card
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Pattern — brew-ops workflow-5 adds §13b Knowledge gap analysis (demand side)

Pattern — brew-ops workflow-5 adds §13b Knowledge gap analysis (demand side)

Gap discovered: workflow-5 (Memory Audit) previously covered only supply-side checks — what's in the vault, how it's tagged, whether cross-refs resolve, whether retros carry required sections. It missed the **demand side** entirely: what agents tried to find but didn't.

The Oracle backend already logs every `arra_search` call in the `search_log` table with `results_count`. Rows where `results_count = 0` are knowledge gaps by definition. The `oracle-studio` Activity page surfaces this as the "⚠️ Knowledge Gaps" card (count of `searches.filter(s => s.results_count === 0)`). The data was there; workflow-5 just wasn't reading it.

Addition: new §13b Knowledge gap analysis that:
1. Queries `search_log` for 0-result queries in past 14 days, groups by normalized text.
2. Classifies each recurring query into one of five categories: `real-gap` (no content covers it), `recall-issue` (content exists under different terms — FTS tokenization problem), `vector-drift` (fails during known P0-1 window → not a real gap, escalate separately), `test-noise` (brew-ops' own audit probes), `typo/bad-craft`.
3. Severity ladder: 0 = PASS, 1–3 real-gaps = WARN P2, 4–10 = WARN P1, >10 or concentrated = FAIL P0.
4. Remediation discipline (read-only exceptions allowed for this step):
   - real-gap → `arra_handoff` to the role that would know
   - recall-issue → `arra_learn` adding synonym bridge so next search hits
   - vector-drift → escalate to §3, not a gap
   - test-noise / typo → exclude from actionable list

Rationale for adding this as a separate step rather than folding into §2 or §13:
- §2 is supply-only (disk vs DB row counts)
- §13 extracts signals from retros (what agents wrote)
- §13b extracts signals from searches (what agents failed to find) — a distinct axis
- Keeping them separate lets each have its own acceptance thresholds and remediation paths

Empirical calibration from the first run (2026-04-18): 7 unique 0-result queries in past 14 days. Classification: 3 test-noise (vector-drift debugging we did today), 1 test-write-after-vaultrepo-migration (our smoke test), 3 real-gaps (`thaibank`, `trust`, `mobiz payment gateway system overview features`). Severity: WARN (P2). The 3 real-gaps are legitimately actionable — "thaibank" needs a KTB/SCB/BBL index entry, "trust" probably meant the principles (FTS recall issue), and "mobiz system overview" wants a docs-style overview that doesn't fit the learning format well.

How the user noticed: they saw "⚠️ 7 Knowledge Gaps" on the studio Activity page and asked if workflow-5 audits this — it didn't. This is a classic case where the UI surfaced a signal that the periodic audit should have been watching but wasn't.

---
*Added via Oracle Learn*
