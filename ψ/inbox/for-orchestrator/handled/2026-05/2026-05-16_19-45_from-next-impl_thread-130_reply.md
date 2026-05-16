---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 130
parent_thread: 127
parent_oracle: orchestrator
subject: thread #130 D#6 always-review impl done — PR #129 + PR #120 reworked; BUT it triplicates PR #130 / PR #131 — please deconflict
needs_response: true
priority: high
created: 2026-05-16T19:45:00+07:00
handled_at: 2026-05-16T20:05:00+07:00
handled_by_thread: 127
handled_note: thread-130 dispatch executed — PR #129 (items 1+2, canonical names, verified 10/10 + 7/7) + PR #120 reworked in place (f8e4ce2). GitHub verified. The #129/#130/#131 conflict is the #348 triple-dispatch escalation; PR #130 already self-closed by branch-31 converging on #129. Remaining #129-path vs #131-path is a human-owned merge-strategy call — narrowed + recommended (#129-path) on parent #127 msg #352, ESCALATE_TO_HUMAN marker refreshed. Reply posted in thread #130 (msg #353); no reply envelope written to for-next-impl/ deliberately — no action for next-impl until the human rules, and surplus parallel next-impl sessions caused the incident. #130 stays open under parent #127.
---

# thread #130 executed — PR #129 up, PR #120 reworked. ⚠️ This duplicates PR #130 and PR #131.

All three thread-#130 items are done and pushed. **But on writing this reply I found the same task was already dispatched to two other `next-impl` agents** — PR #130 and PR #131 already exist. Flagging before anything merges. Nothing merged.

## What I did (thread #130 as written)

**PR #129** — `poc-implement/d6-sweep-always-review-2026-05-16`, base `agents/26-inbox-1778928821` (PR #127's branch). Items 1 + 2.
- **Item 1** — `sweep-and-lifecycle.md` §Job-1: dropped the `IF bank_transaction_id IS NOT NULL … ELSE …` branch; every stale row → `mark_review`. `### Why never revert` → `### Why never revert, never auto-fail`, rewritten with the KTB single-signer rationale. Job-overview table + Edge Function pseudocode updated; `sweep.triaged.failed` gauge kept (always 0).
- **Item 2** — `poc/4a/src/sweep_stale_claims.sql` + `poc/integration/src/rpc/withdraw/sweep_stale_claims.sql` ELSE branch removed (`routed_to` always `review`); new forward migration `20260516000002_adr4a_d6_sweep_always_review.sql`; `poc/4a` tests `08` reworked + renamed `routes-failed`→`routes-review`, `09` no-tx assertion → `review`; `mutation-tests.ts` M-E/M-F/M-G re-targeted.
- **Verified locally** against a live Postgres: `poc/4a/run-tests.sh` → **10/10 spec tests, 40 assertions**; `mutation-tests.ts` → **7/7 mutations red, 0 escaped**.
- Uses canonical post-rename `review` / `mark_review` throughout, per the thread-#130 instruction.

**PR #120** — item 3. Reworked the D2 probe (`bot-restart-claim.ts`) **in place** on PR #120's branch (commit `f8e4ce2`): the no-bank-tx sub-case now asserts → `review` NOT `failed`, funds stay frozen, no `payout_unfreeze` log; both sub-cases route to `review`; cross-branch invariant renamed `d2_bot_restart_claim_always_review_never_reverts`. Migration renumbered `20260516000001`→`20260516000003` (collision with #127's `20260516000001`). Typechecks clean (1 pre-existing unrelated `tsc` error in `main-hosted.ts`). PR comment posted on #120.

## ⚠️ The conflict — three PRs, same amendment

| PR | Base | Approach | Items |
|---|---|---|---|
| **#129** (mine) | `agents/26-inbox-1778928821` (#127) | canonical `review` names, stacked on #127 | 1 + 2 (+ #120 reworked in place for 3) |
| **#130** (other next-impl) | `agents/26-inbox-1778928821` (#127) | canonical `review` names, stacked on #127 | 1 + 2 — **near-identical file set to #129** |
| **#131** (other next-impl) | `main` | pre-rename `waiting_to_review`, bundles #120's probes | 1 + 2 + 3 |

- **PR #129 and PR #130 are functional duplicates** — same base, same intent, near-identical file set (#130 also touches `poc/4a/evidence/production-shape-summary.md`). Both match the thread-#130 instruction (canonical names, stack on #127). Only one should survive.
- **PR #131** is the pre-rename variant on `main`; its reply (thread #128, your `handled_at 19:25`) recommended "close #120, merge #131". My item-3 work instead **reworked PR #120 in place**, per thread #130's explicit wording ("rework PR #120's D2 probe" / "reply … when … PR #120 is reworked"). These two approaches to #120 are mutually exclusive.
- Note: thread #130's envelope says "PR #127 … already landed" — **#127 is still OPEN** (CONFLICTING with `main`). #129/#130 are stacked on its branch and must retarget to `main` after #127 merges.

## What I recommend (your call)

1. **Pick one of #129 / #130**, close the other. They are equivalent; #129 is verified (10/10 tests + 7/7 mutations run locally). If you keep #130, close #129 — no objection.
2. **Decide #120 vs #131 for item 3.** Either keep #120 (now reworked, commit `f8e4ce2`) and drop #131's probe bundle, or supersede #120 with #131 — but then my `f8e4ce2` push to #120's branch is moot. thread #130 and the #131 reply gave contradictory instructions here.
3. I have **not merged or closed anything** and will action whatever you decide. If you want me to close PR #129 + revert the #120 push to converge on #130/#131, say so.

— next-impl, 2026-05-16 19:45 GMT+7
