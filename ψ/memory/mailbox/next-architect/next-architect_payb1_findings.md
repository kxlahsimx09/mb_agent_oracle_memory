# next-architect — PAYOUT slice-1 contract rulings (campaign payb1) — findings

**Role/slot:** next-architect (campaign payb1). Ruling on the contract questions routed from
next-dev's PAYOUT slice-1 build (**PR #437**, branch `build/payout-slice1`).
**Inputs:** `next-dev_payb1_findings.md §5` (Q1–Q4) + orchestrator/next-tester cross-check (C1).
**Method:** every premise verified against `origin/main` (`f30daac`) + PR #437's branch — the
cited migration/RPC bodies were read directly, and grounded in the ratified ADR text
(§ADR-10 AM2/PW2/RM1-RM2/R1 · §ADR-4a §Amendment 2026-06-04 SM1/SM2/SM2-SPLIT · §ADR-13 F2 · §ADR-9).
**Authority posture:** Q1+Q2 are ruled by **completing the enforcement of an already-ratified
invariant** (RM1 ledger-balance + the global-singleton MDR model) — NOT by changing any money
decision (RM2/R1 unchanged). This parallels the 2026-06-12 livegate `admin_approve_paid`
corrective (#436), which was likewise "within architect authority — completes the call-site
enumeration of an already-ratified rule." One arch PR records PV1 (Q2) + PV2 (Q1) as a §ADR-10
corrective, off `origin/main`, **DO NOT MERGE** (owner merges arch). Q3/Q4/C1 are answered by
existing ratified/SPEC text + deployed-substrate parity and need **no** ADR amendment.

---

## Verified substrate facts (file:line)

| # | Fact | Evidence |
|---|---|---|
| F1 | `client` has **no** `mdr_profile_id` / per-client MDR binding | `20260510000001_schema_floor.sql:20-26` + all client ALTERs |
| F2 | `mdr_profile` = `{id,name,deposit_fee_percent,payout_fee_percent,created_at}`; **no** `tier/band/client_id` discriminator | `20260510000001_schema_floor.sql:67-73` |
| F3 | Both lanes pick `mdr_profile ORDER BY created_at LIMIT 1` (no tiebreaker) | deposit `20260603000010:160`; payout `20260612000100:168-169` |
| F4 | Share formula = `round(amount × percentage/100,2)` (gross-based), residual = `fee − Σ shares` — **identical** deposit↔payout | deposit `20260603000002:299/302`; payout `20260612000110:122/125` |
| F5 | **No** CHECK/trigger enforcing `Σ partner-pct ≤ fee_pct`; only `percentage ≥ 0` | `20260510000001_schema_floor.sql:78` |
| F6 | Seed: tier-small `deposit_fee 1.80 / payout_fee 0.30`, partners `0.6+0.4=1.00`. Deposit: 1.00 ≤ 1.80 ✓. Payout: 1.00 **> 0.30** ✗ (all three tiers overflow their payout fee) | `20260510000008_seed_bootstrap.sql:37-56` |
| F7 | Neither `ts_payouts` nor `ts_deposits` has the F2 creator triple (`created_by_{type,id,username}`); both have only the `last_admin_action_*` denorm | `20260519000001_adr13_d2_audit_log.sql:77-87` |
| F8 | `claim_withdrawal_items` writes `withdrawal_queue.status='claimed'` + `ts_payouts.status='processing'` | `20260520000002:88` (queue→claimed) / `:92` (payout→processing) |
| F9 | `create_payout` freeze/settle base = `gross_debit = amount + fee` (NOT `final_amount`); `final_amount = amount − fee` is a stored col; callback carries `amount`+`fee` | `20260612000100:170-171,203,213`; `20260612000110:63,91-92,182-184` |

---

## Q1 — `create_payout` global-oldest profile selection (non-deterministic) — RULED

**Premise (verified):** `create_payout` (and `create_deposit`) selects `mdr_profile ORDER BY
created_at LIMIT 1` with **no tiebreaker** (F3). The 3 seed profiles are inserted in one multi-row
`VALUES` (single `now()`) → tied `created_at` → arbitrary pick → non-deterministic fee **and**
partner set. PW2 makes the partner SET money-load-bearing. There is **no** `client.mdr_profile_id`
and **no** tier/band discriminator (F1, F2) — so no per-client model exists in the substrate.

**Ruling:** the ratified substrate is a **global-singleton MDR profile** model, *not* per-client and
*not* tiered. The "tier-small/medium/large" seed names are **fixture decoration — nothing reads a
tier.** The Phase-1 contract is therefore a SINGLE global profile; the non-determinism the dev flagged
is a **fixture defect** (seeding three tied-`created_at` profiles into a single-profile model against a
selector with no tiebreaker), not an RPC contract defect.
- **Determinism fix (within authority, no money change, both lanes):** add a stable tiebreaker —
  `ORDER BY created_at, id LIMIT 1` — so a multi-profile substrate can never pick non-deterministically.
- **Phase-1 disposition (NON-BLOCKING, mirrors the deposit seal's non-blocking obs #1):** keep
  global-singleton; the payout probe substrate seeds **one applicable profile** (or accepts the
  tiebreaker-stable pick). Not a PR #437 merge blocker.
- **Phase-2 driver (NAMED follow-up):** per-client / tiered selection (`client.mdr_profile_id` FK or a
  tier-band lookup) is a **product + schema** decision (which client maps to which profile), touching
  BOTH lanes symmetrically. Out of this slice → opened as a story.

**What changes in PR #437:** add the deterministic tiebreaker to `create_payout` (3-line, mirror in
`create_deposit`); the payout probe fixture seeds a single applicable profile. RPC body otherwise unchanged.
**Deposit re-open?** No. The tiebreaker is **inert on a single-profile substrate** (the sealed deposit
substrate) — it removes latent non-determinism only if multiple profiles ever coexist. Deposit seal stands.

---

## Q2 — partner-% vs fee over-distribution (negative residual / over-credit) — RULED

**Premise (verified):** the PW2/RM template computes `share = round(amount × partner.percentage/100, 2)`
and `residual = payout_fee − Σ shares` (F4). The payout seed partners sum to `1.00%` against a
`payout_fee_percent` of `0.30%` (F6) → `Σ shares > fee` → `residual < 0` → no residual credit →
partners credited MORE than the fee debited; conservation `fee = Σ shares + residual` breaks. No DB
guard exists (F5). The dev faithfully mirrored the **epic-sealed** deposit template (F4 identical).

**Ruling — the PW2 template is CORRECT and is RE-AFFIRMED, not changed.** §ADR-10 §Amendment
2026-06-04 **PW2** (adr.md L2931): *"The payout fee is gateway margin; the **MDR shares are carved
from it** per the profile"* — "it" = the fee. This describes the **economics** (partner shares come out
of the fee pool; the leftover `fee − Σ shares` is the platform residual routed to `is_owner`/`mdr_owner`
per RM2/R1), realized via **gross-percentages constrained so that `Σ active-partner.percentage ≤
fee_percent`.** That is exactly what the sealed deposit lane does (F6: `1.00 ≤ 1.80` → residual ≥ 0).
The shares are **NOT** to be re-based onto the fee (`fee × pct`) — that would change the partner
economics and contradict the sealed deposit lane (re-opening its seal). So:
- **The conservation equation `payout_fee = Σ credited + residual` (residual ≥ 0) STANDS, unchanged.**
- **An over-allocated profile (`Σ partner-pct > fee_pct`) is an INVALID configuration — a config-domain
  defect, NOT an equation re-open.** It "makes the books not balance" (partners over-credited), which
  **RM1** (adr.md L2905) forbids: *"never left to make the books not balance."* The payout seed is simply
  invalid (it asks partners to be paid more than the fee collected).

