---
title: workflow-7 staging deploy self-triggers a benign no-change churn loop. A run's m
tags: [workflow-7, staging-deploy, brew-ops, deploy-currency, change-detection, idempotency, cf-worker-drift, manifest, gotcha]
created: 2026-06-13
source: brew-ops workflow-7 staging deploy run 2026-06-13 17:00 +07:00 (PR #483); evidence docs/deploy-evidence/staging/2026-06-13_1700.md
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# workflow-7 staging deploy self-triggers a benign no-change churn loop. A run's m

workflow-7 staging deploy self-triggers a benign no-change churn loop. A run's mandatory output is a manifest PR (STAGING-DEPLOY-MANIFEST.md + docs/deploy-evidence/staging/<ts>.md) merged to gateway main. That merge IS a "main advance" — so a naive PUSH auto-deploy trigger (w2-watcher / wake) re-fires workflow-7 on its OWN output. Each iteration: change-detect → all substrates skipped-no-change → re-stamp manifest → new ops/staging-deploy-* PR → merge → re-trigger.

Confirmed 2026-06-13: GW main 1af6c73 (deploy run, PR #478) → manifest PR #482 merged → main=8f18b10. `git diff 1af6c73..8f18b10` = ONLY the manifest + prior evidence file (zero substrate-path delta). Next run (PR #483) correctly detected all-skip and re-stamped only.

Why it's safe-but-wasteful: change-detect (git diff per substrate path + migration ledger) prevents any substrate mutation, so the loop never deploys anything harmful — but it spends a full run + opens a PR each time. NOT dangerous; just churn.

How to apply / mitigate: the PUSH trigger should treat a manifest-only advance (delta confined to STAGING-DEPLOY-MANIFEST.md + docs/deploy-evidence/**) as non-triggering; OR suppress the PR when change-detect finds the only delta-vs-baseline is the manifest itself. Until then, a no-change re-stamp run is the correct, expected outcome — verify readiness live (ledger + ef-deploy-list --assert + alias probe) and re-stamp; do not skip the manifest just because nothing deployed.

Separately (recurring, route to owner): cf-worker is still not a deployable staging substrate at main@HEAD — no [env.staging]/wrangler.staging.toml, mb-next-gw-staging.midasgoteam.workers.dev returns 404, staging slot has no Cloudflare creds, wrangler not on PATH. Pre-existing drift vs workflow-7 §Scope, unchanged across the 16:16 and 17:00 runs.

Tags: #brew-ops #repo:cross #fleet #deploy #staging #workflow-7 #gotcha

---
*Added via Oracle Learn*
