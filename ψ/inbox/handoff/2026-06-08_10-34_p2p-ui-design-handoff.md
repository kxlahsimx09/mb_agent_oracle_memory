# P2P UI Design — handoff (campaign p2pdesign, next-ui)

**Date:** 2026-06-08 · **Branch:** `campaign/p2pdesign` · **PR #351** (base `main`, OPEN, NOT merged — owner ratifies) · commit `fe41e93`.

## What landed
Authored the **P2P UI design** for §ADR-17 (PR #333, `#provisional`) under `docs/design/p2p-matching/ui/` — 4 files, each ≤250 lines, every section PM/DP-cited. Committed AFTER next-writer's core-design commit (`b500e5c`) per writer→me serialization.

- `ui/README.md` — index + **canonical status→user-label mapping** (one mapping shared by depositor/withdrawer/admin) + copy/a11y rules.
- `ui/client-depositor.md` — p2p-wallet view (PM2), P2P-deposit opt-in grid-50 (PM5/DP9), **the transfer-instruction screen** (real destination account + exact leg amount, manual, **no QR** per PM1), slip submission (PM10), DP4 verification outcomes (forged/mismatch/timeout/over-underpay).
- `ui/client-withdrawer.md` — payout request+freeze (PM8.i), **DP0 progressive-fill** pool screen (honest bar from `remaining`, N legs, SLA fail-fast), filled/settling (DP5), expire→unfreeze (DP6), large→payout (DP10a/PM12), DP11b truncate+resubmit (pure-P2P only).
- `ui/admin-dashboard.md` — health strip incl. the **50-baht-supply metric** (DP9, top billing, wired to grid-100 lever), FIFO primary queue (DP1/DP2), active 1:N matches (DP0/DP5), secondary/overflow lane (DP10), leg-failure→dead-letter→CS (DP4), expiry sweep (DP6), operator config levers.

## Faithfulness
Status enums + lifecycles (deposit POOLED→LOCKED→INSTRUCTED→SETTLED; withdrawal POOLED→PARTIALLY_MATCHED→FILLED→SETTLED; leg INSTRUCTED→TRANSFERRED→VERIFYING→VERIFIED|FAILED) and DP4 reasons + window defaults (transfer ~45m, SLA ~15m, deposit ~30m, T_large ~90m) taken **verbatim** from the committed `data-model.md` / `failure-and-expiry.md` so UI labels map 1:1 to backend states. Numbers trace to ADR-17 §Data-validation + `sim/match_sim.py` (X=5,000; ~5% 50-baht supply for grid-50; ~1.2 legs; 3.6:1 ratio; ~13% overflow/~95% match). Defaults bound to operator-config, not hardcoded.

## impeccable skill
Applied its principles (not the code-gen flow — building UI code is out of scope, repo has no PRODUCT.md): no em dashes in UI microcopy, verb+object buttons, status never color-only (WCAG 1.4.1), ≥4.5:1 contrast, designed empty/edge states, admin avoids hero-metric + card-grid clichés.

## Residual OPEN (tagged inline)
PM-O4 exact window numbers (config-bound); DP9 grid-100 fallback (lever exposed); PM-O8 DP11b resubmit ergonomics (proposed pre-filled Resubmit); PM-O7 supply-starvation SLA view (admin overflow-%/match-rate). Deployment flag: secondary-queue + TRUNCATED/Resubmit states are pure-P2P only; gateway build hides them.

## Findings
`next-ui_p2pdesign_findings.md` at repo root (committed).
