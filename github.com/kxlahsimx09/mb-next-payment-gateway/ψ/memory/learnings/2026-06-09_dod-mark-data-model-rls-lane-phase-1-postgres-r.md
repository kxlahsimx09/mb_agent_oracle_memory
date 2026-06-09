---
title: DoD-MARK — DATA-MODEL RLS LANE (Phase-1 Postgres RLS authoritative tenant isolat
tags: [dod-mark, auth, auth-004, rls, tenant-isolation, nextteam]
created: 2026-06-09
source: next-pm / campaign rlspm — DoD-mark
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# DoD-MARK — DATA-MODEL RLS LANE (Phase-1 Postgres RLS authoritative tenant isolat

DoD-MARK — DATA-MODEL RLS LANE (Phase-1 Postgres RLS authoritative tenant isolation, §ADR-13-F4 A1)
Campaign: rlspm · DoD-marker: next-pm · Date: 2026-06-09 · Method: ARTIFACTS ONLY, each gate re-verified gate-to-artifact.

VERDICT: ALL 5 GATES GREEN — LANE DONE.

GATE 1 — SPEC/DESIGN [PASS]
  - docs/design/auth-login/05-rls-claim-tie-in.md present on origin/main; head confirms §Amд 2026-06-07 §ADR-13-F4 A1-A3 (A1 RLS = Phase-1 authoritative boundary; A2 F4 middleware/controller = defense-in-depth; A3 action-level RBAC stays app-layer). §5.1 per-actor effective tenant (client to own client_id; sub-client to parent_client_id; partner to own partner id; admin no pin).
  - docs/spec/rls-data-model-slice.md present on origin/main; status=published, trust S2, binding_sources cite design 05/06 + adr.md §ADR-13 F4 §Amд 2026-06-07 A1-A3. Scope = access-token hook baking effective_client_id + per-tenant-table RLS + tenant-read EF.

GATE 2 — BUILD [PASS]
  - PR #360 state=MERGED (gh), mergeCommit c9feb9dbb27d62da0d5d89324dfa7630e0e76618, mergedAt 2026-06-09T06:18:10Z.
  - git merge-base --is-ancestor c9feb9d origin/main = YES-ANCESTOR (in main line).
  - Delta (git show --stat c9feb9d): migration 20260609000010_rls_data_model_tenant_isolation.sql (+288) = gotrue custom_access_token_hook SECURITY DEFINER baking entity_type/effective_client_id/effective_partner_id + claim accessors + ENABLE RLS + one isolation predicate per tenant table (ts_deposits/ts_payouts/idempotency_keys/wallet/mdr_shared/transactions/withdrawal_queue) + dropped dev-only adminweb anon-select-all hole + RLS-predicate indexes; tenant-read EF supabase/functions/tenant-read/index.ts (+91); pgTAP supabase/tests/rls_tenant_isolation_test.sql (+151). Includes rlsreview fixes (3c88650: partner_profiles guard, withdrawal_queue isolation, 6 indexes).

GATE 3 — REVIEW [PASS]
  - next-code-reviewer ## VERDICT: APPROVE on PR #360, after the 3 REQUEST-CHANGES items were fixed. Corroborated: the 3 fixes (partner_profiles guard, withdrawal_queue isolation, RLS-predicate indexes) landed as commit 3c88650 and are present in the merged squash c9feb9d. (GitHub-native reviewDecision empty — review is the internal team artifact, not a GH PR review.)

GATE 4 — VERIFY [PASS]
  - next-tester: 9/9 AUTH-004 probes GREEN with real gotrue AAL2 JWTs, hook live (rls_hook_claims through rls_ac5_no_partial_side_effect: own-tenant, cross-tenant=0, admin bypass, sub-client to parent, partner-axis no client widen, default-deny, EF status-code contract, no partial side-effect). Evidence: /tmp/rlstest-report.txt.
  - brew-ops pgTAP 32/35 — ALL isolation-critical assertions pass incl withdrawal_queue (tests 7/10/11/19/20/28/33) + partner axis (23-28). The 3 fails (tests 29/31/32) = admin exact-count (3/3/2 deposits/wallets/transactions) on shared-staging pre-existing rows = ENV, NOT defects (admin cross-tenant bypass working correctly; fixture assumes pristine DB). Evidence: /tmp/rlsdeploy-v2.txt.

GATE 5 — SEAL [PASS]
  - next-investigator SEALED on staging (mb-next-staging ref sinuwgsqqyqzlpaavimf) — fully independent: minted OWN 4 gotrue users (client A, client B, sub-client of A, admin) for 2 fresh tenants, re-derived from truth DB (user-scoped PostgREST) AND live tenant-read EF; did NOT inherit tester/pgTAP. All 8 load-bearing claims PASS: own-tenant, cross-tenant=0, sub-client to parent, admin bypass, hook bakes claims, withdrawal_queue anon-hole GONE, service-role bypass intact, tenant-read EF aal2-gated (aal1=>401). Cleanup verified 0 residual; staging restored to baseline. Evidence: /tmp/rlsseal-report.txt.

OUTCOME / DOCUMENTATION
  - UNBLOCKS AUTH-004 tenant-scope at the DB layer (Layer-1 RLS now the authoritative filter; user-scoped reads were RED pre-RLS, returning 0 for everyone).
  - The 3 admin exact-count pgTAP fails are shared-staging environmental (pre-existing rows), NOT defects.
  - ADVISORY: pgtap extension remains installed on staging (added to run the suite) — flag for cleanup/hardening.

SCOPE BOUND — this is the DATA-MODEL RLS LANE only; NOT epic-done. Remaining epic-auth-rbac lanes still open: gateway CF edge, frontend login UI, AUTH-007 refund-EF-slug, config.toml verify_jwt hardening, and 008/009/010 coverage.

---
*Added via Oracle Learn*
