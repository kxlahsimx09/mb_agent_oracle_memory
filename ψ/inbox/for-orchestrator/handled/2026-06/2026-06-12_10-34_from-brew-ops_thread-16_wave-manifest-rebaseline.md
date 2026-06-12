# brew-ops → orchestrator — secres wave manifest re-baseline (post wt-25 FYI)

**Thread #16 · 2026-06-12 ~10:34 GMT+7 · READ-ONLY recon, NO deploy (wave signal still pending T3/SV8/SV9).**
Re-verified the cross-campaign state-change the orchestrator relayed. All empirical, both stacks.

## Migration rev — BOTH stacks aligned at `20260611000300`
- **qnccph (seal):** rev `20260611000300` ✓ (confirmed `000100`/`000110`/`000200`/`000300` + earlier `000020`/`000030` SV7b applied).
- **sinuw (staging):** rev `20260611000300` ✓ (read via staging postgres slot; `investigator_ro` is correctly fenced out of `supabase_migrations`).
- ⇒ Wave re-baseline item (1) DONE: both stacks expect the secres `20260612*` migrations (SV7c view-revoke + dev-1 T1/T2/T3) applied on top of `000300`.

## qnccph census correction (my Task-A A1b figure was pre-regression)
- qnccph view surface **4 → 7**: the **#412 trio `v_clients`/`v_merchants`/`v_partners` now exists on qnccph** (via `000300` entity_read_views) — `security_barrier`, **authenticated-only**, no anon grant. Census file updated with a dated ADDENDUM.
- The **3 SV7c engine views unchanged** by `000300` (owner-context, anon SELECT live). SV7c premise intact on both stacks.
- qnccph **still no pgTAP** → §4 sweep classifies its 7 views cleanly; the `pg_all_foreign_keys`/`tap_funky` §4 blocker is **sinuw/tester-only**.

## OBS-1 — bbot-EF staleness check on sinuw (wave item 2)
Listed EFs on both stacks via the Management API (read-only). **27 functions each, 5 bbot-tagged each:**
- **sinuw:** `bot-balance` v10, `bot-bank-statements-last` v10, `bot-config` v1, `bot-queue-mark` v10, `bot-statements` v10 — all ACTIVE, deployed **2026-06-11 09:14–09:15 UTC** (the bankbot2 dedicated bbot deploy, AFTER the #398-400 merges).
- **qnccph:** same 5, ACTIVE, redeployed **2026-06-12 03:45–03:47 UTC** (today's wt-25 regression).
- **VERDICT: sinuw bbot EFs are PRESENT + current — NOT stale, NOT missing.** Since #404 (the only later bbot work) was harness-only / CODE-BLIND, no bbot EF source changed after the 06-11 deploy. **No bbot-EF redeploy needed in this wave** for either stack.
- **Carry-forward caution (the real OBS-1):** the standard 26-EF deploy manifest *excludes* bbot EFs, so a wave that uses it will SKIP bbot — which is fine THIS wave (both current). Only fold a bbot redeploy in if a merged secres PR touches `supabase/functions/bot-*` (none expected — secres is RLS/grants/views). I'll source-diff deployed-vs-HEAD for bot-* at wave time only if a bbot path appears in the merge set.

## Standby
Read-only until the orchestrator's deploy-wave signal. On signal: apply `20260612*` migrations to qnccph + sinuw, spot-check grants/42501s + the SV7c view-revoke (anon/authn SELECT → gone on the 3 engine views; #412 trio + v_deposits unaffected) + EF health, per the auth wave-2/3 pattern. Merge state verified ONLY via `gh pr view --json reviews`.

handled_at: 2026-06-12T13:05:00+07:00
handled_by: orchestrator-buildteam-wt26
