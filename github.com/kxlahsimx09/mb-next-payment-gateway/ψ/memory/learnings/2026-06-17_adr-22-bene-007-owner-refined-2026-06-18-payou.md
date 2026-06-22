---
title: §ADR-22 BENE-007 — owner REFINED 2026-06-18 (PAYOUT advisory / SETTLEMENT enforc
tags: [next, bank-account, settlement, adr-22, bene-007, enforcement, beneficiary-registry, create_settlement, spec]
created: 2026-06-17
source: next-architect / campaign settleenforce
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# §ADR-22 BENE-007 — owner REFINED 2026-06-18 (PAYOUT advisory / SETTLEMENT enforc

§ADR-22 BENE-007 — owner REFINED 2026-06-18 (PAYOUT advisory / SETTLEMENT enforced). Supersedes the 2026-06-17 blanket-advisory resolution for the settlement path only.

WHAT: A settlement's destination MUST reference an APPROVED `beneficiary_bank_account` that is (1) owned by the settling party (owner_type/owner_id = settlement entity_type/entity_id; a sub-client settlement is owned by its PARENT client), (2) status='approved', (3) purpose ⊇ {settlement} ('settlement' = ANY(purpose)). Free-form / unapproved / wrong-purpose (e.g. a client topup-only account) / cross-owner / unknown destination → REJECTED at create. PAYOUT is UNCHANGED (free-form/advisory; current parity). Rationale (owner): otherwise registered registry accounts never get used — enforcement makes the registry load-bearing for settlement while leaving payout flexible.

BUILD VERDICT = BUILDABLE NOW (not forward-only). Both halves already on main:
- Settlement create path BUILT+SEALED: create_settlement RPC (supabase/migrations/20260616000110_settlement_forward_slice_rpcs.sql:54-161) + admin-settlements EF action:"create" (supabase/functions/admin-settlements/index.ts:58-122). PR #542 merged 2026-06-16 (merge 476e3ec), investigator-sealed.
- beneficiary_bank_account registry BUILT: §ADR-22 P1-P4 migrations 20260617000100..000130 + admin-bank-accounts EF.

ENFORCEMENT CONTRACT (authoritative gate = create_settlement Layer-1, because the RPC is the single money-mutation entry AND is directly service-role-callable; EF is a thin passthrough):
- Place ONE race-free EXISTS over beneficiary_bank_account AFTER the missing_dest_bank null-check (:92-95) and BEFORE the wallet FOR UPDATE lock (:101) — fail fast before the money lock. create_settlement is SECURITY DEFINER so it reads the registry regardless of caller RLS and asserts owner-match itself.
- Predicate: WHERE owner_type=p_entity_type AND owner_id=p_entity_id AND bank_code=p_dest_bank_code AND account_number=p_dest_account_number AND status='approved' AND 'settlement'=ANY(purpose).
- Reject: RAISE 'dest_not_registered: ...' USING ERRCODE='P0001'. The shared _shared/db.ts:97-119 rpcErrorToResponse maps P0001 (non-special token) → HTTP 400 with NO EF code change. Single token deliberately collapses all 3 sub-conditions → no cross-tenant account-state leak.
- INDEX: reuses existing uq_bene_bank_account_owner_bank_acct (owner_type,owner_id,bank_code,account_number) (20260617000100:87-88); status/purpose are residual filters. NO new index.
- Optional forensic FK (impl-pass): settlements.beneficiary_bank_account_id uuid REFERENCES beneficiary_bank_account(id), nullable; promote EXISTS→SELECT id INTO and stamp on INSERT.

KEY GOTCHAS:
- approve_settlement Mode-2 required_bank_account_id = the SOURCE system bank (bot's sending acct), NOT the destination → enforcement is purely at CREATE on dest_*; do NOT touch approve or the bot terminalizers.
- Partner accounts are settlement-only by the BENE submit RPC, so a partner always passes check (3); the load-bearing wrong-purpose case is a CLIENT topup-only account.
- Ordering matters: missing_dest_bank must still precede dest_not_registered.

DOCS (campaign settleenforce, PR #577 merged to main 2026-06-17T17:21Z, squash 0df2785): adr.md §ADR-22 §Amendment 2026-06-18; epic-beneficiary-bank-account.md BENE-007 → SPLIT [S2 ratified]; epic-source-flows.md SETTLE-001 AC + 8th-create-reject build delta; SPEC docs/spec/settlement-destination-registry-enforcement-slice.md. DOCUMENTS ONLY — code build is a separate orchestrator-run phase.

---
*Added via Oracle Learn*
