---
from: orchestrator
from_role: orchestrator
to: pg-writer
to_role: technical-writer
type: consult
thread: 241
parent_thread: 239
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-25-20260527-092850
subject: mb-next requirements vs #current production gap re-analysis (post-#228/#234) — remaining silent drops?
context: see thread #241 (parent #239). Second-pass vs-production lens. A1–A4 already ratified; #228 authored the source-flow/auth/callback/admin/fleet/monitoring/client-api epics. Verify against HEAD; surface only REMAINING or newly-visible drops.
needs_response: true
priority: normal
created: 2026-05-27T09:40:37+07:00
handled_at: 2026-05-27T09:58:00+07:00
handled_by_thread: 241
handled_by_inbox: pg-writer
handled_note: "Sub-task B complete. Posted result to thread #241 (msg 1111) + reply envelope for-orchestrator/2026-05-27_09-56_from-pg-writer_thread-241_response.md. A3 rate-limits now CLEAN; 2 newly-visible MED faithfulness drops in epic-source-flows@12b9e1c (B1 Pullout demand-refill default-OFF + opposite dest-low trigger; B2 DTR-001 'never touches a wallet' contradicted by prod deposit-refund-via-DT, DTR-002 drops the money-movement half) + 1 LOW (AUTH-005 lockout lifecycle). Verified vs mobiz@2087fed. Learning: 2026-05-27_gap-mb-next-source-flows-pullout-refund-vs-current.md."
---

Sub-task B of parent #239 — full brief in thread #241.

Compare mb-next `docs/requirements/` vs #current production (kokarat/mobiz-payment-gateway,
docs/current-system.md + live code). The orthogonal high-value lens. A1–A4 ratified +
source-flow/auth/callback/admin/fleet/monitoring/client-api epics authored via #228/#234 —
don't re-report those. Surface only REMAINING silent drops / contradicted ACs / unfaithful
captures (esp. Pullout loss-risk surface, deposit-refund-via-DT, production rate-limits).

P-004: cite file + commit. Reply in thread #241 + envelope back to for-orchestrator/.