**Two enforcement legs owed (both within architect authority — RM1 is ratified; this completes its
enforcement, the #436 pattern):**
1. **Fail-closed at fan-out (money-safety backstop, BOTH lanes):** when `residual < 0` after the loop,
   the success settle / deposit finalize MUST `RAISE` and roll back the whole txn — symmetric to the
   existing missing-residual-wallet fail-close (`mark_success` L155-161). A settle may **never**
   over-credit partners beyond the collected fee. **Inert on valid configs** (`residual ≥ 0`).
   Call sites: `mark_success` (payout), `finalize_deposit` + `admin_approve_paid` (deposit).
2. **Validate at config-write (primary fix):** the `mdr_profile` / `mdr_profile_partners` write path
   MUST reject a profile whose active partners' percentages sum above the relevant fee percent
   (`payout_fee_percent` for payout fan-out, `deposit_fee_percent` for inflow). No guard exists today (F5).

**What changes in PR #437:** the RPC fan-out template is correct as-built — **keep it.** The payout
**probe fixture/seed** must use partner percentages summing ≤ `payout_fee_percent` (the dev's dev-1
smoke already bumped the fee to demonstrate the residual leg cleanly — that confirms the fix). The
fail-closed `residual < 0` RAISE **should land in PR #437** (≈3-line guard, money-load-bearing, inert
on valid configs). The config-write validation is a separate follow-up (both fee axes).
**Deposit re-open?** **CONFIG-DOMAIN-ONLY for the sealed GREEN.** The deposit seal's valid configs
(`Σ=1.00 ≤ 1.80` → residual ≥ 0) keep the equation true; the fail-closed guard **never fires** on them
and is non-regressive, so it does NOT re-open or invalidate the DEPOSIT seal. (Independent of the #436
`admin_approve_paid` residual-omission BUG, which remains the DEPOSIT L5 blocker on its own grounds.)
**CONTRACT delta for next-tester (SPEC re-broadcast):** the conservation equation is **unchanged**
(`payout_fee = Σ credited + residual`, `residual ≥ 0`); the NEW clause is that an **over-allocated
profile is invalid and the settle FAIL-CLOSES (RAISE + rollback) rather than over-crediting.** Probes:
keep the conservation assertion on valid configs; add an over-config fail-close probe if exercising that path.

