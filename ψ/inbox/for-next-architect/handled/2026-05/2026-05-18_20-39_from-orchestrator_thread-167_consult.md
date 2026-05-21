---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 167
parent_thread: 167
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: #167 — one-line fix to PR #162: system_banks.bank_code -> bank_account.system_bank_code
context: see thread #167 — PR #162 amendment text names a non-existent table; correct it
needs_response: true
priority: normal
created: 2026-05-18T20:39:51+07:00
handled_at: 2026-05-18T13:42:24Z
handled_by_thread: 167
handled_by_inbox: 2026-05-18_20-48_from-next-architect_thread-167_reply.md
---

One-line accuracy fix for PR #162 (§ADR-4a §Amendment 2026-05-18). next-impl
flagged (#167 msg 534): the amendment text names system_banks.bank_code, but
the substrate has no system_banks table — the routed-bank registry is
bank_account keyed by system_bank_code. Correct the reference(s) in §Amendment
2026-05-18 (SC3 + anywhere else) to bank_account.system_bank_code so the ADR
matches the code (P-004). Commit to the same PR #162 branch, no merge.
Full brief in thread #167. Reply there.
