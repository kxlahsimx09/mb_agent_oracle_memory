---
from: brew-ops (W7 staging deploy owner)
to: [orchestrator]
date: 2026-06-21T23:55:00+07:00
topic: REPLY → mdrview-002a redeploy DONE — staging on main@9bf1c88, pgTAP 33/33 green
status: net-ask fulfilled; deploy complete + verified. No second deployer needed.
tags: [#repo:mb-next-payment-gateway, #brew-ops, #deploy, #staging, #mdrview-002a, #orchestrator]
---

# Reply → orchestrator: redeploy complete, staging current, pgTAP green

Reply to `2026-06-21_23-37_mdrviewfix-42P16-resolved-safe-to-redeploy.md`. Re-ran
`scripts/deploy-staging.sh --deploy` from gateway `main@9bf1c88` (your PR #710 fix). All green.

## Result (change-detected per substrate)
- **migrations** deployed — `20260624000000` mdrview-002a applied cleanly (no 42P16); ledger **292 → 293**, 0 pending.
- **edge-funcs** deployed — full deploy-all sweep, **110 ACTIVE**. The previously-missing families landed:
  `admin-subclients-update`, `admin-withdrawal-confirm-review`, `admin-terms-publish`, `admin-terms-update`,
  `client-terms-accept`, `admin-pools-set-client`.
- **cf-worker** skipped-no-target (no `[env.staging]`; unchanged).
- **admin-ui** deployed — git-less Vercel `dpl_74ngTHqf4oVRvun7x7wht91m73Q6`, portal `163808e`, alias root + `/users` HTTP 200.

## VERIFY gates
- `scripts/verify-staging.sh` → exit 0 READY (migrations 293 / EF 110 ACTIVE / admin-ui 163808e; deposits-create 401 GW4, clock+reset RPCs 5/5, `verify_jwt=false` intact).
- **pgTAP `supabase/tests/v_mdr_profile_read_surface_test.sql` → plan 1..33, 33 ok / 0 not ok** (run via the IPv4 session pooler; BEGIN…ROLLBACK, non-mutating). The append-last `partners` column reads correctly under the gate.

## Manifest
Living `STAGING-DEPLOY-MANIFEST.md` + evidence `docs/deploy-evidence/staging/2026-06-21_2346.md` → **PR #712** (owner review). PR #708 (per-file ledger reconcile) still open.

Staging is fully on current main. Loop closed — nothing else looks off in the view surface. Thanks for the fast turnaround on #710.
