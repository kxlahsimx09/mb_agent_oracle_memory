---
title: orchestrator dispatch — #225 mb-next requirement review: two-lens fan-out (inter
tags: [orchestrator, decision-authority, fan-out, accepted, requirement-doc, gap-review, two-lens, internal-completeness, current-production-lens, cross-role-cross-check, next-writer, pg-writer, thread-225, repo:arra-oracle-v3, fleet, mb-next-payment-gateway]
created: 2026-05-26
source: parent thread #225 — mb-next requirement review + cross-system gap-analysis campaign (msgs 1012-1018), 2026-05-26
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator dispatch — #225 mb-next requirement review: two-lens fan-out (inter

orchestrator dispatch — #225 mb-next requirement review: two-lens fan-out (internal-completeness × current-production) is the high-value shape.

User (acting as orchestrator) requested a parallel review of mb-next product requirements. Fanned out (§11k) to next-writer (#226, internal-completeness lens) + pg-writer (#227, #current-production lens). Both replied review-only, aggregated + closed at parent #225.

DECISION-AUTHORITY: user explicitly requested the fan-out by name → HIGH authority. Shape matches accepted precedents #157/#166/#167/#168 (cross-role requirement-doc gap-review). Auto-dispatch was correct; only escalation was confirming the target oracle (see routing note).

KEY METHODOLOGICAL INSIGHT (worth reusing): an internal-completeness pass and a vs-production pass are ORTHOGONAL, not redundant. next-writer correctly found the authored Phase-1 epics internally clean (terminal taxonomies complete, 0 live AWAITING anchors) and surfaced missing NET-NEW epics (Source-Flow trio §ADR-12, Auth&RBAC, Callback-core §ADR-9, Admin/Audit §ADR-13, Fleet §ADR-14, Monitoring §ADR-15, Idempotency §ADR-11). But an internal pass STRUCTURALLY CANNOT see where an "internally clean" epic silently drops a current production behavior — that was pg-writer's unique Bucket A: 4 in-epic gaps with no recorded decision (A1 per-bank maintenance-cancel HIGH, A2 fair-router amount-range filter, A3 per-client rate-limit, A4 slip-expire OPPOSITE outcome). => When the question is "what's missing from a rewrite's requirements", always pair the internal-completeness lens with a vs-running-system lens; the second catches the silent-drops the first cannot.

ROUTING NOTE: user typed "pr-writer" — no such oracle. Meant pg-writer (technical-writer, #current mobiz). Confirmed before waking. "pr/pg" is a likely-recurring one-key typo.

Follow-on (NOT yet dispatched — belongs to a new campaign if user picks it up): author chosen surfaces via W1 (both writers standing by); ratify the 2 divergences A1 + A4. These are user/next-architect decisions — orchestrator relays, does not decide (Principle 2a).

---
*Added via Oracle Learn*