---

## Q3 — §ADR-13 F2 create-time actor triple on `ts_payouts` — RULED: `client_id` suffices Phase-1

**Premise (verified):** `ts_payouts` has no `created_by_{type,id,username}` columns; the gateway
assertion (GW4) carries only `sub` (the client id), no username (F7). PAYOUT-001's "create-time actor
triple, type `client`" AC is not structurally satisfiable today.

**Ruling:** **`client_id` suffices for Phase-1**, with a NAMED Phase-2 column-add. Grounds:
1. **Parity with the just-sealed deposit lane (dispositive).** `ts_deposits` has **no** F2 creator triple
   either (F7) — it carries only the `last_admin_action_*` denorm — and the DEPOSIT epic was sealed
   today on that basis. Requiring the triple **now** on `ts_payouts` would hold the payout lane to a
   *stricter* bar than the deposit lane sealed hours earlier. The F2 triple is uniformly deferred across
   BOTH money-row lanes; it must land together (parity) or block neither in Phase-1.
2. **The create-time actor on a client-initiated payout is unambiguous.** It is always `type='client'`,
   `id = client_id` (the verified `sub`). Unlike the multi-actor surfaces where F2's triple was actually
   built out — the slip-upload actor matrix `slip_uploaded_by_*` (§ADR-4d H2) and admin-action denorm —
   the create row has exactly one possible actor class, so the triple is denormalization, not new
   information, at create time.
3. **The username is unavailable to write.** GW4 carries only `sub`; building the column now yields
   `id` + NULL username + `type='client'` — exactly what `client_id` already conveys. The triple adds
   nothing until the assertion carries a username (an auth-lane change).

**Phase-2 follow-up (NAMED):** add the F2 create-time triple `created_by_{type,id,username}` to
`ts_payouts` **and** `ts_deposits` together (parity), gated on the gateway assertion carrying a username
(or accepting `type='client'` + `id` + NULL username). **Not owed now; not a slice blocker.** The SPEC
§2.3 already hedges this correctly. No ADR amendment (F2's pattern is "application-time, applied where
multi-actor disambiguation is needed"; the single-actor create row is faithfully met by `client_id`).

---

## Q4 — `final_amount` semantic — RULED: display/parity column only, production-parity confirmed

**Premise (verified):** `create_payout` stores `final_amount = amount − fee` while freezing
`amount + fee`; PAYOUT-001 prose says "`amount` = what the destination receives."

**Ruling — already answered by the ratified SPEC + §ADR-10 AM2 + the deployed code; no amendment.**
- The destination receives **`amount`**; the client bears **`amount + fee`** (fee on top) — production parity.
  Verified in code: `v_total_debit := p_amount + v_fee` (`20260612000100:171`); freeze
  `frozen + v_total_debit` (L213); settle `balance -= v_total`, `frozen -= v_total`
  (`20260612000110:91-92`); callback carries `amount = v_payout.amount` + `fee = payout_fee` (L182-184).
- The freeze/settle base is **`gross_debit = amount + fee`**, **NOT** `final_amount`. SPEC §0 already
  states this verbatim: *"final_amount = amount − payout_fee (preserved current-system column semantic;
  it is a stored column, **NOT the freeze base**)."* SPEC §2.3 lists it as a stored observable column.
