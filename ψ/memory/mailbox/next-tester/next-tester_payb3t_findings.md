# next-tester — PAYOUT cancel-sweeps slice-3 probe build (campaign payb3t)

> **Role / de-bias:** Step-1 PARALLEL probe build (build-workflow.md). Probes bind **EXCLUSIVELY** to
> the broadcast SPEC contract `origin/build/payout-slice3 : docs/spec/payout-cancel-sweeps-slice.md`
> (**v1, 2026-06-13**), read via `git show` — **the contract, never next-dev's `supabase/` code**
> (layer-1 de-bias, never violated; the sibling `…wt-c-payb3` build worktree was NOT read). It
> **EXTENDS** slice-1 (`payout-core-lifecycle-slice.md`, money model §0 + state machine §1) and slice-2
> (`payout-review-cancel-slice.md` **§4**, the shared `cancel_stale_payout` bundle) — both read first;
> not restated. Expected behaviour is derived from the SPEC + the ratified epic/ADR text it cites
> (epic-payout PAYOUT-008/010; §ADR-4a §Amendment 2026-05-15 PA1/PA3/PA5 + **PA7** (per-bank
> maintenance, ratified 2026-05-26 thread #229) + §Amendment 2026-05-18 LO1 + thread-#128
> never-auto-fail; §ADR-9 cancelled-codes + Bundle TS2 + CS1; §ADR-10 AM2/AM3/AM4/AM5; §ADR-20
> T1/T2/T4/T5).
>
> **Status: ✅ VERIFIED GREEN on the tester stack (yupsev, 2026-06-13).** Substrate deployed (brew-ops,
> 7/7 items on BOTH stacks: migrations …000160/…000170, `sweep_stale_payouts` new sig w/ flag-gate-first
> + service-role grant, `sweep_payouts_bank_maintenance` always-ON, both crons active, flag=`false` +
> knob=`15` seeded, 3 active banks NULL windows). Suite ran push-button → **GREEN 39/39, all 6 lanes**
> (git_sha `56f62b9`, evidence `evidence/integration-run-payout-cs-1781286938959-56f62b9e.json`). The
> first run surfaced ONE probe-side staging RED (the unrouted Mode-1 fixture — fixed + re-run GREEN; see
> §7); the substrate was correct throughout. Offline self-check `payout-selfcheck.ts` **78/78** (50
> carried + **28 new `cs_`**) gates every run; `bun build` graph clean; `tsc --noEmit --strict` 0 errors.
>
> **Branch / PR:** `test/payb3-probes` off `origin/main` — **PR #458**. **Test-only — DO NOT MERGE** until
> the gates clear (no `supabase/` code touched; harness + docs only).

---

## 0. What was built

```
tests/integration/probes/payout/         (NEW _cs modules sit alongside the merged slice-1 + slice-2 suites)
  _spec-cs.ts        slice-3 SPEC binding (sweep_stale_payouts / sweep_payouts_bank_maintenance,
                     cancel_stale_payout (shared), _bank_in_maintenance, flag+knob, bank-window cols,
                     cancel-code matrix, legalSource, cron names, AC quotes — §5.7 exact param lists)
  _assert-cs.ts      NEW pure predicates (agePastTimeout, autoCancelTarget [flag-gated], bankInMaintenance
                     [NULL/zero-len/normal/wrap/boundary], maintenanceCancelTarget [unrouted SKIP],
                     cancelCodeCorrect / codesNeverCrossed, idempotentResweep, isLegalSourceCs,
                     untouchedAndFrozenHeld) — reuses unfreezeApplied/exactlyN/exactlyOneWinner/am5Holds/benignNoOp
  _flow-cs.ts        TRANSPORT (both sweep RPCs, cancel_stale_payout, _bank_in_maintenance cross-check,
                     flag/knob readers, app_settings get/set, bank-window setter + bank resolution,
                     cancelled-callback reads + code extraction) — ALL service-role; NO EF/gotrue this slice
  _stage-cs.ts       per-age drive (backdate ts_payouts.created_at vs the virtual-clock anchor), per-bank
                     routing drive (re-route / NULL required_bank_account_id), BKK time-of-day helpers
  p008-autocancel.ts PAYOUT-008 per-age sweep — 7 assertions
  p010-maintenance.ts PAYOUT-010 per-bank maintenance sweep — 8 assertions
  cs-bundle.ts       shared-bundle properties (3-code matrix / cancel-vs-claim race / idempotent re-sweep) — 3
  am5-cs.ts          AM5 walk across create→auto-cancel + create→maintenance-cancel — 2
  sm3-cs.ts          SM3 extension for the shared bundle's CAS (pending-only) + illegal-source matrix — 2
  readiness-cs.ts    Lane-0 slice-3 stack-readiness gate — 17 gates
tests/integration/run-payout-cs.ts        NEW runner (reset+clock → readiness → money lanes; evidence JSON)
tests/integration/payout-selfcheck.ts     EXTENDED (+28 cs_ meta-assertions; reuses slice-1/2 plumbing)
```

**Reuse (house style, GOAL-directed):** the merged slice-1 helpers `_spec-payout / _assert-payout /
_flow-payout / _stage-payout` and the slice-2 `_assert-rc` (unfreezeApplied/exactlyN/exactlyOneWinner)
are imported as-is — prior tester artifacts on `main`. The `_cs` siblings **ADD** the slice-3 surface
without mutating the slice-1/2 files (keeps their bijections + green runs intact). The only edit to a
prior file is the **additive** `payout-selfcheck.ts` extension. *(`_flow-cs` deliberately re-implements
its own `getAppSetting`/`setAppSetting`/`cancelledCallbackRows` rather than importing the slice-2
`_flow-rc`, so slice-3 has zero coupling to the slice-2 admin-auth module — there is no admin EF here.)*

**Harness validation (offline, stack-bare):** `bun tests/integration/payout-selfcheck.ts` → **78/78**.
Every NEW predicate is proven **GREEN on a valid input AND RED on a deliberately-violated one** — the
load-bearing safety cases the GOAL named:
- **flag-OFF-still-cancels → RED** (`autoCancelTarget({flagOn:false,…,agedPast:true})` must be `pending`,
  not `cancelled` — PA1 fail-closed; a money op never runs on an unconfirmed flag);
- **wrong-code-cross → RED** (`cancelCodeCorrect('auto','bank_maintenance')` is false; `codesNeverCrossed`
  rejects a crossed matrix);
- **unrouted-cancelled → RED** (`maintenanceCancelTarget({routed:false,inWindow:true})` must be `pending` —
  the deliberate §3.2 skip);
- **claimed-swept → RED** (`autoCancelTarget`/`maintenanceCancelTarget` with `source:'processing'` must be
  unchanged — pending-only / never-auto-X);
- per-age boundary is **relative + inclusive** to the knob and **tracks a changed knob**;
- `bankInMaintenance` discriminates NULL / zero-length / normal `[start,end)` / overnight-wrap / the
  start-inclusive + end-exclusive edges;
- `idempotentResweep` rejects a 2nd callback or a 2nd unfreeze on the second tick.

---

## 1. Probe → AC bijection

Every `ok(...)` row carries the verbatim SPEC clause it binds (the `:: …` quote tail in the detail
string). Coverage is **per the SPEC's AC surface (GOAL minimum)**; nothing is invented beyond it.

### PAYOUT-008 — per-age auto-cancel (SPEC §2.3)  — `p008-autocancel.ts`

| AC (SPEC §2.3) | probe assertion |
|---|---|
| **AC#2** flag OFF (shipped default) = structural no-op even FAR past the timeout (drive the clock way past; zero transitions, zero callbacks, freeze intact); **AC#2 second half** flip ON ⇒ the SAME fixture cancels (the flag is the only difference) | `p008.autocancel_a_flag_off_structural_noop_even_far_past` + `p008.autocancel_b_flag_on_cancels_same_fixture_auto_cancelled` |
| **AC#1** flag ON + at/after the timeout ⇒ cancelled: AM2/AM4 unfreeze (frozen −= amount+fee, **balance untouched**), one `payout_unfreeze`, queue cancelled, **exactly one** `payout.cancelled` code `auto_cancelled`; AM5 | `p008.autocancel_b_flag_on_cancels_same_fixture_auto_cancelled` |
| **AC#3** threshold boundary RELATIVE to the knob (older cancels, younger stays); re-run after CHANGING the knob proves config-tracking | `p008.autocancel_c_threshold_split_relative_to_knob` + `p008.autocancel_d_threshold_tracks_changed_knob` |
| **AC#4** virtual-clock drivable (a fresh-at-anchor row cancels only after `clock_advance` crosses the boundary, not by waiting real time) | `p008.autocancel_e_virtual_clock_drives_boundary` |
| **AC#5** pending-only / never-auto-X (claimed/processing/review/terminal ancient + flag ON ⇒ never swept) | `p008.autocancel_f_pending_only_never_auto_x` |
| **GOAL** flag flip OFF mid-life = no further cancels | `p008.autocancel_g_flag_flip_off_midlife_no_further_cancels` |

### PAYOUT-010 — per-bank maintenance cancel (SPEC §3.4)  — `p010-maintenance.ts`

| AC (SPEC §3.4 / §3.2) | probe assertion |
|---|---|
| **AC#1** assigned (active) bank inside `[start,end)` ⇒ cancelled: unfreeze frozen-only (balance untouched), queue cancelled, **exactly one** `payout.cancelled` code `bank_maintenance`; AM5 | `p010.maintenance_a_assigned_bank_in_window_cancels_bank_maintenance` |
| **AC#2** ALWAYS-ON / NOT flag-gated: cancels with the 008 flag OFF; flip the flag ON ⇒ code is STILL `bank_maintenance` (codes never crossed) | `p010.maintenance_a` (flag OFF) + `p010.maintenance_b_unconditional_not_flag_gated_code_never_crossed` (flag ON) |
| **AC#3** bank NOT in a window ⇒ survives (window NULL · `app_now()` BKK outside · zero-length `start=end`) | `p010.maintenance_c_bank_not_in_window_survives` (all three shapes) |
| **AC#4 / §3.2** UNROUTED (`required_bank_account_id IS NULL`) ⇒ SKIP, regardless of any bank's window | `p010.maintenance_d_unrouted_skipped` |
| **GOAL** per-bank isolation (A in maintenance cancels only A-assigned; B-assigned survive) | `p010.maintenance_e_per_bank_isolation` *(needs ≥2 active banks — see §2 fixture note)* |
| **AC#5** pending-only / never-auto-X (claimed/processing/review/terminal on a bank in maintenance ⇒ never swept) | `p010.maintenance_f_pending_only_never_auto_x` |
| **AC#6** overnight wrap (`start>end`, 20:00→08:00): cancel at 02:00 BKK (inside), survive at 12:00 (outside) | `p010.maintenance_g_overnight_wrap` |
| **AC#1 [start,end)** window boundary: cancel at BKK==start (inclusive), survive at BKK==end (exclusive) | `p010.maintenance_h_window_boundary_entry_exit` |

### Shared bundle — both producers (SPEC §4)  — `cs-bundle.ts`, `sm3-cs.ts`

| GOAL / AC clause | probe assertion |
|---|---|
| **§4.2** 3-code matrix across `admin_cancelled` (slice-2 staging via `cancel_stale_payout(id,'admin_cancelled')`) / `auto_cancelled` (008 sweep) / `bank_maintenance` (010 sweep) — codes never crossed, each cancelled once | `cs.bundle_code_matrix_three_codes_never_crossed` |
| **§4.3** cancel-vs-claim lock-first-wins — a just-claimed payout SURVIVES a racing sweep tick (claim-first determinism + a genuine concurrent claim‖sweep = exactly one winner) | `cs.bundle_cancel_vs_claim_lock_first_wins` |
| **§2.3 AC#6 / §3.4 AC#7** idempotent re-sweep — second tick = zero second effect (proven for BOTH sweeps) | `cs.bundle_idempotent_resweep_zero_second_effect` |
| **SM3 extension** for the new sweep RPCs: `cancel_stale_payout` legal source = {pending} ONLY (CAS) + illegal-source `race_lost` benign no-op matrix | `sm3cs.legal_map_cancel_stale_payout_pending_only` + `sm3cs.cancel_stale_payout_illegal_sources_race_lost_benign_no_op` |

### Cross-cutting

| GOAL clause | probe |
|---|---|
| **AM5 walk** across create→auto-cancel and create→maintenance-cancel (cancel produced by the REAL sweeps) | `am5cs.autocancel_invariant_each_step`, `am5cs.maintenance_invariant_each_step` |

---

## 2. Stack-needs delta (PENDING-DEPLOY — for brew-ops/owner cross-stack deploy)

The slice-3 substrate must land on the **tester** stack before any money probe runs (Stack-readiness
gate). `readiness-cs.ts` (Lane-0) asserts all of this; on a bare stack it goes RED → money lanes report
**BLOCKED-ON-DEPLOY** and never run. Exact delta vs the slice-1/2 deploy:

**Edge Functions:** **NONE this slice.** Both producers are pg_cron-driven RPCs; probes call the RPCs
DIRECTLY via service-role. There is **no admin EF and no gotrue/aal2 actor** for slice 3 (unlike slice 2).

**RPCs (present, service-role-callable — bound to the §5.7 EXACT param lists):**
- `sweep_stale_payouts(p_batch_size int DEFAULT 500, p_now timestamptz DEFAULT NULL)` → `TABLE(payout_id uuid, outcome text)` — **D8 rewrite**: reads `COALESCE(p_now, app_now())` (NOT wall-clock `now()`), adds `p_now`, `SECURITY DEFINER` + `GRANT EXECUTE … TO service_role`, the old single-arg overload **dropped**. Flag-gate + fail-closed + knob preserved. *(migration …000160)*
- `sweep_payouts_bank_maintenance(p_batch_size int DEFAULT 500, p_now timestamptz DEFAULT NULL)` → `TABLE(payout_id uuid, outcome text)` — **D10 NEW**, ALWAYS-ON, reuses `_bank_in_maintenance` verbatim + `cancel_stale_payout(id,'bank_maintenance')`. *(migration …000170)*
- `cancel_stale_payout(p_payout_id uuid, p_failure_code text DEFAULT 'auto_cancelled')` → `text` — the shared bundle (REUSED, unchanged; migration …000005).
- `_bank_in_maintenance(p_start time, p_end time, p_now time)` → `boolean` — REUSED (migration …000010).
- `_payout_auto_cancel_enabled()` → `boolean` (PA1 fail-closed) and `_payout_pending_timeout_minutes()` → `int` (fail-safe 15) — REUSED (migration …000003).
- carried/required: `clock_set` / `clock_advance` / `clock_reset` / `app_now`, `reset_for_test`, `claim_withdrawal_items` (the cancel-vs-claim race), `payouts-create` EF (create staging).

**Tables / config seed:**
- `app_settings` rows: **`payout_auto_cancel_enabled`** (seeded `'false'` — the correct ships-OFF default; the probe flips it ON/OFF and restores) **and `payout_pending_timeout_minutes`** (default `'15'`). The rows must exist to set/restore (the readers fail-safe, but a missing flag row ⇒ the flip/restore is a no-op).
- `bank_account.maintenance_window_start` / `maintenance_window_end` (`time`, Bangkok time-of-day) columns present + `is_active` — the PAYOUT-010 source of truth (carried substrate migration …000010, generic `bank_account` columns).

**pg_cron jobs (SOFT — verify at deploy; not readable over PostgREST, and NOT a probe dependency since the probes drive the RPCs directly):**
- `sweep-stale-payouts` **re-pointed** to the new `(int,timestamptz)` signature.
- `sweep-payouts-bank-maintenance` **NEW** (≈1-min tick).

**Tester slot env (brew-ops provisioning):**
- `GATEWAY_ASSERTION_SIGNING_KEY` + `GATEWAY_ASSERTION_KID` (scope=payout GW4 keypair) — needed by the **create staging** (slice-1 dependency; every fixture payout is created through `payouts-create`).

**Fixture note (surfaced, not faked — both confirmed present on yupsev):**
- The **per-bank isolation** leg (`p010.maintenance_e`) needs **≥2 ACTIVE `bank_account` rows**
  (`resolveActiveBanks` picks a second bank `≠ fx.bankAccountId`; yupsev has 3 → GREEN). If only one,
  the assertion records **BLOCKED**, not a false pass.
- The **unrouted SKIP** leg (`p010.maintenance_d`) needs **≥1 `pool` row** — a faithful Mode-1 unrouted
  queue row is `required_bank_account_id IS NULL` **+ `pool_id` set** (the `withdrawal_queue` Mode-2↔Mode-1
  XOR requires the pool when the bank is nulled). `resolvePoolId` reads the seeded `pool` (yupsev:
  `66666666-…-001 main_pool` → GREEN). If no pool, the assertion records **BLOCKED**. *(This was the one
  probe-side fix the live run surfaced — see §7.)*

> **Do not run money probes against any stack until the owner signals stack-ready.** A bare stack is a
> BLOCKER I surface here, not a green and not an idle (build-workflow.md).

---

## 3. SPEC bindings — all PINNED by §5.7 (no flagged-pending RPC-param guessing this slice)

The suite is **BOUND** (`SPEC_CS_UNBOUND = false`). The slice-3 SPEC §5.7 gives the EXACT param lists up
front, so — unlike slice-2 v1 — there were **no `[SPEC-PENDING]` RPC-param guesses to route**. The only
**defensive** bindings (read defensively / surfaced, never silently invented), enumerated in
`SPEC_CS_PENDING_BINDINGS`:

1. **`bank_account.maintenance_window_start` / `maintenance_window_end`** column spelling — SPEC §0/§3.1
   names them (carried substrate migration …000010); the window-setter reads back `select=*` and the
   in-window probe asserts the columns are present + non-null (`windowColsPresent`). `readiness-cs R4`
   gates their presence — a rename surfaces as a RED gate, not a silent miss.
2. **`callback_queue` payout source-linkage** (`source_id = payout_id` OR `withdrawal_queue_id`) — carried
   from slice-1 `[SPEC-PENDING]`; cancelled-callback reads filter by `event` + a best-effort linkage and
   record which matched (identical to the slice-1/2 approach).
3. **pg_cron presence** — a deploy-readiness item not directly readable over PostgREST (cron schema);
   `readiness-cs R6` notes it SOFT. Probes drive the RPCs directly, so cron is not a probe dependency.

→ **Nothing routed to next-dev/next-architect on bindings.** If the live run surfaces a column/linkage
mismatch (as slice-2's `audit_log` rebind did), it will be a probe-side rebind reported here, code-blind.

---

## 4. Decisions (named, per GOAL)

- **New `_cs` sibling modules** rather than mutating the merged slice-1/2 helpers — keeps their
  bijections + verified-green runs untouched; the slice-3 binding block is self-contained and traceable
  to the slice-3 SPEC. Only `payout-selfcheck.ts` is edited (additive).
- **Runner = `run-payout-cs.ts`** (a NEW runner, per GOAL "or extend — your call") — keeps the slice-1/2
  push-button gates independent and lets the slice-3 lanes/evidence file stand alone.
- **Service-role-only, gotrue-INDEPENDENT** (the SPEC §5 reality): both producers are pg_cron RPCs with
  no EF, so there is **no admin/gotrue surface** this slice. The `admin_cancelled` leg of the code matrix
  drives `cancel_stale_payout(id,'admin_cancelled')` directly (no actor) — slice-2's admin EF/RPC is NOT
  imported. The only env dependency is the GW4 signing key for create staging.
- **Claim-path-independent staging** (the SPEC §5 drive): per-age = create then backdate
  `ts_payouts.created_at` relative to the frozen virtual-clock anchor; per-bank = create Mode-2 then
  re-route / NULL `withdrawal_queue.required_bank_account_id`. No reliance on the real fair-router/claim
  (out of slice).
- **PAYOUT-010 BKK time-of-day driven by the virtual clock**: Asia/Bangkok is UTC+7 (no DST), so the
  boundary/wrap legs `clock_set` to a computed UTC instant whose derived BKK time-of-day lands exactly on
  the window edges (`utcIsoForBkk`), crossing `[start,end)` deterministically without real time.
- **Per-leg cleanup in p010** (not just a finally sweep): the maintenance sweep batch-cancels ALL
  in-window pending rows on a bank, so a leftover survivor would cross-talk into a later in-window leg —
  each leg cleans its own payouts before the next.

---

## 5. Isolation / out-of-scope (per SPEC + GOAL)

- **PAYOUT-008 ↔ PAYOUT-010 isolation:** p008 only calls `sweep_stale_payouts`; p010 only calls
  `sweep_payouts_bank_maintenance`. The 008 flag defaults OFF in p010 (proving 010 is unconditional), and
  p010 never calls the per-age sweep — so neither producer contaminates the other's fixtures.
- **DRIFT-V (out of slice, routed to next-architect):** the `v_payouts`/`v_payouts_read`/`v_deposits`
  `effective_status` 0-lag view-clock residue (reads wall-clock `now()`) is **NOT** built/probed here —
  SPEC §0/§7 routes it to next-architect. Production behaviour is unaffected (`now()==app_now()` on a
  real clock); only virtual-clock test coherence of the 0-lag ACs is. Bound only as a quote (`C.quote.driftV`).
- **Out of scope (not probed):** PAYOUT-005 admin-cancel surface (slice 2 — this slice only SHARES its
  bundle), PAYOUT-004 sweep/reconcile (slice 2), PAYOUT-007/009/012/013, fair-router / bot-claim internals
  (seeded in fixtures), the dev `supabase/` code.
- **Crash-safe (SPEC §2.3 AC#6 / §3.4 AC#7):** a tick killed mid-batch is not black-box-injectable without
  reading/altering code (de-bias). The observable half — "no `payout.cancelled` lost or duplicated on
  re-run" — is covered by the **idempotent re-sweep** assertion (`cs.bundle_idempotent_resweep_*`); the
  mid-batch-kill leg is noted, not faked.

---

## 6. DONE-WHEN status

- [x] Probe suite authored (PAYOUT-008 + PAYOUT-010 + shared-bundle + AM5 walk + SM3 extension + readiness + runner)
- [x] Harness-validated offline (`payout-selfcheck.ts` **78/78**; `bun build` graph clean; `tsc --noEmit --strict` 0 errors)
- [x] Committed on `test/payb3-probes` off `origin/main`
- [x] Probe→AC bijection (§1) + stack-needs delta (§2) in this file
- [x] ONE PR open (test-only, **DO NOT MERGE** until gates clear) — **PR #458**
- [x] **VERIFY run GREEN on yupsev — 39/39, all 6 lanes (§7)**
- [ ] next-investigator L2 ground-truth falsification (own seal stack) → then review-gate → DONE (not mine)

---

## 7. VERIFY run (yupsev, 2026-06-13) — ✅ GREEN 39/39

`set -a; source .secrets/slots/tester.env; set +a; bun tests/integration/run-payout-cs.ts`
→ **GREEN, 39/39 passed**, git_sha `56f62b9`, evidence
`evidence/integration-run-payout-cs-1781286938959-56f62b9e.json`.

| lane | result |
|---|---|
| lane0-readiness | GREEN (17/17 — tables/RPCs/clock/flag/knob/bank-window cols; soft R6 cron note only) |
| lane1-autocancel | GREEN 7/7 (flag-OFF no-op far-past, flag-ON cancels same fixture `auto_cancelled`, threshold-relative-to-knob + tracks-changed-knob, virtual-clock, pending-only, flag-flip-OFF) |
| lane2-maintenance | GREEN 8/8 (in-window `bank_maintenance`, unconditional/not-flag-gated code-never-crossed, not-in-window survives ×3, unrouted SKIP, per-bank isolation, pending-only, overnight wrap, window boundary `[start,end)`) |
| lane3-bundle | GREEN 3/3 (3-code matrix never crossed, cancel-vs-claim lock-first-wins, idempotent re-sweep both sweeps) |
| lane4-am5 | GREEN 2/2 (create→auto-cancel, create→maintenance-cancel) |
| lane5-sm3 | GREEN 2/2 (cancel_stale_payout pending-only legal map + illegal-source `race_lost` benign-no-op) |

**Live-confirmed money facts (ground truth):** flag OFF + a pending payout aged **10015m** (≫15m knob)
stays `pending` with `frozen` held + zero callbacks → the SAME fixture cancels the instant the flag flips
ON (`auto_cancelled`, `frozen 426.3→0`, balance untouched, queue cancelled, exactly one callback);
PAYOUT-010 cancels an in-window-bank payout with `bank_maintenance` **even with the 008 flag ON** (codes
never crossed); the unrouted Mode-1 payout (`required_bank_account_id` NULL, `pool_id` set) is **SKIPPED**
while a window-open bank's own payout cancels (per-bank isolation); overnight-wrap (02:00 in / 12:00 out)
and the `[start,end)` edges (10:00 cancel / 11:00 survive) both hold; the 3-code matrix
(`auto_cancelled`/`bank_maintenance`/`admin_cancelled`) is distinct and never crossed; a just-claimed
payout survives a racing sweep; a second tick is a zero-effect benign `race_lost`; AM5 holds at every step.

**Post-run state restored (verified over the wire):** `payout_auto_cancel_enabled='false'` ✓ (the critical
one), `payout_pending_timeout_minutes='15'` ✓, all 3 banks `maintenance_window_*` NULL + active ✓, the
§ADR-20 clock is **live** (`app_now()` == wall) ✓, zero leftover `payb3-*` payouts ✓.

### Probe-side fix the live run surfaced (mine; reported + fixed, code-blind — substrate was CORRECT)

1. **`p010.maintenance_d_unrouted_skipped`** first ran RED — but the diagnostic showed
   `required_bank_account_id` was still the bank (NOT NULL) and the payout cancelled: the substrate
   **correctly** cancelled a payout genuinely routed to an in-window bank. The bug was in my staging —
   `stageUnroutedPending` nulled `required_bank_account_id` **without** setting a `pool_id`, which the
   `withdrawal_queue` **Mode-2↔Mode-1 XOR** rejects (the PATCH was silently dropped, leaving the row
   Mode-2). Fix: resolve the seeded `pool` (`66666666-…-001`) and set `required_bank_account_id`→NULL +
   `pool_id`→pool in ONE PATCH — a faithful Mode-1 pre-router row (exactly the SPEC §5 recipe: "queue row
   `required_bank_account_id IS NULL` + a `pool_id`"). Re-run → GREEN; the unrouted payout is now genuinely
   unrouted and the sweep SKIPs it. A no-pool stack now records BLOCKED (surfaced), never a false pass.

> Per the build-workflow, this GREEN is the tester's VERIFY layer; it is not a seal. next-investigator
> independently falsifies every PASS against the truth DB on its own seal stack (run git-sha = merged
> HEAD) before any seal.
