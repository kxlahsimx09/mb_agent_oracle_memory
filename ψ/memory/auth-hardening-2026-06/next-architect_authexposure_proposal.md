# Decision Proposal — Human Auth Surface Exposure Posture (gotrue password-grant · AAL gate · PostgREST reads · raw origin) (campaign authexposure)

**From:** next-architect · **To:** owner (DECISION REQUIRED — security posture, class (b)) · **Cc:** next-dev/next-writer (propagation after GO) · **Date:** 2026-06-10
**Status:** **DECIDED — owner GO 2026-06-10.** m1 / m2 / m4 / m5 ratified per the architect lean. **m3 — owner OVERRIDE (not the lean):** split-by-verb RLS — see §m3-RESOLVED below. Propagation §4 updated to the decision.
**Snapshot:** refs at main `4690345`; ADR refs to `docs/adr.md`. Companion: `next-architect_authsec_spec.md` (code fixes that do NOT depend on this memo — X3(b) makes the IP header non-spoofable regardless of m4).

---

## 1. The problem (what GW1a-H changed underneath the auth controls)

§ADR-2's identity-bound controls all live **inside the custom login EF / EF middleware**: the LK lockout counter, the G4-D audit rows, the G5-D IP-allowlist, the G1-D 2FA two-step, Layer-2 RBAC. **GW1a-H (ratified 2026-06-10, `adr.md:180-202`) put the whole Supabase human surface — gotrue, PostgREST, Realtime, EFs — behind the custom domain**, and GH2 even configures rate-limit rules for `/auth/v1/token*` — i.e. the surface assumes those paths are reachable. Four consequences, none ratified:

1. **The gotrue password grant is directly reachable** (`POST /auth/v1/token?grant_type=password`) — a credential attempt that never touches the login EF: **no lockout increment, no audit row, no IP-allowlist, no 2FA orchestration**. Every EF-resident login control becomes advisory for an attacker who skips the EF. (Nothing in ADR-2 ratifies "the login EF is the only credential path.")
2. **An AAL1 session can read PostgREST.** G1-D's `temp_token` is a real gotrue JWT (`adr.md:47`); RLS predicates key on tenant/entity claims only — **no `aal` predicate anywhere** (`20260609000010`). Password-only (no TOTP) ⇒ tenant data readable. The `ccd7608` strict-aal fix covers the EF gate (`admin-auth.ts:105`) — PostgREST has no such gate.
3. **Action-RBAC does not exist on direct PostgREST reads.** A3 keeps RBAC app-layer (`adr.md:3727`); R3's orphaned-user "authorized for nothing" (`adr.md:232`) and every `*:view` permission split are enforced only in EFs. Direct PostgREST read = tenant-scoped by RLS, but RBAC- and orphan-blind.
4. **The raw `*.supabase.co` origin stays reachable** beside the custom domain — bypassing every CF protection (WAF, bot fight, per-IP limits, and the `CF-Connecting-IP` provenance X3(b) relies on).

**Why this wasn't caught earlier:** each amendment was individually correct (EA1–EA5 deliberately kept identity controls EF-side; GW1a-H is "config-only" protection) — the gap is the *composition*: protective config went wide while the enforcement points stayed narrow. Mobiz, for all its flaws, had **no direct-DB/auth surface at all** — all four legacy flows pass through its API. Option-A-style lockdown is parity-in-spirit.

## 2. Sub-decisions

