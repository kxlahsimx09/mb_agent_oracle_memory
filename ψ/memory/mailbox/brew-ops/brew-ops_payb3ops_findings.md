# brew-ops — payb3ops cross-stack deploy findings

Campaign **payb3ops** · branch `campaign/payb3ops` · agent **brew-ops** on team **payb3ops**.

GOAL: Cross-stack deploy of the **PAYOUT slice-3 delta** (PR #457, branch `build/payout-slice3`)
to the TESTER stack (`tester.env` / **yupsev** `yupsevcrubgprsbujbpu`) and the
INVESTIGATOR/seal stack (`investigator.env` / **qnccph** `qnccphgykzdydebmdwdf`), then verify
readiness per-item on both. Light deploy — **no Edge Functions this slice** (2 RPC-only migrations).

---

## Deploy run — 2026-06-12T17:42Z — **GREEN on BOTH stacks**

### Source / provenance
- **Fresh isolated source**: extracted via `git archive origin/build/payout-slice3` (origin ref,
  re-fetched this session) into a throwaway workdir `/tmp/payb3-slice3` — **never** the dev worktree,
  **never** dev-1. File integrity verified by sha256 vs the origin ref:
  - `20260612000160_payout008_sweep_appnow.sql` → `73b9ac1a…3c9ada3`
  - `20260612000170_payout010_bank_maintenance_sweep.sql` → `66340292…b73b7570`
- slice3 HEAD `3899f10`; main HEAD `be9f124`.
- PR #457 diff = **exactly** `000160` + `000170` (+ `docs/spec/payout-cancel-sweeps-slice.md`,
  `SPEC-BROADCAST.md`, `next-dev_payb3_findings.md`). Confirmed scope = the two migrations only.

### Method
- `supabase db push --db-url <pooler, percent-encoded> --workdir /tmp/payb3-slice3 --yes`
  (IPv4 session pooler `aws-1-ap-southeast-1.pooler.supabase.com:5432`, `postgres.<ref>` user).
- Workdir = the **full** slice3 migrations tree **minus `000150`** (see scope note below) so the
  CLI history-consistency guard passes (all 147 remote versions present locally) while the pending
  set is **exactly {000160, 000170}**. Dry-run confirmed on both stacks before the real push.
- Both migrations are idempotent (`DROP FUNCTION IF EXISTS`, `CREATE OR REPLACE`, cron
  `unschedule-if-exists`+reschedule); re-runnable with no drift.

### ⚑ Scope note / surfaced observation (NON-BLOCKING for slice-3)
- Brief stated both stacks were "at full main parity through 000150". **They were actually at
  `000140`** — `20260612000150_rm_admin_approve_paid_residual.sql` was **unapplied on both**.
- `000150` is **NOT** part of PAYOUT slice-3 / PR #457. It is a **separate campaign** — §ADR-10
  RM corrective to `admin_approve_paid` (deposit path), directive
  `docs/spec/secres-rm-admin-approve-residual-fix-slice.md`, arch **PR #436** (secres). It rode into
  the slice3 branch only via rebase lineage.
- **Deliberately excluded** from this deploy (out of my scope). `000160`/`000170` have **zero
  dependency** on `000150` (they reference only `app_now`, `_payout_auto_cancel_enabled`,
  `_payout_pending_timeout_minutes`, `cancel_stale_payout`, `_bank_in_maintenance`,
  `bank_account.maintenance_window_*`, `ts_payouts`, `withdrawal_queue` — all pre-`000150`
  substrate, all verified present pre-flight). Slice-3 probes (PAYOUT-008/010) do not touch
  `admin_approve_paid`, so the absence does not block next-tester (payb3t).
- **Routed to orchestrator**: schema_migrations now has a hole at `000150` on both stacks
  (`…000140, [000150 absent], 000160, 000170`). A future `supabase db push` will require
  `--include-all` (or `000150` first). If secres wants `000150` on these stacks, that is a separate
  deploy task — not done here.

---

## Per-item verification checklist

Legend: **GREEN** = pass. Both stacks returned **identical** results.

| # | Check | yupsev (tester) | qnccph (investigator) |
|---|-------|:---:|:---:|
| 1 | `schema_migrations` shows `000160` + `000170` | **GREEN** | **GREEN** |
| 2 | `sweep_stale_payouts(p_batch_size int, p_now timestamptz)` — single 2-arg overload, old `(int)`-only **GONE**, SECURITY DEFINER, `service_role` EXECUTE grant, prosrc `COALESCE(p_now, app_now())`, FIRST stmt = `_payout_auto_cancel_enabled()` gate | **GREEN** | **GREEN** |
| 3 | `sweep_payouts_bank_maintenance(p_batch_size, p_now)` present, SECURITY DEFINER + grant, prosrc has `required_bank_account_id IS NOT NULL` + reuses `_bank_in_maintenance` + passes `'bank_maintenance'` to `cancel_stale_payout` + **NO** flag check (always-ON) | **GREEN** | **GREEN** |
| 4 | cron: `sweep-stale-payouts` re-pointed to `sweep_stale_payouts(500)` (new sig) **AND** new `sweep-payouts-bank-maintenance` job present, `* * * * *`, active | **GREEN** | **GREEN** |
| 5 | seeds: `payout_auto_cancel_enabled='false'` (ships OFF ✓) + `payout_pending_timeout_minutes='15'` in `app_settings` | **GREEN** | **GREEN** |
| 6 | `bank_account.maintenance_window_start/_end` columns present + ≥1 usable bank row (3 banks, 3 active: SCB/KTB/Kasikorn, windows NULL → tester sets) | **GREEN** | **GREEN** |
| 7 | clock/reset RPC sanity: `app_now`/`clock_set`/`clock_advance`/`clock_reset` all present; `app_now()` ≈ `now()` (clock at baseline, **not** left frozen) | **GREEN** | **GREEN** |
| — | Smoke (zero-footprint, `BEGIN…ROLLBACK`): `sweep_stale_payouts(500)`→0 rows (flag OFF self-gate); `sweep_payouts_bank_maintenance(500)`→0 rows (no bank in maintenance) — both **callable, no side effects** | **GREEN** | **GREEN** |

### Detail captured (identical on both stacks)
- **Item 2** overload census: exactly one row — `p_batch_size integer, p_now timestamp with time zone`, `prosecdef=t`. Old `(int)` overload absent.
- **Item 3** census: one row — `p_batch_size integer, p_now timestamp with time zone`, `prosecdef=t`; `no_flag_check=GREEN` (no `_payout_auto_cancel_enabled` in body).
- **Item 4** commands:
  - `sweep-stale-payouts` → `SELECT count(*) FROM public.sweep_stale_payouts(500)` (was no-arg `sweep_stale_payouts()`).
  - `sweep-payouts-bank-maintenance` → `SELECT count(*) FROM public.sweep_payouts_bank_maintenance(500)` (new).
- **Item 7** app_now vs wall delta < 1s on both → clocks clean for the tester's virtual-clock probes.

---

## Verdict
**Slice-3 substrate is LIVE and READY on BOTH yupsev (tester) and qnccph (investigator/seal).**
No blockers. Edge Functions untouched (none in this slice). One non-blocking observation routed
(the `000150` secres gap above) — does not affect slice-3 readiness.

→ **Stack-ready signal to next-tester (payb3t)**: both stacks GREEN; PAYOUT-008/010 probes may proceed.

OUT-OF-SCOPE (untouched): sinuw / dev-1 / livegate / authfull; merging; production code edits.
