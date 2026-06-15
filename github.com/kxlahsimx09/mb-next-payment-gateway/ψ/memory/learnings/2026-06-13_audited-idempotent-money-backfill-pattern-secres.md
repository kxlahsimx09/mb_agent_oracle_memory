---
title: Audited idempotent money-backfill pattern (secres campaign, PR #466 merged 2026-
tags: [backfill, idempotency, money-safety, adr-10, migration-collision, multi-stack, prefix-resolution, reviewer-verdict, deposit-l5]
created: 2026-06-13
source: next-dev-1 (campaign secres, thread #16)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Audited idempotent money-backfill pattern (secres campaign, PR #466 merged 2026-

Audited idempotent money-backfill pattern (secres campaign, PR #466 merged 2026-06-13, SHA 6d3344be) — the §ADR-10 RM2→R1 mdr_residual backfill for 3 run-57bd31e7 deposits manually approved BEFORE #438 added the residual→mdr_owner leg (their residual landed only in transactions.fee, never the mdr_owner wallet; per-deposit conservation short by Σ=19.40: abd853c2→8.00, a0f823b6→5.70, e6367d60→5.70). Migration 20260612000250_adr10_rm_residual_backfill_run57bd31e7.sql.

DESIGN (reusable for any "fix N already-committed money rows" task): one DO block, resolve+LOCK the sink wallet FOR UPDATE (§ADR-10 D5 id-ASC, fail-closed RAISE if absent); per row — (1) credit balance += amount with UPDATE…RETURNING * INTO v_owner so before/after accumulates across rows; (2) append a wallets_change_logs row mirroring the FIXED fn's exact shape (operation='mdr_residual', reference_type='deposit', reference_id=<resolved id>, full balance_before/after); (3) append an audit_log row (action_type='mdr_residual_backfill', actor_type='system', rich metadata). NEVER a silent UPDATE — every credit is a NEW append mirrored by audit.

THREE SAFETY PROPERTIES that made it bulletproof + multi-stack-safe:
• IDEMPOTENT — guard each write on NOT EXISTS an mdr_residual wcl row for (reference_id, sink wallet) → re-run is a pure no-op (no double-credit). The orchestrator's hard requirement.
• EXISTENCE-AWARE / multi-stack-safe — the run deposits are sinuw-ONLY, but the migration deploys to sinuw AND qnccph. A non-existence-aware hardcoded credit would OVER-CREDIT qnccph's mdr_owner (which was never under-credited there). Fix: resolve each deposit from its id-prefix ON THIS STACK (array_agg(id) → cardinality check); 0 matches → CONTINUE (no-op). The credit lands only where the under-credit actually happened.
• FAIL-LOUD on ambiguity — prefix matching >1 deposit → RAISE 'refuse to guess' (never credit the wrong row).
Also: actor_type='system' makes _denorm_last_admin_action early-return (it only denorms actor_type='admin'), so the deposits' ORIGINAL last_admin_action_* (the real approve) is preserved — the backfill doesn't masquerade as an admin act.

KEY GOTCHA — only 8-char prefixes were ever provided (the full sinuw UUIDs were never handed over; dev-1 has no access to sinuw rows). Rather than stall, prefix-resolution-at-apply-time turned the missing-UUID blocker INTO the multi-stack-safety mechanism. Resolver: SELECT array_agg(id) INTO v_ids …WHERE id::text LIKE prefix||'%'; v_n:=COALESCE(array_length(v_ids,1),0); 0→CONTINUE, >1→RAISE, else v_dep_id:=v_ids[1]. (NOTE max(uuid) has NO aggregate — array_agg, not max.)

DEV-1 VERIFICATION (no sinuw access, no docker) — created 3 FIXTURE deposits whose ids carry the real prefixes (status must be ∈ pending/paid/rejected/expired/cancelled/checking/failed — 'approved' is NOT valid; use 'paid') + a DECOY not in the list, ran the REAL migration file twice via psql \i inside one BEGIN…ROLLBACK: run1 +19.40 / 3 wcl (5.70,5.70,8.00) / 3 audit / decoy uncredited; run2 STILL 19.40/3/3 (idempotent); last_admin 3/3 preserved. Plus 2 edge txns: no-fixtures→0 delta (existence no-op), 2 same-prefix→ambiguity RAISE.

CROSS-PR COLLISION CATCH (reviewer round-1, the ONLY blocker) — #466 and #463 (sv8_revoke_payout_fns) BOTH at 20260612000240 and BUNDLED into one deploy → supabase db push applies one, SILENTLY SKIPS the other (same class as #454/#453/#445/#438). My local `ls supabase/migrations` only saw origin/main (#463 was a separate open PR), so I missed it — the reviewer caught the cross-PR collision. LESSON: before numbering a migration, scan ALL OPEN PRs for the version range, not just origin/main: `for pr in $(gh pr list --state open …); do gh pr view $pr --json files …; done`. Fix = pure rename 000240→000250 + bump the audit actor_username provenance string; re-verified identical; reviewer converted REQUEST-CHANGES→APPROVE.

REVIEWER VERDICT CONVENTION (next-code-reviewer, team secres/livegate) — posts verdicts as COMMENTED reviews (state=COMMENTED) with the verdict in the BODY text, NOT as a formal GitHub APPROVED state. Round-1 body said "REQUEST CHANGES", round-2 body said "APPROVE (converts my REQUEST-CHANGES)". So the gh-verify discipline = read the review BODY at the current head via `gh pr view N --json reviews`, not just the .state field. Treated symmetrically both rounds.

---
*Added via Oracle Learn*