| # | Question | Architect lean | Cost if adopted |
|---|---|---|---|
| **m1** | External password-grant: allowed or blocked? | **Block.** Ratify the invariant *"the login EF is the only credential path"*; mechanism = impl pass (CF rule on `/auth/v1/token` `grant_type=password` from non-EF callers, or gotrue provider config) — the EF's own server-side `signInWithPassword` must keep working. | CF rule/config + one probe (direct grant → blocked) |
| **m2** | AAL gate at the database: require `aal2` for human reads? | **Yes.** Add `(auth.jwt()->>'aal') = 'aal2'` (or equivalent claim from the access-token hook) to the human-role RLS predicates, so an AAL1 temp-token reads nothing. Service-role unaffected. | RLS policy edit + pgTAP cases (AAL1 token → zero rows) |
| **m3** | Read topology: may the portal read business tables via direct PostgREST, or EF-only? | **OWNER OVERRIDE → split-by-verb (see §m3-RESOLVED).** Reads = direct PostgREST with RLS enforcing tenant + aal2 + **RBAC `:view`**; writes/actions = EF/CF-only (PostgREST write grants revoked). NOT the architect's EF-only-reads lean. | RLS read-RBAC predicates + write-grant revocation + DB-fresh perm resolver |
| **m4** | Raw `*.supabase.co` origin: leave reachable or restrict? | **Restrict as far as the platform allows**, and *document the residual honestly*: Supabase-hosted origins can't be fully firewalled Phase-1, so the enforceable form is (a) the X3(b) CF-provenance header (already in the fix-spec), (b) Supabase network restrictions where applicable, (c) an explicit EA-amendment note that volumetric/per-IP edge protections do NOT cover the raw origin. | config + one ADR paragraph |
| **m5** | Sub-client → parent resolution in RLS: JWT claim or DB-fresh resolver? (left open at `adr.md:3738`; ~72% of users) | **DB-fresh** (C4-consistent): STABLE SECURITY DEFINER resolver reading `app_user.parent_client_id`; the JWT claim stays as a fast hint, never authoritative. Defines re-parenting as effective-next-request; pgTAP case for a stale-claim token. | one resolver fn + policy edit + pgTAP |

**Composed-failure note (ratify alongside, one paragraph):** the human path stacks fail-open layers (EA2 edge limit fail-open · GH2 rules in Log/Challenge pending promote-to-Block `adr.md:202` · S4 toggle can flip step-up fail-open). Individually reasoned; the ADR should state the composed posture during a substrate outage once, so future amendments stop re-deriving it.

## m3-RESOLVED — split-by-verb RLS (owner GO 2026-06-10, overrides the EF-only-reads lean)

**The decision:** the read/write boundary is split by verb, not collapsed to one path.
- **READS — all direct via PostgREST + RLS.** No read traverses an EF. RLS on every human-readable table/view enforces, in one `USING` predicate: **(1) tenant isolation** (m5 resolver) **+ (2) `aal = 'aal2'`** (m2) **+ (3) the `:view` RBAC permission** for that resource. The `deposit-log:view`-class splits become their own predicates on the forensic columns/tables. Realtime rides the same SELECT policy (so a no-`:view` role or an AAL1 token cannot subscribe — RBAC + aal on realtime for free).
- **WRITES / actions — EF/CF-only.** Revoke `INSERT/UPDATE/DELETE` from the `authenticated` role on all business tables; only `service_role` (the EF identity) writes. RLS write policies are therefore unnecessary (there are no direct human writes to police). Action-RBAC + step-up + audit stay where they belong — in the EF, behind the GW4/CF path.

**Owner rationale (recorded):** (a) read latency — EF cold/warm start (G3-D ≤800ms warm / ≤3s cold) is unacceptable for dashboard reads; direct PostgREST is sub-100ms. (b) Realtime — DR4's live-update channel **requires** RLS-gated direct table access; an EF-only read topology would have forced a parallel realtime channel-auth or killed the feature. Direct-read-with-RLS is what Realtime needs anyway.

**This OVERRIDES ratified text — needs its own amendment (A2 below):** §ADR-13 A3 ("RBAC stays app-layer") and §ADR-2 "Why not RBAC at RLS". Re-examining that original objection's two prongs under this decision:
- **Prong 1 (policy explosion, "15 tables × 6 actions = 90+ policies") — DEFUSED.** Only the **read verb** enters RLS; writes carry **zero** policies (grant revocation, not predicates). Result ≈ 2 predicates per readable table (tenant + read-RBAC), not 6× — within the same order as the tenant-isolation RLS already accepted in Phase-1.
- **Prong 2 (no column-level control) — LIVE, see Wrinkle 2.** RLS is row-level; per-role column masking is not expressible in a row policy.

