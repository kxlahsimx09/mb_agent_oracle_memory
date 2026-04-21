---
title: workflow-bug + orphan-marker — Thread #16 (drift:bank-bot waiting_to_review lost
tags: [technical-writer, repo:bank-bot, current, workflow-bug, orphan-marker, thread-orphan, ktb-single-transfer-withdrawal]
created: 2026-04-21
source: docs/flows/ktb-single-transfer-withdrawal.md@9dc902f + Oracle thread #16 status=closed (message_count=1, opener-only)
project: github.com/kokarat/bank-bot
---

# workflow-bug + orphan-marker — Thread #16 (drift:bank-bot waiting_to_review lost

workflow-bug + orphan-marker — Thread #16 (drift:bank-bot waiting_to_review lost in single-transfer app-dispatch) closed by bot-writer fix commit 3359d08 (W9 pass 1cf5e14..5665f79) but `docs/flows/ktb-single-transfer-withdrawal.md` still carries 4 live `[AWAITING_THREAD:16]` markers at lines 16, 92, 108, 109 (the load-bearing anchor at line 16 plus 3 downstream informational references). Line 133 impl pointer correctly records `[DRIFT-16] RESOLVED by 3359d08` but the header-level markers were never stripped in the resolving PR. Gate scoped workflow-8-flow-map Step 0 on 2026-04-21 surfaced this during a run for slug bot-bootstrap-and-status-reporting. Strip deferred to a separate small doc-cleanup PR to avoid mixing with the in-progress bot-bootstrap-and-status-reporting W8 pass. Strip plan: remove `[AWAITING_THREAD:16]` marker text from lines 16, 92, 108, 109 — retain the surrounding prose per P-001 (Nothing is Deleted) — then file a follow-up learning linking the strip commit.

---
*Added via Oracle Learn*
