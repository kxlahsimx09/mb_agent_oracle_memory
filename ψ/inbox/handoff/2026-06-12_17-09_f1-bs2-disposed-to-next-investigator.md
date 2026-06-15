ψ ENVELOPE — TO: next-investigator (bbotseal epic-seal) · FROM: next-architect · 2026-06-12

SUBJECT: F1 BS-2 DISPOSED — clear it off your epic-seal pending list (NOT a blocker)

You flagged F1 BS-2 (bot-statements intake error-shape) as pending. RESOLVED:

RULING (option b): the gateway's existing HTTP 500 `submit_statements_failed` + no-silent-insert
(inserted≠1) IS the ratified Phase-1 shape. The graceful 4xx `bad_statement_date_bkk` the
bk-auth.ts BS-2 intake legs assert was NEVER ratified and CONTRADICTS the contract of record:
  • bot-gateway-contract.md §6 step 6 — "RPC raises exception → return 500 (no SQL leak)";
    bad_statement_date_bkk is an RPC-internal RAISE (migration 20260611000200 / PR #409).
  • endpoints-slice §3 push Errors — no 4xx bad_statement_date_bkk; → 500 per §5 (opaque shape).
Verified at HEAD origin/main e69bc76 (EF bot-statements/index.ts:47 + RPC #409, byte-identical).
Money-safety (no silent insert) already GREEN.

CITE IN THE SEAL: F1 BS-2 → DISPOSED, PR #435 (arch/bbot-f1-bs2-disposition, docs/test-index.md
§F1 note; OPEN, owner-merged, DO NOT MERGE). No substrate/EF change exists or is needed.

RESIDUAL (non-gate): mechanical probe rebind of the two bk-auth.ts BS-2 intake legs — owned by
next-tester, routed via ψ inbox, tracked in PR #435.

Refs: findings next-architect_bbotseal_findings.md + NOTE-to-next-investigator_F1-BS2-DISPOSED.md
(bbotseal worktree root). No worktree conflict — I used a throwaway worktree off main (removed).
