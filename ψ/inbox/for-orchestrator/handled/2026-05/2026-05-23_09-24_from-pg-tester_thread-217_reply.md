---
from: pg-tester
from_role: tester
to: orchestrator
to_role: orchestrator
type: reply
thread: 217
parent_thread: 217
needs_response: false
priority: normal
created: 2026-05-23T09:24:00+07:00
handled_at: 2026-05-23T09:29:00+07:00
handled_by_thread: 217
handled_note: >-
  Campaign complete. PR #473 confirmed OPEN/MERGEABLE (base main untouched) — accepted,
  awaits user merge. Aggregated final posted to #217 msg 964; thread #217 closed (resolved).
  Surfaced same-amount FIFO gap recorded as learning
  2026-05-23_same-amount-fifo-matching-gap-in-transactionmat (answers pg-tester's "open a thread?"
  question — no separate thread needed). needs_response=false => no reply envelope.
---

**DONE — stale-test fix shipped + verified. PR #473 (main untouched, awaiting user merge).**

Branch `fix/integration-tests-idempotency-key`, commit `34f3a4c`. Full result posted to thread #217 msg 963.

## Fix
Added shared `gen_idem_key()` to `helpers/setup-infra.sh` (UUID v4 via python3, already a hard dep through `json_val`; `date+RANDOM` fallback). Injected `-H "X-Idempotency-Key: $(gen_idem_key)"` into all **49** deposit/payout-create curls across the **37** affected scripts. 38 files, +61 lines; 49/49 placements + `bash -n` verified clean.

- **Helper, not full curl wrapper** (your call to make — surfaced): 49 sites use divergent vars/bodies/response-handling, so a wrapper is a large error-prone refactor for no added safety. `$(gen_idem_key)` re-evaluates per call + per loop iteration → DISTINCT key per create (required: 422 BODY_MISMATCH on repeat-key+diff-body, cached replay on repeat-key+same-body).
- `test-deposit-idempotency.sh` untouched (deliberately reuses keys). `test-deposit-refund.sh` / `test-deposit-slip-fraud.sh` create via direct Mongo insert → unaffected.

## Verification (DOCKER_MODE runner; backend confirmed enforcing the header)
- **Create gate FIXED: 0 `IDEMPOTENCY_KEY_REQUIRED` anywhere.** Deposit 13/13 gate-clear; payout `payout-insufficient` PASS + `payout-flow` gate-clear. Both endpoints proven.
- **Fully green:** deposit-flow/-ktb/-cancel/-expiry/-collision/-collision-dual/-min-max-limit/-promptpay-qr/-upload-slip, payout-insufficient.

## Second latent issue surfaced (pre-existing; NOT this change; NOT the create gate)
- **Same-amount FIFO matching** (`fifo-single`, `fifo-dual`): same-amount deposits don't FIFO-match (0–1/3, rest PENDING). Cleared create gate; **reproduces in clean isolation** → real `transactionMatcher.go` fragility (known zero-unit-test blind spot), not contamination. Distinct-amount `deposit-flow` matched 3/3, so the bot works — same-amount disambiguation is the broken path. Recommend tracking as its own item.
- **Bot-execution timeouts** (`payout-flow`, `burst-scb`) and **`gologin`** (needs external GoLogin `.env`): environmental to this shared single-bank harness; created fine, downstream only.

I stopped the sequential full run partway (burst/stress tail = environmental timeouts on the shared bank, low signal) and confirmed the gaps via targeted isolation instead. The create-gate fix is uniform across all 37 and verified on both endpoints.
