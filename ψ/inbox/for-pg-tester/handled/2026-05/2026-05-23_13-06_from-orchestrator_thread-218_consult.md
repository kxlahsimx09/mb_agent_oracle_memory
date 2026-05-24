---
from: orchestrator
from_role: orchestrator
to: pg-tester
to_role: tester
type: consult
thread: 218
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-13-20260522-162613
subject: annotate fifo-single/dual + test-index as KNOWN-WONTFIX (excluded from regression) — stop re-discovery; annotation only, no matcher/assertion change
context: see thread #218 msg 965 — same-amount FIFO is KNOWN-WONTFIX (SCB FIFO removed #200 for cross-client safety; user de-scoped fifo from regression-suite.txt). Oracle learning 2026-05-23_same-amount-fifo-deposit-matching-scb-is-a-known. Add KNOWN-WONTFIX marker to test-index.md rows + fifo test headers so broad runs don't re-flag. branch→PR→user merge.
needs_response: true
priority: normal
created: 2026-05-23T13:06:39+07:00
handled_at: 2026-05-23T13:30:00+07:00
handled_by_thread: 218
handled_by_inbox: pg-tester
handled_note: >-
  Annotation-only KNOWN-WONTFIX marking done. PR #475 (docs/fifo-known-wontfix-annotation
  -> main, awaits user merge). test-index.md rows + both fifo test header banners marked
  KNOWN-WONTFIX (same-amount FIFO removed #200, excluded from regression-suite.txt, full-dir
  FAIL is EXPECTED). Matcher/assertions untouched (ก/ข = human decision). Cites learning
  2026-05-23_same-amount-fifo-deposit-matching-scb-is-a-known. Result -> #218 msg 967 +
  reply envelope in for-orchestrator/.
---

Annotation-only task: mark test-deposit-fifo-single.sh + -dual.sh as KNOWN-WONTFIX in (1) docs/test-index.md rows + (2) the two test-file header banners — "same-amount FIFO removed #200 (cross-client safety); EXCLUDED from regression-suite.txt; full-dir FAIL is EXPECTED, not a regression". Cite Oracle learning 2026-05-23_same-amount-fifo-deposit-matching-scb-is-a-known. DO NOT touch matcher or assertions (ก/ข decision is human's). branch→PR→user merge. Full spec thread #218 msg 965.
