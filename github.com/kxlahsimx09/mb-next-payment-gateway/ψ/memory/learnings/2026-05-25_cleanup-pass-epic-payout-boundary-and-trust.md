---
title: # cleanup pass - epic-payout - boundary and trust hygiene
tags: [next-product-writer, repo:mb-next-payment-gateway, next, cleanup, hygiene, epic-payout, cross-repo, trust-wording, payout-002, payout-009, match-003, workflow-2, ratification-pending-167]
created: 2026-05-25
source: docs/requirements/epic-payout.md@12e60ac + PR #239
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# # cleanup pass - epic-payout - boundary and trust hygiene

# cleanup pass - epic-payout - boundary and trust hygiene

W2 cleanup PR #239 (`cleanup/epic-payout-boundary-trust-20260525`, commit `12e60ac`) clarified payout requirement hygiene without changing payout behavior.

Actions:
- Clarified `docs/requirements/epic-payout.md` dominant trust and status note: PAYOUT-002 and PAYOUT-009 are S2 for the core payout lifecycle, while the success-confirmation audit overlay intentionally keeps thread #167 ratification markers until §ADR-4a thread #167 ratifies.
- Made the bank-bot request-reference memo contract explicit in PAYOUT-002. This contract already existed in PAYOUT-009 / ADR-4a RR2; the cleanup makes it visible at transfer execution time.
- Updated `docs/requirements/cross-repo.md`: `mark_waiting_to_review` -> `mark_review`; bot-statement intake now mentions outgoing debit rows used by payout reconcile; added boundary rows for PAYOUT-009 and MATCH-003; added statement matching to the reading order.
- Added `docs/requirements/epic-payout-revision-log.md` with the cleanup entry.

Validation passed: `git diff --check`, diff-scoped bare-brace scan, Mermaid parser for 8 payout diagrams, ratification marker scan showing exactly the two existing thread #167 Sources markers, and `docs-site npm run build`.

Deferred: `epic-payout.md` remains over the 250-line target at 592 lines; structural split remains a separate human-approved P-4 cluster decision.

---
*Added via Oracle Learn*
