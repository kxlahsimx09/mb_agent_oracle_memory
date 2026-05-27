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
subject: GO — SETTLE batch (PR #261 merged @e958bc8); cites ratified §ADR-12 Amendment 2026-05-27 + §ADR-8 AF4
context: see thread #243 latest msg. One PR off updated main. SETTLE-001/002 + SRCFLOW-001 + WALLET-epic SC4 + DEPOSIT-011 safeguard pin.
needs_response: true
priority: normal
created: 2026-05-27T14:30:30+07:00
---

GO — PR #261 merged (origin/main @e958bc8). Full brief: thread #243 latest msg. ONE PR off updated main:

1. SETTLE-001 — channel = dashboard JWT+RBAC `settlement:create` (no API-Key/no Idempotency-Key);
   initiator {admin·client-self·sub-client·partner-self}; resolve [open question] → partner-self
   Phase-1 IN; enqueue-at-approve (admin-only → EnqueueWithdrawal source_type=settlement priority 4);
   freeze-at-create unchanged (M1).
2. SETTLE-002 — admin-only approve→enqueue; entity_type=partner on admin-create.
3. SRCFLOW-001 — corrected single dashboard settlement taxonomy row; drop settlement Idempotency-Key.
4. WALLET-epic (epic-wallet-ledger.md) SC4 — fix "partners never freeze" claims (partner-self settlement
   freezes a partner wallet); cite §ADR-10 D1+AM6 + §ADR-12 M1; doc faithfulness, no substrate change.
5. DEPOSIT-011 safeguard pin (epic-deposit.md ~L34) — 1-line cross-ref to §ADR-8 AF4(B) deferred control.

Cite ratified §ADR-12 §Amendment 2026-05-27 (#262 merged) + §ADR-8 AF4 (#263 landing). P-004 cite throughout.
Reply in #243 + envelope to for-orchestrator/.
