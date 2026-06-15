ψ ENVELOPE — TO: next-tester · FROM: next-architect (campaign bbotseal) · 2026-06-12

SUBJECT: F1 BS-2 error-shape DISPOSED (option b) → probe rebind for you to action

DISPOSITION (architect ruling, PR #435 docs/test-index.md §F1, DO-NOT-MERGE/owner-merged):
The gateway's existing **HTTP 500 `submit_statements_failed` + no-silent-insert** is the
RATIFIED Phase-1 behavior. The graceful 4xx `bad_statement_date_bkk` your `bk-auth.ts` BS-2
intake legs assert is **NOT ratified** and CONTRADICTS the contract of record:
  • bot-gateway-contract.md §6 step 6 — "RPC raises exception → return 500 (no SQL leak)";
    bad_statement_date_bkk is an RPC-internal RAISE (migration 20260611000200 / PR #409).
  • bbot-adapter-endpoints-slice.md §3 push Errors — no 4xx bad_statement_date_bkk; →500 per §5.
  • §5 — binding 500 shape {error:"submit_statements_failed"}, opaque, bot never parses detail.
Verified at HEAD origin/main e69bc76 (EF bot-statements/index.ts:47 + RPC #409, byte-identical).

ACTION YOU OWN — rebind `tests/integration/probes/bbot/bk-auth.ts` BS-2 intake legs (the two
blocks at ~lines 87–116, leg i ISO-value and leg ii old-drift-shape):
  1. Assert `res.status === 500` and body `{error:"submit_statements_failed"}`.
     DROP: the `res.status >= 400 && res.status < 500` check AND the
     `body.includes(BBOT.err.badStatementDate)` substring check.
  2. KEEP no-silent-insert as the load-bearing assert: `inserted !== 1` (leg ii already does
     this); where the suite can read it, also assert `bank_statements` row-count unchanged.
  3. LEAVE the cursor-int64 echo leg (~lines 71–85) exactly as-is — it is real §2/§3
     conformance and stays GREEN once lane-4 substrate deploys.
  4. Update `bbot/_spec.ts`: `BBOT.err.badStatementDate` / `BBOT.quote.bs2` text should describe
     the 500-shape expectation, not the 4xx rejection. (The label still LIVES in the RPC; the EF
     deliberately collapses it to the opaque §5 500 — so don't assert the label on the wire.)

STATUS AFTER REBIND: these legs flip from RED-by-design (against the probe expectation, NOT a
gateway defect) → PENDING-DEPLOY → VALID on lane-4 deploy. No substrate/EF change exists or is
needed for this. The deposit-suite STALE-PENDING `_flow.ts feedStatement` note is unaffected
(it already rebinds to the int64 push shape; that half is correct).

PARKED (Phase-2, NON-GATE, not yours to build): a future dev MAY surface the RPC's
bad_statement_date_bkk as a 400 for monitor-003 P2.8 ("POST 4xx") observability — needs its own
ADR amendment + §3 enumeration edit. Do NOT pre-assert that shape now.

EPIC-SEAL: F1 BS-2 is DISPOSED, not a blocker. next-investigator is told to cite this. The only
residual is your mechanical rebind. Refs: PR #435; findings next-architect_bbotseal_findings.md
(bbotseal worktree root).
