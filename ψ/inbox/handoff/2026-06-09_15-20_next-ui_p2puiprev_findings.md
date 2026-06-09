# Handoff — next-ui · campaign p2puiprev — WUI-122 P2P match-likelihood PREVIEW

**Status:** DONE (pending owner merge). PR **#6** on `mb-next-admin-portal`, base `main`, head `campaign/p2puiprev` — **MERGEABLE, NOT merged** (owner merges).
**Trust:** S2 (§ADR-17 ratified). Date 2026-06-09.

## What was added

New UI story **WUI-122** — the last P2P piece: the client-facing "check match likelihood BEFORE submitting" affordance on the P2P deposit/withdrawal surface.
Flow: enter amount → tap "Check match likelihood" → **read-only** `GET /p2p/match-preview?side=&amount=` → coarse `{high|medium|low}` band + **aggregate-only** pool facts → decide whether to submit the real request (WUI-116/WUI-119), adjust, or wait.
`side` = own side: deposit preview looks up opposing withdrawal demand; withdrawal preview looks up opposing deposit supply.

## Invariants kept visible in the UX (the point of the story)

- Aggregate-only — NEVER counterparty identity / `client_id` / destination (CK2).
- No fabricated probability — coarse band only, no %/odds/ETA (CK3).
- Advisory, not a guarantee — creates/locks/freezes nothing, does not gate submit; High is not a reservation (CK4).
- Snapshot — timestamped + Re-check, empty pool → designed Low state not error (CK5).
- DP9 grid-50 + band reuse — never previews an unsubmittable amount.

## Files

- `docs/requirements/epic-p2p-ui.md` — WUI-122 story (As-a/I-want/So-that + AC + edge cases + Sources) + trust line + at-a-glance table row + footer Amended provenance.
- `docs/requirements/INDEX.md` — WUI-122 row + epic blurb.
- `docs/design/p2p-matching/ui/{client-depositor,client-withdrawer}.md` — Screen 1b match-likelihood preview each side.
- `docs/design/p2p-matching/ui/README.md` — coverage row + principle 7 (advice-not-a-promise).

## Source / pairing

§ADR-17 §Amendment 2026-06-09 (2) CK1–CK5 (ratified) + gateway backend pairing **P2P-011** (campaign p2pprop, authored in parallel, referenced by repo-qualified id).

## Caveat for reviewers

CK1–CK5 exact decision-text was not in my context — mapped to the brief's stated constraints (CK1 read-only endpoint / CK2 aggregate-only / CK3 coarse band-no-probability / CK4 advisory-no-reservation / CK5 side+amount lookup-snapshot). Reconcile per-id citations if the ratified amendment numbers them differently; the architectural claims are safe regardless.

## Out of scope (bounced)

Backend gateway P2P-011 + preview backend design (next-writer p2pprop); the ADR (merged); ratifying; merging PR #6 (owner).
