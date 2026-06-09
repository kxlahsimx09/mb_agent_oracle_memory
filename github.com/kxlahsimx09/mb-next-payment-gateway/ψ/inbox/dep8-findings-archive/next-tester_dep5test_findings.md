# next-tester — dep5test campaign findings (DEPOSIT-005, multi-candidate review parking)

**Goal.** Build the VERIFY probes for **DEPOSIT-005** (multi-candidate review / DEPOSIT-002 safety
branch), Step 1 of `docs/build-workflow.md`, **in PARALLEL with next-dev** — binding every probe to
the **AC + next-dev's published SPEC**, **NEVER reading next-dev's production code** (`supabase/`
forbidden, ever; reading the SPEC contract doc from the dev PR branch IS allowed). One probe per AC
clause (V1 bijection), each QUOTING its clause and asserting **positive + negative off ground-truth**
(PostgREST table reads + RPC responses) under the **§ADR-20 frozen clock**.

**STATUS: GREEN — 14/14 assertions PASS (7 ACs, all bound + run + evidenced). Test PR open, NOT merged.**

---

## Result — per-AC bijection + pass/fail (run git-sha `4da6839`, tester stack `yupsevcrubgprsbujbpu`)

Evidence: `evidence/integration-deposit-5-1780571270420-4da6839c.json` (runner exit 0; green only when
every assertion passes AND `DEP5_UNBOUND=false`). Bound to the SPEC
`docs/spec/deposit-005-multi-candidate-review.md` (read via `git show origin/campaign/dep5dev:…` — the
contract, never `supabase/`). Each probe emits a positive + a negative/contrast assertion row.

| AC | Probe | Positive (✅) | Negative / contrast (✅) |
|----|-------|--------------|--------------------------|
| **AC-1** diff-source → review | `d005-ac1-different-source-review.ts` | `match_status='review'`, **2** candidates each with the 8-field row shape, `match_note` contains `review required`, **NO finalize** (both pending, 0 credit/MDR/mdr_shared, Δwallet 0, 0 paid cb, `matched_request_id` null) | a SINGLE-candidate match → matcher finalizes (`matched`+`paid`+1 credit) |
| **AC-2** degenerate FIFO **(LIFO-FIX)** | `d005-ac2-degenerate-fifo-oldest.ts` | OLD@T0 / NEW@T0+5m, same `(client,src_acct,src_bank)` → `matched`, `matched_request_id`=**OLDEST**, `link_step='1'`, OLD `paid`+1 credit+1 cb, wallet Δ = OLD net (196.40), **NEW stays pending** | **anti-LIFO refutation:** `matched_request_id != NEWEST` AND NEW not paid AND 0 credit — the explicit refutation of the old LIFO bug |
| **AC-3** cross-client → review | `d005-ac3-cross-client-review.ts` | same src+bank, DIFFERENT clients (A,B) → `review`, ≥2 candidates, both pending, no credit/cb either client, `matched_request_id` null | **boundary:** same src+bank, SINGLE client (degenerate) → FIFO-finalizes (matched, oldest paid, other pending) — isolates the §CS5 client-scope guard |
| **AC-4** sweep excludes review | `d005-ac4-sweep-excludes-review.ts` | park `review`, tick `sweep_unmatched_statements()` → STILL `review`, no finalize, `matched_request_id` null | a non-review statement → sweep responds 200 + does not leave it `review` (sweep is live + selective) |
| **AC-5** admin candidate list | `d005-ac5-admin-queue-fetch.ts` | parked `review` → `match_candidates` len 2, every entry exposes the 8 fields, `name_score` present + numeric | a degenerate-matched statement → `match_candidates = []` (populated only on the review branch) |
| **AC-6** admin resolve → finalize | `d005-ac6-admin-resolution-finalize.ts` | `admin_resolve_multi_candidate(stmt, pick, admin…)` → `outcome:resolved`, statement `review→matched`, `link_step='admin_multi_candidate_resolve'`, `matched_request_id`=chosen, chosen `paid`+1 credit+1 cb | the UNCHOSEN candidate stays `pending` (0 credit, 0 cb) |
| **AC-7** never auto-resolves | `d005-ac7-no-auto-resolve-no-expiry.ts` | park `review`, advance clock **+7d**, tick expire + auto-match sweeps → STILL `review`, `matched_request_id` null, candidates unchanged, statement row exists, never finalized | a short-TTL pending DEPOSIT DOES flip to `expired` under the same clock (time advanced; statement immunity is specific) |

**Bijection: 7 probes / 7 AC clauses; 14 assertion rows; 14 PASS. AC-6 is IN-SLICE** (the SPEC built the
`admin_resolve_multi_candidate` RPC; only the HTTP `admin-deposit-resolve` EF wire shape is design-deferred,
which AC-6 does not depend on — it binds to the RPC observable).

---

