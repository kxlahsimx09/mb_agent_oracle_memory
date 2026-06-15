# next-code-reviewer — PAYOUT slice 4 review (campaign payb4r)

**Date:** 2026-06-13 · **Branch:** `campaign/payb4r` (wt-c-payb4r) · **Reviewer:** next-code-reviewer
**Step-3 three-dimension review** (requirement / clean-code / perf), one COMMENTED review per PR.

## Verdict

| PR | Title | Verdict |
|---|---|---|
| **#472** | build: payout slice-4 — PAYOUT-007 resend + PAYOUT-009 statement-reconcile/audit (§ADR-20 clock fixes) | ✅ **APPROVE** — no blocking findings |
| **#473** | test: slice-4 resend + statement-reconcile probes (`_rr` modules + `run-payout-rr.ts`) | ✅ **APPROVE** — no blocking findings |

House rules honored: **DID NOT MERGE.** Self-merge deferred — gated on my APPROVE (✅ done) **+ investigator GREEN** (falsifying in parallel, not yet returned) + owner. No code edited (review-gate only).

---

## PR #472 (build) — verification matrix

Diff vs `main` = 5 files: `supabase/migrations/20260612000260_payout009_reconcile_clock_grace.sql` (ADD, 192L), `supabase/functions/payout-resend-callback/index.ts` (MODIFIED, +3/−1 comment-only), `SPEC-BROADCAST.md`, `docs/spec/payout-resend-reconcile-slice.md` (ADD), `next-dev_payb4_findings.md` (ADD).

| # | Focus | Result | Evidence |
|---|---|---|---|
| 1 | Renumber 250→260 clean | ✅ | File is `…000260`; only "250" residue is in explanatory comments. `git ls-tree` shows no leftover `…000250`-named reconcile/grace file on the branch; no dangling reference. |
| 2 | `sweep_payout_reconcile` | ✅ | 2-arg `(p_lookback interval, p_now timestamptz DEFAULT NULL)`, `v_now := COALESCE(p_now, app_now())`. Old 1-arg `DROP FUNCTION IF EXISTS …(interval)`. SV8 tight grant (`REVOKE … FROM PUBLIC, anon, authenticated` + `GRANT … TO service_role`). Flag-gate is FIRST stmt (`IF NOT _payout_auto_reconcile_enabled() THEN RETURN`). Never-auto-fail preserved (only invokes matcher + `RETURN NEXT`; per-row `EXCEPTION→CONTINUE`; fails nothing). |
| 3 | Primary vs safety-net distinction | ✅ | PRIMARY = inline `match_payout_statement` (bot-statements EF); this = pg_cron 1-min catch-up over pending OUT statements. Zero-arg cron resolves to the 2-arg fn after overload drop. |
| 4 | `v_success_payout_audit` | ✅ | `CREATE OR REPLACE VIEW`; grace predicate `now()`→`app_now() - completed_at > grace_window`; 18 cols unchanged (match §5.7). DETECTION-ONLY: pure SELECT, every referenced fn is read-side, no INSERT/UPDATE/DELETE/side-effect. |
| 5 | Success leg delegates to `mark_success` | ✅ | No reimplementation; `mark_success` not in diff (inherits SM2-SPLIT/AM2/PW2/PV1-R). |
| 6 | **CRITICAL cross-boundary** | ✅ **PASS** | `grep 'FUNCTION.*(match_payout_statement\|mark_success)'` over the full diff → NONE redefined. Both appear only as a call + comments. bbot-seal + slice-1 lock **byte-intact**. Not a blocking finding. |
| 7 | EF comment-only | ✅ | Entire hunk is the JSDoc header (`§ADR-2 JWT (stub)` → real-gotrue note). Net +2 comment lines, zero behavior diff. |
| 8 | No `_shared/*` edits, deposit sibling untouched | ✅ | `_shared/` absent from diff; `deposit-resend-callback` untouched. |
| 9 | Migration safety | ✅ | Forward-only (`…000260` max). Idempotent: `DROP IF EXISTS` / `CREATE OR REPLACE FN` / `CREATE OR REPLACE VIEW` / idempotent `REVOKE`+`GRANT`. `SET search_path=public`. |

**Clean-code:** header comment exemplary (documents both drifts + renumber + §4.2 lock). Minor non-blocking: per-row `EXCEPTION WHEN OTHERS THEN CONTINUE` swallows errors silently (defensible for a "don't stall the tick" safety-net; a future hardening pass could add `RAISE WARNING`/a skip counter).

**Perf:** sweep predicate `direction='out' AND match_status='pending' AND created_at > v_now - p_lookback ORDER BY created_at ASC LIMIT 500` runs per-minute. Shape is **pre-existing** (unchanged from the 1-arg sweep bar the clock var) → no new regression. Forward-looking: confirm an index on `bank_statements(match_status, direction, created_at)` backs the partial scan at scale.

