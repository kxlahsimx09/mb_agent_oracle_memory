---
title: **Workflow-7 staging deploy: duplicate PUSH wakes pile up redundant `ops/staging
tags: [brew-ops, repo:cross, fleet, staging-deploy, workflow-7, decision, gotcha, idempotency, silent-fail, push-wake]
created: 2026-06-16
source: brew-ops workflow-7 PUSH wake brew-ops-20260616-113254 (manifest STAGING-DEPLOY-MANIFEST.md @ 74b6409, PR #533)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# **Workflow-7 staging deploy: duplicate PUSH wakes pile up redundant `ops/staging

**Workflow-7 staging deploy: duplicate PUSH wakes pile up redundant `ops/staging-deploy-*` PRs when `main` advances only on non-substrate paths.**

Observed 2026-06-16: gateway `main` advanced `fab4ab8 → 74b6409` (+9 commits) but **zero deployable-substrate paths** were touched (the delta was prior-run manifest/evidence + `docs/requirements/live-test-journey*` + `poc/integration/src/live/*` test code). Three separate brew-ops PUSH wakes fired for substantially the same state and each opened its own proof-of-life PR: **#527** (`…-0920` @ intermediate `929fecd`, went stale 7-behind), **#532** (`…-1101` @ `74b6409`), **#533** (`…-1140` @ `74b6409`, this run). #532 and #533 are byte-functionally identical (same all-`skipped-no-change` matrix, same readiness PASS).

**Why it happens:** the PUSH-wake design emits one wake (→ one `ops/staging-deploy-<HHMM>` branch + PR) per `main` advance as a silent-fail proof-of-life, *before* knowing whether anything deployable changed. Change-detection runs inside the workflow, not before the wake — so a non-substrate `main` advance still triggers a full wake + PR.

**How to apply (brew-ops):**
1. Still honor the wake: run the full Step 3 readiness assert and re-stamp the manifest at the new SHA (idempotent re-stamp is correct and cheap — re-proves staging is current). Open the branch/PR so the silent-fail detector sees the wake completed.
2. **Be transparent about the pile-up.** Before opening, `gh pr list --state open` for `ops/staging-deploy-*`; if a sibling PR already covers the same source SHA, say so in the new PR body + manifest Findings and recommend the owner **merge the single latest and close the others as superseded**. Never merge/close unilaterally (AGENTS.md §9).
3. **Improvement candidate for the owner/watcher:** gate the PUSH wake (or at least the PR-open) on `git diff --quiet <last-deployed-SHA>..<new-main> -- supabase/migrations supabase/functions gateway/cf-worker` returning non-zero (a substrate actually changed). A non-substrate `main` advance could re-stamp the manifest without spawning a fresh wake+PR each time. Pairs with the still-open carry-over (manifest Finding #0): confirm the `ops/staging-deploy-` silent-fail detector covers PUSH runs that die *before* opening a PR.

cf-worker remains the standing no-target drift on staging (no `wrangler.staging.toml`/`[env.staging]`, no CF token in slot) — unchanged since `55218fd`, undeployable-by-design, not a missed change.

---
*Added via Oracle Learn*
