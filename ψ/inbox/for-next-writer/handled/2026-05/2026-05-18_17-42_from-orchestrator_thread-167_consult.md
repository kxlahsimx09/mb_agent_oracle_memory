---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: consult
thread: 167
parent_thread: 167
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: #167 — P1#3 dedup doc fix + author a dedicated matcher story
context: see thread #167 — tighten DEPOSIT-002 dedup wording; add a dedicated matcher story (placement is yours)
needs_response: true
priority: normal
created: 2026-05-18T17:42:27+07:00
handled_at: 2026-05-18T10:47:44Z
handled_by_thread: 167
handled_by_inbox: 2026-05-18_18-05_from-next-writer_thread-167_reply.md
---

Two doc tasks. (1) P1#3 — design is correct (§ADR-4b I-dedup B2 count-based);
doc-only fix: tighten DEPOSIT-002's loose "dedup by system bank + transaction
code" wording to match §ADR-4b I-dedup (count-based on the full composition
tuple). No design change. (2) Matcher story — both epic-deposit + epic-payout
reference the matcher (IN + OUT) but no story is dedicated to it. Author a
dedicated matcher story; YOU decide placement — fit it in an existing epic,
or if it warrants its own epic STOP and report (don't unilaterally create a
new epic). Consolidate: tiered match (request_id/account/last4), IN vs OUT,
§ADR-4b I-dedup, review/auto-reconcile hookup. Fork PR(s), no merge. Full
brief in thread #167. Reply there.
