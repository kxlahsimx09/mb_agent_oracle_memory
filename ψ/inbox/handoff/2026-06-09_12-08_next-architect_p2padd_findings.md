# next-architect — campaign p2padd — findings

**Deliverable:** NEW `§ADR-17 §Amendment 2026-06-09 (2)` in `docs/adr.md` (additive, house-style). Class `#provisional [RATIFICATION_PENDING:p2padd]` — **NOT self-ratified, awaits owner GO.**
**PR:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/361 — base `main`, head `campaign/p2padd`, **MERGEABLE, OPEN, NOT merged** (owner merges §9). Commit `449b15c`.
**Verify-against-HEAD:** amends the merged §ADR-17 (single-flag amendment present on origin/main `ca4828a`); no duplicate `2026-06-09 (2)` block. DP0/DP1/DP2/DP3–DP9/PM7–PM10 + the single `hybrid_enabled` flag are UNCHANGED — both ADDs are additive.

## Decisions

### ADD-1 — Split large-amount threshold DEPOSIT vs WITHDRAWAL (DT1–DT4)
- **DT1** — replace the single `p2p_config.overflow_threshold_x` with **`deposit_overflow_threshold_x` + `withdrawal_overflow_threshold_x`**, both default **5,000** → literal **no-op migration**. DP9 band (`amount_min` 50 / `amount_max` 50,000) + grid (`grid_step` 50) separate + unchanged.
- **DT2** — the **withdrawal** threshold IS today's X verbatim; gates DP10/DP10a/DP11/DP12 + `hybrid_enabled` (ON→bank rail / OFF→pure-floor secondary) with **zero behavior change**. Every existing "X"/"> X" on the withdrawal side now reads `withdrawal_overflow_threshold_x`.
- **DT3** — the **deposit** threshold is **GENUINELY NEW**. Grounded finding: *today there is NO deposit-side threshold* — the single X is **withdrawal-side-only** (confirmed in `sim/match_sim.py`: `if a > X` applies only to the payout/withdrawal stream; deposits enter the single pool at any band-valid amount; `queue` exists only on `p2p_withdrawals`). A "large deposit" today is bounded only by DP9 `amount_max` and, by **PM7 no-split + DP3 no-overfill** (`leg.amount ≤ withdrawal.remaining`, whole-deposit-consumed), can only lock to a withdrawal with `remaining ≥ its amount` — so a `> withdrawal-X` deposit already can't fit any primary withdrawal; it's consumable only by a secondary (large-floor) withdrawal in `hybrid_enabled=OFF`, else sits POOLED to `deposit_ttl` expiry. **What DT3 changes:** the deposit threshold makes that implicit boundary explicit + independently tunable — a `> deposit_overflow_threshold_x` deposit is classified **"large supply"** (secondary matcher only). It is **POOL-ELIGIBILITY / OVERFLOW classification — explicitly NOT fee (DP7 unchanged), NOT reject.** Architect lean: realize as a **derived predicate** at match-time (no stored column).
- **DT4** — flagged: (a) `deposit-X > withdrawal-X` creates **dead primary supply** (lean: soft guard / document); (b) in `hybrid_enabled=ON` a large deposit has no in-pool large counterparty → Phase-1 **pool-and-expire** (no regression; supply-positive market already ~70% deposits unmatched), richer handling Phase-2. Sim follow-up: add a `deposit_X` param to `match_sim.py` (deposit cutoff not yet simulated).

