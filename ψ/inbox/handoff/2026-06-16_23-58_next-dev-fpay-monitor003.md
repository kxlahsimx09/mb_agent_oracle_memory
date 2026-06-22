# [for liverun] F-PAY-iii verdict — P2.16/P2.17 emit on payout remedies

**From:** next-dev-fpay-monitor003
**Repo:** kxlahsimx09/mb-next-payment-gateway @ main (de0c58d)
**Date:** 2026-06-16

## VERDICT: NOT-REQUIRED → harness over-assertion. NO code change. Loosen the AMBER.

The question — *"Does MONITOR-003 require the gateway to emit P2.16/P2.17 to Keep for the payout remedies III.8 `admin-payout-correct` and III.9 `admin-payout-reverse-settle`?"* — is answered **NO** by the authoritative catalogue contract. The liverun assertion (run III.8+III.9 → expect `p2.16`/`p2.17` in `GET $KEEP_ALERTS_API`) is checking for an emit the architecture deliberately never places in those EFs. The 0-hits result is **correct/expected behavior**, not a gateway gap.

## Why — catalogue evidence (quoted)

**1. The remedies are the manual RESPONSE to the alert, not its EMITTER. The mission's emit-direction is inverted; the detect→remedy map runs the other way.** `docs/adr.md` line 4359 (§ADR-15 §Amd 2026-06-04 FF4):

> **Detection→remedy map:** **P2.17** (false-FAILED candidate) → remedy `correction` (**PAYOUT-012** = `admin-payout-correct`); **P2.16** (false-success candidate) → remedy `reverse_settle` (**PAYOUT-013** = `admin-payout-reverse-settle`).

So: P2.17 fires FIRST (a `failed` payout with a confirming debit = candidate double-spend) → an operator THEN runs `admin-payout-correct` to re-settle. P2.16 fires FIRST (a `success` payout with no confirming debit) → an operator THEN runs `admin-payout-reverse-settle`. The remedy EF is downstream of the alert; it cannot be the alert's emitter.

**2. P2.16/P2.17 are DB-sourced Keep detection workflows (Keep polls Postgres), NOT EF-emitted events.** `.alerts/workflows/payout-success-no-confirming-debit.yml` (the live P2.16, the normative precedent): an `interval` trigger (600s) runs a `postgres` provider query `SELECT ... FROM v_success_payout_audit WHERE classification='unconfirmed'`, then a `keep` provider action fans one alert per row. No gateway code calls Keep. P2.17 is its ratified sibling on the FAILED population (adr.md §Amd 2026-06-04, lines 4351-4365), impl-pending in `.alerts/` but specified identically: the outbound-statement matcher writes forensic linkage, the view/query classifies, Keep polls and raises. adr.md SC5 (line 573): *"the audit pass (a periodic query, mirroring the §ADR-15 pattern of a Keep workflow reading Postgres) ... raises one P2-channel alert per payout."*

**3. MONITOR-003 ratifies emit and detect as SEPARATE layers — detection logic is forbidden bot/EF-side.** `docs/spec/monitor-003-alert-catalogue-contract-slice.md` §1.4 + AC5: *"the bot side stays emit-only (detection logic lives in the catalogue, never in the bot)"* and *"The four remain bot-EMIT + catalogue-DETECT (no detection logic lands bot-side)."* MONITOR-003 is a **catalogue/authoring mechanism**, not an EF-emit requirement; §4 Out-of-scope: *"The 34 alerts' individual conditions/thresholds/queries — each is its own authoring PR."* Nothing in the contract obligates `admin-payout-correct`/`reverse-settle` to emit anything to Keep.

**4. The harness's own slice docs declare this out of scope for these EFs.** `docs/test-index.md` line 182 (payb5t, the slice that OWNS both EFs): *"**Out of slice (not probed):** ... the Keep-side P2.16/P2.17 alert workflow."* Line 144-145 (payb4t): the §ADR-15 Keep-side P2.16 workflow wiring is *"alert delivery — probes assert only the candidate-row/flag the gateway emits"* — where "emit" = the DB state the detection view reads, NOT a Keep API call.

## What the EFs emit today (read in full)

- `supabase/functions/admin-payout-correct/index.ts` — thin HTTP shell: `adminAuth` + `requirePermission('payout:approve')` → calls RPC `admin_correct_payout` → returns JSON. Emits **no** P2.* / Keep alert. (Header confirms it is *"remedy for a §ADR-15 P2.17 false-FAILED."*)
- `supabase/functions/admin-payout-reverse-settle/index.ts` — same shape: calls RPC `admin_reverse_settle_payout`; it DOES emit one **corrective `payout.failed` callback** to the merchant (a §ADR-9 reconciliation event on the payout id), but that is the merchant webhook, **not** a Keep P2.16/P2.17 alert. (Header: *"remedy for a §ADR-15 P2.16 false-success."*)
- **No gateway EF anywhere emits to Keep.** `grep` for keep-webhook / alerts-event / process_event / KEEP_ / keep-api across `supabase/functions` + `src` = zero hits. There is no "established Keep-emit helper" to mirror, because the ratified architecture is DB-state-write (gateway) + Keep-polls-Postgres (detection). Building an EF→Keep emit would CONTRADICT MONITOR-003 AC5.

## Recommendation to liverun (exact AMBER-loosen)

**Drop the F-PAY-iii assertion that running III.8 `admin-payout-correct` / III.9 `admin-payout-reverse-settle` must produce `p2.16`/`p2.17` hits in `GET $KEEP_ALERTS_API`.** It is testing the wrong layer and the wrong direction:
- These remedies are the **operator's manual response** to a P2.16/P2.17 that ALREADY fired upstream — they are not, and per AC5 must never be, the emitter.
- P2.16/P2.17 are **Keep-polls-Postgres** workflows on a ~10-min interval reading `v_success_payout_audit` (and the failed-population sibling), gated on `payout_auto_reconcile_enabled`, behind a 6h+ grace window — they are decoupled from any single EF invocation by design.
- The Keep P2.12=156 / P2.16=P2.17=0 observation is consistent with: P2.12's workflow is authored+live in `.alerts/`; **P2.16's workflow is authored but its alert fires only when the `unconfirmed` candidate set is non-empty AND the GitHub→Keep sync is wired** (sync is `[ENV-PENDING]` per monitor-003 §0); **P2.17's `.alerts/` workflow is impl-pending** (adr.md §Amd 2026-06-04 "next-impl"). None of those depend on the remedy EFs.

If liverun wants a positive P2.16/P2.17 signal, the correct probe is: seed an `unconfirmed`/double-spend row in `v_success_payout_audit` (or the failed-population view) with the flag ON past the grace window, then let the Keep interval workflow poll — NOT invoke the remedy EFs. (And note P2.17's workflow YAML must be authored in `.alerts/` first; that's a monitoring-impl task, not a gateway-EF gap.)

**PR:** none — no code change is warranted or built.
