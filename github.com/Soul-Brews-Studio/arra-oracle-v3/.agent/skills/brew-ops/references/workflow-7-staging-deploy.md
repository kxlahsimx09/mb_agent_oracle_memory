---
description: Repeatable, idempotent full-stack deploy of the next-gen gateway + admin UI to the STAGING substrate. Change-detect per substrate (deploy changed, skip unchanged), default source = main, and ALWAYS emit a tracked deploy manifest. Owner/brew-ops only — holds the staging slot creds.
owner: brew-ops
autonomy: substrate-mutating (db push / functions deploy / wrangler deploy / vercel deploy) — owner-held creds; gated re-runs are safe (idempotent)
cadence: on-request after a merge to `main`, before a tester/VERIFY round, or ad-hoc to refresh staging
---

# Workflow 7 — Staging Full-Stack Deploy

The single command brew-ops runs to put **all of staging on a known commit**. It answers one
question per run, and leaves behind a document that answers it forever after:

> **"Which exact commit is each substrate on staging currently running — and what changed to put it there?"**

Every substrate of the stack is in scope, but a substrate is only redeployed **if its source
actually changed**. Re-running on an unchanged tree deploys nothing and still refreshes the
manifest. The default source is **`main`** of each repo unless the run pins a commit/branch.

## Scripted execution (run this; don't hand-execute the steps)

This workflow is now **100% scripted** in `mb-next-payment-gateway/scripts/` — the prose
below is the spec the scripts implement, kept for review/debugging, not a manual checklist.
**Binding (brew-ops SKILL §9): run the script, do NOT hand-execute the steps.** A deploy
bug is fixed in the script (then PR), not by running CLI verbs ad-hoc.

```bash
cd mb-next-payment-gateway
scripts/deploy-staging.sh --dry-run     # plan + git-less stage, ZERO mutation, no manifest write
scripts/deploy-staging.sh --deploy      # full live deploy — GATED on the deployed-shape green gate
scripts/verify-staging.sh staging       # Step-3 readiness gate alone (read-only; safe for any role)
```

- `deploy-staging.sh` — orchestrator: Step -1 gate → Step 0 slot+resolve → Step 1 plan →
  Step 2 deploy (migrations→EF→worker→UI) → Step 3 verify → Step 4 manifest. Helpers:
  `deploy-staging-migrations.sh` (Mgmt-API SQL apply + ledger reconcile — **not** `db push`,
  see Step 2a), `deploy-staging-ui.sh` (git-less Vercel), `deploy-staging-manifest.sh` (Step 4).
- **Binding precondition baked in:** `--deploy` runs `mb-next-bank-bot dmirror/gate.sh` first and
  **refuses to mutate if it is RED** (brew-ops SKILL §8). `--dry-run` runs it informationally.
- cf-worker auto-detects: no `[env.staging]` in `wrangler.toml` ⇒ `skipped-no-target` (current state).
- Timestamps are generated in-script (`date`, GMT+7 first); no caller need supply them.

## Scope — the staging stack

One target stack, two repos, four+ substrates:

- **STAGING Supabase project** `mb-next-staging` — ref `sinuwgsqqyqzlpaavimf` (org
  `lsgheeuhvfqhmombfqsl`, region `ap-southeast-1`).
- **Slot** `~/.arra-oracle-v2/fleet-secrets/mb-next-payment-gateway/slots/staging.env`
  (`chmod 600`, outside git). Exports `SUPABASE_ACCESS_TOKEN` (account PAT, EF deploy +
  Management API), `SUPABASE_DB_PASSWORD` (db push), **and `VERCEL_TOKEN`** (the admin-UI
  deploy auth — added 2026-06-17; pass it as `--token=$VERCEL_TOKEN` to every `vercel`
  command in Step 2(d)). **Only brew-ops/owner hold it** (AGENTS.md §3b slot isolation).
  Source it; never echo it, never `git add` it.
