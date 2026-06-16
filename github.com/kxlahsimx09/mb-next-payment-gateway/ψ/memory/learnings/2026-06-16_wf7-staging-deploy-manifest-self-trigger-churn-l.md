---
title: **wf7 staging-deploy manifest self-trigger churn loop is now CONFIRMED self-sust
tags: [brew-ops, repo:cross, fleet, deploy, staging, next, workflow-7, idempotency, gotcha, churn-loop, manifest, self-trigger]
created: 2026-06-16
source: brew-ops workflow-7 run, wake brew-ops-20260616-091438, PR #527; ref sinuwgsqqyqzlpaavimf
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# **wf7 staging-deploy manifest self-trigger churn loop is now CONFIRMED self-sust

**wf7 staging-deploy manifest self-trigger churn loop is now CONFIRMED self-sustaining across consecutive same-day wakes** (#brew-ops #repo:cross #fleet #deploy #staging #next #workflow-7 #idempotency #gotcha #churn-loop).

Observed 2026-06-16: wake `brew-ops-20260616-091438` fired a full wf7 PUSH run that found the gateway `main` advance `fab4ab8 → 929fecd` was **manifest-only** — `git diff fab4ab8..929fecd` = exactly `STAGING-DEPLOY-MANIFEST.md` + `docs/deploy-evidence/staging/2026-06-16_0853.md`, i.e. the OUTPUT of the immediately-prior 08:53 run (PR #526, wake `brew-ops-20260616-084324`). Zero substrate-path delta ⇒ every substrate change-detected unchanged, nothing deployed, re-stamp only (PR #527). So the documented churn loop ([[2026-06-13_workflow-7-staging-deploy-self-triggers-a-benign-n]]) has now chained at least 3 consecutive same-day links: 19:55 dead-run (PR-less) → 084324/PR#526 → 091438/PR#527. Each unmitigated PUSH wake burns a full agent run + a PR purely to re-stamp its own predecessor's output.

Run facts (all green, idempotent, zero mutation): migrations ledger 175 = repo 175 (max `20260615000070`, 0 pending); `ef-deploy-list.sh --assert sinuwgsqqyqzlpaavimf` exit 0 (51/51 ACTIVE, none stale); `deposits-create` 401 GW4-gated, `mock-merchant` 200, admin-ui 200, cf-worker 404 (standing undeployable, em-dash SHA); RPCs present (`app_now`/`clock_*`/`reset_*`); `stack-freshness.sh staging` exit 0. Pre-Step-0 silent-fail check: pg primary clean on `main@929fecd`, no orphaned uncommitted manifest (the [[2026-06-16_wf7-staging-deploy-a-push-wake-run-that-dies-be]] residue already resolved).

HOW TO APPLY: the mitigation is no longer optional polish — it is actively needed because the loop is self-sustaining (every merge of the manifest PR re-advances main → re-wakes wf7). Owner action: make the PUSH trigger (w2-watcher / wake) treat a manifest-only advance (delta ⊆ `STAGING-DEPLOY-MANIFEST.md` + `docs/deploy-evidence/**`) as NON-triggering, OR suppress the PR when change-detect finds the only delta-vs-baseline is the manifest itself. Until then, a no-change re-stamp is the correct expected per-wake outcome (do NOT skip the manifest just because nothing deployed). Separately-recurring (unchanged): cf-worker still has no `wrangler.staging.toml`/`[env.staging]`/CF token — undeployable on staging.

---
*Added via Oracle Learn*
