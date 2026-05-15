---
title: W1 amendment ratify pass — §ADR-4b Decision #6 (admin manual re-match endpoint) 
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, amendment, w1, adr-4b, adr-4b-d6-amendment, admin-rematch-statement-deferred-phase-2, thread-91-closed, combined-baseline-ratify-landing-instance-3-DURABLE, pre-dpay-mcp-drift-risk-instance-1-NEW, drift-closure-as-decision-instance-5, verify-divergence-via-production-mcp-instance-4, deliberate-divergence-as-deferral, deposit-driven-match-canonical-late-match, phase-1-architectural-surface-19-decisions-0-provisional, trace-chain-31-links, pr:63, next-writer-handoff-deposit-006]
created: 2026-05-12
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 amendment ratify pass — §ADR-4b Decision #6 (admin manual re-match endpoint) 

W1 amendment ratify pass — §ADR-4b Decision #6 (admin manual re-match endpoint) deferred to Phase-2 (combined baseline + pass-2 ratify; thread #91 closed). Corrective amendment closing 3 drift classes surfaced via DEPOSIT-006 user-story author verification.

# Pass shape

Combined baseline + ratify landing — instance #3. Pattern reaches **durable threshold** at this pass (3-instance rule per W1 §Port-from-mobiz protocol rule 2). After §ADR-16 ratify (instance #1, 2026-05-09) + §ADR-4d D1 amendment ratify (instance #2, 2026-05-09) + this §ADR-4b D6 amendment (instance #3, 2026-05-12). Brew-ops handoff: add to W1 workflow doc as lifecycle option alongside "combined pass 1.5+2 lifecycle."

Triggers for combined-landing:
1. Cross-session-boundary baseline-to-ratify gap (this pass: baseline 2026-04-27, ratify 2026-05-12 = 15 days, multi-arc span)
2. Wholesale ratify with no revise scope (user: *"(A) Defer endpoint Phase-1"*)
3. Branch rebase debt OR small amendment that doesn't justify separate commits (this pass: amendment is corrective, single concern)

# 3 drift classes closed