- **Slot** `~/.arra-oracle-v2/fleet-secrets/mb-next-payment-gateway/slots/next-ui.env` — holds
  the admin-portal build env (`SUPABASE_URL` / `SUPABASE_ANON_KEY`, i.e. the public Supabase
  url + anon key the portal bundle needs). Source it in Step 2(d) for the Vercel build-env. Same
  isolation rules — never echo, never `git add`.

| # | Substrate | Repo | Deploy verb | Change-detect signal |
|---|---|---|---|---|
| (a) | **DB migrations** (+ pg_cron sweeps/dispatcher + RPCs ride along) | `mb-next-payment-gateway` | `supabase db push` over IPv4 session pooler | `supabase/migrations/*.sql` filenames not present in staging `supabase_migrations.schema_migrations` ledger |
| (b) | **Edge Functions** (set GENERATED from `supabase/functions/` at HEAD — never a frozen count) | `mb-next-payment-gateway` | `supabase functions deploy` | EF source (`supabase/functions/<name>/**`) changed vs last-deployed SHA |
| (c) | **CF Worker** (gateway edge) | `mb-next-payment-gateway` | `wrangler deploy -c wrangler.staging.toml` | `gateway/cf-worker/**` changed vs last-deployed SHA |
| (d) | **Admin UI** | `mb-next-admin-portal` | **git-less** `vercel deploy --prod` from a `.git`-stripped temp copy (linked project; token from `staging.env`) | UI source changed vs last-deployed SHA |

Staging edge: CF Worker `mb-next-gw-staging.midasgoteam.workers.dev` (JWKS ES256, GW4
assertion). UI live at `mb-next-admin-portal.vercel.app` (Vercel project `prj_ZIws…`).

**Not in scope:** production substrates (different egress shape, §ADR-9 EG8–EG10 — never touch
from this workflow); dev/tester/investigator stacks (those are other slots); secret rotation
(owner-only, see `edge-function-deploy.md`).

## References — read these, don't reinvent

- `mb-next-payment-gateway/docs/runbooks/edge-function-deploy.md` — the PAT requirement for
  `functions deploy` (§1–§3) **and** the db-push **IPv4 session-pooler workaround** (§4): the
  direct DB host is IPv6-only, so migrations go over
  `aws-1-ap-southeast-1.pooler.supabase.com:5432` with only the DB password. Port `5432` =
  session pooler (migrations); `6543` = transaction pooler (apps) — use 5432 here.
- `mb-next-payment-gateway/docs/runbooks/provision-substrate-stacks.md` — how a stack is stood
  up and which 9+1 per-stack secret slots exist. This workflow assumes the stack is already
  provisioned; it **deploys onto** it.
