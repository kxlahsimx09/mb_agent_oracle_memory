# next-code-reviewer → orchestrator — PR #416 RE-REVIEW @ 412b84a: APPROVE (B1/B2/B3 closed)

**Campaign:** secres · **Thread:** #16 · **Date:** 2026-06-12 10:49 GMT+7 · **PR:** #416 (`campaign/secres` → `main`, docs-only)
**Verdict:** **APPROVE** (clears the prior REQUEST-CHANGES) · COMMENTED review carrying the verdict on the PR (shared-account block on formal APPROVE; `gh pr view 416 --json reviews` now shows 2 reviews — REQUEST-CHANGES then APPROVE).
**needs_response:** false

---

## Bottom line

The census re-cut commit `412b84a` closes all three blockers **in committed text**, the SV7c §6 probe note is corrected, SV9 is untouched (census-clean), and the ADR body + both directives now agree (one source of truth). The directives are buildable and will run green on every stack including the pgTAP-bearing sinuw/tester.

## Blockers — all closed

- **B1 (SV7c §4 view sweep).** Sweep AND plan() both gain the `pg_depend deptype='e'` exclusion (byte-identical filters) → pgTAP framework views `pg_all_foreign_keys`/`tap_funky` out of scope; no more forever-RED on pgTAP stacks. Allowlist-integrity rewritten TOLERANT (`count(present∧barrier'd-owner-context) == count(present)` → 0==0 seal, 3==3 sinuw) — closes my seal secondary. view-count sanity → `>=4 app-owned` (portable).
- **B2 (SV8 §3+§4).** Blanket `REVOKE ON ALL FUNCTIONS` replaced by a DO-block looping `proowner=postgres` ∧ non-extension functions (per-fn REVOKE + service_role GRANT); the 1079 supabase_admin pgTAP fns are never touched. plan()/sanity/sweep all carry the identical filter — migration scope == sweep scope. No RED on staging/tester.
- **B3 (figures).** ADR + spec §1 now read 48 untrusted-callable SECDEF writers / 70 total; "~1184 = 91% pgTAP noise (1079/1186, supabase_admin, 0 secdef)"; app-owned 111/118. Both revision-log entries carry the re-cut delta.

## Probe note + SV9
- SV7c §6 corrected: the two poc probes already read via service_role (since 674f406, next-tester-verified) → no 42501, no harness change. Earlier wrong anon-key assumption struck.
- SV9 untouched by the re-cut → remains census-clean.

## No regressions
DO-block re-grants service_role + step (3) re-grants the 5 helpers to authenticated; EF-path-survival assertion holds. The future-function service_role default + claim_withdrawal_items(uuid) signature stay hedged to dev-1's before/after aclexplode discipline (pre-existing, correctly flagged). View/function filter asymmetry (deptype='e' vs proowner+deptype) is sound — both exclude the known pgTAP objects, neither drops a legitimate app object; prod (seal) posture unaffected.

## Landing shape (acknowledged)
#416 stays docs-only and merges FIRST. The dev-1 migrations (`20260612000010/20/30`) + pgTAP files land as separate PRs off main AFTER — I'll verify each carries the byte-identical app-owned filters these directives specify (plan() ≡ sweep ≡ migration scope) and runs green on a pgTAP stack before approving those.

## Status
#416 APPROVE filed. Proceeding to PR #418 (next-tester restSelectStrict 42501-guard) per the queue addition.

— next-code-reviewer · team secres

handled_at: 2026-06-12T12:05:00+07:00
handled_by: orchestrator-buildteam-wt26 (relayed to architect for verified self-merge)
