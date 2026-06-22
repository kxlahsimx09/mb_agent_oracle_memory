---
title: workflow-7 staging deploy (PUSH auto-deploy after main advance) — two operationa
tags: [brew-ops, repo:mb-next-payment-gateway, next, staging-deploy, workflow-7, idempotent, push-deploy, gotcha, manifest]
created: 2026-06-16
source: brew-ops workflow-7 run, wake brew-ops-20260616-110149 (2026-06-16 GMT+7), PR #532
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# workflow-7 staging deploy (PUSH auto-deploy after main advance) — two operationa

workflow-7 staging deploy (PUSH auto-deploy after main advance) — two operational notes from the 2026-06-16 11:09 +07 run (wake brew-ops-20260616-110149), gateway pinned 74b6409:

1. **main can advance MID-RUN.** Active campaigns (campaign/livecov, campaign/ii3c-forged) merged PRs #530/#531 while the run was in flight (origin/main moved fab4ab8→ea50d52→74b6409). `stack-freshness.sh` does its own `git fetch origin main` and surfaced the drift (printed BASE 74b6409 when the worktree was still at ea50d52). Discipline: re-fetch + re-pin the worktree/branch to the FINAL STABLE origin/main HEAD right before stamping the manifest, and re-run the asserts there. For doc/test-only advances the EF `--assert` + migration-ledger results are substrate-state checks (SHA-independent), so they stay valid — but the manifest must pin the true HEAD, not a stale mid-run SHA.

2. **Consecutive all-skipped PUSH runs pile up unmerged `ops/staging-deploy-*` PRs** that all overwrite the SAME living `STAGING-DEPLOY-MANIFEST.md`. This run found PR #527 (re-stamp @929fecd) still open; it opened PR #532 (re-stamp @74b6409) which supersedes #527's content. Safe (living file is overwrite-every-run; evidence files are distinct append-only filenames) but creates PR-soup + a race if owner merges them out of order. Surfaced both in the manifest Findings + PR body; owner closes/merges. Worth considering: have wf7 detect+note (or the owner auto-close) a prior still-open same-purpose PR.

Idempotency contract held: zero substrate mutation, manifest re-stamped only. cf-worker remains the standing undeployable-by-design drift (no wrangler.staging.toml/[env.staging], no CF token in slot). #next system family. Tags: #brew-ops #repo:mb-next-payment-gateway #next #staging-deploy #workflow-7 #idempotent #push-deploy #gotcha

---
*Added via Oracle Learn*