## Drift #1 — Shape mismatch
- ADR text (2026-04-27 thread #52 ratification): per-statement `{statement_id}` input
- mobiz current code (`services/transactionMatcher.go:1312-1370 ReMatchPendingStatements(accountNumber)` + `controllers/BankStatementController.go:737-755 ReMatchStatements`): account-scoped batch with `account_number` optional query string
- Surfaced via DEPOSIT-006 author verification (writer-territory pass)

## Drift #2 — Bot-coupling prose
- ADR text use cases: "(a) bot-down recovery / (b) post-parser-fix re-run / (c) DBA force-rematch"
- Operation is pure gateway-side on persisted `bank_statements` rows (no bank-bot interaction)
- User-flagged: *"requirement ตรงนี้ก็ไม่ถูกต้องเลย เพราะไม่ได้เกี่ยวอะไรกับ bot เลย... API นี้แค่ พยายาม match ใหม่เฉยๆ"*

## Drift #3 — Purpose drift (zero-evidence)
- Production audit (dpay MCP, 27-day window 2026-04-15 → 2026-05-11):
  - 51 calls / 47 = 403 Forbidden / 4 = 200 Success
  - **0 documents** updated_at within ±15min of the 4 success calls → zero successful matches in production
  - 3,587 late-match cases (lag >1h) flow entirely via §ADR-4b D2 deposit-driven match cascade
  - 37,471 stale unmatched; 33,798 with `updated_at` >1h after `scraped_at` (continuously touched by deposit-driven scan)
- Conclusion: endpoint is functionally redundant for the late-match use case (which deposit-driven path solves)

# AM1-AM4 (wholesale-ratified)

- **AM1** — Defer Decision #6 (`admin-rematch-statement` Edge Function) to Phase-2. No Phase-1 admin EF, RBAC permission, queue UI.
- **AM2** — Canonical late-match mechanism = §ADR-4b D2 deposit-driven match path. When new `ts_deposits` row INSERTED, matcher scans `bank_statements WHERE direction='in' AND match_status IN ('pending', 'unmatched')` for amount-matching candidates.
- **AM3** — Phase-2 re-introduction triggers (any one):
  - Volume signal: >50 stale unmatched/month with matching ts_deposits candidate
  - Correctness signal: match-correction (un-match + re-match) emerges as recurring need
  - Concrete business driver — not speculative
- **AM4** — Pre-dpay-MCP drift-risk pattern NEW. Ratifications in 2026-04-13 → 2026-05-07 window carry latent drift risk (production-data grounding unavailable). When verification post-MCP surfaces drift, deferral is the right architect posture if production zero-evidence.

# Patterns surfaced/confirmed

## Combined baseline + ratify landing — instance #3 (DURABLE)

3-instance threshold reached. Brew-ops handoff to W1 workflow doc.

## Pre-dpay-MCP drift-risk — instance #1 NEW

Decision #6 ratified 2026-04-27, ~10 days before dpay MCP availability (2026-05-07). Verification post-MCP surfaced drift. Pattern: pre-MCP ratifications may carry latent drift; if surfaced, deferral > minor amendment when production zero-evidence.

Brew-ops handoff candidate at instance #2.

## Deliberate-divergence-as-deferral — sub-pattern NEW

Distinct from "deliberate divergence at requirements-time" (catalogued in 2026-05-11 deposit-epic learning). This pass diverges by *removing* Phase-1 surface entirely (vs. mobiz parity port). Justification: mobiz current endpoint produces zero matches; parity port = zero-value Phase-1 surface area + maintenance debt.

## Drift-closure-as-decision — instance #5 (durable continues)

When verification pass surfaces drift in already-ratified text, close via amendment (not silent edit). Amendment captures all drift findings + production evidence + Phase-2 re-introduction conditions = full auditability of why Phase-1 scope shrunk.

## Verify-divergence-via-production-MCP at amendment time — instance #4

Durable continues. Production-DB MCP audit at both shape verification AND purpose verification.

## Forward-compatibility check before ratify — instance #2 (backward variant)

This pass: forward-compatibility *backward* — checking whether deferral closes off any future Phase-2 design space. AM3 lists explicit triggers + framing constraints to preserve design optionality. Candidate-durable at #2; brew-ops handoff at #3.

## Single-actor-decision sub-pattern

Original Decision #6 used 3 use-case framing (a/b/c). AM3 re-frames Phase-2 triggers in terms of *signals* rather than *use cases* — pattern: use case taxonomy assumes a workflow exists; production-zero-evidence challenges the assumption. Trigger framing (volume / correctness / business driver) is more rigorous because it requires concrete signal before re-introducing surface.

# User dialogue trajectory

- next-architect's DEPOSIT-006 verification pass (writer-territory; PR #59 merged 2026-05-11) surfaces shape drift; thread #91 opened with 4-option survey
- User selects deep-dive path ("D") before deciding shape → architect runs dpay MCP audit
- Audit reveals zero successful matches → architect proposes 5th option (e) Hybrid + async background-job (initially recommended)
- User flags story prose carries bot-coupling drift independent of shape decision; scope expands from shape-only to shape + prose
- User clarifies API has no bank-bot interaction
- Architect runs deeper audit (account-level stale stockpile + lag distribution + 4 success-call timestamps) → 3-direction re-assessment (A: defer / B: narrow Phase-1 / C: hybrid+async)
- User selects "(A) Defer endpoint Phase-1" → wholesale ratify AM1-AM4

User-pushback-as-design-force pattern instance #30 — user surfaced prose-drift concern at deep-dive time + redirected scope from shape decision to deferral decision via grounded-skepticism. Pattern: when user surfaces fundamental framing concern mid-decision, expand scope rather than narrow ratify around original frame.

Pre-Input-5 instance count: 20 → 21 (dpay MCP audit at amendment time — shape + purpose verification combined).

# Architecture-decision phase status post-pass

**19 ADRs/amendments ratified `#decision`; 0 live `#provisional`.** Corrective amendment closes 3 drifts without opening new ones.

Trace chain: extends 30 → 31 links (continuing longest-in-repo). Previous links: `bffd971f` §ADR-13 amendment ratify (2026-05-08) → `42c30ed4` §ADR-16 ratify (2026-05-09) → `0eef3209` §ADR-4d D1 amendment ratify (2026-05-09) → this pass.

# Threads

- **Closed:** #91 (with closing message + commit citation `d4ecc14` + writer handoff for DEPOSIT-006)
- **Opened:** none

# Writer handoff — DEPOSIT-006 removal from Phase-1 scope

Thread #91 reply explicitly tags `@next-writer / @next-product-writer` for DEPOSIT-006 story removal/deferral. Two options offered:
- W-A: Remove story + revision-log entry
- W-B: Mark `[DEFERRED-PHASE-2]` + retain text

Glossary / cross-cut prose cleanup suggested in same pass (late-match references should point to §ADR-4b D2 deposit-driven cascade, not admin manual re-match).

# Sources

- thread:#91 (single architect message + this resolution; ratify trajectory in body)
- dpay MCP audit 2026-05-12: `audit_trail` + `bank_statements` collections (51 calls, 3,587 late-matches, 37,471 stale-unmatched)
- mobiz code: `services/transactionMatcher.go:1312-1370 ReMatchPendingStatements` + `controllers/BankStatementController.go:737-755 ReMatchStatements`
- §ADR-4b D2 matcher cascade (load-bearing for AM2)
- session-arc memory `project_session_arc_2026-05-10-to-11.md` (DEPOSIT epic review context that surfaced the drift)

# Commit anchor

`c5c4ee5` (§ADR-4b D6 amendment combined-landing) on branch `architect/w1-adr4b-d6-amendment-defer-2026-05-12` (force-pushed clean from main). PR #63 merged via `d4ecc14`.

---
*Added via Oracle Learn*
