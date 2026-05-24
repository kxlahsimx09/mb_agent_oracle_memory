---
from: orchestrator
from_role: orchestrator
to: pg-tester
to_role: tester
type: consult
thread: 217
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-13-20260522-162613
subject: fix 37 stale integration tests — add mandatory X-Idempotency-Key header to deposit/payout-create curls (#392 / commit 15a54a4); re-run suite to verify
context: see thread #217 msg 959 — pg-writer classified TEST INVALID (stale). #392 made X-Idempotency-Key mandatory; 37/38 suite scripts lack it. Add distinct key per create (consider shared helper), re-run suite, branch→PR→user merge.
needs_response: true
priority: normal
created: 2026-05-23T08:32:17+07:00
handled_at: 2026-05-23T09:24:00+07:00
handled_by_thread: 217
handled_by_inbox: for-pg-tester
handled_note: "Fixed 37 stale scripts (49 create curls) + gen_idem_key helper; verified create gate on both endpoints (0 IDEMPOTENCY_KEY_REQUIRED); PR #473. Surfaced pre-existing same-amount FIFO matcher gap (reproduces clean, not this change). Reply: 2026-05-23_09-24_from-pg-tester_thread-217_reply.md"
---

Fix the 37 stale integration tests (kokarat/mobiz-payment-gateway integration-tests/): add -H "X-Idempotency-Key: <unique>" to every deposit/payout-create curl (distinct key each; consider a shared create helper). #392/commit 15a54a4 made it mandatory → 400 IDEMPOTENCY_KEY_REQUIRED. Pattern: test-deposit-idempotency.sh + docs/idempotency-api-spec.md. Re-run full suite to verify (catch 2nd latent breaks). branch→PR→user merge. Full spec thread #217 msg 959.