## SPEC-vs-substrate divergences (record, don't inherit)

**None material.** The two watch-items resolved positively at run:

1. **`match_status='review'` (NOT `review_required`) — CONFIRMED landed.** The pre-build worry was that
   the §ADR-4d §CR3/§CR4 substrate-catchup might not be deployed (the slice-1 `_spec.ts` still enumerates
   the old `review_required`). Ground truth at run: every parked statement is written `review`. The catchup
   has landed; no divergence.
2. **Eager-intake vs explicit cascade (observed, expected — not a divergence).** `bot-statements` invokes
   `match_deposits_cascade` eagerly on intake (SPEC §0), so the probe's *explicit* second `cascade()` call
   returns `already_consumed` (NT-9 single-consumption guard) while the statement is correctly parked /
   finalized by the first pass. The probes therefore gate on **DB ground-truth** (match_status, deposit
   status, credits, callbacks), not the explicit RPC's return — the cascade `outcome` is captured in
   evidence only. AC-2 shows this: `cascade_outcome=already_consumed` yet the DB shows `matched` +
   FIFO-oldest credited. Authoritative state matches the SPEC exactly.

The **LIFO→FIFO fix is verified against the deployed substrate** (SPEC §6): AC-2 credits the OLDEST-by-
`created_at` deposit (`matched_request_id` = oldest's `request_id`, `link_step='1'`); the anti-LIFO row
confirms the NEWEST was NOT credited. (This is the probe that was RED against the pre-fix LIFO substrate
and is now GREEN — the whole point of the build.)

---

## Harness validation + de-bias

- `bun tests/integration/harness-selfcheck.ts` → **4/4** (a false assertion forces RED; all-pass+bound is
  GREEN; `UNBOUND=true` blocks GREEN). The runner's exit predicate is `failed===0 && !DEP5_UNBOUND`.
- Each probe's **negative/contrast leg** additionally exercises fail-on-violation against **live** ground
  truth (a wrong branch / wrong winner / non-empty-where-empty would go RED).
- **No `supabase/` source read** — the d5 fork transports over the wire (PostgREST + EF/RPC) and asserts
  off the DB observable surface + the SPEC RPC return shapes. The dev↔tester de-bias (build-workflow.md
  layer 1) holds. (One mid-build probe-setup bug — the AC-3 degenerate contrast initially used the 30s-TTL
  client and the candidates expired pre-cascade → fixed by moving to a long-TTL client within TTL; a probe
  bug found + fixed by the tester, not inherited from dev.)

---

## Stack-readiness gate (passed before any run)

Tester stack `yupsevcrubgprsbujbpu` verified deployed BEFORE running (not a bare stack): `ts_deposits` 200;
`bank_statements.match_note` + `match_candidates` columns present; `match_deposits_cascade` present
(`P0001 statement_not_found` on a dummy id — the FIFO cascade, not 404); `sweep_unmatched_statements` 200;
`admin_resolve_multi_candidate` present (`{"outcome":"statement_not_found"}` on dummy — SPEC §5b);
`clock_set/advance/reset`, `reset_for_test`, `sweep_expired_deposits` present. (brew-ops migration
`20260604000010`.)

---

## Files (committed on `campaign/dep5test`)

```
tests/integration/probes/d5/_spec5.ts                          SPEC binding block (DEP5_UNBOUND=false, bound)
tests/integration/probes/d5/_flow5.ts                          transport helpers (multi-candidate setup, candidate/finalize reads, sweep, cleanup)
tests/integration/probes/d5/d005-ac1-different-source-review.ts
tests/integration/probes/d5/d005-ac2-degenerate-fifo-oldest.ts (the LIFO-fix verification)
tests/integration/probes/d5/d005-ac3-cross-client-review.ts
tests/integration/probes/d5/d005-ac4-sweep-excludes-review.ts
tests/integration/probes/d5/d005-ac5-admin-queue-fetch.ts
tests/integration/probes/d5/d005-ac6-admin-resolution-finalize.ts
tests/integration/probes/d5/d005-ac7-no-auto-resolve-no-expiry.ts
tests/integration/probes/d5/index.ts                           registry (bijection 7; DEFERRED empty)
tests/integration/run-deposit-5.ts                             runner → evidence/integration-deposit-5-<run>.json
evidence/integration-deposit-5-1780571270420-4da6839c.json     RUN evidence (14/14, git-sha 4da6839)
```

## Handoff

- **next-investigator** (VERIFY layer 2): falsify each PASS against the TRUTH DB on your own seal env;
  the LIFO-fix (AC-2) and cross-client park (AC-3) are the money-safety-critical rows to re-derive. Run
  git-sha must equal the merged HEAD at seal.
- **Out of scope (not done by me, by design):** no product code; no reading dev code; no self-cert of the
  epic as done (investigator seals); no merge — the PR is a test PR for review, not for the bot to merge.
