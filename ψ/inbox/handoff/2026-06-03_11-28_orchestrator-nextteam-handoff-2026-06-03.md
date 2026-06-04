# ORCHESTRATOR HANDOFF — campaign `nextteam` (mb-next-payment-gateway build team)

**Date:** 2026-06-03 · **For:** the next orchestrator session. Read this + the vault learnings cited below before acting.

## What this campaign is
Standing up + running a 6-role build team to DELIVER `kxlahsimx09/mb-next-payment-gateway` (18 ADR + 18 epic/~65 story S2-ratified). Roles: **next-dev** (×2: dev-1, dev-2), **next-tester**, **next-code-reviewer**, **next-investigator**, **next-pm**, **next-ui**. Dispatch via `maw team` (workflow-2); each role spawned with `scripts/team-dispatch-helper.sh --campaign nextteam --role <r> --repo github.com/kxlahsimx09/mb-next-payment-gateway --prompt "<contract>"`. Shared worktree `mb-next-payment-gateway.wt-c-nextteam`. Findings = `<role>_nextteam_*_findings.md` (untracked in that worktree).

## Authoritative specs (arra_search these — they are binding)
- `campaign-brief-nextteam` — the 6 roles, Definition-of-Done (SPEC→BUILD→REVIEW→VERIFY + investigator seal), env.
- `revised-build-workflow-bias-minimized-parallel` (2026-06-03) — THE current build workflow. dev+tester PARALLEL off a shared SPEC; **tester NEVER reads dev code**; investigator falsifies every probe-PASS against the truth DB; **only next-pm marks done, on evidence**; **orchestrator NEVER marks**; build CODE PRs self-merge after reviewer approval (no owner gate, AGENTS.md §9a); orchestrator has standing autonomy + pings owner only for genuine decisions.
- `live-gate-design-the-5th-gate` → §ADR-21 (LIVE gate, 2 modes SIM/REAL-BANK). §ADR-20 = virtual-clock + 4-stack env.

## STATE OF PLAY (2026-06-03)
- ✅ **All setup merged**: 6 role SKILLs (#9,#10), ADR-20/§ADR-9/§ADR-21, runbook, fleet symlink, mb-next registered as Oracle project (vault_repo set).
- ✅ **Provisioning COMPLETE** — 3 stacks all in Singapore (ap-southeast-1): dev-1 (`qvmjywljrgqzyxshexhx`), tester (`yupsevcrubgprsbujbpu`), investigator (`qnccphgykzdydebmdwdf`) — each Supabase + CF Worker (via wrangler OAuth) + shared egress (`mb-next-egress` ECS/Fargate, AWS acct 261955339426). Slots at `~/.arra-oracle-v2/fleet-secrets/mb-next-payment-gateway/slots/` filled (Supabase+CF+egress). DEFERRED-on-purpose: BOT_SECRET + MOCK_* (harness/bank-bot Phase-1), dev-2 (not needed for first slice), EGRESS_PROXY_URL (runtime-resolved). aws-egress.env + supabase mgmt token = present.
- ✅ **Phase-0b done** — handoff docs in the worktree: `next-impl_nextteam_harness-handoff.md` (harness + §0 BIAS-DISCLOSURE: tester must VALIDATE the harness first, §D.6 dup_egress artifact) + `next-writer_nextteam_deposit-ac.md` (DEPOSIT slice = story DEPOSIT-002 core + DEPOSIT-001 setup; 5 AC clauses + guardrails).
- 🟡 **OPEN PRs awaiting owner glance (DO NOT auto-merge — charter/meta)**: #11 (central: 4 SKILLs + AGENTS.md §9a), #309 (product: docs/build-workflow.md). Also #297/#307/#308 runbook/IAM (ops docs).

## NEXT STEP = Phase-1 (the first vertical slice, NOT yet started)
DEPOSIT slice with the NEW workflow: dispatch **next-dev** (emit SPEC: API contract + DB schema first) ∥ **next-tester** (design probes from SPEC only, never code) → **next-code-reviewer** review → self-merge → **next-investigator** falsify probe-PASSes against truth DB → **next-pm** mark done on evidence. Orchestrator coordinates, marks nothing, pings owner only for real decisions.

## Orchestrator operating notes (learned this campaign)
- Close idle teammate panes with `tmux kill-pane -t <id>` (campaign stays open; finish.sh would close the whole campaign). Don't `maw team send` to a teammate that's mid-task — message ordering gets confused (caused a wrong dev-1 repoint); re-spawn fresh instead.
- Owner authorized destructive/outward AWS+Supabase provisioning via temporary scoped keys (revoke after). Supabase mgmt token can be revoked now (projects created, keys in slots). CF uses wrangler OAuth, not a token.
- The owner interacts in Thai; artifacts in English.
