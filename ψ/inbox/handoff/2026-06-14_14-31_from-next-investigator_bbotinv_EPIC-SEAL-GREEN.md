# [from next-investigator → orchestrator bbot] EPIC SEAL ISSUED — 🟢 GREEN — BBOT-010/011/012/013

**Campaign:** bbotinv · **de-bias layer 2 (TRUTH DB)** · 2026-06-14 · build = PR #495 `campaign/bbotbot`

## VERDICT: 🟢 EPIC SEAL ISSUED — GREEN. No failed lane. next-tester's 115/115 is CONFIRMED by truth data.

I independently FALSIFIED the tester GREEN against the **truth database** (not harness flags, not the
tester's word, not dev code-as-proof). **59 independent re-derivations, all reconcile, 0 contradicting
discrepancies.** Behaviour proven by *executing the deployed RPCs* + *reading raw tables* inside
`BEGIN…ROLLBACK`, plus my own `openssl` HMAC vs the live EFs.

**Truth-DB access used:** option (b) — direct DB on tester stack **yupsev** (`yupsevcrubgprsbujbpu`, mig head
`20260614000040`) via the `tester.env` DB password over the IPv4 session pooler. Already provisioned → no
brew-ops wait. De-bias-valid (my own fixtures + raw re-derivation). Cross-checked sealed-fn bodies on my
OWN seal stack **qnccph** (independent 2nd stack).

## What I confirmed from RAW data
- **PAYOUT seal HOLDS (highest stakes):** `claim_withdrawal_items` does NOT mutate `mark_success`/`mark_failed`/
  `mark_review`/`match_payout_statement`. Proven 3 ways — (1) no bbot migration redefines them (the diff is the
  6 new files only; `…000020` references them only in a comment); (2) the defining files are byte-identical
  main↔bbotbot, `…000110` unchanged since payout-seal commit `1af6c73`; (3) deployed `md5(prosrc)` is
  **identical on yupsev AND qnccph** (mark_success `65ed78f1…`, match_payout_statement `d0abcef7…`). Behaviour
  re-derived live: claim drives `ts_payouts pending→processing`, mark→`review` (uncertain never failed/success).
- **BBOT-010 (25/25):** TTL gate `>app_now()` + virtual-clock flip; non-consuming re-read (get_bot_otp is
  `sql STABLE` → structurally can't write); expired/never both collapse to 0 rows; wildcard `'_'`=freshest
  OVERALL; no cross-acct leak; save append-only + `app_now()+300` TTL + the RAISE matrix (incl. `invalid_source`
  RAISE not coerce = tester C3 confirmed); Plane-B `verify_otp_producer` env-scoped, 401-only matrix, **NO 403**.
- **BBOT-011 (15/15 — money+security core):** W1 two-branch (pool_id NULL claims on method-less bank, pool_id
  NOT NULL doesn't); `claimed_by` keystone; one-batch lock; checkpoint advance + one-shot (`COALESCE`); **RPC-level
  claimed_by binding** on `record_bank_refs` (B≠owner → FOUND=false, no mutation); fetch-processing isolation;
  budget gate; mark→review.
- **BBOT-012/013 (13/13):** `set_withdrawal_evidence` latest-wins + RPC-level binding + proof NOT on ts_payouts;
  heartbeat `last_heartbeat_at = app_now()` **exactly Δ=0** (virtual-clock stamp, days off wall) + LOAD-BEARING
  availability + dual_control.
- **EF security keystones (6/6, my own HMAC):** no-key→401, A-key-naming-B→**403 bot_account_mismatch**,
  own→404-collapse, no-producer→401, wrong-sig→401, POST-to-GET→405. Both planes live on the right plane.
- **Posture:** all 18 bot RPCs SECDEF + execute-revoked (postgres/service_role only); both new tables
  RLS-on/0-policy/0-anon-grant; `ts_payouts` 6-enum + 0 proof cols.

## Non-blocking observations (→ architect/next-dev)
1. **OR4 ref-extraction:** the DB stub `save_bot_otp(p_message)` DOES extract `ref=REFZZ`, but the `bot-otp-log`
   EF parses otp in TS and passes `ref='_'` (tester saw '_'). Money value identical (998877). 1-line SPEC tidy.
2. **mint RPC sig (resolves tester C1):** deployed `mint_otp_producer_credential(p_enc_key,p_env,p_actor_type,
   p_actor_id uuid,p_actor_username,p_reason)` — extra `p_actor_id` vs the tester's bound shape. Mint path real,
   cred verifies. Pin the sig in SPEC.
3. **mark-binding is EF-only** by design (sealed mark_* have no claimed_by param; RPCs execute-revoked so not
   bot-reachable directly) — sound, noted.
4. **MEMORY fix:** prior index md5 `55561e5…`/`966267e…` were a stale different hashing; real prosrc md5s are
   `65ed78f1…`/`d0abcef7…` (identical across both live stacks). Seal intact — false alarm reconciled.

## Method/footprint
All DB work `BEGIN…ROLLBACK` (sys_clock is table-backed → clock rolls back); EF probes read/reject-only.
**Zero footprint verified:** otp_logs/withdrawal_queue/ts_payouts probe rows=0; account A restored
(online/1,000,000/deposit+payout); producer_creds=1; sys_clock=real.

## Out of scope (untouched): merging #495 (note: next-dev-2 flagged #495⟷#496 both edit bot-config/index.ts →
one-line conflict on 2nd merge), marking done (next-pm), LIVE/§ADR-21 signoff (separate, pending).

Full report: `next-investigator_bbotinv_findings.md` (wt-c-bbotinv).
