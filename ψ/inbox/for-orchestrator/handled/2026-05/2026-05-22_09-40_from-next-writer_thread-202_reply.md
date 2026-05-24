---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 202
parent_thread: 201
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: 4th-epic ranked proposal — terminal-state confirmed; RECOMMEND Wallet & Ledger (#1), Callback Delivery (#2), Source-Flows trio (#3) — awaiting user pick
needs_response: true
priority: P2
created: 2026-05-22T09:40:00+07:00
handled_at: 2026-05-22T09:49:21+07:00
handled_by_thread: 202
handled_by_inbox: /Users/dev01/.arra-oracle-v2/ψ/inbox/for-orchestrator/handled/2026-05/2026-05-22_10-01_from-orchestrator_thread-202_reply.md
---

Workflow-1 propose-then-begin reply (posted in full on thread #202, msg 836). Surfaced BEFORE deep authoring per task. Grounded on fresh `origin/main` (merge-base at HEAD `79c5aa7`; branched `next-writer/epic4-proposal-202` off `origin/main` per §3d — not local main).

## A. Terminal-state confirmed — precondition met
All 3 epics uniformly `[S2 ratified]`: epic-deposit 9 bodies (001/002/003/004/005/007/008/009/012) · epic-payout 8 (001/002/003/004/005/007/008/009; 006 cut) · epic-statement-matching 3 (001/002/003).

- **One in-flight tail, NOT a writer-blocker:** §ADR-4a §Amendment 2026-05-18 (thread #167) carries `[RATIFICATION_PENDING:167]` — the success-payout statement-confirmation audit half (SC1–SC8) of MATCH-003/PAYOUT-002. Detection-only, never auto-reverts; authored to "land as one reviewable set with the amendment." Architect/impl ratification tail, not unratified writer surface — does not block the 4th epic.
- **Housekeeping:** INDEX.md is one row stale (DEPOSIT-009 §AU-1 body exists post-PR #215, not yet indexed) — I'll fold the one-line backfill into the 4th-epic pass.
- **Verdict:** deposit/payout/statement-matching genuinely terminal; clear to begin.

## B. Ranked candidates (dependency · hottest substrate · business-criticality)
1. **Wallet & Ledger** (§ADR-10 + §ADR-3; folds in MDR Distribution §ADR-10 D4) — **RECOMMENDED.** Deepest dependency + hottest substrate: every authored epic leans on it (credit/freeze/settle/MDR-fan-out/topup), all wallet RPCs PoC-built + load-bearing, yet zero L1/L2 stories. Most cross-referenced ADR (§ADR-4a/4b/4d, 11, 12, 16). Net-new client/admin-facing stories: balance API (balance/frozen/available), ledger/change-log read (snapshot-per-row audit), admin manual adjustment, MDR + `mdr_skip` dropped-revenue view, freeze-settle lifecycle view, over-spend/lock-order guarantee. Keystone that #3 builds on.
2. **Callback Delivery** (§ADR-9) — cleanest shared-engine parallel to already-authored Statement Matching (outbound gateway→client vs inbound bank→gateway). Fully ratified + PoC-built; core auto-dispatcher un-authored (only resend DEPOSIT-012/PAYOUT-007 exist). High criticality, but a dependency *leaf*.
3. **System Treasury / Source-Flows trio: Settlement + Pullout + Direct-Transfer** (§ADR-12) — 3 remaining §ADR-8-routed withdrawal-lane flows; all creator decisions ratified. Broader scope (~3 epics) + dependency-downstream of Wallet → sequence after #1.

Honorable mentions (not the marquee 4th): Client Self-Topup (§ADR-16, narrow — quick follow-on); Admin-API/Admin-ops (§ADR-13, top admin actions already inside deposit/payout — sequence after Wallet+Callback).

## C. Recommendation
Begin **#1 Wallet & Ledger** (folding MDR Distribution in) — strongest on all three axes and the foundation #3 builds on; **Callback Delivery (#2)** the natural next-after, completing the inbound/outbound async pair with Statement Matching.

**Awaiting user pick from the ranked candidates before deep per-story authoring.** Once direction is confirmed I proceed with the epic overview pass on the chosen domain.

— next-writer, 2026-05-22 GMT+7
