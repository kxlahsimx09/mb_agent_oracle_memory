---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: dispatch
thread: 148
parent_thread: 148
parent_oracle: orchestrator
subject: p2p-hub — new project: design-exploration doc, Phase A (concept) + Phase B (edge cases), checkpoint before protocol
priority: normal
needs_response: true
created: 2026-05-17T12:48:23+07:00
---

# p2p-hub — start the design-exploration document

A new greenfield project, ratified with the user. Full concept on thread #148.

## The concept

**p2p-hub** is a new system, **separate from `current` (mobiz) and `next` (mb-next)**. Its job: find **deposit-side liquidity** and match it against **payout-side liquidity**. Any payment-gateway-like system can **opt in** as a liquidity provider — deposit side, payout side, or both. Every successful matched transaction is charged a hub fee; billing is **prepaid credit** — credit exhausted ⇒ the provider can no longer transact. The opt-in protocol must be **clear and very robust**.

## Start from the prior art

Before anything: `arra_search` for the prior feasibility PoC — query "p2p withdraw deposit matching", learning `2026-05-09_poc-feasibility-p2p-withdrawdeposit-matching-p` (source `poc/p2p-matching/` in mb-next, PR #41). Read that learning and the poc directory. It already proved Phase-1 **1:1 matching** is feasible against current production data — so **feasibility is settled; this dispatch is the system design, not a re-run.**

## Deliverable — phased design-exploration doc

New repo **`p2p-hub`**, doc under `docs/design/`. For the repo: `git init` locally and lay out the structure; **do not create a GitHub remote yet** — the owner/org for the remote is an open question, flag it on the thread for the user.

- **Phase A — concept + grounding.** Restate what the prior PoC proved; define the p2p-hub system: its role, the opt-in liquidity-provider model (deposit / payout / both), the prepaid-credit fee model, how it sits beside current/next.
- **Phase B — edge-case & failure-mode catalogue.** The part the user most wants. Be exhaustive: liquidity matched but the underlying deposit fails; double-matching; provider credit exhausted mid-transaction; opt-in / opt-out races; settlement-timing mismatch across two independent gateways; cross-system reconciliation; provider disagreement / dispute; fraud surface; partial fills; etc.

**Stop after Phase B and post for the user's review on thread #148 — checkpoint before Phase C.** Do **not** draft the opt-in protocol (Phase C) yet: a robust protocol must be built from a complete edge-case catalogue, and the user wants to review B first.

`needs_response: true` — reply on thread #148 with Phase A + B and the repo-remote question, then archive this envelope (§11d).

— orchestrator, 2026-05-17 12:48 GMT+7
