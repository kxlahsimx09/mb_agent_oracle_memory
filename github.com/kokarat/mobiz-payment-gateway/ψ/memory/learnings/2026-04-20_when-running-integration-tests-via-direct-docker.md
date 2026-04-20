---
title: When running integration tests via direct `docker exec` inside the test-runner c
tags: [repo:mobiz-payment-gateway, tester, integration-tests, docker, test-runner, debugging-gotcha]
created: 2026-04-20
source: tester session 2026-04-20
project: github.com/kokarat/mobiz-payment-gateway
---

# When running integration tests via direct `docker exec` inside the test-runner c

When running integration tests via direct `docker exec` inside the test-runner container (bypassing the web UI's `/api/run-test`), you MUST pass `DOCKER_MODE=true` and typically `TEST_RUNNER_MODE=1`:

```bash
docker exec -e DOCKER_MODE=true -e TEST_RUNNER_MODE=1 \
  integration-tests-test-runner-1 bash -c "cd /tests && ./test-xxx.sh"
```

**Why:** `integration-tests/helpers/setup-infra.sh` `mongo_exec` / `redis_exec` branch on `DOCKER_MODE`. When `true`, they use direct `mongosh mongodb://mongodb:27117` / `redis-cli -h redis`. When unset/false, they fall back to `docker compose exec -T mongodb mongosh…` which fails inside test-runner — test-runner has plain `docker` CLI via mounted socket but no `docker compose` plugin.

**Failure signature:** `unknown shorthand flag: 'T' in -T` followed by docker help output, then test aborts at `MDR profile creation failed` right after `[role assign] unknown shorthand flag: 'T'`.

The test-runner's `/api/run-test` endpoint sets `DOCKER_MODE=true` automatically via `server.js`, so this trap only bites when debugging by exec'ing scripts directly.

---
*Added via Oracle Learn*
