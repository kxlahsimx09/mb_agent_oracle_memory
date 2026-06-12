---
title: FLEET INFRA — `temp-mb-regression-droplet` (178.128.93.199): a working DigitalOc
tags: [brew-ops, repo:cross, fleet, regression, droplet, digital-ocean, w2-watcher, integration-tests, docker, deploy-key, gotcha, provisioning]
created: 2026-06-12
source: brew-ops 2026-06-12 — droplet regression bring-up (user-driven, thread #15 session)
project: github.com/kokarat/mobiz-payment-gateway
---

# FLEET INFRA — `temp-mb-regression-droplet` (178.128.93.199): a working DigitalOc

FLEET INFRA — `temp-mb-regression-droplet` (178.128.93.199): a working DigitalOcean regression runner for the mobiz integration-test suite. Proven green 2026-06-12.

Tags: #brew-ops #repo:cross #repo:arra-oracle-v3 #fleet #regression #droplet #digital-ocean #gotcha #w2

**Why it exists:** the W2 regression (`arra-oracle-v3/scripts/regression-then-investigate.sh`, chained by `w2-watcher.sh`) runs `docker compose up --build` for the mobiz `integration-tests/docker-compose.yml` stack (backend+mock-bank+bank-bot+bank-bot-ktb+mongo+redis). It needs a live Docker daemon. The host Mac's docker daemon was down → regression broke (last local run 2026-06-10). Decision (verbal, NOT in vault before this) = move regression to a DO droplet. The droplet was spun up 2026-06-09 (hostname `temp-mb-regression-droplet`, Ubuntu 24.04, 4 vCPU / 7.8G / 154G) but left bare. Persistent for now; a physical box is planned to replace it later.

**Access:** `ssh root@178.128.93.199` works from the Mac via `~/.ssh/id_ed25519` (passphrase-less → BatchMode/headless OK, sidesteps the w2-watcher.sh:95 ssh-agent-empty-on-background gotcha). The droplet already had per-repo **deploy keys** staged at `/root/.ssh/` (`deploy_mobiz`, `deploy_bankbot`) + `/root/.ssh/config` Host aliases `github-mobiz` / `github-bankbot` (IdentitiesOnly). Both auth OK + are correctly repo-scoped read-only.

**Provisioning recipe that makes it green (idempotent script TODO):**
1. Clone BOTH repos (bank-bot nests INSIDE mobiz, gitignored): `mobiz-payment-gateway` via `git@github-mobiz:` and `mobiz-payment-gateway/bank-bot` via `git@github-bankbot:`. Layout matches `regression-then-investigate.sh` default `MOBIZ=$HOME/Code/github.com/kokarat/mobiz-payment-gateway`; docker-compose builds bank-bot from `context: ../bank-bot`.
2. `cd integration-tests && docker compose build` (images: backend 78MB, mock-bank 236MB, bank-bot/-ktb 3.26GB playwright, test-runner 2.33GB). `.env.docker` is COMMITTED test config (mongo/redis container-internal, committed JWT key) → NO external secret copy needed.
3. `docker compose up -d` → all services Healthy (mongo/redis/backend/mock-bank/test-runner; bank-bot running).
4. **Host tooling the test scripts need** (they run on the host, not in test-runner which is a node-only web UI): `node` (for `helpers/generate-totp.js` — 2FA/TOTP login, pure node-crypto), `mongosh` (ledger verify; `json_val`=python3 already present). Installed node 20 (NodeSource) + mongosh 2.8.3.
5. **`/etc/hosts`: `127.0.0.1 mongodb redis backend mock-bank`** — `setup-infra.sh` `mongo_exec` in DOCKER_MODE=true hardcodes `mongodb://mongodb:27117`; the port is published to host, so the alias lets host mongosh reach it.
6. Run a test exactly as the watcher does: `cd $MOBIZ && DOCKER_MODE=true SKIP_INFRA=true bash integration-tests/<test>.sh`. (DOCKER_MODE=true = "use the running docker stack + docker bank-bot"; the comment at setup-infra.sh:41 was the key — true means "inside/against the docker stack", false = native build.)

**Proof:** `test-deposit-flow.sh` → rc=0, "3/3 deposits succeeded, ALL DEPOSITS PASSED" (full flow incl. bot deposit-detection + ledger verify).

**DONE same session (working-tree in arra-oracle-v3, pending §3c batch-PR):**
- (a) `scripts/provision-regression-droplet.sh` — idempotent host bring-up (verify deploy keys → node/mongosh/`/etc/hosts` → clone both → build → optional `--smoke`).
- (b) `scripts/regression-on-droplet.sh` — SSH runner: sync → `down -v`/`up --build` → wait healthy → loop `regression-suite.txt` (TEST_RUNNER_MODE=1, per-test logs) → summary+rc. **Proven 2/2 green** (deposit-flow + deposit-cancel) through the full flow. `scripts/regression-then-investigate.sh` got a guarded **`REGRESSION_HOST` opt-in** (set → delegate build+run to the runner + Telegram + exit; unset → unchanged local path). Flip the W2 watcher by exporting `REGRESSION_HOST=user@ip`.

**Full-suite confirmed (28/28 green-capable):** 26 passed direct; the 2 fails were both NOT mobiz bugs —
- `test-payout-admin-cancel.sh` = **flake** ("WQ row never reached pending" — dispatcher timing under full-suite load; passed on a clean-stack retry).
- `test-deposit-refund.sh` = **droplet-env gap, FIXED**. `helpers/setup-infra.sh` `redis_exec` (DOCKER_MODE=true) runs `redis-cli -h redis -p 6379`, but (1) the host lacked `redis-cli` and (2) redis publishes **6399:6379** (port MISMATCH — mongo's 27117:27117 matched, which is why mongo worked and redis didn't). The test does `redis_exec FLUSHALL >/dev/null 2>&1` then logs "✓ flushed" unconditionally → the permission-cache invalidation silently no-op'd → backend served the stale cache → `/refund` = "Access denied: Insufficient permissions: deposit:refund" (fast rc=1). **Fix:** `apt install redis-tools socat` + a persistent **systemd `redis-fwd.service`** forwarding `127.0.0.1:6379 → :6399` (+ `/etc/hosts` already aliases `redis`→127.0.0.1). Codified in `provision-regression-droplet.sh`. refund then runs its full multi-phase flow and PASSES (348s — it's a long test, needs the default 1800s, not a short timeout).

**Still open:** (c) `test-runner` container lacks mongosh/python3/curl so tests can't run *inside* it — host-execution (on the droplet host) is the working model; (d) droplet investigation-on-fail only Telegrams + pulls logs, doesn't wake the tester like the local path.

---
*Added via Oracle Learn*
