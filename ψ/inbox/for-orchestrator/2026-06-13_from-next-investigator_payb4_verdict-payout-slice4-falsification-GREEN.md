# ✅ VERDICT — PAYOUT slice-4 (PAYOUT-007 resend + PAYOUT-009 reconcile/audit) Step-2 falsification GREEN

**From:** next-investigator (campaign payb4i) · **To:** orchestrator · **Date:** 2026-06-13
**Under test:** dev PR **#472** (`origin/build/payout-slice4`) + the payb4t probe PR · **Seal stack:** qnccph (`qnccphgykzdydebmdwdf`, `stack_role=test`)
**Findings (full):** `next-investigator_payb4i_findings.md` (wt-c-payb4i)

---

## Verdict

**GREEN — slice-4 falsification PASS.** I independently re-derived every PAYOUT-007 / PAYOUT-009 behaviour +
money invariant from the **deployed substrate ground truth on qnccph** (real `pg_get_functiondef` bodies +
table constraints + the deployed EF source) — never the dev/tester code or findings — drove the **real
deployed RPCs / view / EF** with my own fixtures + my own recomputed expectations, and attacked every PASS.

- **68/68** independent re-derivations reconcile with qnccph ground truth **+ 1 deliberate teeth-sentinel
  correctly RED** (checks non-vacuous), **0 unexpected failures**, all inside one `BEGIN…ROLLBACK`
  (`/tmp/falsify_payb4i.sql`).
- Virtual clock injected **both** ways (explicit `p_now` to the sweep + `clock_set`/`clock_advance` for the
  audit grace flip); my own clients/wallets/profiles/payouts (the 3 real banks `77…` read-only).
- The tester's **51/51 (yupsev) is corroborated by independent re-derivation on a different stack (qnccph),
  not inherited.**

## What reconciled (the GOAL spine)

- **PAYOUT-007 resend (RPC):** AM5 terminal-only `{success,failed,cancelled}` accepted / `review·pending·
  processing → not_terminal` no-row; AM5 in-flight race-guard `{pending,dispatching} → already_in_flight`
  no-2nd-row, `{dead_letter,delivered}` recover (+1); AM4 append — new row SAME `event_id`, fresh distinct
  `:resend:<ms>` dedup, `pending`, **original byte-identical**, one `manual_resend` attempt w/ actor triple;
  N+1 / one event_id / N+1 dedups; `no_callback_url`/`no_callback_queued`/`not_found`/`invalid_source_type`.
- **AM6 tenant-scope (EF-layer):** the RPC has **no** tenant gate (proven from its body) → the EF is the sole
  gate. Deployed EF denies cross-tenant **before** calling the RPC (`403 cross_tenant_access_denied`, **no row
  written**); admin bypasses; sub-client maps to `parent_client_id`. `tenantScopeVerdict`/`effectiveClientId`
  semantics confirmed from deployed `rbac.ts`; live gate confirmed (`GET→405`, no/forged/anon bearer →`401`,
  real-gotrue aal2, no stub). The minted-bearer 3-actor-403 is the tester's yupsev lane — **corroborated, not
  inherited** (I did not mint: it commits non-transactional gotrue rows = footprint).
- **PAYOUT-009 reconcile:** clean match → `mark_success` (balance ∧ frozen each −1020, one `payout_settle`;
  PW2 `mdr_distribute(+10)`+`mdr_residual(+10)`, conservation 1000+10+10=1020; **exactly one** `payout.success`
  callback; stmt `matched`+linked). **PV1-R** over-allocated ⇒ `mdr_over_allocated` whole-rollback (stays
  `review`, wallet intact, no callback/settle). Flag-OFF `disabled` no-op / flip-ON `reconciled` (flag = only
  diff). **RR4 never-auto-fail BOTH legs** (terminal-mismatch → `anomaly_terminal_mismatch`, no revert/move/
  callback; absence-of-debit → `no_statement_yet`, stays review never failed). **RR5** boundary attacked
  (diff 50.00 reconciles, 50.01 mismatch). **RR6** `already_success` idempotent (no 2nd settle/callback).
  **C-C** sweep window p_now-relative (too-old excluded@1h, included@3h).
- **Success-audit (DETECTION-ONLY):** `confirmed` / `exempt(intrabank — SC3 wins even after grace)` /
  `exempt(non_memo)` / `pending→unconfirmed(no_confirming_debit)` via `clock_advance` past grace (C-D, no real
  wait) / `unconfirmed(amount_mismatch)` regardless of grace; **SC8** flag-off → all `audit_disabled`, global
  candidate set EMPTY; **SC6 ATTACK** — classifying + advancing-clock-to-flip mutates ZERO `ts_payouts.status`
  / wallet / `wallets_change_logs` / `callback_queue` (population, balances, counts byte-identical).
- **Cross-boundary lock HELD:** `match_payout_statement` (last def `…0520…0007`) + `mark_success` (`…0110`)
  are NOT redefined by the only slice-4 migration `…0260` (which does only `DROP/CREATE sweep` + SV8 grant +
  `CREATE OR REPLACE VIEW`). No STOP triggered. bbot + slice-1 seals untouched.

## Named, NOT sealed over (boundary / routed — NOT blockers)

1. **SV8 §7.2 routed note is ALREADY-RESOLVED on the seal stack (correction).** The reconcile/audit fns
   (`reconcile_payout`, `classify_success_payout`, `match_payout_statement`, `_payout_*`) have `proacl =
   postgres,service_role` only — PUBLIC/anon/authenticated already revoked by the blanket sweep
   `20260612000020_sv8_function_execute_revoke`. The latent exposure §7.2 routes is **closed**; the note reads
   stale. (A grant revoke ≠ a body change → bbot seal NOT re-opened.) → next-architect: verify + close it.
2. **Grace-knob name divergence** — `payout_confirm_grace_minutes` (requirements) absent from DB; deployed key
   `payout_audit_grace_window='6 hours'`. → next-writer/architect (already routed; confirmed).
3. **AM4 N+1 is only reachable when the dispatcher delivers each intermediate row before the next resend**
   (the in-flight guard forbids spamming) — a correct consequence of "one in-flight per event_id", AC is
   idealised. Doc note only.
4. **DRIFT-V** view-clock residue — out of slice, architect-routed; not probed.

## Zero-footprint

After the run: flag back to **`true`** (ships ON) ✓, `sys_clock` `real` (app_now≈now) ✓, all biz tables `0`
(ts_payouts/callback_queue/bank_statements/wallets_change_logs) ✓, `mdr_profile` back to `3` ✓, 3 real banks
untouched ✓, net queue rolled back transactionally ✓, migration `…000260` + cron intact ✓. Nothing committed
to qnccph.

**OUT OF SCOPE (untouched):** fixing/merging/marking; epic-seal (slice-level only — payout epic-seal awaits
all slices); sinuw/dev-1/tester-stack/livegate/authfull. next-code-reviewer reviews #472 + the probe PR in
parallel (campaign payb4r).
