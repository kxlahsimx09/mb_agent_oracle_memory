---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 128
parent_thread: 128
subject: re — PR #120 rebase done + canonical names verified; item 3 BLOCKED — hosted substrate missing #129 migration 000002
needs_response: true
priority: normal
created: 2026-05-16T20:33:00+07:00
handled_at: 2026-05-16T20:42:00+07:00
handled_by_thread: 127
handled_by_inbox: for-next-impl/2026-05-16_20-42_from-orchestrator_thread-130_notify.md
handled_note: >-
  Reprocessed by orchestrator — this envelope was found already moved to
  handled/ but bare (no handled_* metadata, no thread message, no git commit) by
  a concurrent session; its escalation content would otherwise have been lost.
  Surfaced on parent thread #127 msg #365. Sender mis-addressed it to closed
  thread #128; canonical routing is parent #127 / sub-thread #130. Item 3
  (supabase db push to the shared hosted substrate for PR #120 evidence)
  escalated to the user — orchestrator recommends Option B (push merged-#129
  migration 000002 only). next-impl on HOLD pending the verdict.
---

# PR #120 — items 1 & 2 done; item 3 blocked on substrate drift

## 1. Rebase — DONE

PR #120 rebased onto current `main` (`79469f5`, post-#127/#129). Probe-registry
conflict resolved in both files so the registry carries **all three** probes:

- `poc/integration/src/probes/index.ts` — imports + `ProbeEvidence` + `runAllProbes`
  now wire `cascade_race_probe` (D6, from #129) + `bot_restart_claim_probe` (D2)
  + `cron_fallback_dispatch_probe` (D7). Run order: D6 → D2 → D7.
- `poc/integration/src/hosted-assertions.ts` — evidence object carries all three.

#120's reworked always-`review` D2 probe (`f8e4ce2`) applied cleanly on top —
its index.ts comment edit (always-review wording) survived the rebase.
Branch force-pushed: `19c3255`. **PR #120 is now `MERGEABLE`** (was CONFLICTING).
Migration files post-rebase: `20260516000001_adr4a_review_rename` (#127),
`20260516000002_adr4a_d6_sweep_always_review` (#129),
`20260516000003_resolve_mark_failed_overload_ambiguity` (#120 — renumbered by
f8e4ce2, no prefix collision). NOT merged, per instruction.

## 2. Canonical names — VERIFIED

#120's D2 probe (`bot-restart-claim.ts`) + assertions use the canonical
post-#127 names throughout: `mark_review`, `status = 'review'`. No
`waiting_to_review` anywhere in the D2/D7 probe files.

One pre-existing note (NOT #120, NOT in scope — flagging only): `poc/integration/
src/rpc/withdraw/lifecycle_rpcs.sql:101` still emits a callback **event-name
string** `<source_type>.waiting_to_review` (the RPC's status columns correctly
set `'review'`). This is on `origin/main` unchanged — `git diff origin/main..HEAD`
shows #120 does not touch the file. #127's rename swept status values but left
this event-name label. Your call whether a follow-up sweep is wanted.

## 3. Hosted evidence — BLOCKED (substrate drift, not an auth problem)

I **did** run the hosted suite — no interactive auth was needed (`.secrets/
supabase.env` + `cloudflared` + `supabase` CLI all present). It completed:
`run_id 2026-05-16T13-29-28-113-hosted-tiny`, FIXTURE_SIZE=tiny SPEED=60.

Result: **71/75 PASS, 4 FAIL** — not 74/74. Root cause is **not** the probe
code (the rebased code is correct). `supabase migration list --linked` shows:

| migration | substrate |
|---|---|
| `20260516000001` adr4a_review_rename (#127) | ✅ applied |
| `20260516000002` adr4a_d6_sweep_always_review (#129) | ❌ **NOT applied** |
| `20260516000003` resolve_mark_failed_overload (#120) | ❌ not applied |

The hosted substrate is **not** post-#129 — #129 merged to `main` but its
migration was never pushed to the substrate. All 4 failures trace to the
missing `000002`:

- `d2_bot_restart_stale_claim_with_tx_id` — substrate routes to `waiting_to_review`
  (pre-#129 name), probe expects `review`.
- `d2_bot_restart_stale_claim_no_tx_id` — substrate still auto-`failed`s +
  refunds the no-tx claim (`unfreeze_logs=1`); post-#129 it must route to
  `review` with funds frozen.
- `d2_bot_restart_claim_always_review_never_reverts` — cross-branch invariant
  fails for the same reason.
- `deposit_d6_concurrent_cascade_race` — #129's own D6 probe; race-guard never
  fired (`outcomes=["finalized","no_match"]`).

Diagnostic evidence JSON written (untracked, NOT committed to the branch so #120
doesn't carry a failing run): `poc/integration/evidence/integration-hosted-run-
2026-05-16T13-29-28-113-hosted-tiny.json`. #120's shipped stale evidence
(`...10-13-49-474...`) is left in place untouched.

### Decision needed

Producing fresh 74/74 evidence requires `supabase db push` against the **shared
hosted substrate** to apply `000002` (merged #129) and `000003` (#120's own).
That is a shared-resource schema mutation beyond what this escalation
authorized, so I am **not** pushing it unilaterally — flagging for your call:

- **(A)** Authorize `db push` of `000002` + `000003` → I re-run the hosted
  suite → expect 74/74 faithful PR-120 branch evidence, commit it to the branch.
- **(B)** Authorize `000002` only (merged-main parity) → re-run; #120's `000003`
  stays off the shared substrate until #120 merges.
- **(C)** You/another session apply the migration; I stand by to re-run.

Note also: applying `000002` is independent of #120 — it's merged-#129 work the
substrate is simply missing, so it's worth doing regardless.

### Out-of-scope flag (pre-existing, on `origin/main`)

`bunx tsc --noEmit` in `poc/integration` reports 3 errors — all present on
`origin/main` (verified against a clean `origin/main` worktree), none from #120:
`src/bot-simulator/main-hosted.ts:268` (spread of non-object) and
`src/probes/cascade-race.ts:162` ×2 (`Property 'outcome' does not exist on {}`).
cascade-race.ts is #129's D6 probe — likely landed with a type regression.
Flagging for a separate cleanup; #120's own files are type-clean.

— next-impl, 2026-05-16 20:33 GMT+7

<!-- handled_at: 2026-05-16T20:38:00+07:00 — #120 rebased+MERGEABLE; hosted evidence blocked on substrate drift (#129 migration 000002 not pushed). db-push decision relayed to user. -->
