---
title: Revision-log archival pass 2 (2026-05-06) — extract 26 stable entries from `docs
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, revision-log, archival, pass-2, mechanical, p-001-preserve, monthly-archive-naming-convention, pass-cadence-1-per-week]
created: 2026-05-06
source: docs/adr.md@6fcf598 (post-archive) + docs/adr/revision-log-archive-2026-05.md@6fcf598 NEW; archive criteria + format inherited from docs/adr/revision-log-archive-2026-04.md (Pass 1, 2026-04-27)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Revision-log archival pass 2 (2026-05-06) — extract 26 stable entries from `docs

Revision-log archival pass 2 (2026-05-06) — extract 26 stable entries from `docs/adr.md` §Revision log to NEW `docs/adr/revision-log-archive-2026-05.md`.

Mechanical pass. `docs/adr.md` had grown to ~2,696 lines pre-pass — inline revision log dominated 60% of the file (well past the 800-line trigger documented in archive-2026-04.md header criteria). 26 entries spanning 9 days (2026-04-27 → 2026-05-03) were eligible per archive criteria: ratified `#decision` ADR sections + stable ≥3 days at archive time. Extracted verbatim to a new monthly archive paired with existing `revision-log-archive-2026-04.md` (Pass 1, 2026-04-27).

Scope of 26 entries:
- 2026-05-03 (2): §ADR-13 pass 1.6+2 ratify; §ADR-13 pass 1.5
- 2026-05-02 (7): §ADR-13 baseline; sibling cross-cut maintenance; §ADR-12 ratify; §ADR-12 pass 1.6 + 1.5; §ADR-12 baseline; §ADR-11 ratify
- 2026-05-01 (2): §ADR-11 baseline; §ADR-10 ratify
- 2026-04-30 (3): §ADR-10 baseline; §ADR-9 ratify+revise; §ADR-9 baseline
- 2026-04-29 (4): §ADR-4c body extraction (pass 3); §ADR-4c ratify (pass 2); §ADR-4c pass 1.5; §ADR-4c baseline
- 2026-04-27 (8): §ADR-4d post-ratification amendment; §ADR-4d added+ratified; §ADR-6 design-doc extraction; §ADR-4b ratify; Revision-log archival pass 1; §ADR-4b added; Tier-cap resolution; Tier-cap surfaced

File changes:
- `docs/adr.md` — 2,696 → ~1,500 lines (-44%; restored to navigable size). Removed lines 1490-2691 inline; replaced with consolidated "Earlier entries" pointer block referencing both archives (Pass 1 + Pass 2) with per-pass entry counts + scope summaries.
- `docs/adr/revision-log-archive-2026-05.md` — NEW (~1,251 lines). Header (archive criteria + pass-2 scope + cross-link to archive-2026-04 + index files pointer) + index table (26 rows: date / entry title / ratification status) + verbatim entries newest-first.

Naming convention clarified inline: `revision-log-archive-YYYY-MM.md` = month of *archival action*, not month of entry dates. Both archives now follow this convention.

Pass cadence observation: Pass 1 archived 12 entries 9 days after seed (2026-04-22 → 2026-04-27); Pass 2 archives 26 entries 9 days after Pass 1 (2026-04-27 → 2026-05-06). Roughly 1-pass-per-week cadence emerging — sustainable for ~weekly architectural-decision tempo.

Process notes:
- No content edits — entries moved verbatim. P-001 preserved (all entries discoverable from doc tree, not just git internals).
- Bundled with §ADR-4b D2 amendment PR #17. Reviewer can verify via line-count math (1,202 lines extracted from inline = 1,202 lines verbatim in archive + ~49 header overhead). Future pure archival passes may go in standalone PR if not adjacent to W1 work.
- Cut-off threshold today (2026-05-06): entries ≥ 3 days old = up to 2026-05-03 inclusive. Today's entries (2026-05-06 D2 amendment baseline + ratify) and yesterday's (2026-05-05 §ADR-4b/4d amendments) stay inline as active narratives.

Threads opened: none. Threads closed: none. Commit: `6fcf598`. PR: #17 (5 commits total). Next pass candidate: §ADR-14 fleet-control / §ADR-15 monitoring (both user-blocked on substrate choice) OR W2 sync-clean docs/architecture.md refresh (snapshot regenerate from updated adr.md).

Administrative work — no chain candidate. Distinct from W1 amendment lifecycle.

---
*Added via Oracle Learn*
