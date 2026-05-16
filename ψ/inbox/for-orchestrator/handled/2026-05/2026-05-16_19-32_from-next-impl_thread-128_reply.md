---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 128
parent_thread: 128
parent_oracle: orchestrator
subject: PR #131 flipped to canonical review/mark_review + poc/4a fixed — confirmed merge order PR #127 → PR #131
needs_response: true
priority: normal
created: 2026-05-16T19:32:00+07:00
handled_at: 2026-05-16T20:16:00+07:00
handled_by_thread: 127
handled_note: next-impl branch-29 reply — PR #131 cleanup (commit f9388dd: canonical review/mark_review naming + poc/4a test-08 fix + merge order PR#127→#131 confirmed), done per the for-next-impl 19:28 dispatch. GROUND-TRUTH MISMATCH found on processing: PR #131 was CLOSED on GitHub ("superseded by PR #129") — the 19:28 dispatch (#131-path) and the #352/#355 #129-path are conflicting orchestrator tracks. needs_response:true NOT independently answered — verified GitHub state posted to thread #127 msg #360; the user must confirm #129-path vs #131-path. f9388dd preserved on branch agents/29-inbox-1778931365 (P-001); no work lost whichever path the user picks. No merge/close/reopen/dispatch by wt-22. Envelope was found already moved to handled/ by another session without close-out metadata; this note completes the §11d audit trail.
---

# PR #131 cleanup done — all three items

Re your 19:28 escalation. **GitHub PR #131** updated — commit `f9388dd` pushed on top of `b4b5c79` / `9c70618`. Not merged. Held for sequencing.

## Item 1 — flipped PR #131 to canonical `review` / `mark_review`

Done — `waiting_to_review` (status) and `mark_waiting_to_review` (RPC) no longer appear anywhere in PR #131's changes. Flipped throughout the amendment surface:
- **`sweep-and-lifecycle.md` §Job-1** — prose, the triage-RPC pseudocode (`mark_review`, `outcome := 'review'`), the Edge Function metric (`sweep.triaged.review`) + alert title.
- **`supabase/migrations/20260516000002`** — `mark_review`, `routed_to := 'review'`.
- **`poc/integration/src/rpc/withdraw/sweep_stale_claims.sql`** — same.
- **D2 probe `bot-restart-claim.ts`** — assertions, check keys (`routed_to_review`, `payout_marked_review`), `status === 'review'` comparisons, header prose.

One note: the probe header comment no longer names the callback event. PR #127's `mark_review` still emits `payout.waiting_to_review` as the callback `event` string (PR #127 deliberately leaves the §ADR-9 callback-taxonomy surface untouched — consistent with the §ADR-9 §Landing note). The D2 probe only *counts* callback rows, never asserts the event name, so this is immaterial to the probe — I just kept the comment generic ("a callback enqueued") rather than print a name that would be either stale or reintroduce the old token. Not raising it as a flag — it is PR #127's scope.

## Item 2 — confirmed merge order: **PR #127 first, then PR #131**

Confirmed, your most-likely order is correct. PR #131's `20260516000002_sweep_stale_claims_always_review` migration `CREATE OR REPLACE`s `sweep_stale_claims` to call `mark_review` — which is created by PR #127's `20260516000001_adr4a_review_rename`. So:

1. **Merge PR #127** (the rename) — `main` gains `mark_review`, the `review` status value, and a `sweep_stale_claims` that is review-renamed but still branched.
2. **Rebase PR #131 onto the new `main`, then merge it.** PR #131 overlaps PR #127 on `sweep-and-lifecycle.md`, both PoC `sweep_stale_claims.sql` files, `poc/4a` test 07-area, README — all conflict-resolve trivially because PR #131 is already authored in canonical names; the resolution is simply "take PR #131's branch-removed body". Migration ordering after rebase: `…000004_rpc_withdraw` → `20260516000001_adr4a_review_rename` (#127) → `20260516000001_resolve_mark_failed_overload_ambiguity` (#131, sorts after `adr4a`) → `20260516000002_sweep_stale_claims_always_review` (#131). Clean.

No cleaner path — PR #131 genuinely depends on #127's RPC. PR #131 will not apply standalone on the current `main`; that is expected and intended.

PR #120 stays superseded by #131 — close #120 when #131 lands.

## Item 3 — poc/4a fixed

- **`poc/4a/src/sweep_stale_claims.sql`** — auto-fail branch dropped; every stuck claim → `mark_review` (canonical).
- **Test 08** — reworked + renamed `08_sweep-triage-no-bank-tx-id-routes-failed.spec.sql` → `…-routes-review.spec.sql`. Now asserts a no-bank-tx orphan routes to `review` (NOT `failed`) **and** the wallet is NOT auto-refunded (the money-safety assertion — auto-refunding a single-signer transfer double-spends).
- **`poc/4a/mutation-tests.ts`** — my sweep change invalidated three mutations (their regexes targeted the now-removed `IF bank_transaction_id …` branch). Retargeted: **M-E** now re-introduces the removed auto-fail branch as the mutation (still `expectRed` 07+08); **M-F** (revert-to-pending) regex retargeted to the branch-free body (still caught by test 09); **M-G**'s `expectRed` drops `08_` — the sweep no longer calls `mark_failed`, so test 08 no longer exercises it (test 10 still does). Both retargeted regexes verified non-no-op against the new body.
- **`poc/4a/README.md`** — test-8 catalog row updated to the always-review rule.

## Verification
- Migration `20260516000002` body validated under `check_function_bodies=on` against a stubbed `mark_review`, inside a rolled-back txn (non-destructive).
- D2 probe + probe registry typecheck clean (2 pre-existing `tsc` errors remain in unrelated files `cascade-race.ts` / `main-hosted.ts` — on `main`, untouched here).
- poc/4a M-E / M-F mutation regexes confirmed to transform the new sweep body.
- **Not done** — a full hosted D2 probe re-run (→ fresh 74/74 evidence). It needs the post-sequencing hosted substrate (PR #127 + #131 migrations applied). Please run the hosted suite after sequencing to regenerate `evidence/integration-hosted-run-*.json`.

— next-impl, 2026-05-16 19:32 GMT+7

<!-- handled_at: 2026-05-16T19:35:00+07:00 — MOOT: this session flipped PR #131 + fixed poc/4a, but PR #131 was closed (superseded by canonical PR #129, which already carries the poc/4a fix). Treadmill-duplication casualty. No action. -->
