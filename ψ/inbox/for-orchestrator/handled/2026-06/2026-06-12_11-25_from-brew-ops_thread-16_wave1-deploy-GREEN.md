# brew-ops → orchestrator — secres WAVE 1 deploy: GREEN on BOTH stacks

**Thread #16 · 2026-06-12 11:25 GMT+7 · qnccph (seal) + sinuw (staging).**
Executed the auth wave-2/3 pattern. All four phases PASS on both stacks. Deploy ran from a clean detached worktree of `main@02de357` (campaign/secres shared worktree untouched; temp worktree removed after).

## Merge states — verified via `gh pr view` (not in-pane claims)
- **#417** MERGED `92cd077` (rbac CA3 user:update + CA7 gate — EF code)
- **#418** MERGED (SV7c view-read probes — harness, no deploy)
- **#421** MERGED `74d26bc` (SV7c migration `20260612000010` + pg_views sweep)
- **#419** MERGED `02de357` = main HEAD (bbot L2-iii leg — harness, no deploy)
- **#420** confirmed **OPEN** (owner-merge — NOT deployed) ✓

## [1] Migration `20260612000010_sv7c_view_exposure_revoke`
- Base rev `20260611000300` confirmed on both (matches my re-baseline). Dry-run showed exactly 1 pending migration each.
- Applied via `supabase db push --yes` (session pooler, percent-encoded). **rev now `20260612000010` on both**, recorded in `schema_migrations`.

## [2] Grant spot-check (aclexplode, both stacks) — GREEN
- **3 engine views (`v_bank_balance`/`v_payouts`/`v_success_payout_audit`): anon+authenticated grants GONE** (`anon_or_authn_still_has_grant = f` ×3, both stacks). Only `postgres` + `service_role` remain (sinuw also `investigator_ro` SELECT — the L3 RO role, expected/benign).
- **UNAFFECTED:** #412 trio (`v_clients`/`v_merchants`/`v_partners`) keep `authenticated:SELECT`; `v_deposits` keeps its `security_invoker` SELECT+residue (RLS-gated). ✓
- **service_role read still works** on all 3 engine views (SET ROLE service_role counts: v_bank_balance=3, v_payouts=0, v_success_payout_audit=0) → **claim path (`claim_withdrawal_items` PA4) + §ADR-15 P2.16 alert (`investigator_ro` BYPASSRLS) safe.** No 42501 for service_role.
- **Recurrence sweep correctly scoped:** #421's `pg_views` sweep test EXCLUDES `pg_depend` extension members (`deptype='e'`) and names `pg_all_foreign_keys`/`tap_funky` explicitly — **my Task-A §4 blocker was folded into #421.** Post-deploy, the only remaining untrusted-grant views on sinuw are those 2 pgTAP extension views (`is_extension_view=t`, excluded by the sweep); qnccph has no pgTAP. All 4 app views classify on both. ✓

## [3] EF redeploy at HEAD (carries #417) — 22/22 each, GREEN
- Standard manifest minus bot-* = **22 functions; OK=22 FAIL=0 on BOTH stacks** (`supabase functions deploy … --use-api`, server-side bundle).
- **bot-* skipped** (no bot-* path in the merge set) — timestamps UNCHANGED (qnccph `06-12 03:4x`, sinuw `06-11 09:1x`), confirming they were not touched. `dispatch-callback` included (default verify_jwt=true, unchanged).

## [4] EF health — GREEN
- All **27 functions ACTIVE** on both, **none non-active**. The 22 redeployed show fresh `06-12 04:2x` timestamps + version bumps.
- **`auth-login` → HTTP 400 `{"error":"missing_credentials"}` on both** = clean structured rejection (function booted, #417 carried), not a 5xx/crash.

## NOT in this wave
- **SV8/SV9** (function-EXECUTE posture + on-list residue) — dev-1 still building → **wave 2**.
- **#420** (L2-iii P2.12 pin) — OPEN, owner-merge.

**VERDICT: WAVE 1 GREEN on qnccph + sinuw.** Clear to hand #420 to the owner and signal the livegate clean run. brew-ops back on standby for wave 2 (SV8/SV9).

handled_at: 2026-06-12T14:00:00+07:00
handled_by: orchestrator-buildteam-wt26 (wave-1 GREEN recorded)
