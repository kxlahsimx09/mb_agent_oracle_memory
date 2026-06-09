# next-architect — campaign p2padd — findings (RATIFIED 2026-06-09)

**STATUS: RATIFIED `#decision` (owner GO 2026-06-09 — architect direction + leans accepted wholesale).** Supersedes the earlier `[RATIFICATION_PENDING:p2padd]` handoff.

**Deliverable:** NEW `§ADR-17 §Amendment 2026-06-09 (2)` in `docs/adr.md` (additive, house-style) — now **RATIFIED**; all `[RATIFICATION_PENDING:p2padd]` markers flipped → `RATIFIED #decision`; OQ-A1–OQ-A4 resolved inline.
**PR:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/361 — base `main`, head `campaign/p2padd`, **MERGEABLE, OPEN, NOT merged** (owner merges §9). Commits `449b15c` (author) + `b92f083` (ratify).
**Verify-against-HEAD:** amends the merged §ADR-17 (single-flag amendment on origin/main `ca4828a`); no duplicate `2026-06-09 (2)` block. DP0/DP1/DP2/DP3–DP9/PM7–PM10 + the single `hybrid_enabled` flag UNCHANGED.

## Ratified decisions

### ADD-1 — Split large-amount threshold DEPOSIT vs WITHDRAWAL (DT1–DT4)
- **DT1** — replace `p2p_config.overflow_threshold_x` with **`deposit_overflow_threshold_x` + `withdrawal_overflow_threshold_x`**, both default **5,000** → no-op migration. DP9 band/grid separate + unchanged.
- **DT2** — **withdrawal** threshold IS today's X verbatim; gates DP10/DP10a/DP11/DP12 + `hybrid_enabled` with zero behavior change. Every withdrawal-side "X"/"> X" now reads `withdrawal_overflow_threshold_x`.
- **DT3** — **deposit** threshold GENUINELY NEW = supply-side **POOL-ELIGIBILITY / OVERFLOW classification** (`> deposit-X` deposit = "large supply", secondary matcher only). **NOT fee (DP7 unchanged), NOT reject.** Grounded finding: today X is **withdrawal-side ONLY** (sim `if a > X` on payout stream only; `queue` only on `p2p_withdrawals`); a large deposit today is consumable only by a large withdrawal via PM7 no-split + DP3 no-overfill, else expires at `deposit_ttl`. Architect lean (ratified): **derived predicate** at match-time, no stored column.
- **DT4** — dead-supply + hybrid-state large-deposit limitation flagged (resolved via OQ-A1/OQ-A2 below).

### ADD-2 — Read-only match-likelihood PREVIEW / "check mode" (CK1–CK5)
- **CK1** — dedicated **`GET /p2p/match-preview?side={deposit|payout}&amount=N`** read endpoint (over a `mode=check` POST flag): keeps §ADR-11 mandatory-idempotency-key clean; §ADR-12 distinct-endpoint topology; money-safety.
- **CK2** — likelihood = deterministic READ-ONLY dry-run of the SAME greedy largest-fit assembly (`matching-engine.md` §3 `lock_best_fit`) over a live opposing snapshot → facts (`fillable_now`, `exact_opposing_count`, `matchable_legs`, `residual`, `opposing_depth`) + coarse `{high|medium|low}` band, NOT fabricated probability. Respects DP9 grid + split thresholds + PM7 1:N + `hybrid_enabled` routing. Impl = read-only PL/pgSQL `p2p_match_preview(side, amount)`, plain SELECT / FOR SHARE, never FOR UPDATE.
- **CK3** — strictly READ-ONLY: no row/LOCK/freeze/idempotency-key/wallet/callback; advisory point-in-time (not a reservation).
- **CK4** — §ADR-7/11/12 auth (API-Key+HMAC); no Idempotency-Key (read); **aggregate-only** (no counterparty identity/account).
- **CK5** — UI affordance = downstream admin-portal WUI follow-on (campaign p2pui, mb-next-admin-portal) — NOTE only.

## Open questions — ALL RESOLVED (owner GO 2026-06-09 — architect leans accepted)
- **OQ-A1** ✅ — deposit default 5,000 (= withdrawal, no-op). `deposit-X > withdrawal-X` dead-supply → **SOFT guard + docs (WARNING), NOT a hard CHECK reject.**
- **OQ-A2** ✅ — hybrid-state large deposit (no in-pool counterparty) → **POOLED-AND-EXPIRES Phase-1** (no regression); richer treatment (reject-at-API / dedicated handler) **deferred Phase-2** (new PM-O).
- **OQ-A3** ✅ — preview output = **structured facts + coarse {high/medium/low} band, NO fabricated probability.**
- **OQ-A4** ✅ — **aggregate-only output MANDATORY** (no PII); rate-limit + optional short edge-cache TTL = **design-pass tuning.**

## EXACT downstream propagation set (next-writer + next-ui — NOW UNBLOCKED, ratification done; NOT done by me)
**(A) docs/adr.md (next-writer, additive):** DP10/DP10a/DP11/DP12 + PM7 overflow parenthetical + TM1–TM7 — withdrawal-side "X"→`withdrawal_overflow_threshold_x`; add deposit-side `deposit_overflow_threshold_x` classification (DT3); Scope-boundary "large-amount overflow seam" + "two P2P APIs" bullets (add preview surface); PM-O8 (per-side tuning); NEW PM-O for the hybrid-state large-deposit Phase-2 item (DT4b/OQ-A2).
**(B) docs/design/p2p-matching/ (next-writer):**
- `schema.sql` `p2p_config` (line ~161) — replace `overflow_threshold_x` with the two columns; add the OQ-A1 SOFT guard (warning/doc, not a hard CHECK).
- `data-model.md` §4 — two thresholds; deposit-side `large supply` classification (DT3).
- `matching-engine.md` §5 — deposit-eligibility derived predicate; withdrawal-side "X"→`withdrawal_overflow_threshold_x`.
- `settlement-rpcs.md` §5 — NEW `GET /p2p/match-preview` route row + read-only `p2p_match_preview()` fn; pure-core/extractable note.
- `data-validation.md` — note split; **NEW sim follow-up: add a `deposit_X` param to `sim/match_sim.py`** (deposit cutoff not yet simulated).
- `README.md` — index: preview surface + split-threshold framing.
**(C) docs/requirements/epic-p2p-matching.md (next-writer):**
- P2P-001 AC — fix "when the **deposit/withdrawal** is large": deposit→`deposit_overflow_threshold_x` (DT3), withdrawal→`withdrawal_overflow_threshold_x` (DT2).
- P2P-002 + P2P-007 AC — withdrawal-side "X"→`withdrawal_overflow_threshold_x`.
- **NEW story `P2P-011`** — "Read-only match-likelihood preview (`GET /p2p/match-preview`)" (CK1–CK4: dedicated read endpoint, deterministic dry-run likelihood, strictly read-only, §ADR-7/11/12 auth, aggregate-only).
**(D) UI follow-on (next-ui / campaign p2pui, mb-next-admin-portal — NOTE only, DO NOT touch):** `epic-p2p-matching-ui.md` — "check likelihood before submitting" affordance + operator config surface for the TWO split thresholds (CK5 / DT1).

## Out-of-scope (bounced to team-lead): editing design/requirement/UI docs (writer+ui propagate now that it's ratified); merging PR #361 (owner).
