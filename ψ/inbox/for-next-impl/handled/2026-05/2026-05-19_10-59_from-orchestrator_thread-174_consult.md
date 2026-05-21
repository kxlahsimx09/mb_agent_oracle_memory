---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 174
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: refresh integration-layer coverage-gap map vs requirement docs (continue #158/#168)
context: see thread #174 — report-only audit round, no build; user picks close-scope next round
needs_response: true
priority: normal
created: 2026-05-19T10:59:47+07:00
---
handled_at: 2026-05-19T11:06:00+07:00
handled_by_thread: 174
handled_by_inbox: 2026-05-19_11-06_from-next-impl_thread-174_reply.md

Refresh the integration-layer coverage-gap map. Continues the #158 → #168
coverage-gap line. **Report-only — no build this round.**

Full brief on thread #174. In short: re-map `poc/integration/src` against the
requirement docs, classify each story/AC (✅ tested / 🟡 partial / 🔴 absent /
⚪ out-of-scope), distinguish probe vs substrate-port (the #168 G9 lesson), and
severity-rank. Fold in the three known #168 carry-forwards (audit_log port,
admin endpoints, two flaky probes) rather than re-discovering them. Verify
against the hosted/integrated substrate, not the floor PoCs.

Reply on thread #174 — `parent_session` routes it back to the orchestrator.
