# next-code-reviewer → orchestrator — PR #426 RE-REVIEW @ 8841fac: APPROVE (clears my RC)

**Campaign:** secres · **Thread:** #16 · **Date:** 2026-06-12 12:59 GMT+7 · **PR:** #426 (`arch/secres-sv7c-portal-payout-projection` → `main`, docs-only)
**Verdict:** **APPROVE** · COMMENTED review carrying the verdict (shared-account block; `gh pr view 426 --json reviews` shows REQUEST-CHANGES → APPROVE). → architect self-merge per the ruling.
**needs_response:** false

---

## Blocker CLOSED (by evidence, not assertion)
§1 now confirms ALL PostgREST-consumer repos: admin-portal (only v_payouts) + **client-facing portal = NONE in the fleet** — structural argument (clients = §ADR-7 HMAC API, no gotrue JWT → structurally can't read PostgREST views) PLUS a direct clone-and-grep of the candidate SPA repos (pg_spaweb/maxpay_clone/clone_maxpay → zero refs), with the note that gh code-search false-negatives on private repos so it wasn't relied on. Exactly the rigor I asked for.

## 3 folds landed
SV7c forward-pointer ✓ · rollout order (deploy …000040 before wt-25 repoint; portal down until both land) ✓ · same-file sequencing #421→#425→…000040 ✓.

## Owner-driven design change — reviewed as new substance, SOUND
v_payouts_admin → tier-neutral v_payouts_read, gate widened to the full A4 composite `aal2 ∧ has_read_perm('payout') ∧ (is_admin OR client_id = effective_client_id)`. Traced every role: anon→42501; non-aal2→[]; no payout:view→[]; admin→all rows; client/sub-client→own-tenant rows only (no cross-tenant leak); partner→[] (DR6). = the ratified rls_read_a4 composite for ts_payouts, identical shape to v_deposits. security_barrier=true correctly blocks predicate push-down. Owner-context still avoids SV8 coupling. SECURE. Not-ratification-bearing holds (mirrors ratified A4/SV6a; payout:view already catalogued; owner drove the design → authority settled). Per-tier-views rejection well-reasoned (v_deposits precedent; column-minimization deferred cross-cutting).

## 2 minor nits → for the dev's 20260612000040 migration PR (non-blocking; ADR body + WHERE + COMMENT ON VIEW already correct)
1. The directive §3 example-SQL `--` header comments still say "admin-portal payout read surface" / "aal2 ∧ payout:view ∧ is_admin" (admin-only) — stale vs the widened gate; sync when landing the migration.
2. §5 acceptance states client-tier own-rows as current, but §6 says the tenant arm is dormant today — on dev-1 expect [] for client tiers if payout:view isn't seeded for them (the gate is correct either way via has_read_perm). Verify against the actual seed.

## Status / queue
Session tally now 11 reviews (#426: RC→APPROVE). Standing by for:
- the dev-1 **20260612000040 (v_payouts_read)** migration PR — same #421 bar (byte-identical filters, plan==sweep, green on pgTAP, before/after aclexplode) + I'll check the 2 nits are synced + the widened gate behaves per-tier on dev-1's seed; sequence after #421/#425 (same test file).
- **#420** owner ratification merge; **brew-ops wave 2** gated on #416→#421→#425 (then …000040, then #423 any time after #416).

— next-code-reviewer · team secres

handled_at: 2026-06-12T16:50:00+07:00
handled_by: orchestrator-buildteam-wt26
