---
title: Project: mb-next-payment-gateway (next-system requirement stories). Pattern from
tags: [requirements-writing, adr-amendment, money-out, step-up-auth, freeze-semantics, verify-against-head]
created: 2026-05-31
source: next-writer (mb-next-payment-gateway, campaign archamd1, PR #285)
project: github.com/kxlahsimx09/mb_agent_oracle_memory
---

# Project: mb-next-payment-gateway (next-system requirement stories). Pattern from

Project: mb-next-payment-gateway (next-system requirement stories). Pattern from campaign archamd1 / PR #285.

When an ADR amendment ratifies an admin "resolve a `review` holding state" action, the requirement-story shape depends on whether that flow touches a wallet — and getting this wrong is the most common drift.

Three sibling money-out resolution flows, all parked in the canonical `review` holding state (dispatcher/bot-set, NEVER admin-set), but with DIFFERENT money mechanics:
- Settlement confirm-review (SETTLE-002, §ADR-12 §Amendment 2026-05-30 CR1–CR4): wallet-touching. Reserves a §ADR-10 freeze at create; admin resolution does success→settle-out (frozen+balance both drop, money leaves) / reject→release (frozen drops, balance untouched, back to spendable) — the SAME freeze primitive a payout uses.
- Plain Direct-Transfer override (DTR-001, §ADR-12 §Amendment 2026-05-30 DTO1–DTO4): NON-wallet. A plain DT is bank-to-bank operator money and NEVER touches a wallet, so the override is a PURE `review`→{completed,failed} status reconciliation — NO freeze settle/release, NO wallet_change_logs cross-link. Writing freeze/wallet language here is factually wrong (the earlier ADR draft made exactly this error and was rewritten on user correction 2026-05-31). The terminal status IS the whole action.
- Deposit-refund DT subtype (DTR-002/DEPOSIT-011): the ONE wallet-touching DT variant — deferred Phase-2; do not fold its wallet semantics into the plain-DT override.

Invariants shared by both ratified overrides (write as ACs every time): (1) holding state `review` set by dispatcher/bot, never admin — next-system name is `review`, NOT mobiz `waiting_to_review`; (2) CAS-409 guard — applies only if row still `review`, concurrent/repeat rejected 409, no double-resolution; (3) admin-write + §ADR-13 D1/D2 audit; (4) §ADR-2 step-up (AUTH-007) REQUIRED — even the non-wallet DT override requires step-up (option (a), user GO 2026-05-31) because it finalizes the recorded terminal outcome of a real operator bank money-movement.

Separate pattern (DEPOSIT-007 / §ADR-13 §Amendment 2026-05-30 DL3): a requirement story can presuppose a read-surface feature current production does NOT have. DL3 verified GetAllDeposits returns raw rows with NO read-time fraud-preview badge — the six-check cascade runs ONLY at the admin-approve write path. Fix = downgrade the presupposition to "evaluated at write/approve-time only"; do NOT invent the read-time advisory surface to satisfy the old AC (that is a separate unratified provisional). Rule: when an amendment "carves out" a surface as not-prod-backed, the writer downgrades the claim — never fills the gap by inventing the carved-out feature.

---
*Added via Oracle Learn*
