# next-code-reviewer — PAYOUT slice-1 three-dimension review (campaign payb1r) — findings

**Slot/role:** next-code-reviewer (campaign payb1r). Step-3 three-dimension PR review
(requirement-fidelity / clean-code / perf, per `docs/build-workflow.md`) for the PAYOUT
slice-1 set on `mb-next-payment-gateway`.
**Gate posture:** I review **CODE**; next-investigator falsifies **BEHAVIOR** in parallel.
Both must land (my APPROVE + investigator GREEN) before the team exercises the §9a build-code
self-merge carve-out for #437/#439. **#441 touches the SEALED deposit lane → its merge escalates
to the OWNER** regardless. **I DO NOT MERGE anything.** Verdicts are posted as COMMENTED reviews
(self-approve refused → gh state stays COMMENTED; the BODY-header verdict line is authoritative).

**Inputs verified against:** SPEC v2 (`origin/build/payout-slice1:docs/spec/payout-core-lifecycle-slice.md`),
architect rulings (`next-architect_payb1_findings.md` Q1/Q2/Q3/Q4/C1), origin/main function defs
(`pg_get_functiondef`-equivalent migration source), tester evidence
(`integration-run-payout-1781266973439-91e2497a.json`, 71/71 GREEN on yupsev).

**Heads reviewed:**
- #437 `build/payout-slice1` @ `816919320ba8921a96357916abb64108e7930f50`
- #441 `parity/mdr-residual-guard-tiebreaker` @ `8bc435b9aba13d59a3f8f25f278ecb16ff0979ea`
- #439 `test/payb1-probes` @ `ad0732b3a95297efcda1a142a94995d7d15abe35`

---

## Verdicts (one per PR)

| PR | Title | Verdict (code gate) | Blocking |
|---|---|---|---|
| **#437** | build(payout-slice1): PAYOUT-001/002/003 + SM1–SM3 | **APPROVE** | none |
| **#441** | parity(adr10): deposit-lane mirror (residual-guard + tiebreaker) | **APPROVE** (byte-exact-mirror VERIFIED) | none |
| **#439** | [TEST-ONLY] PAYOUT slice-1 probe suite (71/71 GREEN) | **APPROVE** | none |

---

## PR #437 — build — APPROVE

**Requirement fidelity to SPEC v2 (confirmed clause-by-clause):**
- **Freeze/settle/release bases** = `gross_debit = amount + payout_fee` (NOT `final_amount`).
  create_payout freeze `frozen += v_total_debit` (balance untouched); mark_success settle
  `balance -= v_total AND frozen -= v_total`; mark_failed release `frozen -= v_total` (balance
  untouched). `final_amount = amount − fee` stored, never a base (SPEC §0 / Q4). ✓
- **PW2 fan-out** (mark_success): residual starts at `payout_fee`; one audit row **per partner**
  (`mdr_distribute` active / `mdr_skip` with structured `partner_inactive|wallet_missing` note,
  no silent drop); `share = round(amount × pct/100, 2)` (Q2-reaffirmed gross base);
  `residual > 0 → mdr_residual` to `owner_type='mdr_owner'`; missing residual wallet → RAISE +
  whole-settle rollback. ✓
- **Q2 over-config fail-close** (`residual < 0 → RAISE mdr_over_allocated` + full rollback, payout
  stays `processing`) — present, inert on valid configs. ✓ Matches SPEC §3.2 v2 + architect PV1.
- **Q1 tiebreaker** `ORDER BY created_at, id LIMIT 1` on the MDR-profile select. ✓ (PV2.)
- **SM2/SM2-SPLIT/SM3:** mark_success asserts `status ∈ {processing, review}` (late-bot-from-review
  accepted); mark_failed asserts `status = 'processing'` ONLY (review→failed is a no-op — the
  load-bearing asymmetry); lock-first `withdrawal_queue → ts_payouts → wallet`, illegal source →
  `RETURN` benign no-op (no error/2nd-move/2nd-callback). ✓
- **Callback-endpoint resolve + snapshot** BEFORE any business-state write; NULL key ⇒ `default`
  payout endpoint; unknown/disabled key → INVALID; none configured → NOT_CONFIGURED. Snapshots
  `callback_url`(resolved)/`callback_endpoint_key`/`version`/`mdr_profile_id`/`ref_code`/`metadata`. ✓
- **No raw-callback acceptance:** EF rejects any `callback_url` with `CALLBACK_URL_NOT_ALLOWED`
  (400) *before* state, and forces `p_callback_url: null` into the RPC. ✓
