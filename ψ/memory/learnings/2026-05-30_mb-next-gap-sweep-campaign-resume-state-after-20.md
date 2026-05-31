---
title: mb-next gap-sweep campaign — resume state after 2026-05-30 (PR #282 merged, #283
tags: [orchestrator, team-dispatch, mb-next-payment-gateway, requirement-gap-sweep, campaign-resume, pr-282, pr-283, pr-284, ratification-pending, adr-12, adr-13, next-architect, next-writer, fabrication-caught, repo:arra-oracle-v3, fleet]
created: 2026-05-30
source: orchestrator session 2026-05-30 — campaigns gapqw2/gapw3/archamd1; PRs #282/#283/#284
project: github.com/soul-brews-studio/arra-oracle-v3
---

# mb-next gap-sweep campaign — resume state after 2026-05-30 (PR #282 merged, #283

mb-next gap-sweep campaign — resume state after 2026-05-30 (PR #282 merged, #283/#284 open; #284 needs user ratification)

Orchestrator-driven requirements gap-sweep on github.com/kxlahsimx09/mb-next-payment-gateway. A 13-domain sweep (current #current production vs next requirements, architect-classified) found 31 gaps, 0 ADR conflicts: 5 high / 15 medium / 11 low → 14 writer-authors (ADR already backs), 12 adr-amendment-needed, 5 new-adr-needed.

SHIPPED/OPEN as of 2026-05-30 night:
- PR #282 MERGED — 3 quick-wins (already-ratified ADR): CALLBACK-001 per-attempt 30s timeout (§ADR-9 WC9); AUTH-007 step-up replay per-purpose edge (§ADR-2 Amд 2026-05-26 S3); INDEX Deferred-Payout-Surfaces + minted PAYOUT-011 (§ADR-4a Amд 2026-05-16 RR4).
- PR #283 OPEN, awaiting review — batch-2, 4 ADR-backed AC/edge adds: PAYOUT-001 unroutable-by-band (§ADR-8 AF2); MATCH-003 payout-driven OUT-matcher trigger (§ADR-4a RR1); WALLET-003 is_owner designation (§ADR-10 D1); CLIENT-001 cached-4xx replay (§ADR-11 C4).
- PR #284 OPEN, NEEDS USER RATIFICATION — 3 HIGH ADR amendments in docs/adr.md: (1) §ADR-12 Settlement Confirm-Review CR1–CR4 = class (b) money-material, #provisional [RATIFICATION_PENDING:campaign-archamd1]; (2) §ADR-12 Direct-Transfer Admin Override DTO1–DTO4 = class (b) money-material, RATIFICATION_PENDING; (3) §ADR-13 Admin Deposit List/Read DL1–DL3 = class (a) port-fidelity, ratified within architect authority. Architect verified vs mobiz source + dpay and CAUGHT 2 gap-finder fabrications: NO sparse-btree index on ts_deposits.custom_bank_account_number (it is an unindexed anchored-regex scan); NO read-time fraud-preview badge (DEPOSIT-007's badge presupposition is wrong — the six-check cascade runs only at approve write-path, never at query; DL3 carved the read badge OUT and flagged next-writer to downgrade the DEPOSIT-007 AC to approve-time-only or raise a separate #provisional read advisory).

NEXT (resume):
1. User ratifies PR #284's two (b) money-material amendments (confirm-review + DT-override) → unblocks next-writer SETTLE-002 / DTR-001 stories.
2. After #283/#284 merge: next-writer follow-on authors SETTLE-002 confirm-review + DTR-001 override stories; resolve DEPOSIT-007 fraud-preview-badge per DL3.
3. Remaining backlog (not dispatched): 5 new-ADR (provisioning epic = biggest; deposit QR/fee; pullout-task CRUD; client API-key lifecycle) + ~9 amendments (idempotency-store fail-open, topup filter/residual-MDR, fleet reboot-ack, admin audit-query, monitoring wallet-alert + hourly/daily ops-report, callback redirect/identity). Dispatch architect-first then writer.

MECHANICS: team-dispatch-helper.sh now works end-to-end (kickoff as first user turn, separate window per role-campaign so guard is no-op, opus default) — no TASK_BRIEF.md/manual send-keys workaround needed. Dispatch with SCOPE LOCK + "if ADR doesn't back it, SKIP don't invent". verify-against-HEAD every dispatch (gap-finder worked from stale state; BOT-001/PULLOUT-002 already shipped in PR #261). Vercel CI check is a known false-fail (commit-author-email not in Vercel project) — ignore; mergeable stays MERGEABLE. Orchestrator does NOT merge PRs (user reviews) and does NOT edit files (guard blocks; correct — I dispatch via maw team). Gap dump preserved in session transcript: tool-results/bvfhrnuq7.txt + tasks/wn5phmdig.output.

---
*Added via Oracle Learn*