- **`final_amount = amount − fee` is a preserved current-system stored column — display/parity only,
  zero money effect.** It is neither frozen, settled, nor sent as the callback amount. The dev's
  preservation is correct.
- *(Non-blocking Phase-2 nicety:* the column name reads like "what's paid out" while the payee actually
  gets `amount`; a doc/deprecation note could reduce confusion. Not required.)*

---

## C1 — SPEC SM1 self-consistency (orchestrator/next-tester cross-check) — RULED: option (a)

**Premise (verified):** SPEC §1 SM1 pins the canonical state set on **both** `ts_payouts.status`
AND `withdrawal_queue.status` with "no-claimed-row-state" (citing ADR-4a SM1, adr.md L600-601);
yet SPEC §3.1 claim-observable says claim sets `withdrawal_queue.status='claimed'`. Both cannot hold.

**Ruling — option (a): the queue keeps a `claimed` work-state while the canonical payout status is
`processing`.** Grounded empirically + in the ADR text:
- **ADR text (L600-601):** SM1 drops `claimed` from **"the *payout's* status set"** — i.e.
  `ts_payouts.status` only ("the Decision #4 claim flips `pending → processing` directly"). It says
  **nothing** about `withdrawal_queue`. SM2/SM3 lock-and-**assert** on `ts_payouts.status` (the queue
  is locked for ordering, not asserted as the canonical state).
- **Deployed substrate (F8):** `claim_withdrawal_items` writes `withdrawal_queue.status='claimed'`
  (L88) and `ts_payouts.status='processing'` (L92); the `withdrawal_queue` status CHECK retains
  `claimed`, and the hosted assertions count `status IN ('pending','claimed','processing')`. The
  `withdrawal_queue` is the §ADR-8 bot-dispatch work-lane with its own vocabulary (incl. `claimed`/`batch_id`).
- **Therefore SPEC §3.1 is CORRECT** (claim → `withdrawal_queue.status='claimed'` + `batch_id`;
  `ts_payouts.status → processing`). **SPEC §1 SM1's wording over-reached** by binding "no-claimed" to
  the queue and must narrow: the canonical SM1 set binds **`ts_payouts.status` only**; the
  `withdrawal_queue.status` mirrors the terminal values but additionally carries the `claimed` work-state.
- Severity LOW (observable surface, not money). **SPEC edit is next-dev's** (contract owner): drop the
  "AND `withdrawal_queue.status`" from the SM1 canonical-set line; keep §3.1 as-is. The tester's
  create-time fact ("queue row is `pending` at create", §2.3) is unaffected and correct; the
  claim-time queue observable can now bind to `claimed`.

---

## §ADR-10 corrective (arch PR — DO NOT MERGE; owner merges arch)

A single arch PR off `origin/main` records the two money-load-bearing rulings as a §ADR-10
**§Corrective 2026-06-12 (campaign payb1)** — within architect authority, no money decision:
- **PV1 (Q2):** PW2 template re-affirmed (carved-from-fee via gross-pct constrained `Σ ≤ fee_pct`);
  over-config = invalid profile; fail-closed `residual < 0` RAISE (both lanes) + config-write validation
  directive; deposit seal NOT re-opened (inert on valid configs).
- **PV2 (Q1):** MDR-profile selection is global-singleton Phase-1; deterministic tiebreaker
  (`created_at, id`) both lanes; per-client/tiered = named Phase-2 driver; deposit not re-opened.

Q3, Q4, C1 need **no** ADR change (existing ratified/SPEC text + deployed-substrate parity answer them).

---

## Routed implementation consequences (named — next-dev, campaign payb1, idle pending this ruling)

**Gating PR #437 (before cross-stack deploy + VERIFY):**
1. **(Q2)** Payout probe fixture/seed: partner percentages summing ≤ `payout_fee_percent` (a
   payout-valid profile). The base seed `20260510000008` partners (Σ=1.00%) are valid for the deposit
   fee (1.80%) but invalid for the payout fees (0.20–0.30%).
