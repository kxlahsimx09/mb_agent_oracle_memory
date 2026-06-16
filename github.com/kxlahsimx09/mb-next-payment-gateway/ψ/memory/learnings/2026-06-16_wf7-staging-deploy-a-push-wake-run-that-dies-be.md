---
title: **wf7 staging-deploy: a PUSH-wake run that dies before Step 4 is INVISIBLE to th
tags: [brew-ops, repo:cross, fleet, deploy, staging, next, gotcha, workflow-7, silent-fail, idempotency]
created: 2026-06-16
source: brew-ops workflow-7 run, wake brew-ops-20260616-084324, PR #526
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# **wf7 staging-deploy: a PUSH-wake run that dies before Step 4 is INVISIBLE to th

**wf7 staging-deploy: a PUSH-wake run that dies before Step 4 is INVISIBLE to the `ops/staging-deploy-*` branch-name silent-fail detector** (#brew-ops #repo:cross #fleet #deploy #staging #next #gotcha).

Observed 2026-06-16 (wake `brew-ops-20260616-084324`). The prior PUSH run (wake `brew-ops-20260615-194948`, ~19:55) wrote the living `STAGING-DEPLOY-MANIFEST.md` (all-`skipped-no-change` at gateway `aed55b0`) into the mb-next-payment-gateway **primary** working tree, but never committed it, never emitted a `docs/deploy-evidence/staging/` evidence file, and never opened a PR — Step 4 never completed. Because it produced **no** `ops/staging-deploy-*` branch at all, a branch-name-based silent-fail detector has nothing to match — the dead run leaves zero signal except an uncommitted file in the primary.

**Why it matters:** wf7's idempotency normally makes a half-run safe to re-run, and it was — this run (`fab4ab8`) just superseded the orphaned manifest (the living file is overwritten-by-design every run; the 19:55 run deployed nothing, so no deploy evidence was lost). But the *detection gap* is real: a PUSH run can silently fail before producing any branch, and the operator never learns. The only residue was a dirty primary checkout (which also violates AGENTS.md §3c "primary stays clean on main").

**How to apply:**
1. On every wf7 run, before Step 0, check the deploy-target primary (`mb-next-payment-gateway`) for an uncommitted `STAGING-DEPLOY-MANIFEST.md` — its presence means a prior run died before Step 4. Preserve it with `git stash push -u -m "orphaned wf7 ... " -- STAGING-DEPLOY-MANIFEST.md` (recoverable, P-001 / §3c verify-before-discard), then `git merge --ff-only origin/main` to restore the §3c freshness anchor. Surface it as a manifest Finding.
2. The silent-fail detector should also flag PUSH-wake wf7 runs that fired but produced no `ops/staging-deploy-*` branch within the verify window — not only branches-without-PRs.
3. Change-detect for this run: only `supabase/functions/mock-merchant/index.ts` changed in `aed55b0..fab4ab8` → EF deploy-all sweep (51, idempotent); migrations (ledger 175=175, 0 pending) / cf-worker (standing no-target) / admin-ui (0 commits) all skipped. Readiness gate PASS. PR #526.

Related: [[close-idle-teammates-immediately]] (orphaned-session hygiene). cf-worker remains a standing undeployable substrate on staging (no `wrangler.staging.toml`/`[env.staging]`, no CF token in slot) — owner decision pending.

---
*Added via Oracle Learn*
