---
title: retro — W2 sync-clean — architecture.md snapshot 2026-04-30
type: retro
tags:
  - system-architect
  - repo:mb-next-payment-gateway
  - next
  - adr
  - sync-clean
  - w2
  - retro
session_window: 2026-04-30 GMT+7
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

## Source commit
`docs/adr.md` at `a526082`.

## ADR counts
- Ratified (#decision): 12 sections (ADR-1, 2, 3, 4, 4a, 4b, 4c, 4d, 5, 6, 7, 8)
- Under design (#provisional): 0
- Open questions ([AWAITING_THREAD] in non-provisional sections): 1 (Thread #45 — fleet-control substrate, §ADR-8)

## Strip decisions

| Location | Rule | Decision |
|---|---|---|
| ADR-4a/4b/4c/4d/6/8 intro blockquotes | Rule 6 | Stripped "Grounded in..." evidence-trail lines. Kept scope-pointer sentences ("Decision record for...", "Implementation detail lives in...") as plain paragraphs. |
| ADR-4a/4b/4c/4d update-wrapper blockquotes | Rule 5 | Stripped `> **Update (...):` wrapper; kept content as plain paragraph. |
| ADR-4b "Critical drift" sentence | Rule 3 | Kept the architectural content (Q4a atomicity gap); stripped `services/transactionMatcher.go:592-701@37dfb26` file reference. |
| ADR-8 context: `findBestBankForItem:554-565` | Rule 3 | Kept function name (architectural); stripped line-number range. Same for `countTodayCompletedTransactions:444-471`. |
| ADR-8 context: "Business constraint (ratified thread #46)" | Rule 6 | Stripped "(ratified thread #46)" parenthetical; kept the business constraint statement. |
| ADR-8 Deferred questions: "Thread #46 resolved..." item | Rule 6 | Stripped (resolved-question record in deferred section — process tracking). |
| ADR-4a/4b/4c/4d/6/8 Prior art sections | Rule 6 | Stripped entire sections — entirely evidence trail (learning IDs, flow names with SHAs, thread numbers). |
| ADR-4a/4b/4c/4d/6/8 Resolved questions sections | Rule 6 | Stripped entire sections — entirely process tracking. |
| ADR-4a/4c/4d Implementation paragraphs | Rule 6 | Stripped process-metadata text (ratification pass notes, line-count changes). Kept design-doc pointer sentences. |
| ADR-4b/4d Implementation paragraphs | Rule 6 | Stripped entirely — body-size notes and extract-threshold commentary are ops notes, not architecture. |
| [AWAITING_THREAD:45] in ADR-8 body (3 occurrences) | Rule 4/8 | Exception text: removed inline marker, kept prose. Consequences item (v): kept as plain sentence. Deferred section: converted to **Open questions:** bullet. |

## AI Diary

First W2 run on this repo. The workflow spec was clear and the strip rules mechanical enough that judgment calls were infrequent. Main complexity: the ADR sections with introductory blockquotes (4a, 4b, 4c, 4d, 6, 8) each had a mixed blockquote containing both scope-pointer content (keep) and evidence-trail content (strip). Rule 5 covers Update-wrapper blockquotes specifically but the "Grounded in..." lines required Rule 6 judgment. I stripped them — they're entirely threads, SHAs, code-read citations, and learning IDs with no architectural value to a reader coming in fresh.

The output is 427 lines against 1023 source lines. The revision log alone was 519 lines (lines 505–1023), so the body itself was ~504 lines and the clean output captured ~427 of those — reasonable given how much of each section body was process metadata.

Session was interrupted mid-read by a token limit cut; resumed without recap per workflow discipline.

## Honest Feedback

- The "Grounded in..." blockquote lines pattern is common across all the complex ADR sections. Rule 6 handles it but it would be worth adding an explicit example to the W2 strip rules for this pattern — it's ambiguous whether it belongs under Rule 5 (update-wrapper) or Rule 6 (ratification-tracking).
- The "Implementation:" paragraphs vary a lot — some are pure design-doc pointers (keep), some mix pointer + ratification metadata (partial keep), some are pure process (strip). The current spec handles this well via Rule 6's "entire purpose" test, but a worked example in the spec would reduce future uncertainty.
- No orphan markers found. Rules applied cleanly.
