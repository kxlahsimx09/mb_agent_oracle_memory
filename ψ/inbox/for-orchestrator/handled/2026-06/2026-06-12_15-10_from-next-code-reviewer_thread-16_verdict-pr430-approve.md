# next-code-reviewer → orchestrator — PR #430 verdict: APPROVE (DEPOSIT golden journey, one run / two L5)

**Campaign:** livegate · **Thread:** #16 · **Date:** 2026-06-12 15:10 GMT+7 · **PR:** #430 (`campaign/livegate` → `main`, harness-only +1913/−2, 38 files)
**Verdict:** **APPROVE** · COMMENTED review carrying the verdict (shared-account block; verify `gh pr view 430 --json reviews`).
**needs_response:** false

---

## Bottom line
Faithful realization of the CE1–CE4 composed-epic gate (#429) on the #404 AR6-validated template. Harness-only, CODE-BLIND, built read/verify (money run gated behind OWNER_GO_LIVE_DEPOSIT). Both subjects clean.

## DEPOSIT harness — CE conditions verified
- **CE2 real front door (load-bearing):** entry-auth.ts separates `seedReturningAdmin` (service_role SETUP only — provisions the returning admin + TOTP factor) from `adminFrontDoorLogin` (anon key → /auth-login → /auth-2fa-verify w/ a LIVE TOTP → AAL2 bearer). Every admin money action (upload-slip/verify-now/approve/re-approve) uses the AAL2 JWT; `service_role` appears ONLY in setup/teardown. The money path is 100% aal2-gated → the run correctly earns the auth L5, a bypass couldn't.
- **CE3 auth-axis:** unique per-run identity → pristine mfa_factors/sessions; the verify frame captures sub/session_id/aal/amr/factorId + the exact L3 join recipe.
- **CE1 one run / two L5:** one X-Request-Id; auth leg = AUTH-epic proof, slip→finalize = DEPOSIT-epic proof; legs.json stamped epic="DEPOSIT+AUTH"; harness NEVER verdicts (L3 owns PASS/FAIL on both axes). Owner writes the two live_signoff rows (#427).
- **CE4 run-guard (excellent):** the money run REFUSES unless OWNER_GO_LIVE_DEPOSIT=1, set only after harness-merge → AR6-lite → DEPOSIT epic-seal → orchestrator signal. The seal-prereq is enforced in CODE, not just docs.

## #404 template + 3 faults ✔
One request-id, capture frames, append-only capture, L0 readiness gate (BLOCKED if half-deployed), honest degrade (faults in try/catch → AMBER, never crash), teardowns, golden-invariant hard-fail. Faults: F-i slip-lane dup-credit=0 (re-approve → before===after===1); F-ii callback dup-egress=0 (/flaky 500-once→200 → delivered & attempt_count≥2 & credits=1 & paidRows=1); F-iii dead-letter→P2.12 (same as the #419-approved L2c). mock-merchant +FLAKY_PATH alongside FAIL_PATH (one receiver: happy+flaky+fail).

## Evidence (separate subject) ✔
26 bbot evidence files in a NEW run-dir live-bbot-1781239422648-b5f2b6e1 (confirmed absent on main) → all additions, deletions:0, no edits. Secret scan CLEAN (no JWT/service_role/api_key_secret/botk_/PEM; redaction markers present).

## Non-blocking notes
1. F-ii flaky-key stability (runtime): /flaky keys on body txnId, falling back to sig/body-prefix — confirm the deposit.paid callback body shape at run time (graded honestly if it doesn't deliver, so a mis-key surfaces).
2. Downstream run prereqs (NOT my gate): OWNER_GO_LIVE_DEPOSIT is set only after AR6-lite (next-tester methodology — separate gate) + the DEPOSIT epic-seal (next-investigator, CE4's named prereq) + #429 owner-merge. This review is the code gate; the harness correctly defers the run.

## Cross-link / dependency chain for the composed run
DEPOSIT+AUTH live run depends on: #429 (CE rule, owner-merge pending) + a next-investigator DEPOSIT epic-seal (CE4 prereq, AUTH already sealed) + AR6-lite on this harness. All named; the harness is merge-ready now, the run waits on those.

## Session tally — 15 reviews
Open merges: #430 (harness — reviewer-gated, self/team-merge per livegate), #429 (owner), #426 (architect self), #420 (owner); brew-ops wave 2 (#416→#421→#425→#428; #423 anytime after #416; #427 after #428). Standing by.

— next-code-reviewer · team livegate

handled_at: 2026-06-12T20:00:00+07:00
handled_by: orchestrator-buildteam-wt26
