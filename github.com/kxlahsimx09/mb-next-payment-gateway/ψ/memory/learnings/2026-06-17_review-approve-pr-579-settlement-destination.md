---
title: REVIEW (APPROVE) — PR #579 SETTLEMENT destination-registry enforcement gate (§AD
tags: [next-code-reviewer, repo:mb-next-payment-gateway, next, review, smell, requirement-conformance, approve, settlement, decision]
created: 2026-06-17
source: https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/579 (review + merge 9abf6fb)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# REVIEW (APPROVE) — PR #579 SETTLEMENT destination-registry enforcement gate (§AD

REVIEW (APPROVE) — PR #579 SETTLEMENT destination-registry enforcement gate (§ADR-22 §Amendment 2026-06-18, BENE-007 refined).

Reusable review-conformance checks confirmed clean on this slice (a Layer-1 PL/pgSQL validation gate added to an existing money RPC):

1. P0001→400 mapping must be TRACED through `_shared/db.ts rpcErrorToResponse`, not assumed. The 404 branch fires on `msg.includes("not_found") || code==P0002 || msg.includes("missing")`. A token like `dest_not_registered` is SAFE because "dest_not_registered" does NOT contain the substring "not_found" (it's "not_registered") and not "missing" — so it skips 404, enters the P0001 branch, and (being absent from WIRE_CODES/SERVICE_UNAVAILABLE/FORBIDDEN/CONFLICT token-sets and not "insufficient_funds") falls through to 400. ALWAYS grep the new token across supabase/functions/ to confirm "no EF change" — if it appears nowhere there, the EF is genuinely untouched and the mapping is the sole surface.

2. "Single token, no cross-tenant leak" verified by reading the RAISE message: it must interpolate only the CALLER's own params (p_entity_type/p_entity_id), never the other tenant's account state, and one `IF NOT FOUND` must collapse all sub-conditions (owner-match ∧ approved ∧ purpose) so a caller cannot enumerate WHICH check failed.

3. Gate-placement conformance = diff the re-created function against the BASE body (here 20260616000110) to confirm: gate sits after missing_dest_bank and before the wallet FOR UPDATE; rest preserved verbatim; signature unchanged so REVOKE/GRANT preserve privileges (re-assert for self-containment). Relocating a pure local arithmetic line (v_total) past the gate is not a behavioral change.

4. "No new index" + nullable forensic FK: a `REFERENCES` column does NOT auto-create a referencing-side index in Postgres; reusing an existing UNIQUE index for the equality tuple with status/purpose as residual filters is a single race-free indexed lookup (not per-row) — no N+1. Un-indexed referencing FK is acceptable when the parent (registry) has no hot delete path.

5. Negative-scope claim ("PAYOUT untouched") is fastest verified via `gh pr diff --name-only` + grep that create_payout/ts_payouts are absent from the diff.

Verdict: APPROVE on all 3 dimensions; MERGED (squash 9abf6fb) per §9a. Only failing check was Vercel preview (irrelevant to gateway).

---
*Added via Oracle Learn*
