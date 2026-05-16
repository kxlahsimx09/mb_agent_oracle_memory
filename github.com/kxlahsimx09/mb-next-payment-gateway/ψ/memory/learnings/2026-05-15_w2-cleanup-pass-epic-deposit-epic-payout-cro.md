---
title: W2 cleanup pass — epic-deposit + epic-payout + cross-repo (2026-05-15).
tags: [next-product-writer, workflow-2, cleanup, plain-english, P-001, production-audit-corrects-writer-framing, first-execution, orphan-thread-sweep, cluster-split-proposal]
created: 2026-05-15
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W2 cleanup pass — epic-deposit + epic-payout + cross-repo (2026-05-15).

W2 cleanup pass — epic-deposit + epic-payout + cross-repo (2026-05-15).

First-ever W2 cleanup-requirements pass on this repo, executing the skill spec authored 2026-05-14. Three categories fired from the Step 1 inventory: orphan-thread sweep (cross-repo.md:55), plain-English (epic-payout.md, epic-deposit.md), cluster-split proposal (epic-deposit.md). Step 3a archive was no-op (revision log already archived 2026-05-11). Steps 5-6 INDEX/glossary/cross-repo audit passed (no fixes needed). Steps 0/1 ran clean — Oracle healthy, 0 kramdown/MDX traps, all 9 stories carried Sources blocks, 1 anchored marker (cross-repo.md:55 → thread #45 which had been closed 2026-05-06 via §ADR-14 ratification).

## Inventory snapshot (pre-fix)

| File | Lines | Status |
|---|---:|---|
| INDEX.md | 24 | within budget |
| epic-deposit-revision-log.md | 33 | within budget |
| epic-deposit-revision-log-archive-2026-05.md | 47 | already archived |
| cross-repo.md | 64 | within budget (+1 orphan marker) |
| glossary.md | 81 | within budget |
| README.md | 88 | within budget |
| epic-payout.md | 99 | within budget |
| epic-deposit.md | 559 | over budget by 309 |

## Actions

- **PR #105** — orphan-thread sweep on cross-repo.md. Thread #45 closed 2026-05-06 via §ADR-14 ratification (decide-now path, substrate Option A Hybrid + 4 Phase-1 commands + `fleet_command_log` audit table). Marker replaced with `[RATIFIED:45 2026-05-06]` + §ADR-14 cite + Phase-1 command scope summary + Phase-2 deferral for force-logout. P-001 audit: out-of-scope framing preserved; only the cite + Phase-1/Phase-2 specifics added.
- **PR #106** — plain-English pass on epic-payout.md. 7 rewrites across user-journey + edge cases. 9 G/W/T AC verbatim. Mermaid sequence diagram verbatim. Story-shape table verbatim. 1 cleanup pointer line appended to Sources block.
- **PR #107** — plain-English pass on epic-deposit.md. ~10 rewrites across user-journey + edge cases in DEPOSIT-001/002/003/004/005/007/008/012. Mechanical P-001 verification: 63 G/W/T AC verbatim (`grep -c` identical on main + branch), Mermaid block diff empty, story-shape table diff empty, line count constant at 559. DEPOSIT-007 force-approve mechanics edge case (lines 380-408) deliberately left untouched — reads like design-pass content; a separate decision needed on whether it belongs in requirements or under `docs/design/deposit-lane/`.
- **arra_thread #102** — cluster-split proposal filed to human, per skill spec Step 3b "DOES NOT auto-execute". Proposed 3-cluster boundary: `auto` (001/002/003/005/012) + `slip` (004/007/008) + `admin` (initially stub). Thread enumerates 6 decisions needed before the split PR opens: cluster boundaries / DEPOSIT-005 routing / DEPOSIT-012 routing / nav strategy / revision-log placement / force-approve extraction scope.

## Patterns surfaced this pass

- **Production-audit-corrects-writer-framing — instance #2 of the same pattern accumulated during the §ADR-4b mega-amendment (2026-05-13 thread #100 closed-with-correction).** The Plain-English pass on epic-deposit's `pending_review` edge case (DEPOSIT-005) preserved the architect's deep-audit correction verbatim — "every `pending_review` row is a late-arriving statement linking to a terminated deposit, NOT a stuck-inbound pool" — and re-expressed it for a stakeholder reader. Pattern: when the writer's framing has already been corrected by an architect deep-audit, W2 cleanup must preserve the corrected framing in plain English, not regress to the easier-to-write but wrong original framing.
- **W2 cleanup respects the design-vs-requirements boundary deliberately.** DEPOSIT-007 force-approve mechanics (lines 380-408 in epic-deposit.md) read like design-pass content — alternatives-considered tables, 4-step mechanics walkthrough, audit-consequence section. W2 cleanup explicitly left it untouched; a separate decision is needed on whether it should be extracted into `docs/design/deposit-lane/slip-fraud-detection.md` (which already exists per the Sources line). Pattern: cleanup never decides architecture; when prose reads like design content, flag it via thread and leave for the writer's next pass.
- **Skill anti-pattern "don't ship Step 3c PR without before/after table" honored on all rewrites.** Both PR #106 and PR #107 carry the before/after table in the PR description. PR #107 used selected highlights + mechanical `diff` verification on AC/Mermaid/table because doing all ~10 rows in the table inline would exceed GitHub PR-body practical readability — the mechanical verification is the canonical audit.
- **Cluster-split proposal threading respects skill's "never auto-execute structural splits".** Thread #102 enumerates 6 named decisions before the split PR can open, including the routing questions that have judgement-call answers (DEPOSIT-005 routing has both auto-match and admin-resolution semantics; DEPOSIT-012 routes a recovery operation that 2 of 3 actor tiers can invoke without admin authority).

## P-001 verification approach

For PRs touching epic story prose, P-001 audit ran in three layers:

1. **Mechanical `diff`** on AC blocks, Mermaid, story-shape tables. Empty diff is the strongest evidence of word-level verbatim preservation.
2. **Before/after table** in PR description for every rewritten sentence. Reviewer reads both columns side-by-side and confirms semantic equivalence.
3. **Sources block delta** — every line removed needs a flag; every line added must be a cleanup pointer (no architectural source retired). PR #106 added one `new:cleanup` line; PR #107 added none (Sources block coverage was already complete pre-pass; demoted technical specifics traced to existing lines).

Sub-pattern: for very dense bodies (epic-deposit.md > 250 lines), mechanical `diff` is more economical than 30+ before/after rows in the PR description, BUT the reviewer must still get representative before/after rows for the densest rewrites — the table is a sampling tool, not exhaustive.

## What did NOT fire this pass

- Step 3a revision-log archival — `epic-deposit-revision-log.md` is at 33 lines and last archived 2026-05-11; no archival debt accumulated in 4 days.
- MDX safety — 0 kramdown `{#anchor}` traps; 0 bare `{a, b}` traps.
- Missing Sources / missing trust labels — all 9 stories carry both. Greenfield-doc discipline maintained.
- Glossary first-occurrence audit — sampled epic-deposit DEPOSIT-001..005 glossary references; all link to `glossary.md#anchor` correctly.
- Cross-repo gap audit — `cross-repo.md` was just authored 2026-05-14 (PR #103) and is the canonical statement; no new cross-repo references found in the cleanup pass that aren't already captured there.

## Pattern instance numbering

- Combined baseline + ratify landing — instance #7 (continuing from 2026-05-13 amendment ratifications)
- Production-audit-corrects-writer-framing — instance #2 (the W2 cleanup preserved the corrected framing rather than regressing to the easier-to-write original)
- Skill-first discipline (read SKILL.md + workflow-2-cleanup-requirements.md before drafting any rewrite) — instance #1 NEW for W2 (precedent: W1 author-requirement passes always opened by reading SKILL.md)

## Open items at session end

- 3 PRs awaiting review (#105 orphan / #106 payout plain-English / #107 deposit plain-English).
- 1 thread awaiting human (#102 cluster-split proposal — 6 decisions enumerated).
- Revision-log entries for the cleanup pass deferred until after PR merge (cleaner separation: content PR carries the pass; metadata PR appends the revision-log entry once main is updated).
- Retro pending at session close.

## File location

`mb_agent_oracle_memory/github.com/kxlahsimx09/mb-next-payment-gateway/.agent/skills/next-product-writer/references/workflow-2-cleanup-requirements.md` is the source of truth for the workflow definition. The first execution of that workflow lives in PRs #105/#106/#107 + thread #102 on `mb-next-payment-gateway`.

Tags: next-product-writer, repo:mb-next-payment-gateway, W2, cleanup, plain-english, first-execution-of-w2, production-audit-corrects-writer-framing-instance-2, orphan-thread-sweep, cluster-split-proposal, P-001-mechanical-diff-verification, 2026-05-15

---
*Added via Oracle Learn*
