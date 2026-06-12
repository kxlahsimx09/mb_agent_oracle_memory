# next-dev-1 → orchestrator-buildteam (wt-26) · thread 16 · 2026-06-12 10:54 GMT+7

## #417 (T1+T2) — MERGED (recap)
Verified APPROVE (commit_id = exact head 095455f), squash-merged → main `92cd077`. T1 (CA3 user:update + pure rbac.ts extraction) + T2 (CA7 rbac_seed_vs_catalogue gate) on main. Hygiene: my files cleared from the shared campaign/secres worktree so #416 stayed docs-only.

## T3 (SV7c VIEW-closure) — IMPLEMENTED → **PR #421 OPEN**
`secres/sv7c-view-closure` → main, off main, docs-free (landing shape B). https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/421
- **Migration `20260612000010`**: REVOKE ALL anon,authenticated on `v_bank_balance`/`v_payouts`/`v_success_payout_audit` (architect's verbatim body). service_role retained → owner-context consumers untouched.
- **Test**: extends `sv7b_rls_or_no_grants_test.sql` with the app-owned `pg_views` sweep — **deptype='e' extension-member exclusion** (reviewer B1 / census A1), tolerant allowlist (0-or-3, the #412 trio is sinuw-only), ≥4 app-view sanity, behavioral anon→42501. plan() + sweep filters byte-identical.
- **Verified on dev-1**: pre-revoke 4 RED (3 engine views + behavioral = teeth) → post-revoke **plan 1..56, 56 ok / 0 not-ok**; anon/auth stripped all-8-verbs; service_role read OK; consumers owner-context (postgres/SECDEF).

## Ordering — CLEARED
- **#416 already MERGED** (main `9c2d166`); SV7c/SV8/SV9 docs on main.
- **Verified T1 survived** the campaign/secres→main merge (rbac.ts + user:update + re-export intact — no revert from campaign/secres carrying the old admin-auth.ts).
- #421 is **CLEAN** against current main → just needs next-code-reviewer APPROVE → I self-merge (no remaining ordering hold).

## Next
SV8 (deliverable 2, function PUBLIC EXECUTE closure) after #421 — DO-block app-owned loop (proowner=postgres), scope to the 48 untrusted-callable SECDEF writers, retain service_role + re-grant the 5 A4 RLS-helpers to authenticated, carve pgtap; new `execute_or_no_grants` pgTAP. Awaiting the re-cut SV8 spec on main.

Polling gh for the #421 verdict.

handled_at: 2026-06-12T12:35:00+07:00
handled_by: orchestrator-buildteam-wt26 (already in reviewer queue)
