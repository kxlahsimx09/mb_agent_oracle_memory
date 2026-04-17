---
title: SUPERSEDED — test-raw-resp.sh is a scratch probe, not a test
type: learning
tags:
  - tester
  - repo:mobiz-payment-gateway
  - current
  - superseded-test
  - settlement
related:
  - 2026-04-16_decision-2026-04-16-gmt7-introduced-the-tes
source: >
  integration-tests/test-raw-resp.sh:1-18 (file is 794 bytes, 18 lines)
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-16
---

## What's wrong

`test-raw-resp.sh` is a full-file dump of:

```bash
#!/bin/bash
source helpers/setup-infra.sh
ADMIN_USERNAME=$(mongo_exec payment_gateway_test --quiet --eval "..." | tr -d '[:space:]')
JWT_TOKEN=$(api POST "/api/v1/auth/login" "{...}" | json_val "['data']['token']")
export JWT_TOKEN
C_ID=$(mongo_exec payment_gateway_test --quiet --eval "..." | tr -d '[:space:]')
echo "C_ID=$C_ID"
EXPLOIT_RESP=$(api POST "/api/v1/settlements" '{...}')
echo "RAW RESPONSE: $EXPLOIT_RESP"
```

It violates pattern-library rules across the board:

- No header block (no category / flow / usage / exit codes)
- No `cleanup_<name>()` trap
- No `--no-bot` flag
- No service-health preflight (`$BACKEND_URL/swagger/index.html`,
  `$MOCK_BANK_URL/api/session`)
- No cross-check assertions before exit — just `echo` of the response
- No `log_*` helpers; uses raw echo
- No explicit `exit 0` / `exit 1`; script ends on success of last command

The `EXPLOIT_RESP` variable name and the hardcoded client lookup
(`name: 'ร้านค้า-Settlement-Test'`) suggest this was authored while
investigating the settlement status=2 exploit later covered by
`test-settlement-exploit.sh`.

## Why this is wrong

Per workflow-1 §2g:

> If the test exercises a feature whose route/controller was removed
> and the feature is explicitly gone from the system (not just
> renamed), the test is SUPERSEDED, not STALE.

The settlement POST path it exercises still exists — the test is not
stale. But the probe's *purpose* has been absorbed by
`test-settlement-flow.sh` (settlement creation) and
`test-settlement-exploit.sh` (regression against the status=2 exploit).
The file is a living artifact of a prior investigation, not a test
the suite depends on.

## Minimal fix (proposed, not applied)

Two options; owner chooses:

1. **Keep in tree, add SUPERSEDED header.** Minimal one-paragraph block
   at the top pointing at `test-settlement-flow.sh` and
   `test-settlement-exploit.sh`. Preserves the investigation breadcrumb
   per P-001.
2. **Remove the file from `integration-tests/`.** Git history preserves
   it (P-001 applies to the vault, not derived artifacts in-repo).
   Remove only after confirming no runner entry points at it.

Test-runner UI entry (`integration-tests/mock-bank/public/test-runner.html`)
has not been checked for a registration of this script. Before
removing, audit that file too.

## Impact if unfixed

Low. The script is not registered in any runner path that I can see
from static inspection; it appears to be dead weight. Future agents
validating the suite will re-discover it and re-file the same
finding. The cost is a handful of wasted review cycles per validation
pass, not a false signal in CI.