### Merge-ordering / SV8 interaction (verified, non-blocking)
- Branch is **behind main**: it lacks the merged `…000240` (SV8 revoke, #463) and `…000250` (adr10 rm_residual). `gh` reports `MERGEABLE`; `…000260` is the highest number → forward-only holds on a full-main apply.
- **No interaction with #463/000240.** 000240 revokes a *different* 6 fns: `create_payout`, `_payout_stuck_review_minutes`, `mark_failed_from_review`, `sweep_payouts_bank_maintenance`, `sweep_stale_claims`, `sweep_stale_payouts`. It does **not** touch `sweep_payout_reconcile` (ours ships its own tight grant) nor the 7 reconcile/audit fns.

### Routed observations carried (NON-BLOCKING — confirmed accurate)
1. **SV8 latent exposure still open** on the 7 pre-SV8 reconcile/audit fns (`_payout_auto_reconcile_enabled`, `_extract_payout_request_ids`, `reconcile_payout`, `_payout_memo_carries_request_id`, `_payout_audit_grace_window`, `classify_success_payout`, `match_payout_statement`) — #463/000240 did NOT cover them (verified above). Fold into the next `execute_or_no_grants` batch. → next-architect.
2. Grace-knob name divergence: substrate `payout_audit_grace_window` vs requirements-doc `payout_confirm_grace_minutes`. → next-writer/architect (reconcile docs to substrate, not vice-versa).
3. DRIFT-V read-view-clock `now()` residue (`v_payouts`/`v_payouts_read`/`v_deposits` effective_status) + deposit-sibling stale `§ADR-2 JWT (stub)` comment — out of slice, already routed.

---

## PR #473 (test) — verification matrix

Diff vs `main` = 12 files (11 ADD `*-rr.ts`/`p007`/`p009`/`readiness-rr`/`run-payout-rr`/evidence/findings; 1 MODIFIED `payout-selfcheck.ts`), 3282 insertions, **zero `supabase/` code**.

| # | Focus | Result | Evidence |
|---|---|---|---|
| 1 | SPEC-not-impl binding | ✅ | `_spec-rr.ts` binds exclusively to `origin/build/payout-slice4:docs/spec/…` via `git show`; explicit de-bias block. `grep 'import .*(supabase/\|functions/\|migrations/)'` across all probes → empty. `UNBOUND=false`. |
| 2 | §4.2 contract lock | ✅ | Probes assert `match_payout_statement` stated outcomes; contract-question escape hatch (`SPEC_RR_PENDING_BINDINGS` + findings §contract-cross-check) wired + in evidence JSON. |
| 3 | Additive `_rr` siblings | ✅ | 11 new modules; `payout-selfcheck.ts` is purely additive (new import + new `rr_*` section after `cs_*`). Zero deletions; no slice-1/2/3 selfcheck mutation. |
| 4 | Fixture restoration in `finally` | ✅ | Flag restored `flagOrig ?? "true"` (ships-ON) per-probe (`p009-reconcile.ts:305`, `p009-audit.ts:240`); clock reset in orchestrator + per-probe `finally`; `teardownResendBearers` deletes all 5 SEED gotrue subs. 2nd tenant read-only resolved; synthetic id is a const. |
| 5 | readiness-rr fails loud | ✅ | Core R1–R6 → `allCore=false → deployed:false` → fixture lanes BLOCKED-ON-DEPLOY (never green) + `exit(1)`. 2-arg sweep probed explicitly. Soft R7/R8 justified (self-seeded flag; cron not over PostgREST). |
| 6 | No secrets | ✅ | Cross-file scan → none. `Pw!deposit1111` is an inherited convention already on `main` (`auth/_authctx.ts`, slice-2 `_flow-rc.ts`) — test-gotrue seed, not a new leak. |
| 7 | Evidence JSON clean | ✅ | 51/51 GREEN, 5 lanes GREEN; full provenance; `stack`=yupsev URL (not a secret); secret scan NONE. |

**Clean-code:** strong self-check discipline (every `rr_` predicate GREEN-on-valid + RED-on-violation → 120/120). Lane gating + `laneOf()` clear; `BLOCKED-ON-DEPLOY` details carry owner + findings pointer.
**Perf:** N/A (probe harness; bounded reads, single run-scoped mint+teardown).

---

## Process notes
- On-PR reviews posted (COMMENTED, verdict in body header): #472 and #473.
- Did not re-run the suite (tester's lane); review-gate pass on the diff. Tester reports 51/51 GREEN on yupsev + `tsc --strict` 0 errors, structurally corroborated.
- Self-merge held: awaiting investigator GREEN (`next-investigator_payb4i`) before any merge, then owner. (Fleet review-gate rule + DO-NOT-MERGE charter.)
