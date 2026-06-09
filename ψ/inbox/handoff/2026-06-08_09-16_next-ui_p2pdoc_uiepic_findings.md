---
to: orchestrator / next session
from: next-ui (campaign p2pdoc)
priority: P1
topic: epic-p2p-matching-ui.md authored + committed (P2P UI lens, 4th lens) — S3 provisional, owner-GO pending
project: github.com/kxlahsimx09/mb-next-payment-gateway
tags: [next-ui, repo:mb-next-payment-gateway, p2pdoc, p2p-matching, ui, adr-17, s3-provisional, ratification-pending]
---

# next-ui — campaign p2pdoc — UI epic COMPLETE

**Deliverable:** `docs/requirements/epic-p2p-matching-ui.md` (197 lines, ≤250 norm) — 5 UI stories **P2P-UI-001..005**, all **S3 provisional `[RATIFICATION_PENDING:p2pdoc]`**. Committed LAST on `campaign/p2pdoc` (e5a27cd), after architect §ADR-17 (333cdac) + writer epic-p2p-matching (b961632). Serialization architect→writer→ui honored.

## The 5 stories (each maps to backend P2P-00x + §ADR-17)
- P2P-UI-001 Depositor route-select (P2P promo vs QR) — MC4·Q4·Q5
- P2P-UI-002 Manual-transfer instruction + slip upload (destination + exact amount, no QR) — MC5·DEPOSIT-004
- P2P-UI-003 In-window status, timeout/fallback + slip-failure feedback — Q2·Q3
- P2P-UI-004 Withdrawer transparency surface (unchanged, no opt-in) — MC4·CALLBACK-004
- P2P-UI-005 Admin matching dashboard (pool·fairness·failures·fraud flags) — Q1/Q2/Q3/Q5·ADMIN-005

## All 5 POC open-question UI implications covered (charter DONE-WHEN)
fallback-timeout (UI-003/005) · slip-failure (UI-003/005) · fairness display (UI-005) · promo-fraud guardrails (UI-001/005) · big-amount fall-through (UI-001).

## Notes for the ratification gate (task #6)
On owner GO of §ADR-17 (OQ1), flip P2P-UI-001..005 S3→S2 alongside the backend P2P-001..007. OQ5 (EDF-vs-FIFO fairness) feeds P2P-UI-005's fairness display; OQ4 (`p2p_max_amount`) feeds P2P-UI-001 fall-through. No UI surface depends on Finance OQ2 literals (KYC rate-limit values render as data, not hardcoded).

## impeccable skill
Applied as a UX-principles contract (money precision, time-pressure clarity, never-a-dead-end, honest/conditional bonus, accessibility+reduced-motion, data minimisation) baked into a cross-cutting section the stories inherit — NOT a code build (out-of-scope; no frontend repo). Findings file: `next-ui_p2pdoc_findings.md`.
