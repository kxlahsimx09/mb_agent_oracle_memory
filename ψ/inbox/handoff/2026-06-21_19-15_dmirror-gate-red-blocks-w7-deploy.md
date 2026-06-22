# HANDOFF → next-tester — dmirror gate.sh is RED (blocks W7 staging deploy)

**From:** brew-ops · **To:** next-tester (dmirror owner) · **Date:** 2026-06-21 (GMT+7)

**Why:** brew-ops ran `dmirror/gate.sh` as the binding pre-deploy gate (brew-ops SKILL §8)
before a workflow-7 staging deploy. It returned **RED**, so the deploy is held. Both RED legs
are **dmirror harness issues, NOT defects in the gateway/portal code** that would deploy.
Please fix + re-green, then ping brew-ops. Full doc also at
`mb-next-bank-bot.wt-c-dmirror/dmirror/HANDOFF_gate-red_2026-06-21.md`.

## What's RED
```
G0 mirror+gateway    : GREEN
G1 withdraw lane     : FAIL   ← primary blocker
G2 deployed substrate: FAIL   ← harness drift
```

## G1 — withdraw lane FAIL (root cause VERIFIED) = seed predates a new gateway feature

Symptom: `drive-payout.sh` seeds a `pending` item then calls `bot-claim` 6× — item never
leaves `pending|-` (`dmirror/drive-payout.sh:64-73`) → `fail: item not claimed`.

Root cause: GW-X-02 "Model B reservation" migration
`mb-next-payment-gateway/supabase/migrations/20260621000900_gwx02_model_b_reservation.sql`
added a fail-closed balance-freshness guard to `claim_withdrawal_items` (lines 196-211):
```sql
IF v_bank.balance_updated_at IS NULL
   OR v_bank.balance_updated_at < v_now - make_interval(secs => 300) THEN   -- v_now = app_now()
    PERFORM emit_monitoring_alert('stale_balance','P2', ... 'reason','never_scraped');
    RETURN;   -- empty claim
END IF;
```
Verified against mirror DB (`postgresql://postgres:postgres@127.0.0.1:54322/postgres`):
```
SELECT id, balance, balance_updated_at FROM bank_account
WHERE id='77777777-7777-7777-7777-000000000001';
-- → 77777777-…-0001 | 1000000.00 | NULL   ← balance_updated_at is NULL
```
Nothing scrapes balances in the mirror, so `balance_updated_at` is never stamped. The
`drive-payout.sh` seed predates this guard — freezes wallet + queues item but doesn't stamp
bank freshness. Same class as the existing "freeze wallet at intake is a SEED rule, not a
gateway bug" note.

Proposed fix (seed-fidelity): in `drive-payout.sh` step [1/5], stamp the SCB bank fresh
BEFORE the claim — relative to `app_now()` (the guard uses the §ADR-20 virtual clock):
```sql
UPDATE bank_account SET balance_updated_at = app_now() WHERE id = '${SCB}';
-- or call bot_update_balance(...) which stamps balance_updated_at (GR4)
```

## G2 — deployed-only substrate FAIL = mirror drift (containers up ~4 days)

`assert-bugs`: 4 RED-reproduced, 2 missed:
- B1+B2 (in-memory session/approval-queue wipe on restart): MISS — expected restart→reset to
  TXN1, got TXN4,TXN5 then TXN6 (kept incrementing, no reset).
- PKG (payout-app.js packaging gap): MISS — expected `MODULE_NOT_FOUND` from image, didn't occur.

Containers Up 3-4 days (`dmirror-bot/payout` 4d, `portal-1/2` 3d). A miss = harness can no
longer prove it reproduces those deployed-only failure modes → fail-closes. Likely mirror
drift: confirm the bug classes are genuinely fixed (update assertions) OR rebaseline the
mirror (rebuild `mb-next-bank-bot:sim`, restart the 4 containers from a clean seed).

## After you re-green
1. `cd dmirror && ./gate.sh` → exit 0 (GREEN).
2. Ping brew-ops. W7 is now fully scripted — brew-ops runs
   `mb-next-payment-gateway/scripts/deploy-staging.sh --deploy --pull-main`, which re-runs
   this gate itself and refuses to mutate unless GREEN.

Context for the waiting deploy: staging is ~40 migrations behind main (incl. `20260621000900`
above), 20 EF families missing + ~84 EFs stale, admin-UI ~29 commits behind — genuinely needed
once the gate clears.
