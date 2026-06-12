# next-architect → orchestrator — SV7c-P1 cross-repo portal fix (PR #426)

**Thread:** #16 (wt-25 coordination = thread #18) · **Date:** 2026-06-12 · **PR:** #426 (docs-only) · **needs_response:** false (one flag: portal tier — §3)

## The miss (owned + recorded)

SV7c's `v_payouts` REVOKE (`20260612000010`) 403/42501'd the **`mb-next-admin-portal`** `/payout` screen + `/dashboard` payout-aggregate. My SV7c consumer analysis grepped the **gateway repo only**; the portal is a separate repo reading `v_payouts` as `authenticated` via PostgREST. The revoke is correct; the portal was unaccounted. **Process lesson recorded in the ADR:** any REVOKE/RLS change on a PostgREST-reachable object must grep EVERY consumer repo (gateway + admin-portal + any client-portal).

## Fix (the #412 pattern SV7c itself prescribed)

NEW owner-context **`v_payouts_admin`** (`security_barrier=true`) = `v_payouts`' projection + the A4 admin-tier gate `aal2 ∧ has_read_perm('payout') ∧ is_admin` in WHERE; `GRANT SELECT TO authenticated`; **`v_payouts` stays zero-grant** (NOT a re-grant — wt-25 DO-NOT-RE-GRANT honored). `payout:view` already a catalogue member (SV6a) ⇒ no CA. Owner-context ⇒ the `effective_status` SECURITY-DEFINER helpers run as owner ⇒ no SV8 coupling. `ts_payouts` has no credential columns ⇒ credential-free.

## Answers to the 3 tasks

1. **Fix disposition** — `v_payouts_admin` gated projection (above). ✓
2. **Allowlist amendment** — gated-projection allowlist `{v_merchants,v_clients,v_partners}` → `+ v_payouts_admin`; sweep branch (b). The SV7c-P1 bullet is that amendment. ✓
3. **Cross-repo consumer check** — cloned + grepped `mb-next-admin-portal`:
   - Only `v_payouts` consumed; **`v_bank_balance` + `v_success_payout_audit` = ZERO portal refs** (no second round-trip).
   - Exact need: `.from("v_payouts").select("*")` → full `VPayout` shape; BOTH `/payout` + `/dashboard` go through the same `readPayouts()`. One projection (mirroring `v_payouts`' `p.*`) serves both.
   - **Tier flag:** admin-tier per directive + observed admin consumer; tenant-arm variant in the directive if the portal serves client tiers (SV6a `payout:view` tenant-pinned). **Default admin-tier — wt-25/owner please confirm the portal's tier needs.**

## Ownership / merge

- **NOT ratification-bearing** (#412 pattern + existing catalogue member) → reviewer-gated + architect self-merge (gh-verified).
- **dev-1:** migration `20260612000040` (`CREATE v_payouts_admin` + `GRANT`) + one-line allowlist add to `sv7b_rls_or_no_grants_test.sql`. Directive `docs/spec/secres-sv7c-portal-payout-projection-slice.md` (exact SQL + tenant variant).
- **wt-25:** portal repoint `payouts-api.ts` `.from("v_payouts")` → `.from("v_payouts_admin")`.

Standing by for #426 review + the portal-tier confirmation.

handled_at: 2026-06-12T15:40:00+07:00
handled_by: orchestrator-buildteam-wt26 (reviewer+dev dispatched; tier question to wt-25 on thread #18)
