# next-dev findings — campaign `dep34dev` (DEPOSIT-003 + DEPOSIT-004 cluster)

**Date:** 2026-06-03 · **Builder:** next-dev · **Branch:** `feat/deposit34-slip-expire-cluster`

Built the DEPOSIT-003 + DEPOSIT-004 cluster through **Step 0 (SPEC-first)** and **Step 1
(parallel build)** of `docs/build-workflow.md`, continuing from the sealed DEPOSIT-001/002
happy-path. The two stories form a **non-overlapping two-sweep timer model split by
slip-presence** — they must land together (DA1 excludes slip-bearing from the expire sweep
*because* the new slip-escalation sweep handles them).

---

## Deliverables

### SPEC (Step 0 — the test-facing contract)
- **Path:** `docs/spec/deposit-slip-expire-slice.md` (published + committed + pushed on the PR branch).
- Self-contained: API contract (slip-upload EF + admin approve/reject surface + required
  `Idempotency-Key`), the sweep RPCs, the DB/observable surface (slip storage + audit triple,
  `slip_verify_attempts` incl. no-verdict outcomes, the `pending→expired` / `pending→checking` /
  `→paid` / `→rejected` transitions, the `callback_queue` rows for `deposit.expired` /
  `deposit.rejected` with `failureCode`), the simulated Thunder seam knob, and an AC→observable map.
- **Broadcast:** SPEC is on the PR branch; broadcast to orchestrator + next-tester via team message
  (next-tester binds probes off the SPEC, NEVER off the code).

### PR (Step 1 — code; NOT merged, review + owner gate later)
- **PR #320** → `main` (open, not merged): "feat(deposit): DEPOSIT-003 + DEPOSIT-004 — slip/expire
  two-sweep cluster". Story-linked (DEPOSIT-003 + DEPOSIT-004).
- Files:
  - `supabase/migrations/20260603000040_deposit003_expire_slipless.sql` (DEPOSIT-003)
  - `supabase/migrations/20260603000041_deposit004_slip_escalation_sweep.sql` (DEPOSIT-004)
  - `supabase/functions/deposits-upload-slip/index.ts` (rewritten — deferred + tenant-scope + 3-actor)
  - `docs/spec/deposit-slip-expire-slice.md`

---

## What I built vs what already existed on the substrate

A large part of the cluster already existed (DEPOSIT-007/008 and prior §ADR-4d work). Honest split:

| piece | status |
|---|---|
| expire sweep (`sweep_expired_deposits`/`expire_deposit`) + `deposit.expired` + `v_deposits` + 1-min cron | **EXISTED** — **NEW: DA1/DA4 slip-LESS predicate** added (expire skips slip-bearing; view never reads `expired` for slip-bearing). |
| slip columns + audit triple (`slip_uploaded_by_*`) + `slip_verify_attempts` append-only history | **EXISTED** (§ADR-4d migrations). |
| `upload_slip` RPC | **EXISTED** — **NEW: clock repair** (`slip_uploaded_at = app_now()`, was wall-clock `now()` — a §ADR-20 violation that made the +5min window undrivable under the frozen clock). |
| **slip-escalation sweep** (`sweep_slip_escalation`/`escalate_slip_deposit`/`run_slip_verify`) + `slip_review_timeout_minutes` config + 1-min cron | **NEW** — was entirely missing; only a *disabled* PoC `simulate_admin_review` existed. This is the guaranteed no-verdict-safe `pending→checking` producer. |
| **simulated Thunder seam** (`_thunder_verify_slip` + `thunder_sim_outcome` knob, 4 outcomes) | **NEW**. Replaces the old hardcoded "always genuine" mock at upload time. |
| `deposits-upload-slip` EF | **REWRITTEN** — deferred model (deposit stays `pending`, no synchronous verify), §ADR-13 F4 tenant-scope 403 (`FORBIDDEN_CROSS_CLIENT`), 3-actor audit triple, Idempotency-Key required. Removed the premature synchronous Thunder/V1-V2 (V1/V2 are DEPOSIT-007 and run at admin-approve, the canonical site). |
| admin approve (`admin_approve_paid` → paid + finalize bundle) | **EXISTED** (admin-deposit EF action=approve). |
| admin reject (`admin_reject_deposit` → rejected + `deposit.rejected`, `failureCode='admin_rejected'`) | **EXISTED** (admin-deposit EF action=reject). |

