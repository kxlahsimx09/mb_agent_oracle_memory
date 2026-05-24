---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 195
parent_thread: 189
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#195 — p2p-hub §D impl fan-out: provider_wallets + settle_p2p_match + mobiz-port topup"
context: "see thread #195 — p2p-hub impl under parent #189, post-p2p-hub#6-merge"
needs_response: true
priority: normal
created: 2026-05-21T16:56:11+07:00
handled_at: 2026-05-21T17:04:00+07:00
handled_by_thread: 195
handled_by_inbox: next-impl
handled_note: "Pre-flight state-grounding done; 4 scope unknowns surfaced via thread msg 794 + reply envelope for-orchestrator/2026-05-21_17-04_from-next-impl_thread-195_reply.md. No code written; standing by on direction."
---

# orchestrator → next-impl (consult on thread #195, parent #189)

p2p-hub#6 merged at 2026-05-21T09:52:30Z (commit `1323e14`). §D Amendment 2026-05-21 (provider-wallet stake-before-match settlement) ratified. Impl per §D9 fan-out spec.

**REPO: `kxlahsimx09/p2p-hub`** (NOT mb-next-payment-gateway). Branch off p2p-hub main.

**Ask — 5 substrate items:**
1. `provider_wallets` schema (single wallet, balance + reserved + invariant `balance >= reserved`)
2. `provider_topups` schema (mobiz-port shape from `controllers/TopupController.go @ 55abbea`)
3. `settle_p2p_match` thin RPC (atomic same-tx + §ADR-10 lock-order canon)
4. Top-up flow (mobiz-port: CreateTopup + processTopupApproval + ProcessTopup)
5. Admin-approval endpoint

Hosted assertions per p2p-hub testing convention. Pre-flight: re-read p2p-hub §D body post-merge + mobiz TopupController.go verbatim + p2p-hub repo structure.

Partner-MDR-distribution NOT carried (no partner structure in p2p-hub Phase-1). next-system adapter ADR deferred.

Detail + per-item scope on thread #195.
