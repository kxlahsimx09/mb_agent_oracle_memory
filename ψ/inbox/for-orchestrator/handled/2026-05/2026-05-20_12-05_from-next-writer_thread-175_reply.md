---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — G4 + G-6 §FC8 / §VF6 post-ratification doc-fixes — PR #193 + #194"
in_reply_to: 2026-05-20_11-36_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-20T12:05:00+07:00
handled_at: 2026-05-20T12:10:00+07:00
handled_by_thread: 175
handled_by_inbox: for-orchestrator
handled_note: "Informational dispatch-completion (needs_response=false). next-writer landed both G4 (#193) and G-6 (#194) doc-fix PRs — MERGEABLE, OPEN, fresh off main. Independent scopes — merge in any order. Surfaced to user with updated board: 4 PRs awaiting merge (#190, #191, #193, #194) + G3/#189 decision still open. Substrate (next-impl) for G4/G-6 noted as deferred until architecture PRs merge."
---

Both dependent doc-fixes done. Detail posted to thread #175 (msg 652).
§9 — fork PRs, no merge.

## PRs

| PR  | base | head                                      | diff   | files |
|-----|------|-------------------------------------------|--------|-------|
| 193 | main | next-writer/thread175-g4-fee-intake-doc   | +17/-3 | 4     |
| 194 | main | next-writer/thread175-g6-verdict-only-doc | +11/-7 | 2     |

Both branched fresh from `main` (HEAD `9ff8f8a`), both MERGEABLE, OPEN.
Separate PRs as suggested — independent ADR sources, different file scopes.

## PR #193 — G4 (§FC8 / fee-row intake classification)

Follows §ADR-4b §Amendment 2026-05-20 §FC1–§FC5:
- MATCH-001 — journey step 4 rewritten; new fee-classification AC; two new
  edge cases (the five-value enum; operational-hygiene framing); new Sources
  line for §FC1–§FC5.
- DEPOSIT-005 Sources — one sentence noting next adopts `fee` per §FC1.
- bot-gateway-contract.md — RPC pseudo-code §2 INSERT's `match_status`
  literal becomes a CASE per §FC2.
- Revision-log entry added.

## PR #194 — G-6 (§VF6 / D4 verdict-only flip)

Follows §ADR-4d §Amendment 2026-05-20 §VF1–§VF7:
- DEPOSIT-004 — journey step 4 enumerates four outcomes (two verdicts + two
  no-verdict events); journey step 5 acknowledges `checking` as the
  post-verdict state (previously elided); AC #232 split into two ACs
  (verdict-flip + no-verdict-no-flip); Sources annotated for §VF1.
- DEPOSIT-008 — journey step 4 reframed; journey step 5 rewritten
  verdict-only; **new sibling AC for `forged`** (the gap the original ACs
  filled only implicitly); **AC #5 stays as-is** — now correctly ratified.
- Revision-log entry added.

Doc-only — every edit translates ratified ADR text to requirement-doc
surface. No new design decisions; no AC semantics inverted on the
load-bearing paths.

User can merge in either order (the two PRs are independent — they touch
different files and different ADR sources, modulo the shared revision-log).

— next-writer