### ADD-2 — Read-only match-likelihood PREVIEW / "check mode" (CK1–CK5)
- **CK1** — **dedicated `GET /p2p/match-preview?side={deposit|payout}&amount=N`** read endpoint, chosen over a `mode=check` POST flag. Rationale: (i) keeps §ADR-11 D5 mandatory-`Idempotency-Key`-on-writes invariant clean (a read consumes no key); (ii) §ADR-12 D5 distinct-endpoint-per-flow topology (same reasoning PM5 used); (iii) money-safety — a forgotten flag on POST would accidentally commit a real LOCK/`payout_freeze`; a GET can't.
- **CK2** — likelihood = a **deterministic READ-ONLY dry-run of the SAME greedy largest-fit assembly** (`matching-engine.md` §3 `lock_best_fit`) over a live opposing-pool snapshot. Returns structured facts: `fillable_now`, `exact_opposing_count` (1:1 fast path), `matchable_legs`, `residual` (grid-50 dead-end gap), `opposing_depth {count,sum}`, + a coarse `likelihood ∈ {high|medium|low}` band by a documented rule — **NOT a fabricated probability** (grounded on `match_sim.py`/`data-validation.md` §C: match is effectively binary + instant). Respects DP9 grid + split thresholds + PM7 1:N no-split + `hybrid_enabled` routing (a `> withdrawal-X` payout preview returns `route=overflow` with the ON/OFF destination; a `> deposit-X` deposit preview returns `large supply`). Impl = read-only PL/pgSQL `p2p_match_preview(side, amount)`, plain SELECT / `FOR SHARE`, never `FOR UPDATE`.
- **CK3** — strictly READ-ONLY: no row INSERT, no LOCK/status-transition, no `payout_freeze`/wallet touch, no idempotency-key, no callback. Advisory point-in-time (NOT a reservation/guarantee).
- **CK4** — auth reuses §ADR-7/11/12 (API-Key+HMAC) + per-client rate-limit; **no** `Idempotency-Key` (read); **aggregate-only output** — counts/sums/bands only, never counterparty identity/`client_id`/destination account (PII/leakage guard).
- **CK5** — UI affordance ("check before submitting") = downstream **admin-portal WUI follow-on (campaign p2pui, mb-next-admin-portal)** — NOTE only, NOT authored here.

## Open questions for owner (BLOCKING ratification)
- **OQ-A1** — deposit-threshold default 5,000 (=withdrawal, no-op) OK? Hard-reject `deposit-X > withdrawal-X` (CHECK) or just document the dead-supply case? (lean: soft guard + document)
- **OQ-A2** — hybrid-state large deposit: Phase-1 pool-and-expire vs a Phase-1 reject-at-API? (lean: pool-and-expire Phase-1, richer Phase-2)
- **OQ-A3** — preview output: facts + coarse {high/medium/low} band (lean) vs raw facts only vs a finer estimate? (NO fabricated probability either way)
- **OQ-A4** — confirm aggregate-only output; tighter rate-limit / short edge-cache TTL on the dry-run? (lean: aggregate-only mandatory; rate/cache = design-pass tuning)

## EXACT downstream propagation set (writer + ui follow-on, AFTER owner GO — do NOT propagate pre-ratification)
**(A) docs/adr.md (next-writer, additive):** DP10/DP10a/DP11/DP12 + PM7 overflow parenthetical + TM1–TM7 — every withdrawal-side "X"→`withdrawal_overflow_threshold_x`; add the deposit-side `deposit_overflow_threshold_x` classification (DT3); Scope-boundary "large-amount overflow seam" + "two P2P APIs" bullets (add the preview surface); PM-O8 (per-side tuning); NEW PM-O for the hybrid-state large-deposit limitation (DT4b).
**(B) docs/design/p2p-matching/ (next-writer):**
- `schema.sql` `p2p_config` — replace `overflow_threshold_x` (line 161) with the two columns; optional DT4a guard.
- `data-model.md` §4 — the two thresholds; deposit-side `large supply` classification (DT3).
- `matching-engine.md` §5 — deposit-eligibility predicate; withdrawal-side "X"→`withdrawal_overflow_threshold_x`.
- `settlement-rpcs.md` §5 — NEW `GET /p2p/match-preview` route row + read-only `p2p_match_preview()` function; note it's pure-core/extractable.
- `data-validation.md` — note the split; **NEW sim follow-up: add `deposit_X` param to `sim/match_sim.py`** (deposit cutoff not yet simulated).
- `README.md` — index: preview surface + split-threshold framing.
**(C) docs/requirements/epic-p2p-matching.md (next-writer):**
- P2P-001 AC — fix the loose "when the **deposit/withdrawal** is large" wording: deposit side → `deposit_overflow_threshold_x` (DT3), withdrawal side → `withdrawal_overflow_threshold_x` (DT2).
- P2P-002 + P2P-007 AC — withdrawal-side "X" → `withdrawal_overflow_threshold_x`.
- **NEW story `P2P-011`** — "Read-only match-likelihood preview (`GET /p2p/match-preview`)" (CK1–CK4: dedicated read endpoint, deterministic dry-run likelihood, strictly read-only, §ADR-7/11/12 auth, aggregate-only).
**(D) UI follow-on (next-ui / campaign p2pui, mb-next-admin-portal — NOTE only, DO NOT touch):** `epic-p2p-matching-ui.md` — "check likelihood before submitting" affordance + operator config surface for the TWO split thresholds (CK5 / DT1).

## Out-of-scope (bounced to team-lead): editing design/requirement/UI docs (writer+ui propagate post-ratification); ratifying; merging.
