# next-architect → orchestrator — secres deliverable (1): VIEW-class exposure DISPOSED (SV7c)

**Campaign:** secres · **Thread:** #16 · **Date:** 2026-06-12 10:17 GMT+7 · **PR:** #416 (`campaign/secres` → `main`, docs-only)
**needs_response:** false (one optional confirm: PR-granularity preference — see §6)

---

## 1. What was delivered

Deliverable (1) of 3 — the **VIEW-class exposure** (PR #394 review finding, reviewer-confirmed real):
`v_bank_balance` / `v_payouts` / `v_success_payout_audit` are **owner-context** views carrying LIVE
`anon`+`authenticated` SELECT on staging, **structurally invisible** to the SV7b `rls_or_no_grants`
sweep (it walks `pg_tables`; views are `relkind='v'`). Migration `20260611000030` explicitly punted
them to the architect.

- **`docs/adr.md`** — §ADR-13 §Amendment 2026-06-11 **SV7c** bullet + Consequences pgTAP line + a 2026-06-12 revision-log entry.
- **`docs/spec/secres-view-exposure-closure-slice.md`** — exact build directive for next-dev-1 (210 lines).
- **PR #416** opened, reviewer-gated.

## 2. Premise verification (vs HEAD)

- Migrations end at `20260611000300`; **nothing** at HEAD touches these views (confirmed by grep). ✓
- All three are owner-context (`security_invoker` unset) and were created **before** `20260611000030`'s
  `ALTER DEFAULT PRIVILEGES … REVOKE` → they retain their project-init grant (the revoke binds only
  *future* objects — which is exactly why #412's `v_merchants/v_clients/v_partners`, created after,
  needed an explicit `GRANT`). ✓
- **No EF / `src` consumer** of any of the three (grep over `supabase/functions` + `src` empty). ✓
- Full view census: 7 views — `v_deposits` (security_invoker, safe), #412 trio (gated projection,
  safe), and exactly these 3 exposed. My 3-branch sweep rule classifies all 7 with no third state. ✓

## 3. Disposition — `REVOKE ALL anon/authenticated` (not security_invoker, not projection)

These are owner-context **ENGINE** views, not portal surfaces. Consumers, all in owner/service/BYPASSRLS context:

| View | Consumer | Context | Post-revoke |
|---|---|---|---|
| `v_payouts` | `claim_withdrawal_items` PA4 race-guard | SECURITY DEFINER (owner) | unaffected |
| `v_success_payout_audit` | `classify_success_payout`; §ADR-15 **P2.16 alert** | SECURITY DEFINER; `investigator_ro` BYPASSRLS | unaffected |
| `v_bank_balance` | none | — | unaffected |

**Alternatives rejected with cause:**
- **`security_invoker`** — viable only for `v_payouts` (single SV6 base); `42501`s `v_bank_balance` +
  `v_success_payout_audit` (both read the zero-grant `bank_account` as caller); and couples
  `v_payouts`'s SECURITY-DEFINER CASE-helpers' EXECUTE to **deliverable (2)**'s function-EXECUTE-revoke lane.
- **Gated-projection promotion (#412/CA8)** — the embedded `aal2 ∧ has_read_perm ∧ is_admin` gate
  evaluated in the owner RPC context NULL-propagates through the PA4 race-guard (**breaks the claim
  path**); for `investigator_ro` (no JWT) it returns zero rows → **silently kills the P2.16 alert**.
  You cannot gate an engine view internal/monitoring contexts consume — promotion is for NEW
  `v_*_admin` portal surfaces, exactly as #412 built.

## 4. Recurrence fix (the sweep blind-spot)

`rls_or_no_grants` extended to **`pg_views`, no third state** — every `public` view is
(a) `security_invoker=true`, OR (b) on the ratified gated-projection allowlist
`{v_merchants, v_clients, v_partners}` + `security_barrier=true`, OR (c) zero anon/auth privileges.
Allowlist = view-side analog of the SV6 list; grows only by amendment. Exact pgTAP given in the directive.

## 5. Merge authority

Ruled **NOT ratification-bearing** — applies the already-ratified SV7b deny-by-default zero-rule to the
VIEW object class (no new catalogue member, no new read surface, no column masking) — the SV7b
self-disposition precedent verbatim. → reviewer-gated + architect **self-merge after next-code-reviewer
APPROVE** (verified ONLY via `gh pr view --json reviews`; standing anti-injection rule honored — no
in-pane/inbox approve claim acted on). **If the owner deems any extension of the closed sweep rule
owner-merge, claim PR #416.** (Contrast CA8/#415 which ADDED members → owner-merge.)

## 6. Open coordination items (non-blocking)

1. **PR granularity** — I used the shared `campaign/secres` branch (as dispatched) and opened #416
   scoped to my 2 docs files. If dev-1's migration lands on the same branch it joins #416 (one campaign
   PR). If you prefer per-deliverable `arch/<topic>` PRs (the dominant precedent), say so — I'll re-cut.
   Default: proceed as-is.
2. **next-dev-1 T3** is unblocked — directive is on `campaign/secres` (pushed). Migration + test
   extension are dev-owned; spec is self-contained with exact SQL.
3. **poc/integration probes** (`payout-view-contract.ts`, `success-payout-audit.ts`) restSelect these
   views → must auth as service_role after the revoke. Harness-only (poc/, CODE-BLIND) — flag to next-tester.

## 7. Next

Proceeding to **deliverable (2)** — function PUBLIC EXECUTE posture (~1184 public-schema functions incl.
SECURITY DEFINER writers; brew-ops Task-B finding). Then (3) on-list non-SELECT residue. No blockers.

handled_at: 2026-06-12T11:05:00+07:00
handled_by: orchestrator-buildteam-wt26 (thread 16)
