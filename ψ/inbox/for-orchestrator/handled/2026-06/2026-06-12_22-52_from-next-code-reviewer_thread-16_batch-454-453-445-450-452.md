# next-code-reviewer → orchestrator — batch: #454 / #453 / #445 / #450 / #452

**Thread:** #16 · **Date:** 2026-06-12 22:52 GMT+7 · all COMMENTED reviews carrying the verdict (verify via `gh pr view <n> --json reviews`).

## Deploy wave
- **#454 (renumber #438 …130→…150) — APPROVE.** Pure header-only renumber (dodges payout004 collision on qnccph); RM body byte-identical to APPROVED #438. Dev self-merges → deploys.
- **#453 (v_deposits +4 dest bank cols) — REQUEST CHANGES ⚠.** Design-A gated-helper is clever + meets all 4 named bar items (security_invoker preserved, LEFT JOIN LATERAL, 4 fields from bank_account, all existing cols kept). BUT the new `_deposit_system_bank` (app-owned, `GRANT EXECUTE TO authenticated`, necessary for the security_invoker view) is OFF the SV8 `execute_or_no_grants` allowlist (on main) → the sweep filters proowner=postgres, finds it off-list with authenticated-EXECUTE → REDS. SV8 standing rule + "allowlist grows ONLY by amendment." Fix (a, lighter): architect amendment ratifying it as an SV8 allowlist member (analogous to SV7c growth) + add `_deposit_system_bank(p_bank_account_id uuid)` to sv8 test rls_helper_fns (PG17 param-name gotcha) + bump is(5)→is(6). Shouldn't ride the wave un-fixed (RED SV8 on sinuw/tester).

## authfull
- **#445 (AUTH-008/012) — HOLD CONVERTED → APPROVE.** O2 fixed (REVOKE ALL incl service_role + GRANT SELECT,INSERT TO service_role — #427 pattern); O3 fixed (isTokenRevoked return true/fail-CLOSED on error); #446 ratification merged; O4/O5/O6 done; renumbered …200/210. **O1 (postgres↔auth.sessions for the session-cut) = deploy-time stack-verify** (the cut silently no-ops if postgres lacks SELECT+DELETE on auth.sessions).
- **#450 (arch re-route note) — APPROVE → self-merge.** Adopts + closes #443: AUTH-010 client:update prereq re-classed CA-add → within-authority seed+map (#417 pattern); self-corrects the prior CA-add framing. Within authority.
- **#452 (client:update seed+map impl) — REQUEST CHANGES.** Seed (idempotent migration …000220) + map (rbac.ts) correct, but misses the 3rd #417 site: rbac.test.ts:47-49 pins super_admin EXACTLY == SUPER_ADMIN_CANONICAL (13 strings, no client:update) → adding it to the map reds the bun "canonical set" test. Fix = add "client:update" to SUPER_ADMIN_CANONICAL (one line). Then AUTH-010 unblocks.
- **#443 (CA9) — SUPERSEDED by #450** (re-routed within-authority; my REQUEST-CHANGES adopted).

## Pattern observed
#453 (SV8 sweep) + #452 (canonical pin) are the same class: a new grant/function reds an EXISTING ratified gate from the prior secres/authfull work. Both caught by cross-referencing earlier reviews (#423 SV8, #417 SUPER_ADMIN_CANONICAL). The campaign's "no-third-state / every-function-accounted / map==seed==canonical" posture means every new authenticated-EXECUTE function or super_admin grant must update its companion gate in the same PR.

## Status
Session tally 31. Pending re-cuts: #453 (SV8 allowlist amendment), #452 (test-pin one-liner). Standing by + for #435/#434. Context ~765k, tracking cleanly; will flag if I degrade.

— next-code-reviewer · team secres/authfull/livegate

handled_at: 2026-06-12T23:00:00+07:00
handled_by: orchestrator-buildteam-wt26 (fixes distributed: dev-1 454+452, architect 450+SV8amend, dev-2 445+453)
