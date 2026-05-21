---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 183
parent_thread: 181
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#183 — Track B: status canonicalization to 'review' across deposit + withdrawal (FA2-shape rename)"
context: "see thread #183 — Track B under parent #181; queued behind Cycle 1 marker-flip on #182"
needs_response: true
priority: normal
created: 2026-05-20T20:18:38+07:00
handled_at: 2026-05-20T20:24:47+07:00
handled_by_thread: 183
handled_by_inbox: for-orchestrator/2026-05-20_20-24_from-next-architect_thread-183_reply.md
handled_note: "Track B received + queued behind #182 marker-flip (architect-serial constraint); no drafting this turn. Substrate fact-check surfaced 3 scope corrections: withdrawal-lane is NULL (already canonical at substrate + ADR level via thread #123 + #132); ts_deposits.status correct as stated; NEW drift on bank_statements.match_status (matcher writes 'review_required', contradicts §FA2). Refined scope + shape options + 3 confirm-questions sent on thread #183 msg 695."
---

# orchestrator → next-architect (consult on thread #183, parent #181)

User redirected Track B from "V15-2 drift fix" to **single canonical `'review'` across deposit + withdrawal lanes**. Quote: "ผมอยากให้มันมี Status เดียวคือ review นะ ทั้ง deposit withdrawl".

**Ask:** draft bundled canonicalization amendment using §ADR-4b §FA2 (ratified) as the precedent shape. Two fields to rename:
1. `ts_deposits.status` CHECK literal `'review_required'` → `'review'` (allowed-but-unused state; rename-free)
2. `withdraw_queue.status` literal `'waiting_to_review'` → `'review'` (active state; data migration + RPC literal updates needed — flagged for next-impl handoff post-ratify)

**Byproduct:** V15-2 predicate drift resolves automatically — once deposit.status canonical is `'review'`, predicate becomes `IN ('paid','pending','checking','review')` (no more substrate-translation hack).

**Queueing:** wait for #182 marker-flip PR to land first (architect-serial per your constraint). Track B work begins after that.

Detail + full schema fact-check + scope-confirm + FA2-precedent citation lives on thread #183.
