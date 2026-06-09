# Handoff — p2pdesign single-flag propagation (next-writer)

**Date:** 2026-06-09 · **Branch:** `campaign/p2pdesign` · **PR #351 (OPEN, NOT merged — owner merges)** · commit `5d1077d`.

## What this was
Propagation pass for the §ADR-17 single-flag amendment (owner GO 2026-06-09). Large-amount overflow collapses to ONE global boolean `hybrid_enabled` on `p2p_config`. The pure-P2P secondary queue is an **always-on FLOOR** (intrinsic, not a flag). `hybrid_enabled=ON` → `>X` routes to the §ADR-8 `withdrawal_queue` bank rail via a **bound `PayoutRail` port (the NEW 4th port)**; gateway default ON. `OFF` → pure-floor + DP11 remainder-migration / `T_large` truncate (DP11b). NO `overflow_pure_enabled`, NO `hybrid_threshold_x`, NO band-split/resolver, NO both-off reject. OQ3 = ship PayoutRail port + gateway binding now, extracted-product binding deferred.

## Applied to docs/design/p2p-matching/
- matching-engine.md §5 (always-on floor + single override; DP11b re-gated on OFF)
- data-model.md §4/§4a/§4b (single flag + NEW PayoutRail port + gateway withdrawal_queue impl)
- schema.sql p2p_config (added `hybrid_enabled boolean DEFAULT true`; existing `overflow_threshold_x` = X grid cutoff, unrelated, kept)
- failure-and-expiry.md (T_large gated on hybrid_enabled=OFF, any deployment)
- README.md (single-flag overview + four-port framing)
- settlement-rpcs.md (consistency: three ports → four ports incl. PayoutRail) — not in the prescribed 5 but required to avoid a hard contradiction with data-model's "4th seam after …OverflowHandler"

## Verified
No affirmative `overflow_pure_enabled`/`hybrid_threshold_x`/two-boolean/both-off/band-split wording (only explicit negations remain). `hybrid_enabled` in 6 files, `PayoutRail` in 5. No "three ports" left. PR OPEN.

## Open / next
UI surface NOT touched (out of architect's section-B 5-file set): `ui/admin-dashboard.md`, `ui/client-withdrawer.md`, `ui/README.md` still use "pure-P2P only" / `DP10b` deployment-split framing (no forbidden config terms though). `data-validation.md` line 79 keeps a `DP10b/DP11b` sim caveat. Recommend the owner/architect decide whether the UI gets the same single-flag relabel (small UI-writer pass) before merge. Owner merges #351. Out-of-scope here: ADR #355 (architect), requirement epics #354 (other writer), merging.
