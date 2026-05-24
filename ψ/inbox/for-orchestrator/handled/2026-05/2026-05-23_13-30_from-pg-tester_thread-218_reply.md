---
from: pg-tester
from_role: tester
to: orchestrator
to_role: orchestrator
type: reply
thread: 218
parent_thread: 218
in_reply_to: 2026-05-23_13-06_from-orchestrator_thread-218_consult.md
needs_response: false
priority: normal
created: 2026-05-23T13:30:00+07:00
handled_at: 2026-05-23T13:48:00+07:00
handled_by_thread: 218
handled_note: thread 218 closed (status=closed) at msg 968. Annotation task complete — PR #475 verified OPEN/MERGEABLE/CLEAN, 3 files +51/−2, matcher+assertions untouched, awaits user merge. needs_response=false, so no reply envelope required (§11g Resolved).
---

**Done — annotation-only KNOWN-WONTFIX marking for the same-amount FIFO tests. PR: https://github.com/kokarat/mobiz-payment-gateway/pull/475** (branch `docs/fifo-known-wontfix-annotation`, base `main`, awaits user merge — main untouched). Result also posted to thread #218 msg 967.

**Scope honored:** matcher + test assertions UNTOUCHED. Diffstat 3 files, +51 / −2 (the 2 deletions = the rewritten test-index rows). `bash -n` clean on both scripts.

1. **`docs/test-index.md`** — both `deposit-fifo` rows: note → `**KNOWN-WONTFIX** — same-amount FIFO removed #200 (cross-client safety); EXCLUDED from regression-suite.txt; a full-dir FAIL here is EXPECTED, not a regression`; Root-cause-commit col → `#200 097c707 + a4ebd0f`; Proposed-fix col → `— (ก/ข product decision: human/mobiz)`; Oracle learning `2026-05-23_same-amount-fifo-deposit-matching-scb-is-a-known` cited. Status left `VALID` (didn't reclassify — avoids corrupting the Summary status counts; KNOWN-WONTFIX lives in the note as you specified).

2. **Header banners** — `⚠ KNOWN-WONTFIX — A FAILURE HERE IS EXPECTED, NOT A REGRESSION ⚠` block at the top of both `test-deposit-fifo-single.sh` and `-dual.sh`: assert PRE-#200 auto-match, mobiz won't fix, intentionally excluded from `regression-suite.txt`, FAIL is expected, change is the human's ก/ข call, points to the learning id.

**Per-file accuracy notes:**
- `fifo-single` expects 3 same-amount deposits → 1 SCB account all FIFO-matched (Step 7 `MATCHED==3`, Step 8 all paid) → 0/3 under #200's `markForReview`.
- `fifo-dual`'s *description* banner says bots "SKIP", but the *actual* assertion (Step 7/8) requires `SCB_MATCHED==3 && KTB_MATCHED==3`, all 6 paid — also pre-#200 auto-match. SCB side regresses; KTB still wires matchByClientScope→matchByFIFO. Flagged that stale-"SKIP" self-contradiction in the new banner so the next reader isn't misled.

No `regression-suite.txt` edit (already excludes both — confirmed: 27 fast-tier entries, zero fifo). needs_response satisfied; nothing further required from me.
