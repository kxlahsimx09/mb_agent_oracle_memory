---
title: DL3 carve-out → RATIFIED (read-time fraud-preview advisory badge), user GO 2026-
tags: [adr, architecture-authority, deposit, fraud-preview, read-only-advisory, next-system-divergence, carve-out-promotion]
created: 2026-05-31
source: next-architect / campaign dl3badge
project: github.com/kokarat/mobiz-payment-gateway
---

# DL3 carve-out → RATIFIED (read-time fraud-preview advisory badge), user GO 2026-

DL3 carve-out → RATIFIED (read-time fraud-preview advisory badge), user GO 2026-05-31 — deliberate next-system divergence from current prod.

CONTEXT: §ADR-13 §Amendment 2026-05-30 (Admin Deposit List/Read Surface, docs/adr.md in mb-next-payment-gateway) originally carved out DL3 (a read-time fraud-preview badge) because current production has NO such badge — the six-check cascade (V2/V13/V14/V3/V1.5/V1) runs ONLY at approve-time (UpdateDepositStatus), never at query time. The amendment named revisit-trigger (b): "DEPOSIT-007 ratifies a read-time advisory badge → promote DL3 from carve-out to a real sub-decision." User fired that trigger 2026-05-31. (campaign dl3badge; PR #286)

DECISION: DL3 promoted to ratified #decision. Admin deposit list/queue endpoint computes, per checking-status row, a READ-ONLY advisory fraud-preview projection running the SAME six-check cascade as approve-time — per-check pass / would_block(+evidence) / skipped. ADVISORY ONLY: no enforcement, no wallet effect; authoritative BLOCK stays at approve-time (Layer 2, reads fresh, WINS on disagreement; preview may be stale).

AUTHORITY PRINCIPLE (reusable): a NEW next-system derived read surface NOT in current prod can still be ratified within ARCHITECT authority (no user money-ratification needed) when it is (1) read-only with NO wallet/money/enforcement effect — the money decision stays unchanged at its existing site — AND (2) reuses an already-ratified algorithm. "No money effect → within authority." This is NOT port-fidelity: it is a deliberate divergence/enhancement beyond current prod and must be flagged as such (DL1/DL2 stayed port-fidelity; DL3 separately ratified on its own reasoning).

EDITING DISCIPLINE: when flipping a rejected trade-off to adopted, NOTE THE FLIP, do not erase the history ("originally rejected … → FLIPPED to ADOPTED per user GO"). Mark the revisit-trigger FIRED. PRESERVE verification findings even after promotion: (i) current prod has no read-time badge; (ii) no sparse-btree index on ts_deposits.custom_bank_account_number — both become impl/data-model-pass concerns (the impl MUST compute the cascade read-side as an advisory projection since prod doesn't). Update all the sub-lines (decision/in-scope/out-of-scope/consequences/trade-offs/revisit/prior-art/resolved+deferred questions/implementation) AND the bottom §revision-log entry, not just the header.

---
*Added via Oracle Learn*
