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
subject: DONE — epic-wallet-ledger deep-authored (WALLET-001..005 full ACs); PR #219 ready for review; 4th epic complete
needs_response: true
priority: P2
created: 2026-05-22T11:05:00+07:00
handled_at: 2026-05-22T10:38:07+07:00
handled_by_thread: 202
handled_note: epic-wallet-ledger complete PR #219 d2e4ea7; surfaced to user for merge
handled_by_inbox: /Users/dev01/.arra-oracle-v2/ψ/inbox/for-orchestrator/handled/2026-05/2026-05-22_10-38_from-orchestrator_thread-202_reply.md
---

GO discharged — **epic-wallet-ledger is fully authored**. PR #219 (commit `d2e4ea7`) ready for review. Posted in full on thread #202 (msg 872). Continued on the PR #219 branch `next-writer/epic-wallet-ledger-202`.

## What changed since the overview pass
3 scoping recs confirmed + baked in: WALLET-005 = substrate-guarantee story · WALLET-003 folds all of MDR · deposit-credit/payout-settle triggers referenced-not-respecified. All 5 stories brought from skeletons to **full Given/When/Then ACs + edge cases + Sources**, at the depth of epic-statement-matching (sibling engine/substrate epic — prose journeys, no mermaid by precedent). Stripped the STATUS overview banner + Scoping-notes section (resolved); story headers now `[S2 ratified]`; INDEX/README drop overview-pass qualifiers (DEPOSIT-009 backfill retained).

## Stories (full)
- WALLET-001 balance read — {balance, frozen, computed available}; AM1 computed-not-stored (closes AM8 drift class); §ADR-2 RLS scope; the PAYOUT-001 spend-guard figure.
- WALLET-002 change-log read — snapshot-per-row 4-field audit (AM3), append-only, grouped by reference_id (D3/PR #171).
- WALLET-003 MDR fan-out — N rows per profile partner + explicit mdr_skip no-silent-drop (D4), atomic in lane finalize/settle, dropped-revenue view; trigger owned by DEPOSIT-002/PAYOUT-002.
- WALLET-004 admin adjustment — §ADR-13 D1 3-layer + D2 audit_log canonical/trigger-denorm/cross-link; 'add' op; CHECK guard; sibling of PAYOUT-005.
- WALLET-005 substrate money-safety — computed available, freeze-settle (AM2), wallet.id ASC lock-order (D5; §ADR-4a §Amendment 2026-05-18 cross-table precedent), CHECK(balance>=frozen) (AM5), §ADR-3.

## Verification
5 stories × {journey, ACs, edge, Sources}; 0 mermaid (gate N/A); all internal + cross-epic anchors resolve; 255 lines. **4th epic (Wallet & Ledger) authored to S2 parity with deposit/payout/statement-matching.**

Next natural step (your call / user's): Callback Delivery (#2) as the 5th epic, completing the inbound/outbound async pair with Statement Matching. Awaiting review of PR #219.

— next-writer, 2026-05-22 GMT+7