### Wrinkles — ALL RESOLVED (owner GO 2026-06-10)

1. **Read-permission freshness → IMMEDIATE-EFFECT / DB-fresh (owner confirmed).** A `STABLE SECURITY DEFINER has_read_perm(resource text)` resolver reads the role→permission map **fresh per query** so a permission change takes effect on the next request with no re-login (AUTH-003/R1 preserved; consistent with the m5 sub-client resolver + C4 DB-fresh). **Impl constraint (hard):** the resolver must evaluate **once per query, never per-row** — structure the predicate as STABLE + parameterized on the JWT role so Postgres caches it; the pgTAP pass MUST include an EXPLAIN assertion proving single evaluation (the accepted cost of immediate-effect is one DB perm-read per query, not per row).
2. **Column-level read RBAC → NONE in Phase-1 (owner confirmed).** No read surface needs per-role column masking; **row-level read-RBAC only**. No role-specific views, no EF read carve-outs for masking. A `:view` permission grants the whole row. (If a future surface needs column masking it is a new amendment, not Phase-1.)
3. **`has_read_perm` source → seed `role_permissions` table (owner OK).** Seed it from the hardcoded `ROLE_PERMISSIONS` map (`admin-auth.ts:43-61`) so EF write-RBAC and RLS read-RBAC share ONE source of truth; this also makes the W1 catalogue-vs-seed CI assertion real. (Brings the AUTH-003 Phase-2 `roles` table partly forward as a read-only seed.)

## 4. RATIFIED propagation (owner GO 2026-06-10 — m1/m2/m4/m5 + m3-split-by-verb)

| # | Surface | Owner |
|---|---|---|
| A1 | §ADR-2 amendment (one block): m1 EF-only-credential-path invariant + m2 aal2 gate + m4 raw-origin residual note + composed-failure paragraph; cross-ref EA3/GH2 | next-architect |
| A2 | **§ADR-13 amendment — partial reversal of A3 (the load-bearing one):** read-RBAC moves INTO RLS (split-by-verb); write-RBAC stays EF. Record both prongs of the old "Why not RBAC at RLS" objection (prong 1 defused, prong 2 = column-level residual via per-surface views); pin the m5 tenant resolver + the Wrinkle-1 `has_read_perm` DB-fresh resolver + the Wrinkle-3 seed `role_permissions` table; per-table read-RBAC rollout list + the write-grant-revocation list | next-architect |
| A3 | CF zone + gotrue config (m1 block password-grant, m4 origin restriction) + staging verification | brew-ops + next-dev |
| A4 | RLS migration: m2 aal2 predicate + m5 tenant resolver + **m3 read-RBAC predicates per table** (via `has_read_perm`, row-level only — no column masking) + **revoke `authenticated` write grants** on business tables + seed `role_permissions` from `ROLE_PERMISSIONS`; pgTAP — AAL1-token-reads-nothing, stale-claim re-parent, no-`:view`-role-reads-nothing, **perm-change-takes-effect-next-query-no-re-login**, direct-write-denied, direct-grant-blocked, realtime-inherits-RBAC; **EXPLAIN assertion that `has_read_perm` runs once/query not per-row** | next-dev |
| A5 | Epic/spec touches: AUTH-002 (temp_token "cannot read data" AC), AUTH-003 (read-RBAC-in-RLS now correct; reconcile the edge `:193` "action perms not at DB" → "**write**-action perms not at DB; **read** `:view` IS at DB"), AUTH-004 (aal + resolver edges), AUTH-005 (direct-path coverage note) | next-writer |
| A6 | Probe additions fold into authsec X7's re-run | next-tester |

---

**Status: CLOSED 2026-06-10.** All five sub-decisions GO'd; m3 = split-by-verb; all three wrinkles resolved (1 = immediate-effect/DB-fresh, 2 = no column masking / row-level only, 3 = seed `role_permissions`). Nothing left pending owner input. A1–A6 ready to dispatch.
