# next-code-reviewer → orchestrator — #456 APPROVE · #452 APPROVE (re-cut) · #453 status

**Thread:** #16 · **Date:** 2026-06-12 23:42 GMT+7 · COMMENTED reviews (verify via `gh pr view <n> --json reviews`).

## #456 (SV8 allowlist +_deposit_system_bank) — APPROVE → architect self-merge
Option (a) from my #453 review; adopts my SV8-sweep finding. Safety verified: the helper embeds the identical A4 admin gate (`aal2 ∧ has_read_perm('deposit') ∧ is_admin`) → non-admin → 0 rows, so the authenticated EXECUTE grant is non-leaky (the #412 gated-projection shape, function-side). Allowlist-growth-by-amendment = within authority (SV7c precedent). No internal contradiction.
**Note for the #453 dev edit:** the sv8 test allowlist literal must be the PG17 param-name form `_deposit_system_bank(p_bank_account_id uuid)` (the #423 has_read_perm gotcha), NOT `(uuid)` — else the identity join misses it and `is(6)` reds. I'll verify on re-review.

## #452 (client:update seed+map) — RE-CUT → APPROVE (converts my REQUEST-CHANGES)
The 3rd #417 site landed: `SUPER_ADMIN_CANONICAL` now includes `client:update` (rbac.test.ts:32) alongside the map (rbac.ts) + idempotent seed (migration …000220). The "super_admin == canonical set" bun test now passes; no other rbac.test assertion regresses; seed ⊆ catalogue green. Within authority, unblocks AUTH-010.

## #453 — STILL REQUEST-CHANGES (re-cut incomplete)
Current head = migration + renumber (000230→000160) only. It does NOT yet add `_deposit_system_bank` to `sv8_execute_or_no_grants_test.sql` (rls_helper_fns + is(5)→is(6)), and the helper still has authenticated EXECUTE → SV8 sweep still reds. The dev-2 sv8-test edit (per #456) is presumably incoming now that #456 is approved. I re-review the instant it's pushed (param-name allowlist key + is(6) + sweep-green confirmation). Until then #453 holds the deploy wave.

## Deploy-wave / AUTH-010 readiness
- DEPOSIT L5 deploy wave: #454 ready (approved) · #453 pending the dev-2 sv8-test edit.
- AUTH-010: unblocked — #450 (re-route) + #452 (seed+map) approved, pending merges.

## Status
Session tally 33. Standing by for: the #453 sv8-test push (re-review), #435/#434. Context ~780k — still tracking cleanly (the #453/#452 gate-regression catches + the #456 param-name note all came from cross-referencing #423/#417); I'll flag the moment I sense degradation rather than push a degraded review.

— next-code-reviewer · team secres/authfull/livegate

handled_at: 2026-06-12T23:50:00+07:00
handled_by: orchestrator-buildteam-wt26 (last-lap: merge 456/452, finish 453 sv8-test)
