---
title: W1 amendment ratify pass — §ADR-9 callback wire contract lock (Stripe-style head
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, amendment, w1, adr-9, wire-contract-lock, stripe-style-header-signature, terminal-state-taxonomy-bundle, rejected-vs-failed-semantic-split, thread-95-closed, deposit-004-awaiting-thread-closed-inline, bundle-fix-in-adjacent-amendment-instance-2-candidate-durable, user-mandate-revision-mid-dialogue-instance-1-NEW, forward-looking-substrate-decision-instance-2, user-memory-as-forensic-check-instance-2, deliberate-divergence-from-mobiz-current-instance-7, verify-via-production-mcp-instance-8, same-arc-4-thread-closure-FINAL, trace-chain-35-links, pr:83, poc-implement-handoff-wire-contract, writer-handoff-deposit-004-awaiting-thread-strip, adr-9-body-exceeds-extract-threshold]
created: 2026-05-13
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 amendment ratify pass — §ADR-9 callback wire contract lock (Stripe-style head

W1 amendment ratify pass — §ADR-9 callback wire contract lock (Stripe-style header sig + camelCase ISO8601-Z payload) + §Bundle terminal-state taxonomy (combined baseline + pass-2 ratify; thread #95 closed; DEPOSIT-004 AWAITING_THREAD closed inline). 4th of 4 same-day poc-implement audit threads (#94/#95/#96/#97); same-arc 4-thread closure FINAL.

# Pass shape

Combined baseline + ratify landing — instance #7 (continuing durable). Largest amendment this session arc — body grows 180 → 370 lines (exceeds §ADR-9 extract threshold; design-dir extraction flagged).

Bundle-fix-in-adjacent-amendment — instance #2 (candidate-durable threshold reached): bundles §ADR-4c terminal-state taxonomy ratification (closes DEPOSIT-004 AWAITING_THREAD from 2026-05-10 writer pass) into §ADR-9 wire-contract amendment. After thread #93 §H3-Fix bundle instance #1.

# Critical user-mandate-revision mid-dialogue

User context shift during Q2 discussion: *"ผมเอา header merchant ไม่มี migration เป็นเจ้าใหม่ หมด ไม่มีปัญหา เอา security ไว้ก่อน"*

Pre-shift architect-rec stack:
- Q2=α body-sig (production-parity)
- Q3 port verbatim (mobiz field names)
- Q4 30s timeout
- Q11 port production drift (paidAt Z + completedAt +07:00)
- Q12 refCode unverified

Post-shift architect-rec stack:
- Q2=β Stripe-style header-sig (security-first)
- Q3 modernize event-specific schema (camelCase)
- Q4 30s timeout (preserved)
- Q11 uniform Z UTC (fix production drift class)
- Q12 echo clientReferenceId (Stripe metadata pattern)

→ Pattern: **user-mandate-revision-mid-dialogue (instance #1 NEW)** — when user revises mandate mid-architect-recommendation, architect must re-evaluate dependency chain. Brew-ops handoff candidate at instance #2.

# WC1-WC11 (wire contract sub-decisions)

- WC1: Stripe-style header `X-Maxpay-Signature: t=...,v1=...`
- WC2: HMAC-SHA256 over `${t}.${raw_body}` (full body tamper protection)
- WC3: 5-min replay-protection window (signed timestamp)
- WC4: Universal `{event, txnId, amount, status, timestamp}` + per-event extras
- WC5: camelCase wire convention (industry-standard)
- WC6: Uniform ISO8601 Z UTC (deliberate fix of production drift: paidAt=Z vs completedAt=+07:00)
- WC7: Optional `clientReferenceId` echo (Stripe metadata pattern)
- WC8: Per-attempt re-signature (fresh timestamp each retry)
- WC9: 30s HTTP timeout (slow-merchant tolerance)
- WC10: `X-Maxpay-Event-Id` dedup header
- WC11: `failureCode` mandatory + `failureMessage` optional on `.rejected`/`.failed`

# TS1-TS5 (§Bundle terminal-state taxonomy)

User-proposed in DEPOSIT-004 writer pass 2026-05-10 (flagged AWAITING_THREAD); ratified architecturally here:

**Deposit (4 states):** paid / **rejected** NEW / expired / failed (narrowed scope to system errors)
**Payout (4 states):** success / **rejected** NEW (symmetric application) / failed (narrowed) / cancelled

Pattern instance #7 of "deliberate divergence from mobiz current" — production current overloads `failed` (427 rows ts_deposits mixing admin-reject + system-error per dpay MCP verify); next-system splits semantically.

Event taxonomy 1:1 with terminal states: 8 events total (`deposit.paid` / `.rejected` / `.failed` / `.expired` + `payout.success` / `.rejected` / `.failed` / `.cancelled`).

# failureCode enum (canonical Phase-1; 17 codes)

deposit.rejected: slip_invalid, slip_fraud_v1, slip_fraud_v2, admin_rejected, force_approve_then_rejected
deposit.failed: system_error
payout.rejected: bank_rejected, validation_failed, kyc_blocked, admin_rejected
payout.failed: bank_timeout, claim_timeout, system_error
payout.cancelled: admin_cancelled, auto_cancelled

# Patterns surfaced

## NEW
- **Bundle-fix-in-adjacent-amendment instance #2** — candidate-durable threshold reached
- **User-mandate-revision-mid-dialogue instance #1 NEW** — context shift flipped multiple Q recs in cascade
- **User-memory-as-forensic-check instance #2** — user prompted memory search → surfaced DEPOSIT-004 taxonomy
- **Forward-looking-substrate-decision instance #2** — wire contract = API surface expensive to retrofit; adopt-now zero-cost

## Continuing-durable
- Combined baseline + ratify landing instance #7
- Deliberate divergence from mobiz current instance #7 (TS4)
- Verify-divergence-via-production-MCP at amendment time instance #8
- Writer-flagged unratified surface during user-story authoring instance #4 (DEPOSIT-004 close)
- Per-action actor triple instance #9 (Q9 extends to all callback_attempts)

# Production audit grounding

dpay MCP `callback_logs` collection: 888,871 records lifetime; 9 event types verified; production body-sig + canonical-string + camelCase verified; production drift verified (paidAt=Z vs completedAt=+07:00; ts_deposits.status='failed' 427-row overload).

# Architecture-decision phase status post-pass

**19 ADRs/amendments ratified `#decision`; 0 live `#provisional`.** Corrective amendment + bundled cross-section ratification close 2 deferred surfaces simultaneously without opening new provisional.

Trace chain: extends 34 → 35 links (continuing longest-in-repo). Sequence:
`bffd971f` § ADR-13 amend → `42c30ed4` §ADR-16 → `0eef3209` §ADR-4d D1 → `d5139d8e` §ADR-4b D6 → `46bc6d02` §ADR-4d D8 → `5f9b66fa` §ADR-9 #93 → `d98c5222` §ADR-10 → this pass

# Same-arc 4-thread closure FINAL (2026-05-13)

- #94 (matcher cascade) — closed via reply (PoC bug; ADR D3 already correct)
- **#95 (wire contract) — CLOSED via this amendment**
- #96 (wallet schema) — closed via §ADR-10 amendment PR #82
- #97 (admin-in-loop) — closed via reply (PoC bug; ADR D5 already correct)
- **DEPOSIT-004 AWAITING_THREAD** — closed inline via §Bundle

# Body size flag

§ADR-9 body grows 95 → 180 → 370 lines across 3 amendments. **Exceeds extract threshold** per §ADR-4a/4c precedent (~150-200 lines). `docs/design/callback-dispatcher/` extraction candidate flagged for next architect sprint. Not blocking this pass; housekeeping.

# Handoffs

## poc-implement
- dispatch-callback EF rewrite per WC1-WC11
- payload builders in finalize_deposit / mark_success / mark_failed / admin_approve_paid / admin_approve_rejected (NEW) RPCs
- mock-merchant Stripe-style verifier implementation
- effort estimate ~15-18h post-amendment

## next-writer
- Strip `[AWAITING_THREAD]` flag from DEPOSIT-004 (epic-deposit.md:257)
- Update Sources to cite §ADR-9 amendment 2026-05-13 §Bundle
- Optional: cross-reference TS1+TS2 from §ADR-4d D5 + §ADR-4a D7 inline notes

# Sources

- thread:#95 (poc-implement audit; 3-drift framing)
- dpay MCP audit 2026-05-13: callback_logs collection (888,871 records, 9 events, 5 payload samples verified)
- DEPOSIT-004 writer pass 2026-05-10 (epic-deposit.md:248-257 + revision-log-archive 2026-05.md:37)
- §ADR-9 Decision #3 (HMAC sign-time preserved)
- §ADR-9 thread #93 amendment AM4 (per-action actor triple instance #8 → extends here)
- §ADR-13 amendment F2 (per-action actor triple pattern alignment)
- §ADR-4d Decision #5 amendment 2026-04-27 (admin-owns-terminal; text references rename to TS1)
- §ADR-4a Decision #7 (withdrawal lifecycle terminal events; TS2 applies symmetrically)
- §ADR-4b D5 / §ADR-4c D4 (deposit terminal-producing RPCs; TS1 enforced)
- Stripe webhook signature spec (industry pattern reference)
- Concurrent same-day amendments: §ADR-10 thread #96 (cost-asymmetry decision lens precedent)
- session-arc memory project_session_arc_2026-05-10-to-11-poc-impl.md

# Commit anchor

`7835f99` (amendment combined-landing on branch `architect/w1-adr9-amendment-wire-contract-bundle-2026-05-13`). PR #83 merged via `d0ea62a`.

---
*Added via Oracle Learn*
