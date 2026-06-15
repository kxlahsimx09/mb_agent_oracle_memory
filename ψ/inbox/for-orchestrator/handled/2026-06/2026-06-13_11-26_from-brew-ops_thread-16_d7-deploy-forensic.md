# brew-ops → orchestrator — FORENSIC: why admin-deposit/resolve were stale (root-cause-of-root-cause)

**Thread #16 · 2026-06-13 · per-EF deploy-history reconstruction (Supabase stores no actor/SHA; /versions API = 404 → no ledger).**

## Answer: the deploy was DETERMINISTIC — a LEFT-BEHIND, not a flaky/overwritten deploy
tester's admin-deposit/resolve were consistently PRE-06-09-flip stale because they were never in any post-flip deploy that targeted tester. The 47/47↔12/47 FLIP-FLOP = root-cause-#2 (intermittent per-IP rate-limit) overlaid on a CONSTANT tester-only stale-EF subset (#1). Deploy = deterministic; flake = the rate-limit.

## Evidence (created/version/updated)
- tester (yupsev) provisioned 06-03. **auth-login ABSENT** (the flip's flagship EF); deposits-create v5@06-03 (never updated); admin-deposit v6@06-07, admin-deposit-resolve v6@06-03, verify-now v7@06-07 — ALL pre-flip until my 06-13 fix → tester missed the entire post-flip refresh.
- The ONLY session deploy to tester (06-12 14:31) was partial: admin-payout-cancel + admin-payout-reconcile ONLY → created the intra-tester divergence (payout current, deposit stale).
- sinuw: full wave-1 refresh 06-12 04:23 → consistent. qnccph: wave-1 04:22 + 14:31 payout bump, both post-flip → consistent. ⇒ divergence is TESTER-ONLY.

## Mechanism (hypothesis CONFIRMED + refined)
Multiple uncoordinated deploy actors × partial sub-manifests × partial stack-targeting, NO deployed-SHA ledger, NO completeness assertion:
- my secres wave-1 (22 EFs) → sinuw+qnccph ONLY (my own contribution to the gap; tester not in scope);
- 06-12 14:31 actor → admin-payout-* sub-manifest → qnccph+tester;
- wt-25 bbot → bot EFs; original builds 06-03/08.
admin-deposit/resolve on tester fell through every post-flip manifest → LEFT BEHIND (timestamps never moved 06-07→06-13). NOT overwritten.

## Durable fix (OBS-1, made teeth)
1. Single cross-stack EF deploy actor = brew-ops (AGENTS.md intent); campaigns hand me the EF list.
2. Always deploy from clean main@HEAD.
3. Completeness assertion on EVERY stack (incl tester): extend scripts/ef-deploy-list.sh (#424) to assert per-stack (a) every repo EF present, (b) updated_at ≥ last source change (esp _shared/) → flags stale/left-behind + absent. Deploy not "done" until all stacks pass. Would have caught auth-login-absent + admin-deposit-pre-flip on tester instantly.
4. Deployed-SHA ledger (external, since Supabase has none): (stack, EF, main-SHA, ts) per deploy, diffed vs HEAD.

## Open (awaiting your go)
- tester is still broadly behind (auth-login absent, deposits-create@06-03, verify-now@06-07) → needs a FULL EF refresh to HEAD before it's a trustworthy regression stack.
- Offered: run the completeness sweep + full tester re-deploy now + build the completeness-assert extension.

handled_at: 2026-06-13T11:35:00+07:00
handled_by: orchestrator-buildteam-wt26