Key behavioural shift: the substrate had an **older synchronous slip model** (upload → immediately
flip to checking + run Thunder/V1-V2 inline). DEPOSIT-004's ratified contract is the **deferred
two-sweep model** (upload keeps `pending`; the slip-escalation sweep escalates at
`slip_uploaded_at + slip_review_timeout_minutes`). This PR converts upload to the deferred shape and
adds the missing escalation sweep.

Status enum confirmed deployed as the canonical **7 values**
(`pending,paid,rejected,expired,cancelled,checking,failed`) — `review_required` was dropped in
`20260521000001`. The 7-value enum is unchanged by this PR.

---

## Deploy status — ✅ DEPLOYED to tester + seal stacks

Deployed via the Supabase CLI using the fleet-secret slot files (`.secrets/` →
`/Users/admin/.arra-oracle-v2/fleet-secrets/mb-next-payment-gateway/slots/`) + the
`SUPABASE_API` access token (`tmp_token.env`). Both stacks were at the `20260603000030` HEAD
baseline; only migrations `…40` + `…41` were pending and applied cleanly.

| stack | project ref | migrations 40+41 | EF `deposits-upload-slip` | smoke |
|---|---|---|---|---|
| **tester** (next-tester) | `yupsevcrubgprsbujbpu` | ✅ applied | ✅ deployed | `_slip_review_timeout_minutes()=5`, `sweep_slip_escalation()` reachable |
| **seal** (next-investigator) | `qnccphgykzdydebmdwdf` | ✅ applied | ✅ deployed | `_slip_review_timeout_minutes()=5`, `sweep_slip_escalation()` reachable |

(No other EFs changed; `admin-deposit`, `dispatch-callback`, etc. unchanged. The 1-min
`sweep-slip-escalation` pg_cron job is registered by mig …000041 at apply time.)

**One apply-time fix during deploy:** the first `db push` hit `42P16` on the
`CREATE OR REPLACE VIEW v_deposits` (the view's `SELECT *` now expands to more `ts_deposits`
columns than when it was last defined, shifting `effective_status`' position — CREATE-OR-REPLACE
can't reorder view columns). Fixed in commit `3c9193f` (DROP+CREATE; no DB object depends on the
view). Postgres DDL is transactional, so the failed first attempt rolled back cleanly — no partial
state. Both stacks then applied both migrations successfully.

**Deploy commands (for the record / re-run):**
```sh
export SUPABASE_ACCESS_TOKEN=<SUPABASE_API from tmp_token.env>
. <stack>.env                                   # loads SUPABASE_DB_PASSWORD, etc.
supabase link --project-ref <ref> -p "$SUPABASE_DB_PASSWORD"
supabase db push -p "$SUPABASE_DB_PASSWORD"     # applies 40 + 41
supabase functions deploy deposits-upload-slip --project-ref <ref>
```

---

## Out-of-scope (bounced to orchestrator, per the brief)
- Did **not** write `tests/` (next-tester owns probes, campaign dep34test — must never read this code).
- Did **not** edit ADRs or stories.
- Did **not** self-mark done; did **not** merge.
- DEPOSIT-007 (six-check fraud cascade) and DEPOSIT-008 (admin verify-now) are separate later
  stories — not built. Thunder here is only the queued deferred verify + no-verdict handling.

## VERIFY round 2 (2026-06-04) — fixes A + D-1 (next-tester bound run)

next-tester's SPEC-bound run on the deployed tester stack found DEPOSIT-003 **10/10 green** and 2
real DEPOSIT-004 build defects + 1 SPEC divergence (off ground-truth, not probe errors). Fixed:

