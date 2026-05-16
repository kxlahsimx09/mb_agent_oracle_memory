---
title: W1 ratification — thread #103 PAYOUT-001 fee-math naming convention closed via r
tags: [system-architect, repo:mb-next-payment-gateway, next, w1, adr-10, substrate-notation-vs-api-contract-clarification-instance-1-NEW, thread-103-closed-reply-only, writer-misinterprets-substrate-as-api-field-names, payout-001-unblocked, no-adr-change-needed]
created: 2026-05-15
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 ratification — thread #103 PAYOUT-001 fee-math naming convention closed via r

W1 ratification — thread #103 PAYOUT-001 fee-math naming convention closed via reply-only (NO ADR change). Writer's option (a) production-parity API naming ratified by default; AM2 algebra is substrate-internal math notation not API contract.

# NEW pattern surfaced — substrate-notation-vs-API-contract clarification (instance #1 NEW)

Writer escalates an apparent ADR conflict that is actually substrate-notation-vs-API-contract scope confusion.

## Trigger pattern
- Writer reads ADR substrate algebra literally as if internal variables = API field names
- Production API field naming actually opposite of substrate variable naming
- Algebra works under both interpretations (substrate-internal math is invariant to API naming)

## Architect role
- Clarify scope boundary (substrate notation vs API surface)
- Ratify impl-pass authority for API naming choice
- No ADR change needed; design-pass owns API↔substrate mapping

## How this differs from related patterns
- "Writer-flagged unratified surface" (threads #91/92/93/95/98/99/100) — where ADR genuinely missed a decision; #103 doesn't require ADR ratification
- "Production-audit-corrects-writer-framing" (instance #1 NEW at thread #100/§ADR-4b mega) — where production data corrects writer inference; #103 is doc-layer-scope confusion not data discrepancy

## Brew-ops handoff candidate at instance #2

Add to W1 workflow doc the lifecycle reminder: **ADR substrate algebra ≠ API contract; design pass owns the mapping**. Future-architect discipline: when writing ADR mutation semantic pseudo-code (e.g., AM2-style), explicitly note "substrate-internal variable names; API surface naming is impl pass concern."

# Resolution

Thread #103 closed via reply-only — even lighter-touch than thread #101 (which had 1-line ADR §Out of scope addition). No commit to docs/adr.md; no PR; no revision log entry.

Writer-rec (a) production-parity API naming ratified by default:
- `POST /payouts` request: `amount` = gross (Stripe/industry convention)
- Response: `amount` + `payout_fee` + `final_amount` (net)
- 149,019 mobiz production rows already conform
- Merchants migrating from Stripe/Adyen/mobiz all expect this shape

## Impl-pass safeguard (recommended; design-pass scope)

`docs/design/payout/payout-create.md` should document API↔substrate variable mapping explicitly:
- API field `amount` = gross-from-wallet (what leaves wallet)
- Substrate variable `amount` in AM2 = net-to-destination (what arrives)
- Mapping: `substrate.amount = api.amount - api.payout_fee`
- Substrate formula: `frozen += (substrate.amount + substrate.fee) = api.amount` (gross freeze)

Without explicit mapping doc → future impl could read AM2 literally + write `frozen += (api.amount + api.payout_fee)` = over-freeze by fee × every payout (real money correctness bug class).

# Writer handoff

PAYOUT-001 re-author:
- Concrete field names (no longer naming-neutral): `amount` = gross / `payout_fee` / `final_amount` = net
- Strip `[AWAITING_THREAD]` anchor
- Collapse "three options" footnote (resolution = option a)
- Cite §ADR-10 amendment 2026-05-13 + production-parity convention in Sources

# Phase-1 state unchanged

19 ADRs/amendments `#decision`; 0 live `#provisional`; trace chain 37 links (no extension this pass since no ADR change).

# Sources

- thread:#103 (writer fee-math naming convention question)
- §ADR-10 AM2 (ratified 2026-05-13 thread #96 PR #82 — substrate mutation semantic)
- §ADR-10 amendment context: AM3 audit shape + AM4 enum values clearly substrate-level → AM2 same context
- Production verification (writer-cited 2026-05-13): 149,019 ts_payouts rows; 99.998% conform to `final_amount = amount - payout_fee` (gross-amount convention)
- Stripe/Adyen/industry payout API convention (amount = gross side)
- PAYOUT-001 story (current state, naming-neutral ACs): docs/requirements/epic-payout.md

# User dialogue trajectory

- Architect initial response analyzed 3 options + recommended option (a) WITH §ADR-10 AM2 clarifying note inline
- User flagged: *"เหมือนจะเป็นเรื่องเข้าใจผิดลองอ่าน thread อีกที"*
- Architect re-read carefully + recognized AM2 was substrate-internal math notation (not API contract); writer escalated as architect-decision when it's design-pass scope
- Architect proposed revised interpretation: no ADR change; ratify by default; design-pass owns mapping
- User confirmed: *"ใช่ตามนั้นเลย"*

User-pushback-as-design-force pattern instance #36 — user redirected architect from over-engineered "add inline clarifying note" path to clean "no ADR change needed" path. Pattern: when architect's first instinct is to add ADR text to "prevent impl bug," check if the prevention is actually architect-scope OR if it's design-pass / code-review scope. **Architect-discipline lesson:** not every potential impl bug class warrants ADR text; some are appropriately design-pass concerns.

# Commit anchor

None — no commit, no PR, no ADR change. Closure via arra thread reply only.

---
*Added via Oracle Learn*
