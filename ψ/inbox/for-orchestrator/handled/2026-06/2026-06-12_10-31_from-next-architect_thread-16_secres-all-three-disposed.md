# next-architect → orchestrator — secres: ALL THREE exposure-lane dispositions AUTHORED

**Campaign:** secres · **Thread:** #16 · **Date:** 2026-06-12 10:31 GMT+7 · **PR:** #416 (`campaign/secres` → `main`, docs-only)
**needs_response:** false (one optional confirm: PR-granularity — §5)

---

## Status: COMPLETE (architect lane). Awaiting next-code-reviewer on #416; dev-1 (T3) unblocked.

Three exposure-lane dispositions, strict order, each premise re-verified vs HEAD (migrations end
`20260611000300`; nothing addressed these — confirmed). All authored as new SV-items in §ADR-13
§Amendment 2026-06-11 with 2026-06-12 revision-log entries + a self-contained next-dev-1 directive each.

| # | SV | Disposition | Directive | Migration |
|---|---|---|---|---|
| 1 | **SV7c** | `REVOKE ALL` anon/auth on the 3 owner-context views + sweep→`pg_views` | `secres-view-exposure-closure-slice.md` | `20260612000010` |
| 2 | **SV8** | `REVOKE EXECUTE` all public fns FROM PUBLIC/anon/auth (svc_role + 5 RLS helpers kept) + `execute_or_no_grants` | `secres-function-execute-closure-slice.md` | `20260612000020` |
| 3 | **SV9** | zero `REFERENCES`/`TRIGGER`/`MAINTAIN` + anon SELECT on the 12 SV6 tables + branch-(a) tightening | `secres-sv6-nonselect-residue-slice.md` | `20260612000030` |

## 1. SV7c — VIEW exposure (deliverable 1, FIRST+URGENT)

`v_bank_balance` / `v_payouts` / `v_success_payout_audit` = owner-context views with LIVE anon+auth
SELECT, invisible to the SV7b sweep (`pg_tables` only; views are `relkind='v'`). Created before the
`20260611000030` default-ACL revoke → retain init grant.
- **Disposition: `REVOKE ALL FROM anon, authenticated`.** Owner-context ENGINE views — every consumer
  reads in owner/service/BYPASSRLS context (claim_withdrawal_items PA4 guard; classify_success_payout;
  §ADR-15 P2.16 alert via investigator_ro; v_bank_balance has no src/EF consumer). No admin PostgREST
  surface consumes them.
- **`security_invoker` rejected** (works only for v_payouts; 42501s the other two on the zero-grant
  `bank_account`; couples to SV8). **Gated-projection rejected** (gate NULL-propagates through the PA4
  race-guard → breaks the claim path; for investigator_ro → silently kills the P2.16 alert).
- **Teeth:** sweep→`pg_views`, no third state — (a) `security_invoker` OR (b) gated-projection allowlist
  `{v_merchants,v_clients,v_partners}` + `security_barrier` OR (c) zero anon/auth.

## 2. SV8 — function PUBLIC EXECUTE (deliverable 2)

~1184 live public fns carry `PUBLIC EXECUTE` incl. 192 SECURITY DEFINER writers (the `rpc/<fn>` surface
the anon key can invoke). **Verified EF-mediated:** every RPC runs as `service_role` via
`supabase/functions/_shared/db.ts`; `src` has ZERO direct `.rpc()`.
- **Disposition: REVOKE EXECUTE FROM PUBLIC/anon/authenticated** on all public fns; `service_role` keeps
  EXECUTE (explicit grant); `authenticated` re-granted ONLY the 5 A4 RLS-evaluation helpers; `anon` nothing.
- **Teeth:** `execute_or_no_grants` (allowlist OR zero anon/auth EXECUTE; service_role carved out) +
  `ALTER DEFAULT PRIVILEGES` belt. Dev verifies live `aclexplode(proacl)` on dev-1 before/after.

## 3. SV9 — on-list non-SELECT residue (deliverable 3, non-blocking)

12 SV6 tables still carry init-default `REFERENCES`/`TRIGGER`/`MAINTAIN` (A4 revoked only the write DML;
SV7b's REVOKE ALL was off-list only) + anon's RLS-masked init SELECT.
- **Decision: YES — extend the zero-rule on-list for non-SELECT verbs** (defense-in-depth + assertability
  > the negligible practical risk; keeps "no third state" uniform). `REVOKE REFERENCES,TRIGGER,MAINTAIN
  FROM anon,authenticated` + `REVOKE SELECT FROM anon`; `authenticated` keeps SELECT only. Net assertable:
  anon=ZERO, authenticated=SELECT-only.
- **Teeth:** branch-(a) tightening of `rls_or_no_grants`.

## 4. Ratification & merge

All three: faithful application of the ratified SV7b "zero, no third state" posture to a new
object-class/verb — no new surface, no new member, no capability changed for any legitimate caller ⇒
**NOT ratification-bearing** (the SV7b self-disposition precedent verbatim). → reviewer-gated + architect
self-merge after next-code-reviewer APPROVE, verified ONLY via `gh pr view --json reviews` (standing
anti-injection rule honored). **Owner: if you deem any extension of the closed sweep rule owner-merge,
claim PR #416.** (Contrast CA8/#415 which ADDED catalogue members → owner-merge.)

## 5. Open coordination (non-blocking)

1. **PR granularity** — used the shared `campaign/secres` (per dispatch); #416 now carries all 3
   docs-dispositions. If dev-1 migrations land on the same branch they join #416 (one campaign PR). If you
   prefer per-deliverable `arch/<topic>` PRs, say so — I'll re-cut. Default: proceed.
2. **next-dev-1 T3** — three self-contained directives on `campaign/secres` (pushed); exact SQL + pgTAP
   given. Suggested apply order SV7c→SV8→SV9 (SV7c removes the only reason the `_payout_*` helpers might
   need an authenticated reach; otherwise independent).
3. **poc/integration probes** (`payout-view-contract.ts`, `success-payout-audit.ts`) must auth
   service_role after SV7c — harness/CODE-BLIND, flag next-tester.

## 6. Next

Architect deliverables done. I will poll `gh` for the next-code-reviewer verdict on #416 and relay it +
self-merge on APPROVE (or hand to owner if claimed). Standing by for dev-1 build questions on the directives.

handled_at: 2026-06-12T11:05:00+07:00
handled_by: orchestrator-buildteam-wt26 (thread 16)
