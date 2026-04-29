---
title: W1 refine pass 3 — §ADR-4c body extraction to `docs/design/deposit-auto-expire/`
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-4c, extraction, pass-3, design-doc, deposit-auto-expire, bidirectional-extraction, fourth-instance, body-shrink-74-percent, lifecycle-archaeology]
created: 2026-04-29
source: docs/adr.md@27e91fd + docs/design/deposit-auto-expire/ (6 files)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine pass 3 — §ADR-4c body extraction to `docs/design/deposit-auto-expire/`

W1 refine pass 3 — §ADR-4c body extraction to `docs/design/deposit-auto-expire/`. ADR body 190 → 49 lines (-74%, best shrink ratio in repo). 4th bidirectional ADR-vs-design extraction in repo.

## Extraction shape

Created subsystem directory with 6 files (~900 lines total):

| File | Content | Source decision(s) |
|---|---|---|
| `README.md` | Index + scope summary + 3-pass lifecycle archaeology + cross-refs | overview + navigation |
| `view-contract.md` | View definition + partial index + read/write contract + effects table + why-not-X rationale + cross-cut refs | Decision #10 (load-bearing) |
| `expire-rpc.md` | RPC body + race-guard semantics + asymmetry vs `finalize_deposit` + outbox row + dispatcher boundary + callback timing contract + regression-candidate closure analysis + preliminary outbox schema | Decisions #3 + #4 |
| `sweep-and-lock.md` | pg_cron sweep query + 3-sweep comparison table + lock-primitive rationale + migration-map note | Decisions #2 + #8 |
| `trade-offs.md` | 5-option matrix (A-E) + per-option detail + key insight + revisit triggers + callback emission alternatives | §Trade-offs |
| `cross-cut-amendments.md` | §ADR-4b D5 + §ADR-4d D3 amendment text + within-scope classification + race-guard symmetry + generalization | Decision #10 cross-cuts |

## ADR body changes

§ADR-4c body in `docs/adr.md`:
- Title preserved
- Header paragraph compressed; ADR-vs-design split documented inline
- Context kept compact
- Decisions 1-10 reduced to 1-2 lines each with cross-ref to design files
- Scope boundary kept full (load-bearing for ADR-level navigation)
- Consequences kept compact summary
- Trade-offs kept summary + pointer
- Prior art kept full (load-bearing citations)
- Resolved questions kept compact (load-bearing ratification record with user quotes)
- Deferred questions kept compact
- Implementation note updated to reflect extraction

## Bidirectional extraction shape — 4th instance in repo

| ADR | Trigger | Body before → after | Reduction | Files |
|---|---|---|---|---|
| §ADR-4a (2026-04-23) | 369 lines | 369 → 51 | -86% | `withdrawal-lane/` (5 files) |
| §ADR-8 (2026-04-24) | 118 + user prompt | 118 → 66 | -44% | `bot-gateway-dispatch/` (4 files) |
| §ADR-6 (2026-04-27) | 136 + user audit | 136 → 73 | -46% | `bot-infra/` (4 files) |
| §ADR-4c (2026-04-29 today) | 190 (Decision #10 + 5-option matrix) | 190 → 49 | **-74%** | `deposit-auto-expire/` (6 files) |

Convention is now battle-tested across 4 instances. Pattern shape predictable:
- Trigger: body grows past ~150 lines
- Subsystem directory under `docs/design/`
- 4-7 themed files per subsystem
- ADR body shrinks 44-86% (depending on extraction-density of original content)
- README at root of subsystem dir provides index + navigation + cross-refs
- ADR body retains decision shape + scope boundary + ratification record + cross-refs to design files
- Resolved questions + user quotes preserved verbatim in ADR body (load-bearing ratification preservation)

## Key discipline

**No re-evaluation of decisions during extraction.** Pass-3 is purely structural restructure. Decision boundaries unchanged; ratification context preserved verbatim; user quotes preserved. Extraction is restructure, not redesign.

This is the right discipline because:
1. Structural changes to ratified ADRs in extraction passes risk silent re-evaluation
2. Future readers might assume extraction-time content reflects ratification-time decisions
3. Keeping extraction "boring" preserves trust in the supersede chain integrity

If extraction surfaces an ambiguity or design gap → that becomes a NEW pass (4th, 5th) with explicit revisit/amendment shape, not silent change in extraction commit.

## Lifecycle archaeology preserved

§ADR-4c full lifecycle now navigable from any entry point:
- ADR body §ADR-4c — decision shape + cross-refs
- `docs/design/deposit-auto-expire/README.md` — index + 3-pass lifecycle table + retro pointers
- 3 retros (pass-1 baseline 10:45, pass-1.5 revise 12:10, pass-2 ratification 12:54, pass-3 extraction TBD)
- `arra_supersede` chain (pass-1 → pass-1.5 → pass-2 → pass-3 once filed)
- `arra_trace_link` chain (98710bfc → f9568328 → 8c04c8e3 → new pass-3 trace)
- thread #55 messages (closed) — full ratification arc

## Body shrink ratio analysis

§ADR-4c at -74% is the best ratio in repo. Why:
- Decision #10 (view contract) had high content density — schema + index + contract + effects table + why-not-X rationale + index rationale + cross-cut amendments. All extracted cleanly to view-contract.md
- 5-option Trade-off matrix (A-E) is high-density tabular content. Extracted to trade-offs.md
- These two pieces alone accounted for ~80 lines of the 190-line body

§ADR-4a at -86% remains the highest because schema + RPC body + sweep + realtime filter + open-questions all extracted. §ADR-4c is structurally similar but had less RPC-implementation density.

## Threads + commits

- Thread #55 — closed in pass-2; not touched in pass-3.
- Commit: `27e91fd` (pass-3 extraction body) + `<this commit>` (revision-log backfill) on branch `architect/w1-refine-adr-4c-deposit-auto-expire-2026-04-29` / PR [#5](https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/5).
- Supersedes: pass-2 ratification learning `learning_2026-04-29_w1-refine-pass-2-adr-4c-ratification-thread-5` (this learning is the post-extraction state).
- Trace chain: this pass should chain to pass-2 trace `8c04c8e3-700a-48a7-82db-4b46082dd0f8`.

## Next-pass candidates

- **Wallet-table cross-cutting ADR** — used by §ADR-4a + §ADR-4b atomic boundaries; no ADR currently. 90-120 min. Strongest standalone next-design candidate.
- **Callback dispatcher ADR** — newly load-bearing after §ADR-4c Decision #4 outbox-row contract. Promoted priority. 90-120 min.
- **§ADR-4b body extraction** — likely candidate if §ADR-4b body grows past ~150 lines on subsequent passes (currently ~80 lines, well under threshold).
- **§ADR-4d body extraction** — currently ~100 lines; close to threshold but not over. May extract opportunistically if next §ADR-4d amendment pushes over.

## Process — pass-3 extraction discipline observations

1. **Pure structural restructure** — no decision text re-evaluation. Discipline preserved.
2. **README first, themed files second** — README provides navigation skeleton; themed files fill in detail. This order helps catch over-spreading or under-spreading content.
3. **Cross-ref every decision back to its design file** — ADR body reader knows where to go for full detail.
4. **Lifecycle archaeology in README** — discoverable record of pass arcs.
5. **Substrate convergence count incremented** — README notes 5 instances now (added §ADR-4c admin-maintenance-cancel reuse as 5th port).
6. **Migration-map notes accumulated** — sweep-and-lock.md notes Redis lock removal needs migration-map entry. Build-up for `docs/migration-map.md` future creation.

---
*Added via Oracle Learn*