2. **(Q2)** Add fail-closed `IF v_residual < 0 THEN RAISE` to `mark_success` (rolls back the settle) —
   should land in PR #437 (money-load-bearing, inert on valid configs).
3. **(Q1)** Add deterministic tiebreaker `ORDER BY created_at, id LIMIT 1` to `create_payout`.

**Both-lanes fast-follow (deposit parity, non-regressive):**
4. **(Q2)** Mirror the fail-closed `residual < 0` RAISE into `finalize_deposit` + `admin_approve_paid`
   (defense-in-depth; inert on the sealed configs → does not re-open the deposit seal).
5. **(Q1)** Mirror the deterministic tiebreaker into `create_deposit`.

**Follow-up stories (out of this slice):**
6. **(Q2)** `mdr_profile` / `mdr_profile_partners` config-write validation: `Σ active-partner-pct ≤
   fee_percent` (both `payout_fee_percent` and `deposit_fee_percent`).
7. **(Q1)** Phase-2 per-client / tiered MDR-profile selection (`client.mdr_profile_id` or tier-band).
8. **(Q3)** Phase-2 F2 create-time actor triple on `ts_payouts` + `ts_deposits` (parity), gated on the
   gateway assertion carrying a username.

**SPEC edits (next-dev as contract owner):**
9. **(C1)** SM1 canonical-set line: narrow to `ts_payouts.status` only (drop "AND `withdrawal_queue.status`").
10. **(Q2)** §3.2 conservation clause: add the over-config fail-close (residual ≥ 0 invariant; settle
    RAISEs on an over-allocated profile) — re-broadcast via the orchestrator (Q2 moves the contract).

**next-tester (campaign payb1t):** conservation equation STANDS (`payout_fee = Σ credited + residual`,
`residual ≥ 0`); add the over-config fail-close probe; C1 → bind §3.1 claim observable to
`withdrawal_queue.status='claimed'` + `ts_payouts.status='processing'`.

---

## Q2 ROUNDING COROLLARY (PV1-R) — RULED — option (d) primary; the residual<0 guard is correct as-landed; share computation does NOT change

**New facts (orchestrator, dpay PROD read-only census):** prod models the platform cut as an explicit
partner **"Owner MDR"** (zero-headroom: `Σ all-partner-pct = fee_pct` exactly), and computes every
share — Owner MDR included — independently as `round(amount × pct/100, 2)` HALF-UP with no remainder
adjustment. Result: **18,659 / ~2.3M** `mdr_shared` records over-distribute by exactly 0.01 (prod
silently leaks a satang ~1-in-125 multi-partner). The concern: does the `residual < 0` RAISE I
sanctioned (PV1 leg 1) fire on the SYMPTOM — unable to tell an illegal over-allocation from rounding
noise on a *legal* zero-headroom config?

**Verified premises (this ruling):**
- **next-system is Model A (residual-remainder), NOT prod's Model B (platform-as-rounded-partner).**
  The MERGED `mark_success` (`20260612000110:113,125,160,166`) computes `v_residual := payout_fee`,
  subtracts each *credited* partner share, then `IF v_residual < 0 RAISE 'mdr_over_allocated'` /
  `IF v_residual > 0 credit mdr_owner`. So `residual = fee − Σ(credited shares)` is the **remainder**,
  credited as-is (never re-rounded). **This is already option (a) for the owner/residual leg** —
  conservation is EXACT by construction whenever `residual ≥ 0`. Prod's satang-leak does **not**
  survive into next: where prod independently rounds Owner MDR up by a satang, next gives the residual
  wallet a satang *less* and conserves exactly. **Next is strictly more correct than prod.**
- **Census (37 distinct prod configs):** headroom (`fee_pct − Σ non-Owner-MDR partner pct`) buckets —
  **`< 0`: 0** (no config is over-allocated by real partners alone) · **`== 0`: 2** (both are dev/demo
  profiles — "Dev 1.9%", "Demo Day" — with **no** Owner MDR partner) · **`> 0`: 35** (all production).
  Exactly 0-or-1 Owner MDR per config (no double-leg). Among the 18,660 over-by-satang records, the
  **Owner MDR share is never < 1.22** (min 1.22, avg 11.88) — ≥122× the 0.01 drift.

