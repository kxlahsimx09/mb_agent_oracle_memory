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
subject: epic-wallet-ledger OVERVIEW PASS up for review — PR #219; 5 story shapes + 3 scoping calls; HOLDING deep authoring
needs_response: true
priority: P2
created: 2026-05-22T10:20:00+07:00
handled_at: 2026-05-22T10:18:34+07:00
handled_by_thread: 202
handled_note: wallet overview PR #219; HOLD deep-authoring pending user GO + scoping confirm
handled_by_inbox: /Users/dev01/.arra-oracle-v2/ψ/inbox/for-orchestrator/handled/2026-05/2026-05-22_10-18_from-orchestrator_thread-202_reply.md
---

Overview pass for the 4th epic (Wallet & Ledger, user pick) is up for review — **PR #219**. Posted in full on thread #202 (msg 861). Branched `next-writer/epic-wallet-ledger-202` off fresh `origin/main` (HEAD `79c5aa7`, no intervening commits).

## Delivered (overview pass = L1 frame + L2 story shape; full ACs deferred)
`docs/requirements/epic-wallet-ledger.md` — canonical wallet-substrate spec on §ADR-10 (`#decision` + 2026-05-13 amendment) + §ADR-3 + §ADR-13. Substrate/lane split mirrors epic-statement-matching (epic owns model + invariants; deposit/payout lanes own credit/freeze/settle triggers, referenced not re-specified). 5 stories:
- WALLET-001 client balance API (balance/frozen/computed available)
- WALLET-002 change-log read (snapshot-per-row 4-field audit)
- WALLET-003 MDR fan-out + mdr_skip no-silent-drop + dropped-revenue view (folds in former MDR Distribution epic)
- WALLET-004 admin manual adjustment via §ADR-13 3-layer write + audit
- WALLET-005 substrate money-safety guarantees (computed available, freeze-settle, wallet.id ASC lock-order, CHECK(balance>=frozen))

Plus INDEX.md (wallet list + DEPOSIT-009 backfill — was one row stale post-PR #215) and README.md (epic-index row planned→authored S2 overview-pass; MDR Distribution folded into WALLET-003).

## 3 scoping calls flagged for review (`## Scoping notes for review` in the file)
1. WALLET-005 = substrate-guarantee story, NOT a freeze-lifecycle re-narration (triggers stay with payout). Recommend keep-as-story; alt = frame-level section.
2. WALLET-003 folds the whole MDR Distribution epic into one story. Recommend one; alt = split behavior vs ops-read.
3. Deposit-credit / payout-settle triggers referenced, never re-specified — the boundary that prevents lane duplication. Confirm split holds.

Trust S2 (proposed) throughout (ratified §ADR-10 surface; column/endpoint shapes §ADR-10-deferred). No mermaid (docs-site gate N/A); cross-epic anchors resolve.

**HOLDING deep per-story authoring** until the shape (esp. the 3 calls) is reviewed. On GO I deep-author the 5 stories to full Given/When/Then ACs + edge cases + Sources parity with the matcher epic.

— next-writer, 2026-05-22 GMT+7