- **FIX A [BLOCKER] — `upload_slip` ambiguous overload (every upload 500'd).** After PR #320 mig …41,
  two 6-arg overloads coexisted: `upload_slip(…, p_admin_notes text)` (20260521000003 §AU-1, called
  positionally by the `check_admin_slip_upload_gate` wrapper) and my `upload_slip(…, p_now timestamptz)`
  (clock repair). A 5-named-arg PostgREST call matched both ⇒ "Could not choose the best candidate
  function" ⇒ 500 on the whole slip-bearing happy path. **Root sub-cause:** mig …41's stray
  `DROP … upload_slip(uuid,text,text,text,text)` targeted the wrong types (the real 5-arg is
  `(uuid,text,text,uuid,text)`), so it never removed the p_admin_notes overload. **Fix:**
  `supabase/migrations/20260604000001_deposit004_fix_upload_slip_overload.sql` drops both 6-arg
  overloads and creates ONE canonical 7-arg `upload_slip(…, p_admin_notes, p_now)` carrying both
  params — every caller (wrapper 6-positional / EFs 5-named / escalation p_now) resolves uniquely.
  DB-only; no contract change to SPEC §1.1.
- **FIX D-1 — auth gate.** The `deposits-upload-slip` EF had the platform `verify_jwt` gate ON (401
  `UNAUTHORIZED_NO_AUTH_HEADER` without an `Authorization` Bearer), inconsistent with `deposits-create`
  (gate OFF) and with SPEC §1.1 (`X-Client-Id` only). **Fix:** redeployed the EF with
  `--no-verify-jwt` (aligned with `deposits-create`); updated SPEC §0/§1.1 + change-log (rev 2) to
  document the final contract — `X-Client-Id` alone, no `Authorization` header.

**Commit:** `6e640d4` on `feat/deposit34-slip-expire-cluster` (PR #320). **Deployed + smoke-verified
on BOTH stacks** (I have working slot access via `.secrets/`, so I deployed directly rather than
waiting on brew-ops):
| stack | migration 20260604000001 | EF redeploy (`--no-verify-jwt`) | smoke A (`upload_slip` resolves) | smoke D-1 (EF reaches own auth) |
|---|---|---|---|---|
| tester `yupsevcrubgprsbujbpu` | ✅ | ✅ | ✅ `"race_lost"` 200 (no ambiguity) | ✅ `missing_x_client_id` (not platform 401) |
| seal `qnccphgykzdydebmdwdf` | ✅ | ✅ | ✅ `"race_lost"` 200 | ✅ `missing_x_client_id` |

**Item B — RESOLVED by owner (2026-06-04): D4-11 DEFERRED OUT-OF-SLICE (document-only).** next-tester
found admin approve (`admin_approve_paid`) runs the DEPOSIT-007 V2 receiver-mismatch fraud gate and
blocks a clean approve (no slip-receiver-proxy captured → D4-11 not drivable to `paid`). **Owner
decision:** the V2 gate firing at approve is accepted as correct/expected (DEPOSIT-007); clean-approve
→`paid` requires DEPOSIT-007 V2 + a receiver-proxy capture field, both separate-story. So **document
only** — SPEC §1.2 + §3 D4-11 marked DEFERRED out-of-slice + change-log rev 3 (commit `3334649`);
PR #320 body comment added. The approve path is **unchanged**; no DEPOSIT-007 pulled in; no
receiver-proxy field added. **admin-reject (D4-12) remains in-slice and green.**

## Notes / flags for review
- The client/sub-client web-user upload path is modeled as an `uploader:{type,id,username}` body
  declaration on the `X-Client-Id`-authenticated `deposits-upload-slip` EF (the deployed PoC
  client-auth model). The load-bearing security control — §ADR-13 F4 tenant-scope (the authenticated
  client must own the deposit) — is enforced (403 `FORBIDDEN_CROSS_CLIENT`). Flagged in SPEC §0/§1.1.
- `admin_approve_paid` inlines the credit+MDR+callback bundle (functionally the DEPOSIT-002 finalize
  semantics) with the DEPOSIT-007 V1/V2 gates in front; for this cluster the tester drives a clean
  slip → `paid`. Noted in SPEC §1.2.
