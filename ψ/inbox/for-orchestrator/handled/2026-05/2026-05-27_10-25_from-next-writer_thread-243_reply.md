---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: notify
thread: 243
parent_thread: 242
parent_oracle: orchestrator
subject: Reply — doc-refresh PR #261 (R1 §ADR-8 A2 9th filter + B1 demand-refill default-OFF + B2 DTR refund capture)
needs_response: true
priority: normal
created: 2026-05-27T10:25:11+07:00
handled_at: 2026-05-27T10:29:00+07:00
handled_by_thread: 243
handled_note: PR #261 (R1/B1/B2) acknowledged → surfaced to user for review/merge. Responded in-thread #243 msg 1126 = HOLD SETTLE/R2 + AUTH-005 pending §ADR-12 amendment ratification. Deliberate hold, no action envelope (would wake agent to do nothing); will re-dispatch post-ratification. Closes the needs_response loop via this handled_note.
---

Sub-A DONE. One doc-refresh PR delivered in thread #243 (msg 1123).

**PR #261** — https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/261
branch `next-writer/doc-refresh-243-r1-b1-b2` off `origin/main` @1d0b7ff. No new ADR;
all three are faithfulness/freshness vs ratified `#decision`s + production `@2087fed`.
Files: `epic-bot-dispatch.md` + `epic-source-flows.md`.

**R1** — §ADR-8 §Amendment 2026-05-26 (A2) propagated. BOT-001 AC#2 8→9 filters
(per-bank withdrawal amount-range) + AF1/AF2 edge cases; PULLOUT-002 stale "being
ratified separately / #229" line superseded. Amendment cited both Sources blocks.

**B1** — Pullout demand-refill (PULLOUT-001): "4 co-equal LIVE triggers" overstatement
corrected → scheduled-tick + admin-manual are the always-available paths; demand-refill
config-gated **default-OFF** (mirrors PAYOUT-008 "ships off") + fires the **opposite edge**
(dest-LOW pull-in, not source-too-full drain). Code-cited BotConfigController.go:557-562 /
pulloutDemand.go:370-384,:21-26. §ADR-12 D3 consolidation untouched — only liveness grounding.

**B2** — DTR refund (FLOW stays deferred per DEPOSIT-011/§ADR-4d): DTR-001 wallet carve-out
to the S2 "never touches a wallet" universal; DTR-002 S4 record enriched with the
money-movement half — wallet debit-at-create, credit-back, enable_deposit_refund default-off,
AUTH-007 step-up, refund_pending_review/ResolveRefund. Code-cited RefundDeposit @2087fed.

No trust labels moved. Mermaid edit parse-safe (paren-alias matches existing epics).

**R2 ready to fold (your sequencing call).** Sibling #244 ruled R2 = defer partner-initiated
settlement to Phase-2 (partner via admin-create `entity_type=partner`). That closes the live
`[open question]` at SETTLE-001 (`epic-source-flows.md:116`) — SAME file as PR #261, ~1-line
swap. Per parent #242 ("sequence at aggregate") I did NOT preempt. On GO I either amend #261
or take R2 + the AUTH-005 follow-on (architect-flagged separate `epic-auth-rbac.md` task)
together. needs_response: true.

Learning: `2026-05-27_doc-refresh-243-adr8-a2-pullout-demandrefill-dtr-refund`.
