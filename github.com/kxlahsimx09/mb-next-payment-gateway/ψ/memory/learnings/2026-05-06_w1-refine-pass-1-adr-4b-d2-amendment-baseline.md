---
title: W1 refine pass 1 — §ADR-4b D2 amendment baseline (Matcher cascade, 3-step orderi
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-4b, adr-4b-d2-amendment, matcher-cascade, linkCheckingDeposit, linkPaidDeposit, v1-fraud, deposit-lane, provisional, ratification-pending, thread-78, deliberate-divergence-from-mobiz-current-instance-6, substrate-convergence-6th-port-candidate, decision]
created: 2026-05-06
source: docs/adr.md@6879a36 §ADR-4b D2 amendment + docs/design/deposit-lane/matcher-cascade.md@6879a36 + bot-gateway-contract.md@6879a36 §8a; evidence bundle in §Revision log
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine pass 1 — §ADR-4b D2 amendment baseline (Matcher cascade, 3-step orderi

W1 refine pass 1 — §ADR-4b D2 amendment baseline (Matcher cascade, 3-step ordering).

Closes architectural debt flagged 2026-05-05 in `docs/design/deposit-lane/bot-gateway-contract.md` §8a (deferred with §ADR-4b amendment baseline thread #76; B7 V1 fraud detection ratified pending cascade specification). The amendment specifies the binding 3-step matcher cascade order inside `match-deposits` EF + per-step writes + V1 fraud loop integration.

The cascade has two distinct write semantics. Step 1 (`matchDepositKTB`/`matchDepositSCB`) finalizes a deposit (atomic credit via `finalize_deposit` RPC; full §ADR-4b D5 bundle). Steps 2a (`linkCheckingDeposit`) + 2b (`linkPaidDeposit`) emit *statement-side link only* — `bank_statements.matched_request_id = $deposit_id` and nothing else. No deposit/wallet/callback movement. Preserves §ADR-4d D5 admin-owned-terminal invariant. The cross-reference write is the V1 fraud lookup target at admin approve (consumes §ADR-4d amendment §V1).

Source ground = mobiz `services/transactionMatcher.go::matchDeposit@20b6fa3` (PR #384, 2026-05-03). Production incident class fixed in #384: `DEP17777364940AC8L3` + `DEP1777733674IBGAQO` (3 พ.ค. 2026) — pre-#384 V1 fraud lookup misattributed statements when slip arrived first (slip → `status=checking` → invisible to Step 1's `pending` filter → fell through to Step 2b → silently attached to OLDEST `paid` deposit of same dest+amount+last-4 → V1 hash check at admin approve sees ownership mismatch → blocked legitimate approval). The new step 2a refuses to act when no source identity can be extracted from the statement description (port-verbatim invariant: don't guess; falls through to Step 2b instead).

Step 2b filter scope is the only deliberate divergence from mobiz current — pattern instance #6 of "deliberate divergence from mobiz current" (after §ADR-4c D10 / §ADR-13 D2 / §ADR-4b amendment B2 / §ADR-4b amendment B6 / §ADR-4d amendment V2-Layer-1). Mobiz filters `status='paid'` only; amendment broadens to `status IN ('paid','expired')`. Rationale verified per §Port-from-mobiz protocol rule 1: mobiz can omit `expired` because synchronous Thunder verify makes expired-with-slip rare in current; next-system's deferred-Thunder per §ADR-4d amendment makes the case structurally reachable, and §ADR-4d D5 admin recovery covers expired-with-slip via force-approve.

5 ratification sub-questions in thread #78:

- D1 cascade as one EF body vs three EFs — architect rec: one body (single entry, sequential steps; shared helpers).
- D2 Step 2b filter scope `paid` only vs `paid OR expired` — architect rec: broaden (deliberate divergence #6).
- D3 refusal on missing source identity in Step 2a — architect rec: port verbatim (refuse, don't guess; rationale verified).
- D4 link write via thin RPC (`link_statement_to_deposit`) vs direct UPDATE — architect rec: thin RPC (uniform audit; substrate convergence #6 if ratified).
- D5 source-identity extraction priority + score tie-break — architect rec: port verbatim (full-account p2 / last-4 p1; score 2/1; tie-break = min minute-delta).

Key deltas:
- §ADR-4b title appended amendment annotation `[RATIFICATION_PENDING:78]` thread #78
- §ADR-4b Decision #2 amended with ~25-line cascade contract block + cross-link to design doc
- NEW `docs/design/deposit-lane/matcher-cascade.md` (~155 lines; 8 sections incl. test plan + V1 fraud loop integration)
- `bot-gateway-contract.md` §8a updated to cross-link new doc instead of "deferred"

No `arra_supersede` this pass (amendment is additive — extends ratified §ADR-4b D2 without replacing prior decision text).

Threads opened: #78. Threads closed: none. Commit: `6879a36`. PR: #17. Next pass candidate: §ADR-4b D2 amendment ratification pass-2 (thread #78 close + markers strip + amendment promotes `#provisional` → `#decision`) when user ratifies D1-D5; then deposit-lane fraud detection loop fully closed architecturally.

---
*Added via Oracle Learn*
