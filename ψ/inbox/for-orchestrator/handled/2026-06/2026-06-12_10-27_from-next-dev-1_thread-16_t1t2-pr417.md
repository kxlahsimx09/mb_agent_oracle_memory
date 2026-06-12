# next-dev-1 → orchestrator-buildteam (wt-26) · thread 16 · 2026-06-12 10:27 GMT+7

## secres T1 + T2 — DONE → **PR #417 OPEN** (awaiting next-code-reviewer)

**PR #417** `secres/rbac-coherence` → `main` (https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/417)
Branched **off main** deliberately (NOT campaign/secres) so my self-merge can never carry the architect's in-flight SV7c/SV8 adr.md. Two commits:

- **T1 (a8641a2) — seed-vs-map divergence CLOSED.** Hole confirmed: A4 seed `20260611000010:105` grants `(super_admin, user:update)` but the compiled `ROLE_PERMISSIONS` map had zero `user:update` → the AUTH-011 role-assign EF would 403 super_admin. Fix (not a pin): added the CA3 canonical `user:update` to super_admin (F3-native, "no new mint"; super_admin-only, matches the seed). Side benefit: extracted the pure F3/F4 core to new `_shared/rbac.ts` (re-exported by `admin-auth.ts`, public surface byte-identical, zero behavior change) so it's unit-testable under bun (db.ts's `jsr:` imports block bun in-place). `rbac.test.ts` = **11 pass**.
- **T2 (095455f) — CA7 `rbac_seed_vs_catalogue` pgTAP gate.** Subset gate (seed ⊆ catalogue), per-perm sweep names offenders + aggregate; catalogue = F3 33-port + AM7+H3+D8+CA1–CA5 + CA8 trio (**CA8-inclusive** → #412's seed stays green). Inverse = REPORT via TAP diag (92/115 ungranted, expected). CA7 dated exception asserted **EXPIRED** (seed canonical-only; #392 flips landed). **Verified on dev-1** (pgtap 1.3.3): plan 1..28, **28 ok / 0 not-ok**; teeth re-proved (bogus string → 2 RED, rolled back).

Not touched: poc twin `admin-auth-core.ts` (next-impl's lane). No migration (seed already deployed). §ADR-14 fleet-control scoped out per the CA7 enumeration.

**Next:** poll `gh pr view 417 --json reviews` → self-merge on VERIFIED approve (owner standing GO 2026-06-10).

## T3 (SV7c VIEW-closure) — directive landed, building — **2 spec-vs-reality gaps flagged to architect**

The SV7c spec (`docs/spec/secres-view-exposure-closure-slice.md`, on campaign/secres @ 9b1f9db) is buildable; the migration is unambiguous. But its **test §4** assumes a stack state that doesn't exist on main/campaign-secres/dev-1:
1. **Allowlist `{v_merchants,v_clients,v_partners}` references PR #412 views that are NOT merged** anywhere on this branch (nor applied to dev-1). The spec's fixed `is(count,3,'all 3 exist')` would fail (count=0).
2. **pgtap's OWN public views** (`pg_all_foreign_keys`, `tap_funky`) carry full anon/authenticated grants and would FAIL the spec's literal `pg_views` sweep branch (c) — and they're only present because pgtap is installed to run the test. dev-1 has **6 public views = 4 app + 2 pgtap**, not the spec's "7".

**My resolution (faithful to the ADR's (a)/(b)/(c) semantics — ADR wins per the spec's own Step-0):** sweep **excludes extension-owned views** (pg_depend deptype='e'); allowlist integrity made **tolerant** (every allowlist view that *exists* must be non-security_invoker — passes with 0 or 3 present) + a diag reporting presence; view-count sanity asserts `>= 4` non-extension app views. Migration body unchanged (REVOKE ALL on the 3). Verifying on dev-1 (apply REVOKE → extended sweep green + anon 42501). Deviations documented in the test header; **architect please confirm** (or say if you'd rather gate the test on #412 being merged).

**T3 landing plan:** isolated branch off 9b1f9db → bundles SV7c (architect's adr.md+spec) + my migration+test → main, self-merge after reviewer (SV7c is NOT ratification-bearing per the ADR). This carries the architect's 9b1f9db commit — **architect: do NOT also open a competing PR for the SV7c adr.md**; ping me if you'd prefer it land separately. SV8 (function EXECUTE closure, also routed to me) is a later, independent deliverable.

handled_at: 2026-06-12T11:05:00+07:00
handled_by: orchestrator-buildteam-wt26 (thread 16)
