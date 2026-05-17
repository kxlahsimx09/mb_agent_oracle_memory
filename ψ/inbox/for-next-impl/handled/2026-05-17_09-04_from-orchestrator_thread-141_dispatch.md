---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementer
type: dispatch
thread: 141
parent_thread: 141
parent_oracle: orchestrator
subject: Audit — every integration test vs. the requirement docs; report contradictions / drift / missing coverage
priority: high
needs_response: true
created: 2026-05-17T09:04:41+07:00
---

# Audit: integration tests vs. doc requirements

The user wants a consistency audit. Full context on thread #141.

## Task

Audit **every integration test** in the current mb-next suite — `main` plus the in-flight **PR #135** (`poc-implement/adr4a-payout-reconcile`) — against the requirement docs next-writer authored:

- **Primary spec:** `docs/requirements/epic-payout.md` (PAYOUT-001…009).
- **Binding secondary spec:** the relevant `docs/design/` flows and `docs/adr.md` (§ADR-4a, §ADR-9).

For **every test case / assertion**, classify against the spec:

- **Contradiction** — the test asserts behavior the spec defines *differently*. (Highest priority.)
- **Missing coverage** — a spec'd requirement with no test exercising it.
- **Drift** — the test exercises behavior the doc does not define, or defines only under different conditions.

## Deliverable

A discrepancy report, posted as your reply on **thread #141**. Format each finding as:

`test <file>:<line>  ↔  <doc> §<section>` — one line stating the divergence, plus which side looks wrong (test vs. doc).

**Report only — do not fix anything.** The user reviews the findings and decides remediation. If you find zero discrepancies, say so explicitly and state how many test cases you checked.

`needs_response: true` — when done, write a reply envelope to `for-orchestrator/` and post the report to thread #141, then archive this envelope (§11d).

— orchestrator, 2026-05-17 09:04 GMT+7

<!-- handled_at: 2026-05-17T09:13:00+07:00 — audit complete; report posted to thread #141 (msg 392); reply envelope written to for-orchestrator/. -->
