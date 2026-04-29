---
title: W1 §ADR-4b ratification — thread #52 closed, all 5 sub-questions resolved → `#de
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-4, adr-4b, deposit, auto-match, atomic-finalize, ratification, decision, thread-52, matchnewstatements, rematch-unmatchedbydirection, statement-driven-primary, safety-net, user-surfaced, input-5-during-ratification, substrate-convergence]
created: 2026-04-27
source: docs/adr.md@a79d1d6 §ADR-4b + thread:#52 messages 103-105 + current-system code reads cited inline
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 §ADR-4b ratification — thread #52 closed, all 5 sub-questions resolved → `#de

W1 §ADR-4b ratification — thread #52 closed, all 5 sub-questions resolved → `#decision`.

User ratified across 2 sessions on 2026-04-27 GMT+7. §ADR-4b promotes from `#provisional` → `#decision`. All 5 sub-questions answered:

Q1 (atomic-finalize boundary) → Option A: full atomicity via PL/pgSQL transaction. Closes mobiz Q4a drift unconditionally at engine level. Architecturally consistent with §ADR-4a `claim_withdrawal_items` RPC — both ports of the substrate pattern. Decision #5 unchanged from pass-1 baseline.

Q2 (multi-candidate safety + slip-integration scope) → preserve current Q4c parking in §ADR-4b. Slip-integration redesign (defer Thunder verify until T+15min after no auto-match; slip-as-fallback path) split to §ADR-4d future via thread #53. Important user observation: client-direct slip-upload API endpoint already exists in current system (`POST /api/v1/deposit/:txnId/upload-slip` with API-Key auth) — what user wanted in "future client API" is actually preservation, not addition.

Q3 (retry cadence) → 1-min `pg_cron` safety-net + statement-driven primary path. Substantial revision during ratification — user surfaced 3 issues with my pass-1 framing:
1. I described 30s ticker as "deposit-tracking retry" — actually statement-tracking (iterates `bank_statements` rows, not `ts_deposits`)
2. I framed sweep cadence as load-bearing latency — actually primary statement-driven path (`MatchNewStatements` goroutine post-`SaveBankStatements`) handles 99% of deposits at ~1-5s; sweep is genuinely a safety net
3. I confused multi-candidate (Q4c) issue with statement-before-deposit ordering — user challenged the case 3 (pool routing reuse), narrowed edge-case list from 5 to 2 realistic cases (user-reuses-old-destination, out-of-band-transfer)

Final Q3 shape rejected my mid-discussion Option B (bidirectional trigger) as over-engineering. Port-verbatim of current intent: primary statement-driven trigger + 1-min sweep on `unmatched` statements within 1-hour window. Decision #4 rewrote to make primary/safety-net distinction explicit + documented full state machine (`pending` → `matched`/`review`/`unmatched` transitions verified from code).

Q4 (auto-expire scope) → split. `deposit-auto-expire-pending` (TTL terminal, ratified mobiz thread #19) deferred to §ADR-4c future as separate ratification surface. Different invariants (callback resend + idempotency from thread #19 (b)+(d) regression-candidates) warrant own ratification.

Q5 (admin manual re-match endpoint) → preserve. Operationally critical — current ops uses for: (a) bot-down recovery for >1hr statements, (b) post-parser-fix re-run on historical statements, (c) DBA / data-correction force-rematch. Code-reuse 100%: admin endpoint = JWT-guard wrapper around the same `match-deposits` EF body that auto-path uses. No additional design surface; just don't remove.

Code reads during ratification (Input 5):
- `services/transactionMatcher.go:25-87 MatchNewStatements` — primary statement-driven match path
- `services/transactionMatcher.go:140-216 matchDepositKTB` + `:225-328 matchDepositSCB` — bank-specific parsers
- `services/transactionMatcher.go:1080-1136 ReMatchPendingStatements` — admin manual re-match
- `services/transactionMatcher.go:1138-1224 ReMatchUnmatchedByDirection` + `scheduler/transaction_matcher.go:24-33` — 30s ticker + 1-hour window
- `controllers/DepositRequestController.go:794-963 UploadSlip` (client API-Key)
- `controllers/DepositController.go:1936-2153 UploadSlipAdmin` (admin JWT) — surfaced code-duplication drift carried forward as Side benefit for §ADR-4d

Pattern observation — fourth user-surfaced clarification in 2 weeks (cross-direction-metric correction 2026-04-24, body-size drift §ADR-8 pass-3 2026-04-24, tier-cap layer redundancy 2026-04-27, today's Q3 mechanism mischaracterization). Pattern: I draft from focused-session context, summarize current-system mechanism from retro/learning summaries; user reviews with broader context and catches conflations / abstractions-too-far. Process improvement candidate: when describing a mechanism (e.g., "30s ticker handles X"), READ THE CURRENT-SYSTEM CODE FIRST instead of relying on retro/learning summaries. Cost is 5-10 minutes of code reading; benefit is substantial — avoids overcommitting to a wrong premise + corrects framing before user has to challenge.

Threads opened: none (thread #53 for §ADR-4d already opened separately during the same ratification session). Threads closed: #52. Commit: a79d1d6 on PR #3.

Supersede applied: pass-1 baseline learning (`learning_2026-04-27_w1-adr-4b-deposit-auto-match-lane-pass-1-baseli`) → this learning per P-001 (provisional → ratified promotion).

Substrate-convergence pattern reinforced (third instance):
§ADR-4a `claim_withdrawal_items` (withdrawal lane atomic claim) + §ADR-4b `finalize_deposit` (deposit lane atomic finalize) + §ADR-4c-future (auto-expire atomic state transition) all share the same shape — thin PL/pgSQL, SECURITY DEFINER, single Postgres transaction wrapping multi-table commit, all-or-nothing semantics. ADR-3 substrate is fully general-purpose — three independent ports converge on the same pattern. Strong evidence that the ADR-1/3/4 substrate decisions were architecturally right.

Next-pass candidates:
- §ADR-4d ratification (thread #53 active; C1-C5 architect-recommendations ready) — primary follow-up
- §ADR-4c baseline (auto-expire) — sibling pass; estimated ~50-60 min if Input 1 sufficient again
- Wallet-table schema cross-cutting ADR — cuts across §ADR-4a + §ADR-4b atomic boundaries; deferred candidate
- arra_trace_link automation proposal — recurring miss, externalize fix needed

---
*Added via Oracle Learn*
