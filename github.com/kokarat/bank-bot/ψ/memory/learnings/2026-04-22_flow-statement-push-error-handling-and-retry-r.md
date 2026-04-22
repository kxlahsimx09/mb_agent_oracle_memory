---
title: flow — statement-push-error-handling-and-retry — ratified revision (S4 → S2 via 
tags: [technical-writer, repo:bank-bot, current, flow, flow:statement-push-error-handling-and-retry, ratified, revision, statement-push, cursor-reload, no-retry-design, s2]
created: 2026-04-22
source: Oracle Learn
project: github.com/kokarat/bank-bot
---

# flow — statement-push-error-handling-and-retry — ratified revision (S4 → S2 via 

flow — statement-push-error-handling-and-retry — ratified revision (S4 → S2 via Oracle thread #38, 2026-04-22). Supersedes the first-pass S4 learning filed earlier the same day.

**Doc:** `docs/flows/statement-push-error-handling-and-retry.md@<follow-up-commit>` (was `6efc727` on first pass, header updated on ratification commit).
**Thread:** #38 — closed 2026-04-22, skipping `answered` intermediate per ratification-thread-closure discipline.
**PR:** kokarat/bank-bot#99 (shared with `queue-claim-to-processing-state-machine` flow + its ratification).

**Five judgment calls, ratification verdicts:**
1. **Q1 (CURSOR_GET_FAIL silent-swallow)** — `[DRIFT]`, fix deferred. W4 queue: `learning_2026-04-22_drift-statement-push-cursor-get-silent-swallow`.
2. **Q2 (POST_4xx ticker-spam)** — `[DRIFT]`, fix deferred. W4 queue: `learning_2026-04-22_drift-statement-push-4xx-no-circuit-breaker-w4`.
3. **Q3 (no-retry intentional vs emergent)** — elevated to `[INTENTIONAL]`. Cursor-reload IS the retry mechanism. This S2 doc is the named-decision reference; no ADR needed.
4. **Q4 (persistent 401/403)** — `[DRIFT]`, fix deferred. W4 queue: `learning_2026-04-22_drift-statement-push-auth-failure-silent-stall`.
5. **Q5 (4 call sites of 9b)** — keep enumerated for debugging clarity.

**Design-contract lockdown (Q3 verdict expanded).** The "no in-memory retry" design for statement push is hereby named and locked. Four load-bearing assumptions, listed in doc §Purpose:
- Gateway dedup is deterministic (key composition per mobiz breadcrumb).
- Scrape is idempotent (depends on `raw_text` / `description` fidelity rule).
- Gateway cursor advances only on successful ingest.
- Bank portal retains rows ≥ 1 business day.

When any one breaks, the no-retry design degrades to dead-letter silently. Flow §Purpose documents each breakage path; sibling drifts (Q1, Q2, Q4) harden observability around the breakage but do NOT change the design contract.

**W4 queue state (3 open drift learnings).**
| Drift | Priority | LOC | File |
|---|---|---|---|
| Q1 cursor-get-silent-swallow | low | ~8 | app.js |
| Q2 4xx-no-circuit-breaker | medium | ~20 | app.js |
| Q4 auth-failure-silent-stall | medium | ~13 | core/api.js |

All three tagged `#drift + #followup + w4-queue + flow:statement-push-error-handling-and-retry`. Bundle recommended because theme is coherent ("add observability + circuit-breakers to silent-swallow error paths"); ship as single PR with 3 commits when someone picks this up. Q4 lives in different file so bundle is optional not required.

**What did NOT change on ratification (doc-side):**
- §Purpose "cursor-reload IS retry" framing confirmed correct, kept verbatim.
- §Actors 3 actors (Scraper, Gateway, explicit non-actor BankPortal) kept.
- §Preconditions / §Sequence / §Success criteria kept verbatim.
- §Error paths — 9 error classes kept; 3 `[DRIFT]` markers annotated with W4 learning IDs.
- §Implementation pointers kept verbatim.
- §Postconditions kept verbatim.

**What DID change on ratification (doc-side):**
- Header `Claim strength` line: S4 → S2 with thread #38 reference.
- Added `// ratified-via-thread:38` marker.
- §Error paths: each `[DRIFT]` marker gained a W4 learning ID pointer + fix plan summary.
- §Open questions → §Resolved questions (rewritten with verdicts + W4 pointers).
- §Change log: new entry for S4 → S2 transition.

**Follow-up learnings:**
- `scb-session-dead-recovery-re-login` — third and last flow from the 2026-04-22 gap analysis, still open. Authorable after this ratification.
- 3 W4 queue items (the drifts above) — ship when someone has appetite for the bundle.

---
*Added via Oracle Learn*
