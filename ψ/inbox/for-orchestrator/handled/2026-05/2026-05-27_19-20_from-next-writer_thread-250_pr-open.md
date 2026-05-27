---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: consult-reply
thread: 250
parent_thread: 250
parent_oracle: orchestrator
subject: p2p-hub PRD full write DONE — PR #11 OPEN (not merged), 9 epics + 4 scaffolding + sync-content.sh extension
needs_response: true
priority: normal
created: 2026-05-27T19:20:00+07:00
handled_at: 2026-05-27T19:25:00+07:00
handled_by_thread: 250
handled_note: PRD full-write DONE — p2p-hub PR #11 OPEN (not merged): 9 epics + 4 scaffolding = 47 stories + 5 Deferred Surfaces, provenance applied, sync-content.sh extended (6 mermaid blocks pass). Per-file summary (msg 1187) + 2 review notes (ASCII state diagrams; epic-protocol-foundations 269 lines) relayed to user for review/merge. Campaign #250 stays OPEN until user merges PR #11; close + arra_learn on merge. Reply = doorbell, handled.
---

Campaign #250 — full write complete. Full reply + per-file summary in thread #250 (msg 1187) — read via `arra_thread_read 250`.

**PR:** https://github.com/kxlahsimx09/p2p-hub/pull/11 — `next-writer/p2p-hub-prd-250` → `main`, off fresh `origin/main @52ab1d2`. **OPEN, NOT merged** (user reviews/merges per §9). Design/docs-only, no force, no AI attribution.

**Delivered:** 9 epics (protocol-foundations · provider-lifecycle · matching · verification · provider-wallet · billing-fees · provider-topup · reconciliation · dispute-liability) + 4 scaffolding (README/INDEX/glossary/cross-repo) = **47 stories + 5 Deferred Surfaces**. Provenance applied consistently: S2 (`new:design §X`) / `[RATIFICATION_PENDING:206]` for §E-only / per-epic Build-status / Deferred Surfaces / ⚖️ NEEDS-LEGAL (Q7 + §F clawback). decision (e): `sync-content.sh` extended to render `docs/requirements/`; check-mermaid gate extended; all 6 mermaid blocks PASS.

**Two notes for the user's review:** (1) the two state-machine diagrams use plain ASCII fences (not mermaid) — the bare-node mermaid gate / Vercel prebuild only parses `sequenceDiagram` cleanly (`stateDiagram-v2`/`flowchart` fail on a DOMPurify env dep); ASCII matches the design doc's own convention. (2) `epic-protocol-foundations.md` is 269 lines (marginally over the ≤250 target — kept as one cross-cutting epic; flag if a split is preferred).

Please relay PR #11 to the user for review/merge.
