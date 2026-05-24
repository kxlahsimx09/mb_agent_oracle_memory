---
title: W2 cleanup-requirements pass #2 — epic-deposit + epic-payout + wallet-ledger (20
tags: [next-product-writer, repo:mb-next-payment-gateway, next, cleanup, hygiene, plain-english, workflow-2, epic-deposit, epic-payout, orphan-sweep, mdx-safety, cluster-split-proposal, P-001, second-w2-pass]
created: 2026-05-22
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W2 cleanup-requirements pass #2 — epic-deposit + epic-payout + wallet-ledger (20

W2 cleanup-requirements pass #2 — epic-deposit + epic-payout + wallet-ledger (2026-05-22, thread #215).

Second W2 pass on this repo (first was 2026-05-15, PRs #105/#106/#107 + thread #102). User flagged docs/requirements/ as "รกมาก" (very cluttered); orchestrator (thread #215) dispatched a full W2 pass, priority = Step 3c plain-English + size-budget triage, cluster-split = PROPOSAL ONLY.

## Inventory snapshot (pre-fix)
epic-deposit.md 659 (over 409) · epic-payout.md 589 (over 339) · epic-wallet-ledger.md 255 (over 5) · rest ≤184 OK. Markers: `[RATIFICATION_PENDING:167]`×4 (epic-payout ×2, epic-statement-matching ×2) + `[RATIFICATION_PENDING:175]`×1 (epic-deposit:452). 2 bare-brace MDX traps (epic-deposit:384 inside an AC, epic-wallet-ledger:70 Sources). 0 kramdown. 0 missing-Sources (heuristic false-positives = large stories). INDEX in sync; glossary healthy; Step 3a archive = no-op (live revision log 2026-05-11→21, none >30d); Step 6 cross-repo = no-op (refs already in cross-repo.md).

## Categories fired + PRs
- PR #227 cleanup/mdx-safety-wallet-ledger — backtick bare `{client, partner, system}` set (JSX-expression trap).
- PR #228 cleanup/epic-deposit-hygiene — 3 categories, ONE file/PR (grouped to avoid inter-PR conflict on epic-deposit.md): Step 3c plain-English on DEPOSIT-007 intro blockquote + journey steps 2/3/5 (demoted jsonb paths, audit_log action_type slugs, 7-FK column union, write_audit_log arg-count/SQLSTATE, inline §-cite chains → plain English; JSON-path tokens 6→0 in journey region; ~2.6KB density removed) + Step 4 orphan-flip (:175 → [RATIFIED:175 2026-05-20]) + Step 2 brace fix (line 384, in an AC, meaning-identical: "at least one of {A ∪ B}" → "at least one of A or B"). 89 ACs byte-verbatim, 1 mermaid unchanged.
- PR #229 cleanup/epic-payout-plain-english — Step 3c, 4 body-prose lines (PAYOUT-002 edge, PAYOUT-005 step 4, PAYOUT-009 steps 2-3): demoted bank_bot_silent_fail_pattern, direction='in'/'out', bank_statements, pg_cron, CAS-flip/WHERE status='pending', cancel_stale_payout/wallets_change_logs/withdrawal_queue/audit_log → plain English. 61 ACs byte-verbatim, 8 mermaid unchanged.
- thread #102 refreshed (msg 937) — cluster-split PROPOSAL for BOTH epics; human sign-off pending.

## Durable learnings this pass
1. **Orphan-marker classification: trust the ADR's ratification state, NOT the thread's open/closed status.** Both thread #167 and #175 were *closed*, but the W2 Step-4 matrix keys on thread.status — which would have stripped BOTH. The correct signal is the source ADR's own marker: adr.md:1150/:828 show §V15 ratified #decision (→ flip :175), but adr.md:359/:402 still record §Amendment 2026-05-18 (Success-Payout audit) as "drafted … awaiting ratification" with the same `[RATIFICATION_PENDING:167]` (→ LEAVE the 4 :167 markers). A discussion/cross-check thread can close while the amendment it surfaced is still pending a separate ratification. **Refinement of the W2 Step-4 rule: verify the cited claim's disposition in docs/adr.md (grep the §Amendment line for [RATIFICATION_PENDING]/ratified #decision), not just arra_thread_read status, before stripping.** Companion to feedback_adr_amendment_supersession.

2. **A cluster-split that was sized to ≤250 can rot out of budget as stories absorb amendments.** Thread #102's 2026-05-15 auto/slip/admin split estimated slip≈220; ten days of fraud-cascade amendments (V13/V14/V3 + audit-uniformity + 7-FK + new DEPOSIT-009) pushed DEPOSIT-007 alone 95→133 and slip→~340. The same 3 cohesive clusters now BOTH exceed 250. Refresh insight: when refreshing a stale split proposal, recompute per-story line counts (not just total) — the long-pole story may have doubled. Pair the split with design-content extraction (DEPOSIT-007 force-approve mechanics + forensic walkthroughs → docs/design/) or go finer (4-5 clusters) to actually reach budget.

3. **Plain-English on long single-line bullets reduces DENSITY, not line COUNT.** epic-deposit stayed 659 lines after the Step 3c pass (each demoted bullet is one long line replaced by a shorter long line); the win is byte-density / readability (the "รก"), not line budget. The ≤250 line-budget fix is structural (cluster-split), which is why the orchestrator framed them as complementary ("plain-English shrinks them; the split finishes the job"). Don't measure a Step 3c pass by line-count delta.

4. **Step 3c scope discipline on a 6-amendment-cycle story (DEPOSIT-007).** The bulk of DEPOSIT-007's density is in its ACs (testable contract, P-001-verbatim, OUT of W2 scope) and forensic-walkthrough edge cases (evidence, high-risk/low-value to rewrite). The right-sized, high-confidence Step 3c surface is the intro blockquote + user-journey steps — the most-read prose, where jargon-demotion is clearly meaning-preserving. Leave ACs and forensic edge cases; note the deliberate boundary in the PR.

5. **PR-grouping by FILE beats strict one-PR-per-category when categories collide on one file.** Workflow says one-PR-per-category, but orphan-sweep + MDX-brace + plain-English all landed on epic-deposit.md; 3 separate PRs would conflict on merge. Grouped into one epic-deposit PR with 3 clearly-labelled sections + per-category before/after — keeps the structural-only trust shape, zero inter-PR conflict. (Prior pass avoided this because its orphan target was on a different file, cross-repo.md.)

## Deferred
Revision-log entries deferred to post-merge per the 2026-05-15 precedent (the entry cites the merged PR commit, which doesn't exist pre-merge). Retro filed separately. epic-payout has no revision-log file (W1-infra gap, surfaced not fixed).

File: docs/requirements/epic-deposit.md@pre-#228 / epic-payout.md@pre-#229 / epic-wallet-ledger.md@pre-#227.

---
*Added via Oracle Learn*
