---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 128
parent_thread: 128
parent_oracle: orchestrator
subject: §ADR-4a §Amendment 2026-05-16 sweep-triage impl landed — PR #131 (reworks PR #120)
needs_response: true
priority: normal
created: 2026-05-16T18:53:00+07:00
handled_at: 2026-05-16T19:25:00+07:00
handled_by_thread: 127
handled_note: next-impl branch-29 reply — PR #131 landed (impl leg of §ADR-4a §Amendment 2026-05-16, supersedes PR #120). This is one of three parallel next-impl runs from the triple-dispatch incident escalated at thread #127 msg #348. needs_response:true NOT independently answered — the 3 sequencing flags (naming / PR#131-vs-PR#127 merge order / poc-4a test 08) are all downstream of the #348 containment decision, which is pending the user. wt-22 recorded PR #131's completion as a factual addendum on #127 (msg after #348) and is waiting on the human verdict. Envelope was found already moved to handled/ without close-out metadata; this note completes the §11d audit trail.
---

# §ADR-4a §Amendment 2026-05-16 (D2 sweep) implemented — PR #131, NOT merged

All three hand-off items done. **GitHub PR #131** on `kxlahsimx09/mb-next-payment-gateway` (branch `agents/29-inbox-1778931365`, base `main`). Held for your sequencing — not merged.

## What landed

PR #131 = **two commits**:
1. `9c70618` — PR #120's D2+D7 probes, **cherry-picked + rebased onto current `main`** (PR #120's branch was based on stale `8618d18`, pre-#119/#124/#128). Resolved one conflict in `probes/index.ts` / `hosted-assertions.ts` — current `main` has the D6 `cascade_race_probe` (PR #119) that PR #120's base lacked; merged all three probes.
2. `b4b5c79` — the amendment itself.

**PR #131 supersedes PR #120** — it carries PR #120's full content plus the rework. Recommend: close PR #120, merge PR #131 in its place. (I did not push to PR #120's branch directly — it is checked out in another worktree.)

### Item 1 — `sweep-and-lifecycle.md` §Job-1
Dropped the `IF bank_transaction_id IS NOT NULL … ELSE …` branch — every stale row → `mark_waiting_to_review`. Job-overview row, the "why never revert, **never auto-fail**" prose (rewritten with the KTB single-signer rationale + SA-block citations), and the Edge Function `sweep.triaged.failed` metric-continuity note all updated. No schema change, no new RPC.

### Item 2 — PoC sweep code + forward migration
- **NEW** `supabase/migrations/20260516000002_sweep_stale_claims_always_review.sql` — `CREATE OR REPLACE sweep_stale_claims` with the branch removed; `routed_to` always `'waiting_to_review'`; `RETURNS TABLE` signature unchanged. Timestamp `20260516000002` — a later, non-colliding slot (per your note `20260516000001` is taken twice: PR #120's overload-fix + PR #127's `_adr4a_review_rename`).
- `poc/integration/src/rpc/withdraw/sweep_stale_claims.sql` — same branch removal in the local-run source mirror (`run.ts` applies `src/rpc/**` directly; the hosted run uses `supabase/migrations/` — both layers covered).

### Item 3 — PR #120 D2 probe rework (the unblock)
`bot-restart-claim.ts` reworked. The no-bank-tx sub-case now asserts the always-review rule: an orphaned claim with **`bank_transaction_id IS NULL` lands in `waiting_to_review`, NOT `failed`** — funds STAY frozen, no `payout_unfreeze` ledger row, callback enqueued, never `pending`. With-bank-tx sub-case + selectivity proof kept; the cross-branch invariant now proves *both* orphans reach review (never auto-fail, never revert). Assertion count unchanged (3) — smoke total stays 74. Stale pre-rework hosted evidence JSON removed.

## Verification
- **TypeScript** — reworked probe + registry typecheck clean. 2 pre-existing `tsc` errors remain in unrelated files (`cascade-race.ts`, `main-hosted.ts`) — on `main`, untouched here.
- **SQL** — migration `20260516000002` body validated against a live Postgres under `check_function_bodies=on` inside a rolled-back txn (non-destructive); `withdrawal_queue` + the 3-arg `mark_waiting_to_review` resolve.
- **Not done** — a full hosted probe re-run (D2 → fresh 74/74 evidence). The D2 probe runs hosted-only; a clean current-`main` hosted substrate + the post-sequencing migration set is needed. **Please run the hosted suite after sequencing** to regenerate `evidence/integration-hosted-run-*.json`.

## Flags for your decision

1. **Naming — pre-rename names kept.** PR #131 uses `waiting_to_review` / `mark_waiting_to_review` throughout (including the design-doc §Job-1), for internal consistency with un-renamed `main` and so the migration applies + verifies as-is. The escalation said §Job-1 → `mark_review`; I deferred that to **PR #127** (the in-flight rename), which already edits `sweep-and-lifecycle.md` (17 lines) and the PoC sweep code, and ships its own `20260516000001_adr4a_review_rename.sql` re-creating `sweep_stale_claims`. Renaming in PR #131 too would double the work and still conflict. If you want PR #131 in canonical `review`/`mark_review` instead, say so and I will flip it.

2. **Unavoidable conflict with PR #127.** Both PRs edit `sweep-and-lifecycle.md` and `poc/integration/src/rpc/withdraw/sweep_stale_claims.sql`, and both ship a `sweep_stale_claims`-recreating migration. **Recommended order: merge PR #131 first** (verifiable, functional, unblocks the probe), then rebase PR #127 — its mechanical rename sweep then absorbs PR #131's additions (the new `20260516000002` migration + new `waiting_to_review` occurrences). The reverse order also works but leaves PR #131 to rebase + adopt canonical names.

3. **`poc/4a` NOT touched.** The Postgres-floor sibling PoC still encodes the old triage in `poc/4a/src/sweep_stale_claims.sql` **and** pgTAP test `poc/4a/tests/08_sweep-triage-no-bank-tx-id-routes-failed.spec.sql` — that test now asserts the money-unsafe `no-bank-tx → failed` rule the amendment removed. Escalation scoped item 2 to the integration PoC + forward migration, so I stayed within it, but flagging: `08` is a test actively asserting the double-spend behaviour. Recommend a `poc/4a` follow-up or folding it into PR #127's `poc/4a` edits. (The integration smoke's Scenario 5 only exercises the *with-bank-tx* branch, which is unchanged — smoke stays green either way.)

— next-impl, 2026-05-16 18:53 GMT+7

<!-- handled_at: 2026-05-16T19:25:00+07:00 — read + actioned by orchestrator. -->
