---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 186
parent_thread: 181
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: reply — #186 Track B substrate landed; PR #206; hosted 188/188; 2 architect-divergence flags raised
in_reply_to: 2026-05-21_10-59_from-orchestrator_thread-186_consult.md
needs_response: true
priority: normal
created: 2026-05-21T11:15:00+07:00
handled_at: 2026-05-21T11:17:57+07:00
handled_by_thread: 186
handled_by_inbox: for-orchestrator/handled/2026-05/2026-05-21_11-17_from-orchestrator_thread-186_reply.md
handled_note: "Track B substrate PR #206 landed: 6 §CR9 items + hosted 188/188 PASS + 2 architect-divergence flags on §CR2 (preserve 'rejected', 7 values) + §CR3 (preserve 'fee', 5 values). Flags concur'd as load-bearing-correct per [[poc-load-bearing-realism]]. Reply at #186 msg 737 + envelope mirrors at for-next-impl/ + for-orchestrator/handled/. Architect notified at #183 msg 738 + envelope for-next-architect/2026-05-21_11-17_..._thread-183_notify.md for §Substrate-correction annotation post-merge (no re-ratify; §FA2 substrate-catchup precedent). User notified at #181 msg 739 for merge decision."
---

Track B substrate landed on fork PR #206 (https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/206). Branch `next-impl/thread186-track-b-review-canonical-rename` off `main@6fa5bc6`. No merge from me — user merges.

**Shipped (all 6 §CR9 items):**
- Migration `20260521000001` — §CR2 (`ts_deposits.status` CHECK rebuild), §CR3 (`bank_statements.match_status` CHECK rebuild), §CR4 (test-aggregator output keys rename + admin_approve_paid §V15-2 predicate `'review'` ghost-token §CR5).
- src literal rewrites — `poc/integration/src/rpc/deposit/match_deposits_cascade.sql:105,109` + `poc/4b/src/match_deposits_cascade.sql:100,104` (`'review_required'` → `'review'`).
- TS reader rename — `hosted-assertions.ts:181-185` (`multiCand.review_required_*` → `review_*`).
- §CR7 INSERT-branch deletion — `poc/4a/src/lifecycle_rpcs.sql:182-188` (obsolete `payout.waiting_to_review` callback).

**poc/4b retire-vs-port decision (impl-pass discretion per §CR9):** REWRITE LITERALS (preserve layer). `poc/4b/` still `[POC_ACTIVE:4b]` per README + load-bearing mutation-test + pgTAP claim tests for §ADR-4b shape; retirement is a bigger-scope call for a separate beat. Same call for `poc/4a/`.

**Hosted-verified 188/188 PASS** @ `SPEED=60x` against `spdazjbmyagekwxixfct` (baseline 188/188 from main HEAD `6fa5bc6` maintained; no new assertions — §CR is a substrate-catchup, not a feature add). Evidence at `poc/integration/evidence/integration-hosted-run-2026-05-21T04-10-32-991-hosted-tiny.json`. Multi_candidate shape confirms renamed keys (`review_count=2`, `review_max_candidates=2`, etc.); FA2 cluster assertions read the new keys and PASS. V15/V13/V14 force-approve still PASS. No regressions on audit_log_denorm / admin_payout_cancel / admin_payout_reconcile / admin_deposit_* paths.

**⚠ Two architect-divergence flags raised — please concur:**
1. **§CR2** — architect's stated 6-value list is grounded against the schema file, not the deployed CHECK. Deployed (per `20260513000004:27-28`) has 8 values — schema-floor enum **plus `'rejected'`**, load-bearing across `admin_approve_failed`, §ADR-9 reject RPC, regression-sentinel `deposits_rejected` counter, slipv1/slipv2 failure seed assertions. PR preserves `'rejected'` → new enum **7 values**: `('pending','paid','rejected','expired','cancelled','checking','failed')`.
2. **§CR3** — architect's 4-value list omits `'fee'` which is load-bearing post §ADR-4b §Amendment 2026-05-20 §FC1 (`20260520000007:38-40`). PR preserves `'fee'` → new enum **5 values**: `('pending','matched','unmatched','review','fee')`.

If you disagree with either, I can revise — but per [[poc-load-bearing-realism]] + [[state-grounding-cite-by-line]] the deployed substrate is the source-of-truth and dropping `'rejected'` would silently break every deposit-reject path; dropping `'fee'` would fail every §FC1 intake-classifier CHECK.

Full reply on thread #186 (msg 736). `parent_thread=181` routes parent campaign mid-stream relay back to you.
