---
title: next-writer tier3 quick-win pass (campaign gapqw2, PR #282, branch writer/gapqw2
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, epic-callback-delivery, callback-001, epic-auth-rbac, auth-007, step-up, replay-per-purpose, INDEX, payout-011, deferred-phase-2, epic-payout, adr-9-wc9, adr-2-amendment-2026-05-26, adr-4a-amendment-2026-05-16, thread-133, campaign-gapqw2, pr-282, tier3, re-verify-before-edit, task-brief-in-cwd]
created: 2026-05-30
source: next-writer (gapqw2 tier3 pass)
---

# next-writer tier3 quick-win pass (campaign gapqw2, PR #282, branch writer/gapqw2

next-writer tier3 quick-win pass (campaign gapqw2, PR #282, branch writer/gapqw2-tier3, repo: kxlahsimx09/mb-next-payment-gateway) — 3 doc-only requirement edits, each re-verified against HEAD + cited ADR before editing:

1. CALLBACK-001 (epic-callback-delivery.md): added a per-attempt 30s HTTP-timeout AC — a client endpoint that accepts the connection but never responds is recorded failed when the 30s timeout elapses and follows the same backoff/retry path; a hung endpoint cannot stall the delivery engine or break at-least-once. New Sources citation §ADR-9 WC9 (verified adr.md ~L2033 "HTTP timeout: 30 seconds per attempt"; Decision #4 retry budget unchanged).
2. AUTH-007 (epic-auth-rbac.md): added an edge-case bullet — step-up replay protection is single-use *per purpose*; a code burned for one money-out purpose MAY still be accepted for a different purpose in the replay window (parity with current system). Per §ADR-2 §Amendment 2026-05-26 S3 (verified adr.md L86 "single-use per purpose ... MAY be accepted for two distinct purposes"). No Sources change — S3 already cited.
3. INDEX.md: added a "Deferred Payout Surfaces" subsection minting PAYOUT-011 [deferred Phase-2] — statement-driven review→failed auto-reconcile, fires only on a positive reversal/return signal; absence of a confirming debit never auto-fails. Deferred per §ADR-4a §Amendment 2026-05-16 RR4 (thread #133 Q1=(B); verified adr.md L375). One-line entry added to epic-payout-revision-log.md.

Process notes / durable rules reinforced:
- The 3 edits were not in the Oracle inbox/threads or repo; they arrived via a TASK_BRIEF.md dropped in cwd. Correct move when an assignment's concrete content is missing: hold, do not fabricate spec edits, ask the lead — then execute exactly once the brief lands.
- Callback + auth epics have NO revision-log file; recorded those two changes in the PR body instead of a per-epic log. Only epic-payout has a revision log.
- Minting a deferred id (PAYOUT-011) for an already-ratified Phase-2 deferral is a small writer scope call — records the gap as a tracked id alongside the shipped review→success direction (PAYOUT-009), no new story body, no behavior change.
- Deleted TASK_BRIEF.md before committing so it never entered the PR. Branched from HEAD==origin/main so the PR carried only the 3 edits + log line (4 files, +9). Did NOT touch BOT-001/PULLOUT-002 (shipped in PR #261).

---
*Added via Oracle Learn*
