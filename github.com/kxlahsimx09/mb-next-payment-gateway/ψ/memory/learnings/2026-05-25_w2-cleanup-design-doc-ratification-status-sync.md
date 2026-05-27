---
title: W2 cleanup — design-doc ratification status sync (2026-05-25).
tags: [next-product-writer, w2-cleanup, design-docs, ratification-status, adr-4b, adr-4d, adr-14, provisional-marker-cleanup]
created: 2026-05-25
source: W2 cleanup session 2026-05-25, branch cleanup/design-ratification-status-20260525
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W2 cleanup — design-doc ratification status sync (2026-05-25).

W2 cleanup — design-doc ratification status sync (2026-05-25).

When scanning for stale `#provisional` or "Ratifies when thread closes" wording after ADR ratification, split live design status banners and cross-references from historical ADR/revision-log narrative. Design docs that serve as implementation companions should not keep a live top banner implying an open ratification once the parent ADR is `#decision`.

Applied pattern:
- `docs/design/deposit-lane/bot-gateway-contract.md`: thread #76 Source ADR and thread #78 matcher-cascade cross-reference updated to ratified wording.
- `docs/design/deposit-lane/matcher-cascade.md`: top status updated to ratified thread #78; §6 renamed from Open ratification questions to Resolved ratification decisions and kept the same D1-D5 outcomes.
- `docs/design/deposit-lane/slip-fraud-detection.md`: thread #77 Source ADR updated; stale §ADR-4b D2 "deferred to future amendment" cross-reference replaced with ratified matcher-cascade wording.
- `docs/design/fleet-control/README.md`: thread #80 status updated to ratified §ADR-14 decision.
- `docs/design/fleet-control/audit-table.md`: monitoring alert wording updated from "when §ADR-14 ratifies" to "after §ADR-14 ratification plus first operational data" so the remaining deferral is the actual trigger.

Keep changelog history as pre-ratification context, but remove live stale markers and add a W2 status-sync changelog row. No contract/schema/behavior change.

---
*Added via Oracle Learn*
