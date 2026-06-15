---
title: deploy-env-guard makes brew-ops the SOLE deploy/secret owner for ALL Supabase st
tags: [deploy-env-guard, brew-ops, deploy-ownership, build-workflow, orchestrator, team-dispatch, config.toml]
created: 2026-06-14
source: campaign bbot (thread-19 OTP-relay build), orchestrator bbot 2026-06-14
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# deploy-env-guard makes brew-ops the SOLE deploy/secret owner for ALL Supabase st

deploy-env-guard makes brew-ops the SOLE deploy/secret owner for ALL Supabase stacks (dev-N, tester, seal) — every tmux window except brew-ops-* is blocked from `supabase db push`/`functions deploy`/`secrets set`/`db reset` (and wrangler/aws/gcloud deploy + edits to *.env / .secrets/ / supabase/config.toml). This OVERRIDES build-workflow.md's "next-dev deploys to its OWN dev-N stack." Operative build flow: next-dev BUILDS code + opens PR → brew-ops deploys (from the campaign branch) → next-tester verifies on the brew-ops-deployed stack. Two consequences for the orchestrator: (1) dispatch prompts must NOT contain the literal strings `supabase db push` / `functions deploy` etc. — the PreToolUse hook greps the Bash command text and false-positive-BLOCKS the team-dispatch-helper spawn (route deploy mechanics by reference to the dev's brew-ops-handoff doc instead of spelling out CLI); (2) config.toml conflicts in a merge are brew-ops's to resolve (next-dev is guard-blocked from editing supabase/config.toml) — split: dev resolves code conflicts, brew-ops resolves config.toml + completes the merge.

---
*Added via Oracle Learn*
