# next-architect — campaign p2pmode — REVISED handoff (single-flag redirect 2026-06-09)

**Deliverable:** §ADR-17 §Amendment 2026-06-08 **(rev. 2026-06-09 — owner single-flag redirect)** — Single-Flag Large-Amount Overflow: an always-on **pure-P2P FLOOR** + ONE operator-toggleable **hybrid override** (`hybrid_enabled`), TM1–TM7.
**Class:** `#provisional` `[RATIFICATION_PENDING:p2pmode]` — NOT self-ratified; owner GO pending.
**PR #355:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/355 — OPEN, MERGEABLE, NOT merged. Branch `campaign/p2pmode`, latest commit `6ce0ff2`. Single file: `docs/adr.md` (+ findings md). Additive to merged ADR-17 (#333, `597615e`) — verified +24/-2 vs `origin/main`, not a duplicate.

## The owner single-flag model (supersedes the original two-boolean TM2 — implemented, not re-litigated)
- ONE global boolean `hybrid_enabled` on `p2p_config`. pure-p2p (DP10b secondary priority queue) is the **always-on FLOOR** for `> X`; the flag only toggles whether the bank-rail hybrid override supersedes it.
- `hybrid_enabled = ON` → `> X` to §ADR-8 `withdrawal_queue` (P2P-origin) → bank rail closes immediately (today's DP10a / PM12 trigger-(1) / P2P-007).
- `hybrid_enabled = OFF` → `> X` to the pure-floor secondary queue + DP11 remainder-migration / `T_large` truncate-partial (no bank rail).
- NO both-on, NO band-split, NO both-off. Exactly one flag; pure = floor; hybrid = override.
- **Gateway (mb-next) default = `hybrid_enabled = ON`** (no-op vs today's DP10a). Extracted pure-P2P product defaults OFF.

## TM block (revised)
- **TM1** — one flag, two STATES (pure-floor `OFF` / hybrid-override `ON`); both ship, both extractable.
- **TM2** — SINGLE boolean `hybrid_enabled`; `overflow_pure_enabled` DROPPED (pure = intrinsic floor). `overflow_threshold_x` (X=5,000) kept. `ON` requires bound `PayoutRail` → else `P2P_NO_PAYOUT_RAIL`.
- **TM3 — WITHDRAWN** (no resolver, no `hybrid_threshold_x`/`X_h`).
- **TM4 — WITHDRAWN** (no both-off, no `P2P_LARGE_DISABLED`; pure-floor always handles `> X`; anti-hoarding preserved by the floor).
- **TM5 — KEEP/revised** — `OverflowHandler` port: `secondary-queue` = intrinsic pure-floor; `route-to-payout` = hybrid override on NEW `PayoutRail` 4th port. Gateway binds it (`adr.md:1918`); extracted product MAY also bind. Both states travel with PM11 extraction.
- **TM6 — KEEP** — PM12 trigger-(1) = the hybrid-state trigger, still P2P-origin into `withdrawal_queue`.
- **TM7 — KEEP/reworded** — DP10b/DP11/`T_large`/DP0 truncate-note apply whenever `hybrid_enabled = OFF`, ANY deployment (flag property, not deployment).

## Open questions — now just OQ3
- OQ1 / OQ4 / OQ5 DISSOLVED by the single flag. OQ2 RESOLVED (gateway default ON).
- **OQ3 (sole remaining):** ship `PayoutRail` port + the ability for the extracted product to bind it NOW, defer the actual extracted-product binding to the future extraction campaign. Architect lean = YES (port-now-bind-later). Owner confirm pending.

## next-writer propagation (AFTER owner GO — do NOT pre-ratify) — SIMPLER now
- (A) `docs/adr.md` §ADR-17 prose: DP10 single-flag model (no resolver/X_h/pure-flag), DP11 + DP0-note → `hybrid_enabled = OFF` state, PM11 (pure-floor intrinsic + `PayoutRail` 4th port), PM12, PM7, scope/trade-offs/consequences, PM-O8 (PayoutRail bind-or-floor as open tuning).
- (B) PR #351 design (`campaign/p2pdesign`, OPEN): `p2p_config` gets ONE `hybrid_enabled boolean` col (NO `hybrid_threshold_x`, NO `overflow_pure_enabled`); matching-engine §5 / data-model §4 / failure-and-expiry / README single-flag framing.
- (C) PR #354 requirement (`campaign/p2preq`, OPEN): P2P-007 = the `hybrid_enabled` toggle; "Deferred P2P Surfaces" row → pure-P2P is now the in-gateway always-on FLOOR (hybrid-OFF state), NOT out-of-scope; P2P-001/002 ACs gain `hybrid_enabled`-awareness; UI epic = single toggle.

## Out of scope (bounced to team-lead)
Editing PR #351 / PR #354 = next-writer after owner ratifies. Ratifying = owner only.
