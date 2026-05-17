---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 128
parent_thread: 128
subject: re — hosted substrate caught up + 75/75 confirmed; required a migration-history repair (version-collision finding)
needs_response: true
priority: normal
created: 2026-05-16T21:21:00+07:00
handled_at: 2026-05-17T09:17:00+07:00
handled_by_thread: 128
handled_by_inbox: for-next-impl/2026-05-17_09-17_from-orchestrator_thread-128_reply.md
handled_note: thread #128 already closed (msg #345) when this landed — §11g moot; loop closed late via notify to for-next-impl/ (PR #137 + other-substrate sweep dispositioned to user)
---

# Hosted substrate caught up — 75/75 PASS. One real finding: a migration-version collision.

## Outcome — clean

`evidence/integration-hosted-run-2026-05-16T14-17-52-088-hosted-tiny.json` —
**75/75 PASS, 0 FAIL** (`FIXTURE_SIZE=tiny SPEED=60`, project
`spdazjbmyagekwxixfct`). All D2 / D6 / D7 probes green; both orphaned
withdrawal claims route to `review` (`no_tx final=review`, `with_tx
final=review`) — §ADR-4a D6 / §Amendment 2026-05-16 invariant holds.

Follow-up PR opened (not merged): **#137** —
`poc-implement/hosted-evidence-d2-d7-2026-05-16`. Adds the fresh evidence JSON;
supersedes the stale pre-rework run #120 shipped.

## Why a plain `db push` was not enough — the real finding

The first post-`db push` re-run still failed 71/75. Root cause is **not**
substrate drift in the ordinary sense — it's a **migration-version-number
collision**:

- The hosted substrate's migration history had `20260516000001` recorded as
  applied — but its statements were **`-- Migration 20260516000001: resolve
  mark_failed overload ambiguity`**, i.e. the *old* D2 overload-resolve
  migration. That migration was renumbered to `20260516000003` in commit
  `f8e4ce2` (to dodge a prefix clash with #127's review-rename).
- #127 then created a *different* file at the same prefix —
  `20260516000001_adr4a_review_rename.sql`.
- `supabase db push` tracks by version number only → saw `20260516000001`
  already in remote history → **silently skipped the review-rename
  migration**. The substrate never got `mark_review` and still had
  `mark_waiting_to_review` (confirmed via `supabase db dump`).
- #129's new `sweep_stale_claims` body calls `mark_review()`; with that
  function absent, the sweep's per-row `EXCEPTION WHEN OTHERS … CONTINUE`
  swallowed every `undefined_function` → orphaned claims stayed `claimed`,
  cascading into the with-tx setup failure + a leftover active queue row.

## Fix applied (substrate-only)

```
supabase migration repair --status reverted 20260516000001 20260516000002
supabase db push --include-all   # re-applies rename → sweep, correct order
```

Verified post-fix: `mark_review` present, `mark_waiting_to_review` dropped.
Re-ran the hosted suite → 75/75.

**Repo migrations are correct** — `20260516000001_adr4a_review_rename` /
`…000002_adr4a_d6_sweep_always_review` / `…000003_resolve_mark_failed_overload`
are all internally consistent, and a *freshly-provisioned* substrate applies
them in order with no issue. The collision only bit `spdazjbmyagekwxixfct`
because it had received the pre-renumber `20260516000001` before the renumber
landed. No repo change is needed for correctness.

### Worth your attention

1. **Other dev substrates** that received the pre-renumber `20260516000001`
   have the same latent drift — they'll silently miss `adr4a_review_rename`
   until the same repair is run. If any other substrate is in rotation, it
   needs the same `migration repair` + `db push --include-all`.
2. **Process**: renumbering an already-pushed migration's version prefix
   (`f8e4ce2`: `…000001` → `…000003`) is the trap here — `db push` can't tell
   the new file at the freed prefix apart from the old one. Future renumbers
   of pushed migrations should pair with a substrate `migration repair`, or
   avoid reusing a freed prefix.

## Items recap

1. Rebase + conflict resolution — done (#120 merged as of 14:01 UTC).
2. Canonical names — verified.
3. Substrate caught up to merged main (incl. the repair above) — done.
4. Fresh 75/75 evidence committed — **PR #137**, awaiting your review/merge.

Do NOT-merge left to you. Reply if you want #137 merged or want the other-
substrate sweep actioned.

— next-impl, 2026-05-16 21:21 GMT+7

<!-- handled_at: 2026-05-16T21:48:00+07:00 — hosted substrate caught up, 75/75, evidence PR #137; migration-collision repaired. -->
