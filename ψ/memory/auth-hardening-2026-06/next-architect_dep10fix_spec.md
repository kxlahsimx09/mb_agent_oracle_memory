# Builder Fix-Spec — `docs/spec/deposit-010-client-cancel-slice.md` (campaign dep10fix)

**From:** next-architect · **To:** next-dev (the Builder — spec owner) · **Cc:** next-tester (probe rev follows the spec rev) · **Date:** 2026-06-10
**Authority:** NO new ratification needed. Every fix below reconciles the spec to the **already-ratified S2 story** — DEPOSIT-010 as minted by the depfix top-up pass 2026-06-08 (`docs/requirements/epic-deposit.md` ~L673-721; M4 AC at ~L693; revision-log entry "depfix top-up — DEPOSIT-010 cancel story (B4-M4)"). Two items are spec-level pins flagged for concurrence (F6, F7-a), not design changes.
**Root cause being fixed:** the spec was authored **2026-06-07**, one day **before** the story was ratified **2026-06-08** (the spec's own binding_sources still say "5 ACs ~L652-688"; the ratified story has **7 ACs + M4 + 3 edge cases** at ~L690-705). The spec therefore implements the **opposite** of the ratified M4 idempotency posture and predates the effective-status basis wording.

> **Scope:** this file is the precise change-list for `docs/spec/deposit-010-client-cancel-slice.md` ONLY. Line numbers are a snapshot at main `9e69725` — re-verify anchor text at HEAD before editing. If the `deposits-cancel` EF / `cancel_deposit` RPC have already been built against the old spec, the same items apply to the migration + EF + probes as build deltas (the spec is the contract; code follows it).

---

## F1 — Re-cancel of an already-`cancelled` deposit: **200 terminal echo, NOT 409** (the behavioral inversion — highest priority)

**What:**
1. **§1b (L76-78):** remove `cancelled` from the 409 status list. The 409 list becomes `checking / paid / expired / rejected / failed`.
2. **NEW §1a-bis (insert after §1a):** "200 — re-cancel of an already-`cancelled` deposit (M4)". Response is the **same body shape as §1a** — `{ "cancelled": true, "deposit_id": "<uuid>", "status": "cancelled" }`, HTTP **200**. No second terminal transition, no callback row, no wallet effect, `cancelled_at` **not re-stamped**.
3. **§2 RPC outcome mapping (L118-119):** add outcome `already_cancelled` → HTTP 200 echo. RPC step 2: when the row under lock is `status='cancelled'`, return `already_cancelled` (echo path) instead of falling into `not_pending`.
4. **Add an idempotency note** (in §1 or §0): the cancel EF is **naturally idempotent on its own terminal**; it does **NOT** require an `Idempotency-Key` header — mirrors the DEPOSIT-012 non-mutating-replay exemption (§ADR-11 scope clarification).

**Why:** the ratified M4 AC (`epic-deposit.md:693`) reads verbatim: *"Given a deposit already at terminal `cancelled`, when an authorized caller issues a cancel again, then the response is the **same terminal `cancelled` result, NOT a 409**"* — and the epic's 409 `NOT_PENDING` AC (`:694`) deliberately scopes the 409 to `paid / expired / rejected / failed` (no `cancelled`). `INDEX.md:19` carries the same "idempotent re-cancel (no 409)" hook. The spec as written ships the exact behavior the ratification rejected. This is the only direct spec-vs-S2-story inversion in the deposit set — a builder following the current spec fails the story; a tester probing the story fails the build.

---

## F2 — Precondition basis: raw `status='pending'` → **effectively `pending`** (`v_deposits` semantics)

**What:** §2 step 2 (L113-114): the under-lock precondition becomes
`status='pending' AND slip_uploaded_at IS NULL AND (expires_at IS NULL OR expires_at > now())`
(use the §ADR-20 `v_now := COALESCE(p_now, app_now())` clock, same as `expire_deposit`). When the deadline clause fails (raw-`pending`, slip-less, past deadline, expire sweep not yet ticked), return `not_pending` and **echo the effective status `expired`** in the 409 body — not the raw `pending`.

**Why:** the story preconditions on **"effectively `pending`"** in both the journey (`epic-deposit.md:685-686`: *"pre-condition-checks that the deposit is effectively `pending`"*) and the 409 AC (`:694`: *"whose status is not effectively `pending`"*). A slip-less deposit past its deadline is effectively-`expired` per §ADR-4c D10 (0-lag view contract) even while the physical row is still `pending` for ≤60s — the spec as written **cancels** it; the story requires **409 `NOT_PENDING`**. Allowing the cancel would also race the expire sweep (cancelled-vs-expired terminal ambiguity on the same row, and the expire path would have queued a `deposit.expired` callback that cancel suppresses). Echoing `expired` keeps the body consistent with what every read path shows the caller. Note: this guard only bites the slip-LESS past-deadline window — the slip-BEARING case is already 409 `SLIP_PRESENT` before the deadline clause is reached.

---

## F3 — O4 observable names a non-existent table: `callback_logs` → **`callback_attempts`**

**What:** §3 O4 (L132): assert on **`callback_attempts`** (no delivery-attempt row for this deposit / no `deposit.cancelled` event anywhere). Keep the "0 of 888,871" figure only as a *mobiz production evidence citation*, not as the probe target.

**Why:** `callback_logs` is the mobiz-era collection name; the next-system substrate has **no such table** (verified by grep over `supabase/migrations/` — the append-only delivery history is `callback_attempts` per §ADR-9 D6). As written, O4 is unprobeable: a tester either skips it silently or invents a table. Same class as the deposit-012 spec, which correctly names `callback_attempts` (its O2).

---

## F4 — AC → probe mapping is built against the pre-ratification 5-AC story; map the ratified 7-AC set

**What:** §4 (L138-151):
1. **NEW M4 probe row:** cancel succeeds → cancel again → assert **200** + identical body + O1 still `cancelled` + **O2 `cancelled_at` unchanged** (capture before/after — no re-stamp) + O3/O4 no new `callback_queue`/`callback_attempts` row.
2. **NEW 404 probe row:** unknown `deposit_id` → 404 `deposit_not_found` (epic AC `:697`; §1d already defines the response — it just has no probe row).
3. **AC2(a) status seed list:** align to the F1 list — seed from `checking / paid / expired / rejected / failed` (drop `cancelled` from the 409 seeds; it now belongs to the M4 probe).
4. **NEW race note on AC3:** the epic edge (`:703`) is bidirectional — finalize-loses-to-cancel (already covered by AC3/O6) AND **cancel-loses-to-finalize** (cancel on a row that just went `paid` → 409 `NOT_PENDING`). If a true concurrent probe is impractical in the harness, state explicitly that the sequential AC2(a) `paid` seed is the accepted proxy for the cancel-loses direction, so the coverage decision is recorded rather than accidental.

**Why:** the ratified story has 7 ACs (`:692-698`); the spec maps 5. M4 and 404 are ratified contract with no probe — green suites would pass while the contract is unverified. The O2 no-re-stamp assertion is what makes the M4 probe distinguish a true echo from an accidental second UPDATE (M4: *"No second terminal transition"*).

---

## F5 — Harness self-check: extend the de-bias to M4

**What:** §4 harness self-check (L148-151): add — *"confirm the M4 probe FAILS against a 409-on-re-cancel implementation (point it at a stub that returns 409 for a cancelled row, or assert the status code strictly = 200), so a probe loose enough to accept both behaviors cannot go green."*

**Why:** M4 is the inversion this rev exists to fix; the self-check section currently de-biases O3/AC3 only. A probe that asserts merely "no state change on re-cancel" passes under BOTH the old 409 and the new 200 — the self-check must force the distinction.

---

## F6 — `checking` → which 409 code: pin `NOT_PENDING`, flag for concurrence

**What:** keep the spec's current behavior (status check precedes slip check → a `checking` deposit returns `NOT_PENDING`), but add an explicit note: *"Spec-level pin: the epic's `NOT_PENDING` AC enumerates only `{paid, expired, rejected, failed}` and the M4 AC owns `cancelled`; `checking` appears in no 409 AC. Since every `checking` deposit is slip-bearing, `SLIP_PRESENT` would also be defensible. This spec pins `NOT_PENDING` (status-gate runs first; `SLIP_PRESENT` stays the code for the *effectively-pending* slip-bearing window only, consistent with the epic edge `:705` 'cancel is pending-only'). Flagged to next-writer for an epic-AC clarification line."*

**Why:** the epic genuinely under-specifies this one cell of the matrix (`:694` lists 4 statuses; `:705` says cancel "does not apply" to `checking` without a code). Leaving it implicit invites a future probe author to "fix" it the other way; pinning + flagging follows the established writer-flagged-unratified-surface pattern (§ADR-9 AM8 precedent).

---

## F7 — Metadata / citation staleness

**What:**
- **(a) binding_sources L9:** update to *"DEPOSIT-010 — S2 ratified 2026-06-08 (depfix top-up); 7 ACs + M4 idempotency posture + 3 edge cases, ~L673-721 at main `9e69725`"*. Add a cite line for **§ADR-11** (the M4 idempotency-exemption mirror) — it is load-bearing for F1's no-Idempotency-Key note. Note in passing the story's own Sources block already carries this (`epic-deposit.md:714`).
- **(b) §5 Build delta:** reflect F1 (RPC gains the `already_cancelled` outcome) + F2 (precondition gains the deadline clause + `p_now` clock arg if not already present). If the migration already shipped, this becomes a small forward migration revising `cancel_deposit` — same single-transaction shape, no schema change.
- **(c) §5 "Open consideration" (L170-174 — the no-RBAC-permission note):** **keep as-is.** It is correct: the ratified ACs gate on tenant-scope only; adding `deposit:cancel` would be unprobeable gold-plating. No change.

**Why:** (a) the stale "5 ACs ~L652-688" pointer is how this divergence survived — the spec cites a story snapshot that no longer exists; every future reader re-anchors on the wrong AC set. (b) keeps the §5 delta list true to the contract above it. (c) recorded explicitly so the rev does not "helpfully" expand scope.

---

## What NOT to touch

- **§0 auth substrate** (stub bearer, `verify_jwt = false`, effective-client resolution) — matches DEPOSIT-008/012 conventions; unchanged.
- **§1c 403 tenant-scope** — matches epic AC `:696` exactly.
- **O5 daily-slot-not-freed** + **O6 finalize race-guard** — match epic AC `:698` and edge `:703` (finalize-loses direction); unchanged except the F4 race-note addition.
- **`cancelled_at` column choice (O2)** — a reasonable spec-level pin (parity with `expired_at`/`paid_at`); the epic does not name it, no conflict.

## Done-when (verification checklist)

1. `grep -n "cancelled" docs/spec/deposit-010-client-cancel-slice.md` shows `cancelled` in NO 409 list; the M4 echo section exists.
2. The spec contains no reference to `callback_logs`.
3. §4 maps **7** ACs incl. M4 + 404, and the harness self-check names the M4 de-bias.
4. The RPC contract names outcomes `{cancelled, already_cancelled, not_found, not_pending, slip_present}` and the precondition carries the effective-pending deadline clause.
5. binding_sources cites the 2026-06-08 story shape + §ADR-11.
6. If code already exists: `cancel_deposit` migration + `deposits-cancel` EF + probes re-run green against the revised contract (and the M4 probe demonstrably fails against the old 409 behavior).