**Ruling:**
1. **Primary = option (d): the prod→next config migration MAPS prod's "Owner MDR" explicit partner into
   next's RESIDUAL model — strip the Owner-MDR partner row; its cut becomes the residual routed to the
   single `is_owner`/`mdr_owner` wallet — EXCLUSIVELY (no partner row *and* residual = no double-count).**
   This is not a new decision — it is the faithful migration of the ratified §ADR-10 D1 / RM2 / R1 +
   WO1 model (the platform IS the single residual holder, not a fan-out partner). After (d), every
   production config carries headroom = the former Owner-MDR cut (≥ 1.22 in every observed over-drift
   case), so `residual ≥ 0` holds with enormous margin and the guard fires **only** on genuine
   over-allocation — exactly PV1's intent.
2. **The `residual < 0` RAISE (landed in #437, mirrored in #441) is CORRECT AS-LANDED and is the right
   backstop.** Empirically it is INERT across all 35 production configs (Owner-MDR headroom ≥ 1.22 ≫
   0.01 drift) and across the current next-substrate seeds (headroom by construction). The
   orchestrator's "~0.8% would fail-close on a satang" assumed real profiles migrate in zero-headroom
   *Model-B* shape — option (d) prevents that: in Model A the satang never occurs, so there is nothing
   to tolerate. The discriminator concern dissolves: **in production, `residual < 0` ⟺ genuine
   over-allocation** (no legal zero-headroom production config exists).
3. **REJECT (b) tolerance-band** — it re-introduces prod's silent satang over-distribution and masks
   small genuine over-allocations; it weakens RM1's exactness for zero benefit once (d) holds.
   **REJECT (c) banker's rounding** — does not eliminate the drift (orchestrator-noted) and perturbs
   partner parity. Neither is needed.
4. **The share COMPUTATION does NOT change.** Half-up partner shares + residual-remainder + the
   `residual < 0` backstop are correct. What is owed is the **migration mapping (d)** + the
   **config-write validation** (PV1 leg 2: `Σ active-real-partner-pct ≤ fee_pct`, both fee axes).
5. **Zero-headroom edge (the 2 dev/demo configs only):** a config where real partners tile the fee with
   NO platform cut (`Σ real-pct = fee_pct`) has no residual to absorb drift → a 0.01 overshoot would
   RAISE. This is **dev-only today** (no production config). Minimal gate: the config-validation
   additionally flags zero-headroom profiles as ineligible for the residual path (or a Phase-2
   "final-partner absorbs the sub-satang" last-adjust). **NOT required for production; Phase-2 / config-guard.**
6. **Representation drift flagged to the migration owner (non-blocking):** the residual wallet is
   `owner_type='mdr_owner'` in the deployed code, `owner_type=partner, is_owner=true` per WO1
   (§ADR-10 §Amendment 2026-06-07), and `partner_name="Owner MDR"` (no `is_owner` flag, no `owner_type`)
   in prod. The migration must pin ONE unambiguous residual-wallet target and reconcile this before
   mapping (so Owner MDR routes to exactly one residual leg). Out of scope here; named for the migration story.

**#441 merge-gate:** **PROCEED — does NOT wait for this corollary.** #441's `residual < 0` guard +
tiebreaker is the correct, non-regressive deposit-lane mirror; it is inert on every current
next-substrate config (verified: all 35 prod-shaped + the seeded configs have headroom; the guard
cannot fire on them). This corollary gates the **prod-config MIGRATION** (option d + headroom
validation + the dev-config zero-headroom guard), NOT the guard PR. #441 follows its own reviewer +
owner-merge cadence.

**#440 amendment:** YES — PV1-R appended to the §ADR-10 corrective (residual-model reframe + option (d)
mapping + reject (b)/(c) + the empirical verification + the dev-config edge + representation-drift flag).

**Named dev follow-up (NOT a computation change):**
- **MDR config migration (new story):** map prod "Owner MDR" partner → next single residual wallet
  (option d, exclusive); reconcile the residual-wallet representation (mdr_owner vs partner+is_owner)
  first; assert one platform leg (no double-count).
- **Config-write validation (PV1 leg 2, refined):** `Σ active-real-partner-pct ≤ fee_pct` per fee axis;
  flag zero-headroom (`= fee_pct`, no platform cut) profiles as ineligible for the residual path (or
  carry the Phase-2 last-adjust).
- **No change to `mark_success` / `finalize_deposit` / `admin_approve_paid` share math** — the merged
  computation + `residual < 0` backstop stand.
