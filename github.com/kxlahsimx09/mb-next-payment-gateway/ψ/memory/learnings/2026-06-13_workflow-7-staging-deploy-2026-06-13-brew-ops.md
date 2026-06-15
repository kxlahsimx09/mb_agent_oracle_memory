---
title: workflow-7 staging deploy (2026-06-13, brew-ops): cf-worker is NOT a deployable 
tags: [brew-ops, workflow-7, staging-deploy, cf-worker, drift, deploy-currency, next]
created: 2026-06-13
source: workflow-7 staging deploy run 2026-06-13 16:16 +07:00; PR #482; ref sinuwgsqqyqzlpaavimf
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# workflow-7 staging deploy (2026-06-13, brew-ops): cf-worker is NOT a deployable 

workflow-7 staging deploy (2026-06-13, brew-ops): cf-worker is NOT a deployable staging substrate at main@HEAD — DRIFT vs the workflow-7 spec. #brew-ops #repo:mb-next-payment-gateway #next #fleet #drift #decision #cf-worker #staging #workflow-7

CONTEXT: First committed STAGING-DEPLOY-MANIFEST run (PR #482). Migrations (156→158: payout-009 clock-grace + payout-012/013 correction toolkit, via IPv4 session pooler), Edge Functions (deploy-all sweep 33/33 — +2 new admin-payout-correct & admin-payout-reverse-settle, refreshed stale payout-resend-callback, verify_jwt=false preserved), and admin-ui (Vercel dpl_72yCXX3PRQfLEBTh2nMHnBN7CzGE aliased to mb-next-admin-portal.vercel.app) all deployed + verified green. stack-freshness.sh staging exit 0.

THE DRIFT: workflow-7 §Scope names `wrangler deploy -c wrangler.staging.toml` → mb-next-gw-staging.midasgoteam.workers.dev as substrate (c). Reality at main@HEAD (1af6c73): (1) gateway/cf-worker/wrangler.toml is named `mb-next-cf-gateway`, EF_BASE=http://127.0.0.1:54321, only [env.verify]/[env.failopen] which are self-labelled "LOCAL-VERIFY aid only (not a deploy target)" — there is NO [env.staging] and NO wrangler.staging.toml; (2) https://mb-next-gw-staging.midasgoteam.workers.dev/ returns HTTP 404 (never deployed); (3) the staging slot has no Cloudflare API token and no GW4_SK_k1/INVALIDATE_SECRET (README "Production deploy" requires `wrangler secret put` for those + a gateway_config seed); (4) wrangler isn't even installed. The worker source last changed at PoC commit 55218fd (thread #254) and did NOT change in this main advance.

HOW TO APPLY: On a workflow-7 run, do NOT attempt to deploy cf-worker until the repo grows a real staging deploy config (an [env.staging] / wrangler.staging.toml targeting mb-next-gw-staging) AND the staging slot gains a CF token + GW4/INVALIDATE secrets. Record it `skipped-no-change` with Commit-SHA column `—` (an em dash, NOT a real SHA) so stack-freshness.sh reports it `unknown (no manifest entry)` instead of a false green — the parser strips all non-hex from the SHA column, so any placeholder containing a-f would be misread. Deploying the PoC as-is would publish a localhost-pointing, wrong-named worker. Owner decision pending: wire it up or drop substrate (c) from workflow-7 scope.

---
*Added via Oracle Learn*
