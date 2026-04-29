---
title: W1 thread-47 resolution — tier-cap responsibility consolidated to fair-router Fi
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-4a, adr-8, withdrawal-queue, tier-cap, fair-router, thread-47, resolution, ratification, decision, user-surfaced, process-improvement, reframe-audit, p-001, surfacing-to-resolution-pattern]
created: 2026-04-27
source: docs/adr.md@4d4bb23 + thread:#47 messages 95-99 + commit chain 1d66c83→0fba3e5→4d4bb23 on PR #3
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 thread-47 resolution — tier-cap responsibility consolidated to fair-router Fi

W1 thread-47 resolution — tier-cap responsibility consolidated to fair-router Filter #7; claim-side `compute-claim-size` + `p_max_items` retired.

User-surfaced (2026-04-27) review of post-sync output caught a leftover from ADR-8 pass-1 → pass-2 reframe: two functions implementing the same tier-cap concept at two layers, both ported from `scheduler/withdrawal_dispatcher.go:205-240 findBestBankForItem`. Pass-1 (pull-first) put tier cap at bot/claim time as `compute-claim-size`; pass-2 reframe (push via fair-router, ratified thread #46) added `pickTierCap` at fair-router as Filter #7 in the routing stack but did not remove the now-redundant claim-side layer.

Operational impact of leaving as-is: two independent random tier rolls produce a leftover-pending-orphan class — fair-router routes M items to bot X (sets `required_bank_account_id` on M rows), bot calls `compute-claim-size` → returns N independently. If N < M, bot claims N, leaves (M−N) rows with `required_bank_account_id = X, status = 'pending'` waiting for re-broadcast or sweep. Sweep extension Case 2 would un-assign and re-route — incorrect, since the bot is healthy and just chose a smaller batch.

Resolution: Option A ratified by user (2026-04-27 via thread #47) — remove the claim-side tier-cap layer entirely. Tier cap = fair-router responsibility 100%. Brings next-system into parity with current-system one-cap-at-routing semantics. Closes the leftover-pending-orphan class.

Concrete deltas:
- §ADR-8 Decision step 2 — Filter #7 annotated as sole tier-cap layer post-thread-#47
- §ADR-4a Decision #4 — claim RPC now has no p_max_items parameter; tier-cap sentence rewritten
- claim-rpc.md — function signature, layered-responsibilities (5→4), RPC body, test plan all updated; "Tier cap (retired from this RPC, 2026-04-27)" paragraph preserves history per P-001
- open-questions.md §5 — `compute-claim-size` section marked RETIRED with git-history pointer

Both ADRs stay #decision; this was a surfaced sub-question within ratified scope, not a re-ratification trigger.

Durable pattern captured — surfacing-to-resolution loop in two adjacent revision-log entries:
First in repo's W1 history that a surfacing entry (revision-log marking the open question + thread + anchors) was followed in the same session by a resolution entry. The journey is preserved as two adjacent records, not collapsed into one. Future architect sessions reading the log can see both the gap and how it was closed.

Process improvement adopted (added to internal pass-cadence checklist):
**"After every reframe (pass-N → pass-N+1 with a model change), audit which old machinery is now redundant, and either remove or explicitly preserve as defense-in-depth with a comment."**

Would have caught the `compute-claim-size` leftover at ADR-8 pass-2 reframe time instead of three days later via user review. Same class of miss as the 2026-04-24 pass-2 cross-direction-metric correction (also user-surfaced) — pattern of "architect reframes a model but doesn't audit which legacy mechanism is now dead". Three user-surfaced design issues in two weeks share this root cause.

Threads opened: none. Threads closed: #47 (with citation to commit 4d4bb23 + revision-log resolution entry). Commit chain on PR #3: 1d66c83 (surfacing) → 0fba3e5 (backfill surfacing) → 4d4bb23 (resolution). Next pass candidate: deposit auto-match lane (ADR-4 other half) — independent of this thread; or backfill of this learning id into revision log.

---
*Added via Oracle Learn*
