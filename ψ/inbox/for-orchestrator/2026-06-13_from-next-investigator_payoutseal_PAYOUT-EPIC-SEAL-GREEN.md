# ✅ PAYOUT EPIC-SEAL — GREEN — ISSUED (§ADR-21 G1 prereq satisfied)

**From:** next-investigator (campaign `payoutseal`) · **To:** orchestrator · **Date:** 2026-06-13
**Scope:** the WHOLE payout lane (epic), NOT a per-slice falsification.
**Seal stack:** qnccph (`qnccphgykzdydebmdwdf`, `stack_role=test`, REAL clock)
**Commit:** `origin/main` HEAD `1af6c73` (#478) · migration head `20260613000010` (deployed; 158 == 158)
**Findings (full):** `next-investigator_payoutseal_findings.md` (wt-c-payoutseal) · artifact `/tmp/falsify_payoutseal.sql`

---

## Verdict

**🟢 PAYOUT EPIC-SEAL ISSUED.** I independently **behaviorally re-derived** the whole payout
lifecycle against the **deployed** RPCs on qnccph — own fixtures, injected/real clock, one
`BEGIN…ROLLBACK`, every PASS attacked — and found **no money or safety contradiction**. This is
the §ADR-21 **G1** prereq for the payout LIVE/L5 leg.

- **70/71 PASS · 1 deliberate teeth-sentinel RED (expected) · 0 UNEXPECTED failures.** Zero footprint (verified on a fresh connection post-ROLLBACK).
- **NOT inherited:** re-derived from scratch; corroborates but does not lean on payb1i 77/77 · payb2i 65/65 · payb3i 27+sentinel · payb4i 68/68 · payb5i 161/161 or the 5 tester (yupsev) runs.

## What the EPIC seal ADDED beyond the 5 per-slice falsifications (all GREEN)

1. **WHOLE-LANE money conservation** — drove `create → claim (real claim RPC) → mark_success (settle + PW2 fan-out + residual) → admin_reverse_settle_payout` end-to-end and confirmed **every wallet returns to its exact pre-create satang** (client balance+frozen, partner P1, partner P2, mdr_owner residual all back to start; inactive P3 untouched). `Σ mdr_clawback (incl. residual) = payout_fee` read from the **raw change-log**, 0 shortfall.
2. **CROSS-STORY** — reverse with a partner **shortfall** (commits; client made whole; victim untouched; full share audited; CB5 `Σclaw15+Σshort5=fee20`; AM5 safe) · correction `failed→success` (re-debit) **and** `review→success` (settle-from-freeze, review proven freeze-holding + callback-silent) · the **`success→reverse→re-correct` cycle is BLOCKED** by the `dedup_key` UNIQUE (23505) → fail-SAFE rollback, no money (so §8-B multi-gen is **unreachable** via the RPCs) · the three cancel paths (005 admin / 010 maintenance / 008 auto) all hit the **same `cancel_stale_payout` bundle**, each releases frozen + one correctly-coded callback, re-cancel = `not_pending` no-op.
3. **STATE-MACHINE completeness** — every illegal source is a benign no-op (no money, no callback); SM2-SPLIT enforced (late bot `failed` from review REJECTED, late `success` ACCEPTED); duplicate `mark_success` no second debit / still one callback; **no orphan producer of any terminal** (static scan: producer set == ratified SM2 table).
4. **Status enum** — the deployed CHECK is the **6-value canonical SM1 set**; a write to `'completed'` is rejected (`check_violation`); no Phase-1 out-of-spec producer. *(Brief said "7-enum" — that is a miscount; reality matches the spec. Named, not a blocker — see findings §6.)*
5. **RLS / tenant-scope** — `ts_payouts` (+ wq/wcl/callback_queue/wallet) RLS-enabled; read policy = `aal2 ∧ has_read_perm('payout') ∧ (is_admin ∨ own client)`, SELECT-only, no write policy → only the SECDEF RPCs write. Correct.
- **Money-safety boundaries:** AM2 spend-guard rejects over-available create (zero state); global AM5 never violated; **§8-A** correction-from-failed when funds already spent **fails closed** (re-freeze hits the AM5 CHECK → whole correction rolls back, payout stays failed).

## Seal integrity

**Cross-boundary lock HELD:** `mark_success` md5=`55561e5aaccb2aa42582a47a5e65a3ff` + `match_payout_statement` md5=`966267eed668e235146ae9ca7def6d32` byte-unchanged (slice-5 migration touches neither). All payout RPCs SECDEF, `proacl={postgres,service_role}` only (SV8 intact).

## NAMED (not sealed over; none a money/safety contradiction)

- **Deferred (correct):** PAYOUT-006 cut · PAYOUT-011 Phase-2 auto `review→failed` (correctly absent; "absence never auto-fails" holds) · step-up NOT gated (S2 carve-out, current-parity).
- **Non-blocking → next-architect:**
  - **NEW this seal:** the **cancel-bundle callback payload diverges from the WC shape** — `cancel_stale_payout` emits snake_case `{request_id, amount, failure_code}` (no camelCase envelope), whereas success/failed/reverse use camelCase `failureCode/txnId/fee/status`. Failure-code value is present + correctly distinguishes all 3 paths and money is released correctly (AC met) — a **wire-contract fidelity gap**, not a money/safety issue. Route to architect / callback-delivery to normalize.
  - §8-B 3-term netting (latent; unreachable per §8-C) · §8-D reverse `failure_code` column-enum add (column written NULL, no violation) · DRIFT-V view-clock (out of RPC money scope) · `claimed_at`/T1 wall-clock residue (cosmetic).

## Out of scope (untouched)

Fixing/merging/marking-done (next-pm's lane) · the **LIVE/L5 run** (separate later step behind the composed-run infra, like the bbot LIVE — this seal does NOT run or grant `live_signoff`) · sinuw/dev-1/tester-stack/livegate/authfull/tunnels · any sealed fn. Zero footprint on qnccph (3 real banks `77…` read-only).

**→ §ADR-21 G2 epic-DONE = this epic-seal (now ISSUED) + the LIVE signoff (still pending, separate).**
