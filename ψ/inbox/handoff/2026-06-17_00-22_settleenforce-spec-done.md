# HANDOFF — settleenforce: §ADR-22 BENE-007 refined (PAYOUT advisory / SETTLEMENT enforced) — SPEC done

**Campaign:** settleenforce (slug `doc`) · **Role:** next-architect · **Date:** 2026-06-18 GMT+7 · **DOCUMENTS ONLY** (done).

## Merged PR
- **PR #577 — MERGED to `main`** (squash `0df2785`, 2026-06-17T17:21Z). Title: `docs(settleenforce): §ADR-22 §Amendment 2026-06-18 — BENE-007 refined (PAYOUT advisory / SETTLEMENT enforced) + build SPEC`. Self-merged per campaign brief (owner decided; no owner gate; append-only ADR/epic notes).

## BUILD-OR-DEFER VERDICT = **BUILDABLE NOW** (not a forward requirement)
The #next SETTLEMENT flow **IS BUILT** (SETTLE-001/002/003 — PR #542 merged + investigator-sealed 2026-06-16) **and** the `beneficiary_bank_account` registry **IS BUILT** (§ADR-22 P1–P4 migrations `20260617000100..000130` + `admin-bank-accounts` EF, all on `main`). Both halves of the enforcement exist → this is a **code-change SPEC**, not a defer.

- Settlement create path: `create_settlement` RPC (`supabase/migrations/20260616000110_settlement_forward_slice_rpcs.sql:54-161`) + `admin-settlements` EF `action:"create"` (`supabase/functions/admin-settlements/index.ts:58-122`). Destination is currently **free-form** (`dest_bank_code/name/account_number/account_name`, no FK).

## The decision (owner-refined 2026-06-18)
- **PAYOUT → ADVISORY (unchanged)** — free-form destination; no registry check.
- **SETTLEMENT → ENFORCED** — destination MUST be an APPROVED `beneficiary_bank_account` (1) **owned by the settling party** (`owner_type/owner_id = entity_type/entity_id`; sub-client → parent client), (2) **`status='approved'`**, (3) **`purpose ⊇ {settlement}`**; else **reject** at create (`dest_not_registered`/HTTP 400, no row, no freeze). Makes the registry **load-bearing for settlement**.

## The SPEC (buildable now)
**`docs/spec/settlement-destination-registry-enforcement-slice.md`** (v1). Key contract for the build team:
- **Gate:** `create_settlement` **Layer-1**, a single race-free `EXISTS` over `beneficiary_bank_account`, inserted **after** the `missing_dest_bank` null-check (`:92-95`) and **before** the wallet `FOR UPDATE` lock (`:101`). RPC is `SECURITY DEFINER` → reads registry regardless of caller RLS, asserts owner-match itself.
- **Reject:** `RAISE 'dest_not_registered…' USING ERRCODE='P0001'` → `rpcErrorToResponse` (`_shared/db.ts:97-119`) maps P0001 → **HTTP 400** with **no EF code change**. Single token → no cross-tenant leak.
- **Index:** reuses existing `uq_bene_bank_account_owner_bank_acct (owner_type,owner_id,bank_code,account_number)` — **no new index**.
- **Optional FK (impl-pass):** `settlements.beneficiary_bank_account_id uuid REFERENCES beneficiary_bank_account(id)` (nullable, forensic).
- **No-change zones:** PAYOUT (`create_payout`/`ts_payouts`), `approve_settlement` (Mode-2 `required_bank_account_id` = SOURCE system bank, not destination), bot terminalizers, registry write EFs.
- **TEETH tests + migration plan (`2026061800010X_…`)** + reject-code table delta (8th SETTLE-001 create rejection) all in §7/§8/§4 of the SPEC.

## Doc artifacts amended (all merged)
- `docs/adr.md` — §ADR-22 **§Amendment 2026-06-18** (full enforcement contract); forward-pointer on superseded 2026-06-17 entry; (b1) markers updated.
- `docs/requirements/epic-beneficiary-bank-account.md` — BENE-007 → **SPLIT [S2 ratified]** (blurb, trust, table, open-decisions).
- `docs/requirements/epic-source-flows.md` — SETTLE-001 AC + edge-case + build-status forward-delta.

## NEXT (for the orchestrator)
Settlement-destination enforcement is **ready to build** as a separate code phase: next-dev implements the `create_settlement` Layer-1 gate (+ optional FK) per the SPEC → next-code-reviewer → brew-ops deploy → tester (the 6 negative + 2 positive probes in SPEC §7). On build, add the `dest_not_registered`/400 row to `docs/spec/settlement-forward-slice.md` §1.1 so the tester binds the probe off the contract.

Oracle learning recorded: `learning_2026-06-17_adr-22-bene-007-owner-refined-2026-06-18-payou` (#next #bank-account #settlement).