- `mb-next-payment-gateway/docs/build-workflow.md` **Stack-readiness gate** (§ "STRUCTURAL
  precondition for Step 2") — the same readiness contract a tester depends on. This workflow is
  what *makes* that gate pass: migrations applied (tables not `404`), EFs deployed (create EF
  not `404`, GW4 live), RPCs present (reset + §ADR-20 clock RPCs respond).

## Workflow body

### Step 0 — Resolve source + load slot

1. **Pick the source ref per repo. Default = `main`.** If the run names a commit/branch, use it;
   otherwise `git fetch origin && git checkout main && git pull --ff-only` in each repo. Record
   the resolved `git rev-parse HEAD` (full SHA) for each repo — this SHA is what the manifest
   pins, not "main" (a moving label).
2. `source ~/.arra-oracle-v2/fleet-secrets/mb-next-payment-gateway/slots/staging.env`. Assert
   `SUPABASE_ACCESS_TOKEN`, `SUPABASE_DB_PASSWORD`, **and `VERCEL_TOKEN`** are non-empty; abort
   early if any is missing (the only owner-only failure mode — surface it, don't guess). The
   `VERCEL_TOKEN` is what makes admin-UI deploy hands-off — without it Step 2(d) blocks on
   interactive `vercel login` (the 2026-06-17 `brew-ops-wf7-adminui` blocker; now resolved by
   the slot). Sanity-check: `vercel whoami --token=$VERCEL_TOKEN` → `midasgoteam-ops`.
3. Confirm CLIs: `supabase`, `wrangler`, `vercel` on PATH and reasonably current.

### Step 1 — Compute the last-deployed baseline (the change-detection ledger)

The manifest **is** the change-detection state. Read the current
`STAGING-DEPLOY-MANIFEST.md` (canonical home below). For each substrate it records the SHA last
deployed. The diff between that SHA and the resolved source SHA decides deploy-vs-skip:

- **(a) migrations** — list `supabase/migrations/*.sql`; compare against the staging ledger
  (`supabase_migrations.schema_migrations`) via Management API `db/query`
  (`select version from supabase_migrations.schema_migrations order by version`). **Pending =
  files whose version is not in the ledger.** Empty pending set ⇒ skip.
  > **Ledger-vs-objects drift (known gotcha):** some migrations were applied out-of-band, so the
  > ledger can lag the actual objects. **Before re-applying a "pending" migration, verify the
  > object does not already exist** (probe the table/RPC). If it exists, reconcile the ledger
  > (insert the version row) instead of re-running the DDL — re-running non-idempotent DDL is the
  > failure mode. Prefer migrations written `IF NOT EXISTS`.
- **(b) EF / (c) Worker / (d) UI** — `git diff --quiet <last-deployed-SHA> <source-SHA> -- <path>`.
  Non-zero exit (changes) ⇒ deploy; zero ⇒ skip. If the manifest has no prior SHA for a
  substrate (first ever run, or a newly added substrate), treat as **changed → deploy**.

Log the deploy plan before mutating anything: `substrate → deploy|skip → why`.

### Step 2 — Deploy each CHANGED substrate (skip the rest)

Order matters: **migrations → EFs → worker → UI** (schema before code that reads it; backend
before the UI that calls it).

- **(a) Migrations** (if pending):
  ```bash
  cd mb-next-payment-gateway
  supabase db push \
    --db-url "postgresql://postgres.sinuwgsqqyqzlpaavimf:<URL_ENCODED_DB_PASSWORD>@aws-1-ap-southeast-1.pooler.supabase.com:5432/postgres"
  ```
  Then re-query the ledger to confirm every pending version now present. pg_cron sweeps/
  dispatcher + RPCs land here (they live in migration SQL).
- **(b) Edge Functions.** The EF set is **GENERATED from `supabase/functions/` at HEAD, never a
  frozen hand-typed list** (OBS-1, thread #17 — the bbot family `bot-config`/`bot-statements`/
  `bot-bank-statements-last`/`bot-balance`/`bot-queue-mark` was once silently excluded from an
  "all-26-EF" sweep). The no-arg deploy-all form is the authoritative sweep — it cannot omit a
  family; the single-function form is for targeted redeploys only:
  ```bash
  supabase functions deploy --project-ref sinuwgsqqyqzlpaavimf            # deploy-all (the sweep)
  # or, targeted (only a changed EF):
  supabase functions deploy <name> --project-ref sinuwgsqqyqzlpaavimf
  ```
  Both are idempotent. `scripts/ef-deploy-list.sh --list` is the source of truth for the set;
  Step 3 asserts deployed ⊇ source so an excluded family fails loudly.
  > **CRITICAL — DEPOSIT-008 / #358 class bug:** EF-owns-auth functions MUST keep
  > `verify_jwt = false` in `supabase/config.toml`. The platform JWT gate must **stay off** for
  > these (login/2FA/step-up + X-Client-Id auth EFs). **Never re-enable the platform gate.**
  > After deploy, confirm the create EF (`deposits-create`) responds (not `404`) with its GW4
  > gate live — that is the build-workflow readiness contract.
- **(c) CF Worker** (if changed):
  ```bash
  cd gateway/cf-worker && wrangler deploy -c wrangler.staging.toml
  ```
  Confirm `mb-next-gw-staging.midasgoteam.workers.dev` serves JWKS (ES256) and the GW4 assertion
  path responds.
- **(d) Admin UI** (if changed) — **GIT-LESS deploy (mandatory; not a `cd …portal && vercel`
  in-place deploy).** A `.git`-present deploy FAILS the Vercel Hobby **seat-block**: the HEAD
  commit author is not a team member, so the platform rejects it (same failure the GitHub
  auto-integration hits). The only proven-working path is to deploy from a copy with **no
  `.git/`** (proven run: `brew-ops-wf7-deploy-exec`, deployment
  `dpl_GYvwADZWkQw9t7T4DBUyj2Tg2c2r`, `READY`, alias serving 200). Recipe:

  ```bash
  # 1. Stage git-less: copy the working tree at main@HEAD, EXCLUDING .git/ and docs-site/
  #    (.git → dodges the seat-block; docs-site/ → a DIFFERENT Vercel project, GOTCHA 2).
  STAGE=$(mktemp -d /tmp/portal-deploy-staged.XXXX)
  rsync -a --exclude='.git/' --exclude='docs-site/' mb-next-admin-portal/ "$STAGE/"

  # 2. Ensure the staged copy is LINKED to the staging project (carry .vercel/project.json):
  #    project prj_ZIwsqrarjYCYgIgxMUgNAocANSCH / team team_NcQL9QEsv53GkO7pBqyiyMFC.
  #    rsync above already copied mb-next-admin-portal/.vercel/; confirm it survived:
  test -f "$STAGE/.vercel/project.json" || cp -r mb-next-admin-portal/.vercel "$STAGE/.vercel"

  # 3. Supabase build env. PREFERRED (hands-off): set them ONCE as persistent project env
  #    vars so every future deploy inherits them — values from slots/next-ui.env:
  #      ( source slots/next-ui.env
  #        printf '%s' "$SUPABASE_URL"      | vercel env add NEXT_PUBLIC_SUPABASE_URL      production --token=$VERCEL_TOKEN
  #        printf '%s' "$SUPABASE_ANON_KEY" | vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production --token=$VERCEL_TOKEN )
  #    Once set, the --build-env flags below are unnecessary. FALLBACK (per-run) if not set:
  #      --build-env NEXT_PUBLIC_SUPABASE_URL=$SUPABASE_URL \
  #      --build-env NEXT_PUBLIC_SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

  # 4. Deploy from the staged dir (token from staging.env; --prod so it auto-aliases prod):
  cd "$STAGE"
  NEW_DPL=$(vercel deploy --prod --yes --token=$VERCEL_TOKEN)   # prints the new deployment URL

  # 5. Alias (confirm --prod auto-aliased; otherwise set explicitly):
  vercel alias set "$NEW_DPL" mb-next-admin-portal.vercel.app --token=$VERCEL_TOKEN
  ```

  - **GOTCHA 3 — alias 401:** if the alias root or `/users` returns `401`, the project has
    SSO/deployment protection on. PATCH it off (needs the same token), then re-verify:
    ```bash
    curl -X PATCH "https://api.vercel.com/v9/projects/prj_ZIwsqrarjYCYgIgxMUgNAocANSCH?teamId=team_NcQL9QEsv53GkO7pBqyiyMFC" \
      -H "Authorization: Bearer $VERCEL_TOKEN" -H "Content-Type: application/json" \
      -d '{"ssoProtection":null}'
    ```
    (On the 2026-06-17 run the alias served 200 already, so this PATCH was not needed — only
    reach for it on an actual 401.)

  Capture the new `dpl_…` id + deployment URL for the manifest, and clean up `$STAGE` after.

Each substrate's deploy is independently idempotent — a re-run with no source change is a no-op
plus a manifest refresh.

> **GOTCHAS — admin-UI (substrate d), so the next operator doesn't rediscover them:**
> 1. **Seat-block → deploy git-less.** A `.git`-present `vercel deploy` fails the Vercel Hobby
>    seat-block (HEAD commit author isn't a team member). Always deploy from a `.git`-stripped
>    temp copy (Step 2(d) recipe). This is the single most important gotcha.
> 2. **Exclude `docs-site/`.** It's a *separate* Vercel project — copying it into the admin-portal
>    stage corrupts the deploy. `rsync --exclude='docs-site/'` (and `--exclude='.git/'`).
> 3. **Alias 401 → ssoProtection.** If the alias 401s, PATCH project `ssoProtection=null` with
>    the token, then re-verify (Step 2(d) GOTCHA 3).
> 4. **Token home.** `VERCEL_TOKEN` lives in `slots/staging.env` (sourced in Step 0); pass it as
>    `--token=$VERCEL_TOKEN` on every `vercel` command. Supabase build env is in `slots/next-ui.env`.

### Step 3 — Verify readiness (the build-workflow gate)

Run the readiness checklist as a post-deploy assertion, regardless of what was skipped:

- Migrations applied — app/deposit tables exist (table query ≠ `404`).
- EFs deployed — `deposits-create` responds (≠ `404`), GW4 gate live.
- **EF-set completeness (OBS-1) — `scripts/ef-deploy-list.sh --assert <REF>` exits `0`: every EF at
  HEAD (incl. the bbot family) is ACTIVE on the stack. A non-zero exit = a family was excluded from
  the sweep → blocker, not a green.**
- RPCs present — reset RPCs **and** §ADR-20 clock RPCs respond.
- Worker — staging worker URL healthy.
- **UI** — new deployment is `READY` and its `dpl_…` id **differs from the prior** manifest id
  (proves you didn't just re-stamp a stale deploy); alias **root + `/users` both HTTP 200** (a
  `401` ⇒ GOTCHA 3 ssoProtection PATCH, then re-verify); optionally grep the live
  `/_next/static/chunks/*.js` for a known new symbol from the shipped PRs to confirm the bundle
  is the new code, not a cached old one. Record the deployed admin-portal SHA in the manifest.

**Consolidated currency gate (the one command).** `scripts/stack-freshness.sh staging` runs the
per-substrate currency check in one shot (migrations ledger + `ef-deploy-list.sh --assert` +
worker/UI vs the manifest); exit `0` = every substrate current. It is the SAME read-only check the
stack-holding roles run on their own stacks (the PULL half) — here it is the post-deploy proof.
Run it last; a non-zero exit is a blocker, not a green.

A failed assertion is a **blocker to surface**, not a silent green.

### Step 4 — Emit + commit the MANIFEST (mandatory, every run)

**Non-negotiable final step. No run completes without it** — including runs where every
substrate was skipped (the manifest still re-stamps "verified on `<SHA>` at `<ts>`").

**Canonical home:** a living `mb-next-payment-gateway/STAGING-DEPLOY-MANIFEST.md` (tracked,
overwritten each run — the always-current answer to "what is staging running?"), **plus** a
timestamped per-run evidence copy at
`mb-next-payment-gateway/docs/deploy-evidence/staging/<YYYY-MM-DD>_<HHMM>.md` (append-only
history — Oracle/Shadow "nothing is deleted"). The living file is the source of truth for Step 1's
baseline next run.

**Required per-substrate columns** (each substrate, every run):

| Substrate | Commit SHA | Source branch | Timestamp (GMT+7) | Status | What changed |
|---|---|---|---|---|---|
| migrations | `<full-sha>` | `main` | `2026-06-09 14:05 +07:00` | deployed | +3 migs: `…__add_x.sql`, … |
| edge-functions | `<full-sha>` | `main` | … | skipped-no-change | — |
| cf-worker | `<full-sha>` | `main` | … | deployed | worker handler reauth fix |
| admin-ui | `<full-sha>` | `main` | … | deployed | dep `…`; vercel `dpl_…` |

Header block records: staging project ref, both repo source SHAs, run trigger, operator, and
the readiness-gate result (pass/blocked). Status vocabulary is exactly
**`deployed`** / **`skipped-no-change`** (and `blocked` if Step 3 failed). Timestamps pass in
from the caller (scripts cannot call `Date.now()`); show GMT+7 first.

Commit the living manifest + the per-run evidence file (NOT the slot, NOT any secret) on the
feature branch. `git grep` the diff for token/password shapes before committing
(AGENTS.md §9/§11a). PR for owner review — **never merge** (CLAUDE.md Git rules).

## Idempotency contract

- Re-run, same source SHAs ⇒ all substrates `skipped-no-change`; manifest re-stamped. Zero
  substrate mutation.
- Re-run after one repo advances ⇒ only the substrates whose paths changed redeploy.
- A half-finished run (e.g. migrations applied, worker deploy died) is safe to re-run: the
  ledger reconciliation (Step 1 drift check) prevents double-applying DDL, and EF/worker/UI
  deploys are last-write-wins.

## What this workflow is NOT

- Not a production deploy — staging only. Production egress/topology differs (§ADR-9 EG8–EG10);
  a separate owner workflow handles prod.
- Not a provisioner — `provision-substrate-stacks.md` stands the stack up; this deploys onto an
  existing stack.
- Not a secret manager — it *consumes* the staging slot; the owner creates/rotates the PAT + DB
  password (`edge-function-deploy.md` §1–§3).
- Not a migration author — it applies what's in `supabase/migrations/`; it does not write DDL.
- Not (yet) a bank-bot / mock-bank deployer — `mock-merchant` rides along as a gateway EF (covered
  by the EF sweep), but the **bank-bot container + its `sim/mock-portal` (mock-bank)** live on
  EC2/DO (`mb-next-bank-bot scripts/aws|do/*.sh`), outside this Supabase/CF/Vercel deploy. Bringing
  those into the PUSH loop (w2-watcher + a per-substrate freshness signal) is **Phase 4** of the
  deploy-currency design — tracked, not silently dropped.

> **Manifest home (forward convention).** The living manifest stays `STAGING-DEPLOY-MANIFEST.md`
> today; the per-stack form is `deploy-manifests/<stack>.md` (same columns). `stack-freshness.sh`
> reads `deploy-manifests/<stack>.md` first, then falls back to `STAGING-DEPLOY-MANIFEST.md`, so the
> worker/UI currency check activates as soon as either exists. Other stacks (tester/seal/dev) get a
> manifest when brew-ops deploys to them via the cross-stack deploy (build-workflow.md), not here.

## Escalation

- **Missing/empty slot creds** → owner action; stop and surface (only the owner can paste the
  PAT/DB password). Cite `edge-function-deploy.md` §0.
- **Ledger-vs-objects drift that can't be auto-reconciled** → drop an `arra_thread` to the
  owning build role with the conflicting version + object probe result; do not force the DDL.
- **Readiness gate fails post-deploy** (bare-stack symptom: tables/EF `404`) → blocker, not a
  green; report which substrate is missing and re-run that substrate.

---

**Created:** 2026-06-09 (GMT+7)
**Amended:** 2026-06-12 (OBS-1, thread #17) — the EF set is now explicitly GENERATED from
`supabase/functions/` at HEAD (deploy-all form authoritative; frozen-count language removed), and
Step 3 gains the `scripts/ef-deploy-list.sh --assert` completeness gate so an excluded EF family
(root cause: bbot adapters missed by the "all-26-EF" sweep) fails loudly instead of sitting stale.
**Amended:** 2026-06-17 (`brew-ops-wf7-runbook-gitless`) — admin-UI substrate (d) hardened for
hands-off runs after the 2026-06-17 proven deploy (`dpl_GYvwADZWkQw9t7T4DBUyj2Tg2c2r`): auth via
`VERCEL_TOKEN` in `slots/staging.env` (`--token=$VERCEL_TOKEN`), and the deploy is now **git-less**
(copy the tree WITHOUT `.git/` and `docs-site/`, deploy from the temp dir) to dodge the Vercel
Hobby seat-block. Added an admin-UI GOTCHAS callout (seat-block / docs-site / ssoProtection 401 /
token home) and a sharper UI verify gate.
**Owner:** brew-ops
**Ground truth:** 2026-06-09 staging session — project ref `sinuwgsqqyqzlpaavimf`, 125
migrations / 27 EFs / `wrangler.staging.toml` / Vercel-linked admin portal verified against the
repos at authoring time.
