# next-dev — PAYOUT slice 3 (pending→cancelled cancel sweeps) — findings + handoff

**Campaign:** payb3 · **Branch:** `build/payout-slice3` (off `campaign/payb3` @ `924d7eb`, = `origin/main` HEAD) · **Slot:** dev-1 (`qvmjywljrgqzyxshexhx`) · **Date:** 2026-06-13
**SPEC (broadcast):** `origin/build/payout-slice3` : `docs/spec/payout-cancel-sweeps-slice.md`
**Stories:** PAYOUT-008 (per-age auto-cancel sweep — flag-gated, ships OFF, `auto_cancelled`) · PAYOUT-010 (per-bank maintenance-window sweep — always-ON, `bank_maintenance`)

---

## 1. TL;DR

Two automatic `pending → cancelled` producers, both riding the **same** `cancel_stale_payout` bundle PAYOUT-005 admin-cancel uses (slice 2). The census found the bundle, the maintenance predicate, the flag/knob readers, and the maintenance-window columns all **stand at HEAD and are reused — not forked**. The slice closes exactly **one producer drift** (the PAYOUT-008 sweep's wall-clock `now()` / no-`p_now` / no-grant — the slice-2 sweep-drift class) and builds **one missing producer** (the PAYOUT-010 payout-side maintenance sweep, which did not exist). The crucial PAYOUT-010 design question — **what is a *pending* payout's "assigned bank"** — resolved to `withdrawal_queue.required_bank_account_id` (NOT `ts_payouts.system_bank_id`, which is only set at claim time); the **unrouted** (Mode-1 pre-router, `required_bank_account_id IS NULL`) case is an **explicit, named SKIP**. `_bank_in_maintenance` turned out to be a **generic** window predicate (not deposit-specific), so PAYOUT-010 reuses it verbatim. **dev-1 smoke 10/10 green** across every required scenario (zero-footprint `BEGIN…ROLLBACK`). One non-blocking residue routed to next-architect (the `v_payouts`/`v_payouts_read`/`v_deposits` 0-lag view-clock `now()` — a read-side, view-family concern, deliberately NOT a partial fix in this producer slice).

---

## 2. Census — PAYOUT-008 + PAYOUT-010 vs the CURRENT ratified text (verified at HEAD, on dev-1)

| Surface | LATEST def | Verdict | Detail |
|---|---|---|---|
| `cancel_stale_payout(p_payout_id uuid, p_failure_code text DEFAULT 'auto_cancelled')` | `…000005` (slice 2) | **STANDS — reused** | The shared cancel bundle. LO1 lock order (queue `FOR UPDATE` first), CAS `pending→cancelled` (else `race_lost`), AM2/AM4 unfreeze (frozen−=amount+fee, balance untouched, `payout_unfreeze` log), queue-cancel, one `payout.cancelled` callback. **Already parameterized by code** → 008 binds the default `auto_cancelled`, 010 passes `bank_maintenance`. **No change, no fork.** |
| `_bank_in_maintenance(p_start time, p_end time, p_now time)` | `…000010` (deposit lane) | **STANDS — reused (GENERIC)** | NOT deposit-specific: a pure window predicate (NULL/zero-length ⇒ false; `start<end` normal; `start>end` overnight wrap). PAYOUT-010 reuses it **verbatim** — no second maintenance predicate. *(Design question the task flagged — "is its shape deposit-specific?" — answered NO; no duplication, nothing to escalate.)* |
| `bank_account.maintenance_window_start` / `_end` (`time`, BKK time-of-day) | `…000010` | **STANDS** | The maintenance-window **source of truth** — already present payout-side (generic `bank_account` columns). Read by the new maintenance sweep. |
| `_payout_auto_cancel_enabled()` + flag `payout_auto_cancel_enabled='false'`; `_payout_pending_timeout_minutes()` + knob `payout_pending_timeout_minutes='15'` | `…000003` | **STANDS** | Flag seeded **OFF** (correct ships-OFF). Both fail-safe reads. Reused by the rewritten 008 sweep. |
| `app_now` / `clock_set` / `clock_advance` / `clock_reset` / `reset_for_test` | `…000001` (§ADR-20) | **STANDS** | The virtual-clock baseline both rewritten/new sweeps read. |
| **`sweep_stale_payouts(p_batch_size int DEFAULT 100)`** | `…000003` | **DRIFT-D8 (clock)** | Predates the §ADR-20 baseline. Read **wall-clock `now()`** on the age predicate (T1 violation), **no `p_now`** (not virtual-clock drivable), **no `service_role` grant** (not probe-callable). Cron `sweep-stale-payouts` still called the old single-arg form. *Same drift class as slice-2's `sweep_stale_claims` (drift-B).* **Closed this slice.** |
| **PAYOUT-010 payout-side maintenance sweep** | — | **MISSING-D10** | No payout maintenance producer existed (`_bank_in_maintenance` only on the deposit create-path). **Built this slice.** |
| `v_payouts.effective_status` (PA2) + `v_payouts_read` (SV7c portal) + `v_deposits` | `…000001`/`…000040`/deposit | **DRIFT-V (read-side, NOT fixed — routed)** | The flag-aware `effective_status` CASE reads wall-clock `now()` (same T1 residue) → under a virtual clock the 0-lag view does not track `app_now()`. **Not a producer this slice owns** (consumed by the out-of-slice claim guard + portal). The whole **view family** carries it; a coherent §ADR-20 view-clock hardening is one architect-owned change, not a partial fix here. **Routed to next-architect (§7).** Production behavior unaffected (`now()==app_now()`); only virtual-clock test coherence of PAYOUT-008 AC#3/#4 is. |

---

## 3. The delta (what shipped) — 2 migrations, forward-only, stack on `…000150`

- **`20260612000160_payout008_sweep_appnow.sql`** — **rewrites `sweep_stale_payouts`** to `(p_batch_size int DEFAULT 500, p_now timestamptz DEFAULT NULL)` reading **`COALESCE(p_now, app_now())`** + the `payout_pending_timeout_minutes` knob; `SECURITY DEFINER` + `GRANT EXECUTE … TO service_role`; **drops the old `(int)` overload** and **re-points the `sweep-stale-payouts` cron** to the new signature (cadence unchanged ≈1 min). **PA1 flag-gate + fail-closed PRESERVED VERBATIM** (the first statement is `IF NOT _payout_auto_cancel_enabled() THEN RETURN`) → flag OFF (the shipped default) or unreadable ⇒ structural no-op for *arbitrarily-old* pending payouts. Per-row cancel via the shared `cancel_stale_payout` (default `auto_cancelled`). *Closes DRIFT-D8.*
- **`20260612000170_payout010_bank_maintenance_sweep.sql`** — **NEW `sweep_payouts_bank_maintenance(p_batch_size int DEFAULT 500, p_now timestamptz DEFAULT NULL)`** — **always-ON** (no flag check), `SECURITY DEFINER` + `service_role` grant + new `sweep-payouts-bank-maintenance` cron (≈1 min). Selects `pending` payouts whose queue row's `required_bank_account_id` points to an **active** bank that is currently inside its own window (via the **reused generic** `_bank_in_maintenance` on `(app_now() AT TIME ZONE 'Asia/Bangkok')::time`); cancels each via `cancel_stale_payout(id, 'bank_maintenance')`. Unrouted (`required_bank_account_id IS NULL`) is the explicit SKIP. *Closes MISSING-D10.*

**No Edge Function this slice** — both producers are pg_cron-driven RPCs (probe them direct via service-role). **No change** to `cancel_stale_payout`, the flag/knob readers, `_bank_in_maintenance`, the maintenance-window columns, `claim_withdrawal_items`, or any view. **No `_shared/*` or auth touch** — zero authfull collision.

---

## 4. The PAYOUT-010 design decisions (pinned in the SPEC so probes bind them)

1. **"Assigned bank" of a *pending* payout = `withdrawal_queue.required_bank_account_id`** — set at create for **Mode-2 (direct)**, set by the fair-router (`fair_router_assign`) for **Mode-1 (pool)**. `ts_payouts.system_bank_id` is NOT the key (only populated at *claim*, `pending→processing`; a swept payout is `pending`). This matches PA7's "pending payouts assigned to any active bank inside its own `maintenance_time`".
2. **Unrouted ⇒ SKIP (named).** A Mode-1 payout whose queue row still has `required_bank_account_id IS NULL` (pre-router) has no assigned bank/window → not cancelled by this sweep (the `IS NOT NULL` predicate enforces it). Its funds are released by PAYOUT-008 (per-age) or PAYOUT-005 (admin) instead. Probe-binding boundary in SPEC §3.2.
3. **`ba.is_active = true`** — PA7 says "active bank inside its own `maintenance_time`"; an inactive assigned bank is out of this sweep's literal scope (consistent with the deposit candidate predicate). Pinned in SPEC §3.1/§3.4.
4. **Reuse `_bank_in_maintenance`, do not fork** — it is generic; forking a payout-specific copy would duplicate the overnight-wrap logic with no benefit.
5. **Always-ON** (PA7: "ships ON, not flag-gated") — no `_payout_auto_cancel_enabled()` check; that flag governs only PAYOUT-008.

---

## 5. dev-1 deploy + smoke (10/10 green, zero-footprint)

Applied `…000160` + `…000170` to dev-1 via psql (recorded in `supabase_migrations.schema_migrations`). RPC-level money smoke in one `BEGIN…ROLLBACK` (`.secrets/payb3_smoke.sql`, dev-artifact, not committed) — **ALL 10 scenarios PASS**:

| # | Scenario | Result |
|---|---|---|
| S1 | 008 **flag-OFF** no-op (ancient pending stays `pending`; empty tick) | empty set; `pending`; frozen unchanged |
| S2 | 008 **flag-ON** timeout cancel + `auto_cancelled` + AM2/AM4/**AM5** | `cancelled`; frozen −1020, balance untouched; one `payout.cancelled`/`auto_cancelled`; one `payout_unfreeze` (balance_before==after); queue `cancelled` |
| S3 | 008 threshold **relative to the knob** (15m) | old(20m)→`cancelled`, young(5m)→`pending` |
| S4 | 010 maintenance-window cancel + `bank_maintenance`, **flag OFF (always-on)** | `cancelled`; `bank_maintenance`; fires with `payout_auto_cancel_enabled='false'` |
| S5 | 010 bank **NOT** in window → untouched | `pending`; not swept |
| S6 | 010 **unrouted** (`required_bank_account_id IS NULL`) → **SKIP** even with a window-open bank | `pending`; not swept |
| S7 | claimed/processing **SKIP** (neither sweep touches a `processing` payout; never un-claim/auto-fail) | `processing`; not swept by either; no callback |
| S8 | race **lock-first-wins**: `processing`→`race_lost` (no effect); re-cancel→`race_lost` (zero 2nd effect) | exactly one callback + one unfreeze on the once-cancelled payout |
| S9 | **callback-code matrix**: `auto_cancelled`(008) / `bank_maintenance`(010) / `admin_cancelled`(005) — 3 distinct, never crossed | all three present + distinct |
| S10 | 010 **overnight-wrap** window (20:00→08:00): cancel at 02:00 BKK; predicate true@02 / false@12; NULL & zero-length ⇒ false | `cancelled`; wrap math correct |

**Zero-footprint verified post-run:** 0 SMOKE leftovers, flag back to `false`, bank windows NULL, clock `real`, migrations 160/170 recorded + live with the `(int, timestamptz)` signatures + service-role grants + both crons (`sweep-stale-payouts` re-pointed, `sweep-payouts-bank-maintenance` new).

---

## 6. CROSS-STACK DEPLOY HANDOFF (for brew-ops / owner — tester + seal stacks)

Deploy the slice-3 delta to the **tester** (`payb3t`) and **investigator/seal** stacks (brew-ops/owner hold those slots; I cannot reach them).

**Migrations to apply (in order, after `…000150`):**
1. `supabase/migrations/20260612000160_payout008_sweep_appnow.sql`
2. `supabase/migrations/20260612000170_payout010_bank_maintenance_sweep.sql`

**Edge Functions to (re)deploy:** **NONE** — this slice is pure substrate (two pg_cron RPCs). No EF, no `_shared/*`, no auth change.

**New / changed cron jobs the readiness gate must check:**
- `sweep-stale-payouts` — **re-pointed** to `public.sweep_stale_payouts(500)` (was the old single-arg form). Harmless while the feature ships OFF (self-gates fail-closed).
- `sweep-payouts-bank-maintenance` — **NEW**, `public.sweep_payouts_bank_maintenance(500)`, `* * * * *`. **Always-on** (does work every tick).

**New RPCs / signatures (readiness gate):**
- `sweep_stale_payouts(int, timestamptz)` — **replaces** `sweep_stale_payouts(int)` (the old overload is DROPPED). `service_role` EXECUTE granted.
- `sweep_payouts_bank_maintenance(int, timestamptz)` — NEW. `service_role` EXECUTE granted.

**No new app_settings keys / flags** — PAYOUT-008 reuses the existing `payout_auto_cancel_enabled` (default `'false'`) + `payout_pending_timeout_minutes` (default `'15'`); PAYOUT-010 has **no** config key (always-on; its inputs are the per-bank `bank_account.maintenance_window_*` columns). Tester fixtures set those window columns per scenario.

**Apply note (out-of-order migration `…000070`):** like slice 2, a stack at `…000150` that skipped `…000070` (`adr10_parity_residual_guard_tiebreaker`, a DEPOSIT-lane file) needs `--include-all` for `db push`, OR apply 160/170 directly (they depend only on objects present at `…000150`: `cancel_stale_payout`, `_bank_in_maintenance`, `bank_account.maintenance_window_*`, `app_now`, the flag/knob readers). dev-1 applied 160/170 directly; smoke unaffected.

**Stack-readiness gate (must hold before the tester runs probes):** `sweep_stale_payouts(int,timestamptz)`, `sweep_payouts_bank_maintenance(int,timestamptz)`, `cancel_stale_payout(uuid,text)`, `_bank_in_maintenance(time,time,time)`, `_payout_auto_cancel_enabled()`, `_payout_pending_timeout_minutes()` present; `bank_account.maintenance_window_start/_end` columns present; `app_now`/`clock_set`/`clock_advance`/`clock_reset`/`reset_for_test` present; both pg_cron jobs present; `app_settings.payout_auto_cancel_enabled` + `payout_pending_timeout_minutes` seeded. No EF gate this slice (probes call the RPCs direct via service-role).

---

## 7. Routed observations (NON-BLOCKING — for next-architect / slice owner; not fixed here)

1. **DRIFT-V — the read-view `effective_status` `now()` residue (view family).** `v_payouts` (PA2 engine view), `v_payouts_read` (SV7c portal), and `v_deposits` all compute the flag-aware `effective_status` with wall-clock `now()` — a §ADR-20 T1 residue on the read side. Under a virtual clock the 0-lag view does not track `app_now()`, so PAYOUT-008 AC#3/#4 (the 0-lag `cancelled` visibility) are only probeable under the **real** clock. **Deliberately NOT fixed here** — these are read-side projections (`v_payouts` feeds the out-of-slice `claim_withdrawal_items` PA4 guard; `v_payouts_read` is the authfull/SV7c portal lane), and fixing only `v_payouts` would split the view family. A coherent §ADR-20 view-clock hardening (all three views) is one architect-owned change. → **next-architect.** *(My producer sweeps are fully `app_now()`-coherent; this is purely the read-view family.)*
2. **§ADR-20 T1 residue on `claimed_at = now()` in `claim_withdrawal_items`** (bot-claim lane, out of slice) — same residue slice 2 already routed; noted again only because the maintenance sweep's race AC touches the claim path. → PAYOUT-002 / bot-dispatch owner.
3. **PAYOUT-010 batch ordering under heavy backlog** — both sweeps `ORDER BY created_at ASC LIMIT p_batch_size`; a very large maintenance backlog drains oldest-first across ticks (≈1 min each). Matches the per-age sweep's batching; no money-safety impact (each cancel is its own txn). Noted for ops awareness only.

---

## 8. Status / next

- **PR:** ONE PR vs `main` — **DO NOT MERGE** (reviewer + owner gate per build-workflow Step-3). Awaits `next-code-reviewer` APPROVE (body header) → team self-merge; then brew-ops cross-stack deploy (§6) → tester (`payb3t`) VERIFY off the SPEC → investigator seal.
- **Tester:** next-tester spawns into campaign `payb3t` (separate worktree) off `origin/build/payout-slice3 : docs/spec/payout-cancel-sweeps-slice.md` (§5.7 carries the exact RPC arg lists; §5 the canonical virtual-clock drives for both sweeps).
- **Out of scope (named overlaps only):** PAYOUT-005 admin-cancel surface (shared bundle only), PAYOUT-004/007/009/012/013, fair-router/bot internals, the read-view family (routed §7.1), livegate/authfull, ratified-text changes (none needed — the substrate matched the ratified PA1/PA5/PA7 + §ADR-9 codes exactly).