- **EF auth precedes body:** `verifyAssertion` → `scope==='payout'` (else 401 `wrong_scope`) →
  THEN `withIdempotency`/body parse/validations/RPC. ✓
- **No secret leakage:** no env/key/token logged; RPC errors mapped via `rpcErrorToResponse`. ✓

**Migration safety:** `ADD COLUMN IF NOT EXISTS`, `CREATE OR REPLACE`, `DROP FUNCTION IF EXISTS`,
seed `INSERT … ON CONFLICT DO NOTHING` — all idempotent; no destructive ops on existing rows
(the `DROP FUNCTION` loop on create_payout overloads is required by the param-list change and is
safe; `mark_rejected` drop removes an uncalled orphan that wrote a now-illegal status). ✓

**Non-blocking observations:**
- **NB-437-1 (ops note, money-adjacent):** migration `…000100` §(4) UPDATEs seed
  `mdr_profile.payout_fee_percent` → 1.20–1.50 in the **forward** migration. Architect-ratified
  as the Q2 fixture-validity fix (routed consequence #1, "lands in PR #437"); **deposit-inert**
  (`deposit_fee_percent` untouched). Because it runs on every substrate, on live (sinuw) the seed
  payout fee jumps wherever those seed profiles are the selected global profile — acceptable as
  the payout lane is pre-production and real per-profile fees are the named Phase-2 driver, but
  worth an explicit heads-up to brew-ops/owner at live deploy.
- **NB-437-2 (hardening, unreachable):** mark_success client-settle is `IF FOUND THEN … END IF`
  with no else — a (structurally impossible) missing client wallet would mark success + fan out
  MDR + queue the callback **without** debiting. Asymmetric vs finalize_deposit, which `RAISE`s
  `client_wallet_missing`. Unreachable (create requires the wallet; wallets aren't deleted); a
  mirrored RAISE would make the fail-closed posture symmetric.
- **NB-437-3 (note only):** `… ORDER BY w.id ASC FOR UPDATE` does not strictly guarantee
  lock-acquisition order under Postgres; this mirrors the sealed deposit template verbatim, so it
  is consistent-with-seal, not a new defect.

**Tester-alignment:** evidence sha `91e2497` is the **test-branch harness sha** (de-bias: the test
branch carries probes, not `supabase/`). The 71/71 GREEN run exercised all three gate features
(`p002.success_f` over-allocated RAISE can only pass against a deployed `mark_success` carrying the
`residual<0` guard; tiebreaker + payout-valid seeds named in `prs_under_test`). Current head
`8169193` matches the tested feature set.

---

## PR #441 — deposit-lane parity — APPROVE (byte-exact-mirror VERIFIED)

**Byte-exact-mirror claim — VERIFIED by normalized diff against origin/main:**
- **finalize_deposit** vs `origin/main:20260603000002` — body matches **line-for-line** except the
  single injected block `IF v_residual < 0 THEN RAISE 'mdr_over_allocated' … END IF;`. All other
  deltas are pure `pg_get_functiondef` normalization (one-line signature, `$function$` vs `$$`,
  `SET search_path TO 'public'`, `timestamp with time zone`).
- **create_deposit** vs `origin/main:20260603000020` (the **current** latest def — confirmed no
  later redefinition) — body matches line-for-line except the single delta
  `ORDER BY created_at` → `ORDER BY created_at, id`. Header diffs = normalization only.
- → the ONLY semantic deltas are exactly the two sanctioned injections (PV1 residual<0 RAISE +
  PV2 `, id` tiebreaker). Claim holds.

**admin_approve_paid correctly OMITTED:** the migration contains only the two `CREATE OR REPLACE`
(finalize_deposit, create_deposit). The header documents the deliberate omission to avoid a
`CREATE OR REPLACE` clobber collision with PR #438 (`…000060`, secres lane) which is concurrently
rewriting admin_approve_paid's residual routing. ✓ This is the right call (matches the #438
collision the dev surfaced); the admin_approve_paid residual<0 guard lands in #438's rewrite.

**Non-regressive on the sealed deposit lane:**
- residual<0 RAISE is **inert** on sealed configs (Σ partner-pct = 1.00 ≤ deposit_fee 1.80 ⇒
  residual ≥ 0 ⇒ never fires). ✓
- migration ordering: `…000060` (#438) < `…000070` (#441) < `…000100/110/120` (#437); #441 only
  touches finalize_deposit/create_deposit (disjoint from #438's admin_approve_paid and #437's
  payout RPCs) — no cross-PR function collision. ✓

**Non-blocking observation:**
- **NB-441-1 (owner/investigator confirm):** the `, id` tiebreaker makes create_deposit's
  global-profile pick deterministic = the min-id seed profile (`…001`). On the 3-profile seed this
  *could* shift the deposit pick if the prior arbitrary pick landed elsewhere. Architect ruled this
  non-regressive (global-singleton model; the tiebreaker only removes latent non-determinism), but
  since this is the SEALED lane, the OWNER's merge + the investigator's behavioral leg should
  confirm the live deposit-profile pick is unchanged. Code is a faithful implementation of the ruling.

**Merge routing:** DO NOT MERGE — sealed-lane PR; owner-escalated per house rules. My gate is code-only.

---

## PR #439 — probe suite (TEST-ONLY) — APPROVE

**Binds SPEC, not impl:** `_spec-payout.ts` cites a SPEC section for **every** constant; genuinely
unpinned shapes carry `[SPEC-PENDING]`/`[SEED-PENDING]` notes and are surfaced (read defensively /
recorded), never invented; the de-bias is explicit ("reading next-dev's `supabase/` source is
FORBIDDEN"). A probe→AC `quote{}` bijection ties each assertion to its SPEC clause. ✓ Confirmed:
zero reads of `supabase/`; assertions read ground-truth tables only.

**No substrate writes outside reset seams:** all mutations go through documented service-role
**staging seams** (`setWallet`/`forceStatus`/`setWalletActive`/`setPartnerPct`/`cleanupPayout`),
labeled "SETUP ONLY … never an assertion target." Every fixture mutation is **restored in a
`finally`** (partner reactivated, pct restored, payouts cleaned, clock reset). State reset rides
the §ADR-20 carried seams (`clock_set/reset`, `reset_for_test`). No pollution. ✓

**No secrets:** no service-role key / JWT / secret / DB URL in any probe file (creds are
env-sourced via the pre-existing `_context.ts` harness, not in this PR); evidence JSON carries
**zero** secret-shaped strings — the lone URL is the public Supabase project ref. ✓

**Coverage:** the money-load-bearing `p002-success.ts` asserts settle(balance&frozen)+audit4+AM5,
PW2 conservation (`fee = Σcredited + residual`, residual≥0), one-row-per-partner, `mdr_skip` w/
note, residual→mdr_owner, duplicate→benign-no-op, and the **Q2 over-config fail-close** (bump
partner pct > fee → assert `mdr_over_allocated` RAISE + full rollback, stays processing, freeze
intact, no settle/fan-out/callback). Evidence: **71/71 GREEN** (create 16, claim 3, success 6,
failed 6, sm2split 2, sm3 + am5 + readiness). ✓

**Non-blocking observation:**
- **NB-439-1 (cosmetic):** `_spec-payout.ts`'s top doc-comment twice stamps "v1, 2026-06-12" while
  the binding is v2-aware (C1/Q2 resolved, residual≥0 invariant, over-config probe present). Bump
  the header version stamp to v2 for accuracy. Non-functional.

**Merge routing:** DO NOT MERGE — TEST-ONLY by its own title.

---

## Summary

All three PRs **APPROVE** at the code-review gate; **no blocking findings**. The two
money-load-bearing claims were independently verified at the code layer: (a) PR #437's `residual<0`
fail-close + PW2 conservation + SM2-SPLIT/SM3 guards faithfully implement SPEC v2 and the architect
PV1/PV2 rulings; (b) PR #441's deposit-lane mirror is **byte-exact** against the current origin/main
defs save the two sanctioned injections, with admin_approve_paid correctly omitted. Non-blocking
items are ops/hardening/cosmetic and routed below. Merge decision is the orchestrator's; #441 is
owner-escalated (sealed lane); the §9a self-merge for #437/#439 awaits my APPROVE **and** the
investigator GREEN.

**Routed (non-blocking):**
- NB-437-1 → brew-ops/owner: seed `payout_fee_percent` bump is live-applied on deploy (deposit-inert).
- NB-437-2 → next-dev: optional mark_success `client_wallet_missing` RAISE for fail-closed symmetry.
- NB-441-1 → owner + next-investigator: confirm the sealed deposit-lane profile pick is unchanged
  by the `, id` tiebreaker on the live substrate.
- NB-439-1 → next-tester: bump `_spec-payout.ts` header version stamp v1 → v2.
