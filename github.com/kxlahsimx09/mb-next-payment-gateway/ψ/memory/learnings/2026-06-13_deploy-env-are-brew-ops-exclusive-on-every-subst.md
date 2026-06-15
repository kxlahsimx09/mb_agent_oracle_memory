---
title: DEPLOY + ENV are brew-ops-EXCLUSIVE on every substrate — owner-directed policy, 
tags: [orchestrator, deploy, env, brew-ops, guard-hook, governance, single-owner, build-workflow, fleet-policy]
created: 2026-06-13
source: orchestrator-buildteam wt-26, thread #16 (owner directive)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# DEPLOY + ENV are brew-ops-EXCLUSIVE on every substrate — owner-directed policy, 

DEPLOY + ENV are brew-ops-EXCLUSIVE on every substrate — owner-directed policy, enforced by a PreToolUse guard hook (mirrors orchestrator-guard).

**Owner directive (2026-06-13, thread #16), binding for the mb-next fleet:**
1. **brew-ops is the SOLE deploy actor** on every stack/substrate (Supabase, Cloudflare, AWS). No other role runs deploy commands.
2. **brew-ops always deploys from LATEST main** unless the orchestrator explicitly specifies otherwise.
3. **brew-ops is the SOLE env/secret actor** on every substrate (Supabase secrets/config, CF, AWS) — no other role mutates env.
4. Codified in `docs/build-workflow.md` + `.agent/AGENTS.md` + a cross-ref in the role SKILLs.
5. Enforced STRUCTURALLY by a PreToolUse **deploy/env-guard hook** (mirrors `scripts/orchestrator-guard-hook.sh`): self-gates on the tmux window name, BLOCKS for any window NOT `brew-ops-*` — supabase db push / functions deploy / secrets set, wrangler deploy/secret/kv-put, aws deploy/update/secrets, gcloud deploy, + direct edits to `.env` / `.secrets/slots/*.env` / `supabase/config.toml` secret blocks / CF+AWS creds. Runs even under `--dangerously-skip-permissions`. A block = the system working → the blocked agent routes the deploy/env ask to brew-ops.

**Why (the triggering evidence):** the d7 forensic (2026-06-13) found admin-deposit/admin-deposit-resolve were deployed with a STALE pre-06-09-gotrue-flip `verifyGotrueJwt` on the tester stack — NOT a flaky deploy, a LEFT-BEHIND: multiple uncoordinated deploy actors (secres waves + auth-campaign + wt-25 regression + brew-ops) × partial sub-manifests × partial stack-targeting + NO deployed-SHA ledger + NO completeness assertion → the EFs fell through every post-flip manifest on tester. Same root class as the same-day migration-version collisions (parallel actors, no coordination). Single-owner deploy + always-from-latest-main + a completeness assertion (every EF present + updated_at ≥ last source change, per stack — extend scripts/ef-deploy-list.sh #424) + a deployed-SHA ledger closes the class.

**How to apply:** when any campaign needs a deploy or an env/secret change, the orchestrator routes it to brew-ops (with the EF/migration list); brew-ops executes from clean main@HEAD and runs the completeness assertion before calling a deploy "done." Never let a dev/tester/architect deploy or set secrets directly — the guard hook blocks it; discipline routes it.

---
*Added via Oracle Learn*
