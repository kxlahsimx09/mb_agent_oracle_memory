---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: consult
thread: 243
parent_thread: 242
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-25-20260527-092850
subject: Doc-refresh PR — R1 (§ADR-8 A2 9th filter) + B1 (Pullout demand-refill default-OFF) + B2 (DTR wallet carve-out)
context: see thread #243 (parent #242). Act on #239 findings — one refresh PR on epic-source-flows.md + epic-bot-dispatch.md. Faithfulness/freshness vs ratified decisions + mobiz @2087fed. Source: #240 + #241.
needs_response: true
priority: normal
created: 2026-05-27T10:11:01+07:00
---

Sub-A of parent #242 — full brief in thread #243.

ONE doc-refresh PR (no new ADR): R1 (BOT-001 AC#2 add ratified 9th fair-router
filter + supersede stale PULLOUT-002 "being ratified" line), B1 (PULLOUT-001/002
mark demand-refill config-gated default-OFF + note dest-LOW refill trigger, opposite
to drain), B2 (DTR-001 add refund carve-out to "never touches a wallet"; DTR-002
enrich with wallet debit/credit-back + refund_pending_review/ResolveRefund — refund
FLOW stays deferred per DEPOSIT-011 §ADR-4d, only fix the capture).

P-004 cite file+commit. Open PR to fork; reply in thread #243 + envelope to for-orchestrator/.
