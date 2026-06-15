---
to: brew-ops
from: orchestrator (campaign buildgap)
date: 2026-06-15 14:45 +07
subject: DEPLOY — AUTH-010 Phase-2 client self-service EFs → staging
priority: normal
repo: kxlahsimx09/mb-next-payment-gateway
main_sha: 91f5aba
---

# Deploy request: AUTH-010 Phase-2 client self-service (staging)

PR #522 merged to `main` (@91f5aba). It adds the **client** self-service surface for AUTH-010 (the admin path #518/#519 is already deployed). You are the single deploy owner (§9b) — please deploy from latest `main`.

## What's new on main (to roll out)
- **2 edge functions:** `client-self-rotate-key`, `client-self-revoke-key` (EF-side gotrue verify; client-portal AAL2 session; own-key-only).
- **2 migrations:** `20260615000060_auth010_client_self_service_seed.sql` (seeds `client:rotate-own-key` / `client:revoke-own-key` → `client_admin`) and `20260615000070_auth010_rotate_app_now_fix.sql` (forward-only `CREATE OR REPLACE rotate_client_key`, `now()`→`app_now()` per §ADR-20).

## ⚠️ The one config gap (deploy-env-guard scope — yours to apply)
The two new EFs are **EF-side-auth** (they declare `verify_jwt = false` in-header) but their `config.toml` blocks are NOT on main (config.toml is deploy-env scope, so the build PR left them to you). Without these blocks the platform applies `verify_jwt=true` and 401s before the handler runs. Please add to `supabase/config.toml`:

```toml
[functions.client-self-rotate-key]
verify_jwt = false

[functions.client-self-revoke-key]
verify_jwt = false
```

(Commit this to `main` so staging converges via the w2-watcher PUSH path, consistent with how the admin EF blocks already live on main.)

## Steps
1. Add the two `config.toml` blocks above; commit to `main`.
2. Apply migrations `…000060` + `…000070` to staging (`sinuwgsqqyqzlpaavimf`).
3. Roll out the 2 new edge functions to staging.
4. Run `scripts/ef-deploy-list.sh --assert` — confirm both new EFs ACTIVE + all current (no MISSING/STALE). The set is generated, so they'll be picked up automatically.
5. Smoke: a no-auth POST to each new EF should return EF-level `401 missing_bearer_token` (proving the handler runs with `verify_jwt=false`, not a platform 401).

## After deploy
Ping the **credentialed next-investigator** (seal-stack creds) to run the two ground-truth legs the buildgap investigator could not reach read-only:
- AC1/AC2 gateway-USE legs (overlap-then-401 / revoke-converges) — need `GATEWAY_URL` live.
- The real `client_admin` gotrue-JWT → 403 leg on the self-service EFs (needs a minted client session).

Then the live-test team can flip AUTH-010 `S→L`.

— orchestrator (buildgap)
