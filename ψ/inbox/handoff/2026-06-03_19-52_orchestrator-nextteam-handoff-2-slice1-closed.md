# ORCHESTRATOR HANDOFF #2 — campaign `nextteam` (post DEPOSIT slice-1) — 2026-06-03

Continuation of the 2026-06-03 #1 handoff. Read both + arra_search "nextteam campaign brief" + "revised build workflow bias-minimized" before acting.

## WHERE WE ARE — slice 1 CLOSED ✅
**DEPOSIT-001/002 complete-AC slice: VERIFY+SEAL PASSED.** 25/30 clauses probed+independently-sealed; 5/30 covered-not-separately-probed (D1-07, D2-06/07/08/10). The bias-minimized workflow ran end-to-end and CAUGHT REAL BUGS pre-prod:
- **NT-9 double-credit** (full-key collision credited 2 → money-safety) — fixed (re-derived on seal stack: credited=1, client_delta=245.5).
- NT-12 wall-clock in cascade pre-filter (§ADR-20 violation) → app_now(); NT-8 band-min (seed); F-1/F-2 SPEC-vs-EF naming (EF canonical, SPEC rev8); d2-12 = probe-rebind (substrate correct, §ADR-4b).
- PRs MERGED to main: #311 (clock+happy+guardrails), #312 (18 gap clauses), #313 (§ADR-9 preconfigured-callback refactor), #314 (NT-9/12/11/8 fixes). next-investigator posted the EPIC SEAL (arra_learn #epic-seal).

## SUBSTRATE (all Singapore ap-southeast-1, provisioned)
- dev-1 = Supabase `qvmjywljrgqzyxshexhx` (mb-next-dev1, Seoul one was DELETED + recreated Singapore; spdazjbmyagekwxixfct abandoned, diff account)
- tester = `yupsevcrubgprsbujbpu` · investigator/seal = `qnccphgykzdydebmdwdf`
- shared egress = ECS/Fargate `mb-next-egress` (AWS acct 261955339426, ap-southeast-1, on-demand, no NAT/EIP for test)
- Secret slots: ~/.arra-oracle-v2/fleet-secrets/mb-next-payment-gateway/slots/{dev-1,dev-2,tester,investigator}.env + aws-egress.env. GW4 EdDSA keypair per stack (private→slot, public JWK→stack GW4_VERIFY_KEYS). dev-2 still REPLACE_ME (deferred). **OWNER: revoke the temp tokens in tmp_token.env now (provisioning done; CF used wrangler-OAuth not token).**

## NEXT (owner to decide — DO NOT auto-fan-out)
1. §ADR-21 **LIVE gate + owner ACCEPT** — per-EPIC, NOT yet run for DEPOSIT. (SIM mode first; REAL-BANK later after bank-bot.)
2. **Fan-out** DEPOSIT-003+/other epics via the same workflow.
3. **Process fixes before fan-out** (from the 7-role retro — high impact): (a) AUTOMATE stack provisioning (brew-ops; #1 time-sink: each stack = manual CONCURRENTLY-migration-via-Mgmt-API + app_settings PoC-ref override + GW4/seed dances) + deploy-ahead so VERIFY isn't gated; (b) SPEC freeze + re-ping protocol (reviewer reviews moving SHA; tester rebuilds on churn); (c) clarify GAP taxonomy (impl-gap vs probe-gap; dev found 11/20 already done = phantom work); (d) fixture/seed contract + in-stack callback stub (httpbin flaky 502/503); (e) findings-file-per-PR + latent-risk register; (f) writer reads substrate when authoring SPEC (caused F-1/F-2).

## LATENT RISK to track (reviewer-flagged, outside slice AC)
`finalize_deposit` routes residual only `IF v_residual>0` → a future profile with Σpartner-pct > deposit_fee_pct → negative residual → partner over-credit (money creation), no rollback. Belongs with §ADR-19 per-client profiles. Add a `v_residual<0` RAISE guard. NOT yet ticketed (no register exists → will evaporate).

## ORCHESTRATOR OPERATING NOTES (learned)
- Dispatch: `scripts/team-dispatch-helper.sh --campaign nextteam --role <r> --repo github.com/kxlahsimx09/mb-next-payment-gateway --prompt "<contract>"`. Roles spawn in own tmux windows; shared worktree `mb-next-payment-gateway.wt-c-nextteam`; findings = `<role>_nextteam_*.md` (untracked).
- Close IDLE teammates with `tmux kill-pane -t %<id>` (NOT finish.sh — that closes the whole campaign + worktree; only run at true campaign end). Verify pane mapping before killing.
- DON'T `maw team send` to a teammate mid-task — message ordering gets confused (caused a wrong dev-1 repoint). Re-spawn fresh, or send only when idle/early.
- Tester re-spawns lose warm context but branches+findings persist. Agents work their committed work on OWN branches off main (feat/test-* ); the campaign worktree HEAD drifts.
- Orchestrator NEVER marks done (only next-pm, on evidence). Build CODE PRs SELF-MERGE after reviewer approval (owner waived PR approval, AGENTS.md §9a). GitHub blocks self-approve (shared bot acct) → reviewers post review-comment + squash-merge per §9a.
- Loop pattern: a `*/4 * * * *` CronCreate self-drives the pipeline (check artifacts → advance → close idle → report milestones → ping owner only for real decisions). CronDelete at the discussion gate.
- Provisioning gotchas (doc in runbook): Supabase Mgmt API blocks Python-urllib UA (use curl+browser-UA+--noproxy); CONCURRENTLY migration `20260528170000` needs per-statement via Mgmt API /database/query; app_settings PoC-ref hard-code must be overridden per stack; the `rh` pathname (hosted Edge serves `/deposits-create` not `/functions/v1/...`).

## OWNER PROFILE
Thai chat / English artifacts. Drives incrementally, approves at decision gates, wants to SEE/trust evidence (likes plain-language accounts), explicitly values the de-bias workflow. Waived PR approval for build PRs. Wanted slice-1 to PAUSE for discussion before fan-out (we're there now).
