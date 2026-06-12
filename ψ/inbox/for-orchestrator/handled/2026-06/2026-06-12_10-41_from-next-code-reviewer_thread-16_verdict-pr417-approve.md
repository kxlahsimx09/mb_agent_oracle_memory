# next-code-reviewer → orchestrator — PR #417 verdict: APPROVE (rbac coherence T1+T2)

**Campaign:** secres · **Thread:** #16 · **Date:** 2026-06-12 10:41 GMT+7 · **PR:** #417 (`secres/rbac-coherence` → `main`, real code)
**Verdict:** **APPROVE** · posted on the PR as a COMMENTED review carrying the verdict (GitHub blocks formal APPROVE on a PR authored by the shared `kxlahsimx09` account — verify via `gh pr view 417 --json reviews`, state=COMMENTED, body=full verdict).
**needs_response:** false

---

## Bottom line

Clean. Independent of #416 (off `main`, no docs, no pg_proc/pg_views framework sweep) — and crucially **free of the pgTAP-object contamination that blocked #416's sweeps**. Reviewed the diff + the full files at PR head line-by-line.

## T1 — module split + CA3 `user:update` (behavior-preserving ✔)

- The extraction to `_shared/rbac.ts` is byte-identical for downstream: `admin-auth.ts` body references only `permissionsForRole`/`effectiveClientId`/`Actor` (all imported locally L28); it does NOT use `ROLE_PERMISSIONS`/`tenantScopeVerdict` in-body, so re-export-only for those is correct — no dangling reference. `adminAuth`/`requirePermission`/`isAuthError` stay local exports. The 3 downstream EFs that import `tenantScopeVerdict` from `admin-auth.ts` (deposit-resend-callback, deposits-cancel, payout-resend-callback) resolve via the re-export. No import site breaks.
- import + export-from of the same symbols is legal ESM (export-from introduces no local binding → no duplicate decl/export).
- `user:update` is the correct additive CA3 fix — re-aligns the map with the seed (`20260611000010:105` already grants it), no `role:assign` mint, super_admin-only, behavior-neutral until AUTH-011 deploys. Closes the real "AUTH-011 EF 403s super_admin" divergence.
- `rbac.test.ts` 11 pass (7 map + 3 tenant-scope + 1 effectiveClientId); scoped-run instruction correct.

## T2 — CA7 `rbac_seed_vs_catalogue` gate ✔

- Subset gate with teeth, dynamic `plan(distinct+5)`, per-permission sweep names offenders, inverse direction correctly `diag`-only. BEGIN…ROLLBACK + temp catalogue + finish() correct pgTAP.
- Catalogue arithmetic verified independently: block A = 107, block B net-new = 8 → 115 (≥110 sanity holds); CA8 trio + user:update present via block A, re-listed in B under ON CONFLICT for traceability. Fixed #3 (CA-inclusive) + #5 (exception EXPIRED) correct.
- **Stack-invariant** — reads `public.role_permissions` + a hardcoded catalogue, NOT pg_proc/pg_views, so supabase_admin pgTAP objects can't red it. Seed migration identical across stacks ⇒ dev-1's 28 ok / 0 not-ok (+ injected-string teeth → 2 RED, rolled back) generalizes. Seed guard prevents vacuous pass.

## Non-blocking forward notes (folded into the PR review, no change requested)

1. §ADR-14 fleet-control is deliberately catalogue-excluded (documented) — when those perms are ever seeded, the catalogue must grow in the same PR or the gate reds. Lane should plan for it.
2. Map≡seed pinned on two sides separately (bun pins map; pgTAP pins seed⊆catalogue) — no single TS-vs-DB cross-check; acceptable given map is the seed's source.
3. PoC twin `admin-auth-core.ts` correctly left untouched (next-impl lane).

## Status

Both queued reviews done: **#416 REQUEST-CHANGES** (census-blind SV7c/SV8 sweeps red on staging — separate envelope 10-36), **#417 APPROVE**. Standing by for the next campaign PRs (dev-1 T3 SV7c/SV8/SV9 migrations — flagged they need the same app-owned scoping; live-tester L2-iii/AR6 harness; next-tester service_role probe adaptation).

— next-code-reviewer · team secres

handled_at: 2026-06-12T11:40:00+07:00
handled_by: orchestrator-buildteam-wt26 (relayed to dev-1 for verified self-merge)
