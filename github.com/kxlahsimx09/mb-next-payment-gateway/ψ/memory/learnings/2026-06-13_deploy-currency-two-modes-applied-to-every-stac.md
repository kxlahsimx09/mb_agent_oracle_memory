---
title: Deploy-currency = TWO modes, applied to every stack/substrate (thread #16 follow
tags: [brew-ops, repo:cross, deploy, freshness, staging, stack-currency, w2-watcher, stack-freshness, decision, build-workflow, thread-16]
created: 2026-06-13
source: brew-ops session 2026-06-13 — PRs mb-next#474 + arra-oracle-v3#123; deploy-currency-initiative
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Deploy-currency = TWO modes, applied to every stack/substrate (thread #16 follow

Deploy-currency = TWO modes, applied to every stack/substrate (thread #16 follow-on, owner directive, 2026-06-13).

**The design.** Every agent must run on the latest stack. STAGING is kept current by PUSH; every OTHER stack by PULL.
- **PUSH (staging only):** `w2-watcher.sh` gained a deploy-class trigger (`brew-ops`) that watches the staging source repos' origin/main (gateway + admin-portal) and, on ANY advance (author-filter OFF — the merger kxlahsimx09 is in IGNORE_AUTHORS; FETCH not pull because the source primary checkout may be on a feature branch; combined fingerprint so a portal-only merge fires; tighter debounce since workflow-7 is idempotent), wakes brew-ops to run workflow-7 staging full-stack deploy from main@HEAD. arra-oracle-v3 fork PR #123 → feat/all-prs-rebased.
- **PULL (tester/seal/dev/live):** NOT auto-deployed. The role that HOLDS the stack runs `scripts/stack-freshness.sh <stack>` (mb-next PR #474) — read-only, per-substrate verdict: migrations vs the schema_migrations ledger + EFs via `ef-deploy-list.sh --assert` (MISSING+STALE) + worker/UI vs the deploy manifest; exit 0 current / 1 stale-or-missing / 2 precondition. A present-but-STALE substrate (the d7 left-behind class) is a BLOCKER routed to brew-ops, never a green.

**Cross-peer sweep filed here (one commit):** the Stack-readiness gate in build-workflow.md is now "present AND current"; the §9b drift is reconciled in build-workflow.md AND next-tester/SKILL.md step-5 (both used to say next-dev deploys tester/seal — wrong; only brew-ops deploys shared stacks, next-dev → dev-N only); and a stack-freshness one-liner was added to next-tester / next-investigator / next-live-tester / next-dev SKILLs. workflow-7 now references stack-freshness.sh as its consolidated post-deploy gate.

**Why:** the d7 forensic — uncoordinated multi-actor deploys left admin-deposit pre-gotrue-flip on tester; partial sweeps + no deployed-SHA ledger + no completeness/freshness assert. PUSH removes the human-trigger gap for staging; PULL makes every other holder KNOW its currency instead of assuming it.

**How to apply:** stack-holding roles run stack-freshness.sh at their stack-readiness gate and route STALE to brew-ops (never self-deploy a shared stack — §9b + the deploy/env-guard PreToolUse hook). brew-ops runs it as the workflow-7 post-deploy proof. The "verify an older commit" exception survives via workflow-7 Step 0 (named commit) + §9b "unless the orchestrator specifies otherwise". Phase 4 (bank-bot container + egress proxy on EC2/DO) is NOT yet covered — tracked. mock-merchant rides along as a gateway EF; mock-bank (bank-bot sim/mock-portal) is Phase 4.

---
*Added via Oracle Learn*
