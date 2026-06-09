## p2preq2 — PROPAGATE + RATIFY (next-writer) — DONE 2026-06-09

Owner GO 2026-06-09 ratified §ADR-17 + its single-flag amendment (2026-06-08, rev 2026-06-09). Propagation pass committed to `campaign/p2preq` (PR #354, kept OPEN — owner merges). Commit `dedf042`.

### Ratified model
Large-amount overflow = SINGLE global boolean `hybrid_enabled` on `p2p_config`. Pure-P2P secondary queue is the always-on FLOOR. `ON` → withdrawal `> X` → §ADR-8 `withdrawal_queue` bank rail (today's DP10a). `OFF` → pure-floor secondary queue (DP10b/DP11 `T_large`). Gateway default `ON`. Same X both states. No band-split, no both-off reject, no second flag, no separate threshold. OQ3: `PayoutRail` port ships now, extracted-product binding deferred.

### Edits (docs/requirements/)
- epic-p2p-matching.md: P2P-007 reframed as the `hybrid_enabled` toggle (ON→bank rail / OFF→pure-floor); deferred "Pure-P2P secondary queue" row promoted from out-of-gateway-scope → always-on in-gateway FLOOR; P2P-001/002 ACs made hybrid_enabled-aware.
- epic-p2p-matching-ui.md: P2P-UI-007 operator-config = the SINGLE `hybrid_enabled` toggle; P2P-UI-005 large-amount note + P2P-UI-D1 deferred row made hybrid_enabled-aware.
- RATIFICATION FLIP: all P2P-00x + P2P-UI-00x flipped S3→S2; removed `[RATIFICATION_PENDING:p2preq]`; dominant-trust + Sources + INDEX (17 labels + blurbs + rows) updated to §ADR-17 ratified.

### DONE-WHEN verified
grep RATIFICATION_PENDING:p2preq = 0; grep overflow_pure_enabled/hybrid_threshold_x/P2P_LARGE_DISABLED = 0; no S3 left on P2P stories; PR #354 OPEN not merged. Findings: next-writer_p2preq2_findings.md.

OUT-OF-SCOPE (untouched): ADR #355 (architect), design pass #351 (other writer), merging.
