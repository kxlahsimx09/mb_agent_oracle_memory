# next-architect — campaign p2pmode — handoff

**Deliverable:** §ADR-17 §Amendment 2026-06-08 — Two Toggleable Large-Amount Overflow Modes (`hybrid-p2p` + `pure-p2p`), TM1–TM7.
**Class:** `#provisional` `[RATIFICATION_PENDING:p2pmode]` — architect direction, owner GO pending. **NOT self-ratified.**
**PR:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/355 (base `main`, OPEN, MERGEABLE — owner merges per §9).
**Commit:** `12242d0` on `campaign/p2pmode`. Single-file: `docs/adr.md` (additive amendment after §Data-validation; header + Implementation-line annotated).
**Verify-against-HEAD:** ADR-17 (#333, `597615e`) confirmed merged on `origin/main`; amendment is additive — NOT a duplicate ADR.

## Decisions (TM1–TM7)
Reframes the DP10 overflow from a gateway-vs-pure DEPLOYMENT split into two co-equal, independently operator-toggleable GLOBAL modes, both behind the DP10 port, both extractable.
- **TM1** names the two modes (`hybrid-p2p` = `>X`→§ADR-8 `withdrawal_queue` P2P-origin; `pure-p2p` = `>X`→DP10b secondary queue + DP11 migration/`T_large` truncate). No longer a deployment property.
- **TM2** GLOBAL toggle granularity (DP6-consistent): two `p2p_config` booleans `overflow_hybrid_enabled` + `overflow_pure_enabled`. `overflow_threshold_x` (X, 5000) retained. Hybrid needs a bound `PayoutRail` (guard `P2P_NO_PAYOUT_RAIL`).
- **TM3** both-on resolver `resolve_overflow(amount)` via new `hybrid_threshold_x` (`X_h≥X`, default=X): both-on `X<amt≤X_h`→pure, `amt>X_h`→hybrid. Default `X_h=X` ⇒ **hybrid-wins** whole tail; raise X_h to carve a pure band. (= owner's "which wins for a given amount band" answer.)
- **TM4** single-mode pass-through; **both-off → reject `>X`** (`P2P_LARGE_DISABLED`); primary pool never accepts `>X` (DP10 anti-hoarding).
- **TM5** PM11 revised: `OverflowHandler` port carries BOTH strategies; `route-to-payout` depends on a NEW **`PayoutRail` port** (4th seam) the extracted pure-P2P product MAY also bind → both modes extract.
- **TM6** PM12 trigger-(1) generalized as the hybrid-mode trigger (still P2P-origin); trigger-(2) stays Phase-2.
- **TM7** DP11 re-scoped "pure-P2P only"→"pure-mode-enabled"; DP0 truncate-note re-gated on the mode.
**Default posture:** gateway `hybrid=ON/pure=OFF` (no-op vs today); extracted `hybrid=OFF/pure=ON`.
**UNCHANGED:** DP0 LOCK/PUBLISH · DP1/DP2 FIFO · DP3–DP9 · PM7 concurrency · PM8–PM10 Thunder/settlement · PM9 `*_p2p`.

## EXACT propagation set (next-writer, AFTER owner GO)
**(A) §ADR-17 prose in `docs/adr.md`:** DP10, DP11 (+DP0-note), PM11 (add `PayoutRail` 4th port), PM12, PM7 overflow parenthetical, Scope-boundary bullet, Trade-offs "pluggable seam" bullet, Consequences (ii) relief-valve, PM-O8 (add `hybrid_threshold_x` sizing + both-on precedence).
**(B) Design — PR #351 / `campaign/p2pdesign` (OPEN, do NOT edit now):** `matching-engine.md` §5 (modes + `resolve_overflow` + X/X_h band + DP0-note re-gate); `data-model.md` §4 + `p2p_config` narrative (2 booleans + `hybrid_threshold_x` + `PayoutRail`); `schema.sql` `p2p_config` (2 booleans + `hybrid_threshold_x numeric`); `failure-and-expiry.md` (`T_large` gated on pure-mode); `data-validation.md` (X_h split not yet simulated); `README.md` index.
**(C) Requirement — PR #354 / `campaign/p2preq` (OPEN, do NOT edit now):** `epic-p2p-matching.md` **P2P-007** (reframe as `hybrid-p2p` mode + toggle + both-off reject + band split); the **"Deferred P2P Surfaces" pure-queue row** MUST change (no longer out-of-gateway-scope; now toggleable, default-OFF); **P2P-001/P2P-002** ACs gain mode-awareness; consider a NEW pure-mode story; `epic-p2p-matching-ui.md` (admin toggle surface + `hybrid_threshold_x`).

## Open questions for owner (block ratification)
OQ1 both-on default precedence (hybrid-wins/`X_h=X`)? · OQ2 gateway default `hybrid=ON/pure=OFF` no-op? · OQ3 ship `PayoutRail` port now, bind-in-extracted later? · OQ4 both-off reject `>X`? · OQ5 ship `X_h=X` (no pure band), tune post-sim?

## Out of scope
Editing PR #351/#354 (next-writer, follow-on after ratification); ratifying (owner only).
Findings file: `next-architect_p2pmode_findings.md`.
