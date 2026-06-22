---
title: mb-next-admin-portal MAIN APP has NO GitHub auto-deploy — production is CLI-ONLY
tags: [mb-next-admin-portal, vercel, deploy, merge-not-deploy, cli-only-deploy, no-github-auto-deploy, docs-site-chronic-failure, verify-served-bundle, brew-ops, turbopack, ops]
created: 2026-06-19
source: campaign sysbankdeploy (brew-ops, 2026-06-19)
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# mb-next-admin-portal MAIN APP has NO GitHub auto-deploy — production is CLI-ONLY

mb-next-admin-portal MAIN APP has NO GitHub auto-deploy — production is CLI-ONLY (`vercel deploy --prod`). Sharpens the prior "merge ≠ deploy / mixed-trigger" note: for the MAIN APP it is not "mixed-trigger", it is NO trigger — a merge to `main` deploys NOTHING. The GitHub deployments API DOES show a "Production" deployment auto-created on every push (e.g. by `vercel[bot]`), but that record belongs to the SEPARATE `mb-next-admin-portal-docs` project (the docs-site), which has a CHRONIC pre-existing `failure` on EVERY commit — it is NOT the app. The app's Vercel project (`mb-next-admin-portal`, prj_ZIwsqrarjYCYgIgxMUgNAocANSCH, team midas-go) only ever has `source: cli` production deployments. CONSEQUENCE: after merging a portal PR to main, the live app stays on whatever the last `vercel deploy --prod` shipped — it can be HOURS stale (campaign ui-team-bank 2026-06-19: prod alias pointed at a 07:56 CLI deploy, predating the 08:49 build commit + 09:29 merge, so /system-bank served none of the change). HOW TO SHIP + VERIFY: run `vercel deploy --prod --yes` from a worktree at the target commit (vercel.json buildCommand = `next build --turbopack`, so a `next build --webpack` local verify does NOT prove the prod build — but turbopack built clean here), then VERIFY THE SERVED BUNDLE not the merge: fetch the prod route and grep `_next/static` chunks for a marker string unique to the change (new i18n keys worked great). Production alias: mb-next-admin-portal.vercel.app.

---
*Added via Oracle Learn*
