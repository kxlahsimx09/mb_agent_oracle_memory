# next-ui — campaign p2pui — handoff

**Agent:** next-ui (owner, mb-next-admin-portal UI docs) · **Date:** 2026-06-09 (GMT+7)
**Branch:** `campaign/p2pui` (base `origin/main`, worktree `mb-next-admin-portal.wt-c-p2pui`)
**PR:** https://github.com/kxlahsimx09/mb-next-admin-portal/pull/5 — OPEN, MERGEABLE, **NOT merged** (owner merges)

## Done

Ported the P2P matching **UI requirement + UI design** HOME to `mb-next-admin-portal` from the gateway repo (where they had been mistakenly authored). Renumbered `P2P-UI-001..007` → **`WUI-115..121`** in `epic-wallet-ui.md` house style, all **S2** (ratified §ADR-17, owner GO 2026-06-09).

- `docs/requirements/epic-p2p-ui.md` (new) — 7 stories WUI-115..121:
  115 client p2p-wallet view · 116 opt-in grid-50 deposit · 117 transfer instruction (real account, exact amount, no QR) + slip · 118 deposit lifecycle + Thunder verdict · 119 withdrawal request + freeze + large→payout · 120 progressive-fill + SLA + expire/unfreeze · 121 operator matching dashboard. Cross-repo substrate pointer → `mb-next-payment-gateway` `epic-p2p-matching.md` (`P2P-001..010`).
- `docs/requirements/INDEX.md` — new "Epic: P2P Matching UI" section.
- `docs/design/p2p-matching/ui/` (new) — ported README + admin-dashboard + client-depositor + client-withdrawer (4-surface split preserved); README cross-repo note maps backend `../` links to the gateway repo.
- `docs/design/INDEX.md` (new) — establishes the portal design-doc index.

## Verification

- WUI-115..121 all present (anchors + INDEX links); **no live P2P-UI-xxx ids remain** (only "was P2P-UI-00x" provenance, per house style).
- File path `docs/requirements/epic-p2p-ui.md` + ids `WUI-115..121` kept EXACTLY so the parallel gateway-side cross-repo pointer (next-writer) matches.

## Cross-team dependency

next-writer (gateway repo, in parallel) removes the misplaced originals (`docs/requirements/epic-p2p-matching-ui.md` + `docs/design/p2p-matching/ui/`) and adds a pointer back to admin-portal `docs/requirements/epic-p2p-ui.md` + WUI-115..121. Those names are final/stable on my side.

## Note / gotcha

Two working trees: main clone `mb-next-admin-portal` was on `consolidate/ui-epic-docs`; campaign worktree `.wt-c-p2pui` on `campaign/p2pui`. Initial absolute-path writes landed in the main clone; reconciled by copying into the worktree (matching INDEX baseline) and restoring the main clone clean. Final commit is on `campaign/p2pui` only (`a97909d`).

## Out of scope (owner)

Ratifying / merging — owner merges PR #5.

Findings: `next-ui_p2pui_findings.md` (repo root of the worktree).
