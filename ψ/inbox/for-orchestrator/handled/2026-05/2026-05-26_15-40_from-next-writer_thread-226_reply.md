---
from: next-writer
from_role: next-product-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 226
parent_thread: 225
parent_oracle: orchestrator
subject: Sub-task A DONE — completeness review of docs/requirements/; 6 missing ratified-ADR surfaces (3 NEW vs W1) + README index stale; authored epics internally clean
needs_response: false
priority: normal
created: 2026-05-26T15:40:00+07:00
handled_at: 2026-05-26T15:17:00+07:00
handled_by_thread: 226
handled_note: Consumed into campaign #225 mid-stream (parent msg 1016). needs_response was false (report deliverable) — no reply envelope required. Aggregate deferred until sub-B (pg-writer #227) lands.
---

Full findings on **thread #226 msg 1015** (reply posted). Review-only pass — no files edited.

**TL;DR — what else the requirements need, prioritized + source-verified (file+§ per P-004):**

**P0 (ratified ADR, large, listed `_planned_`):**
1. **Source-Flow trio — Settlement / Pullout / Direct Transfer** (§ADR-12, adr.md:2425). 5-row taxonomy + 4 decisions, zero coverage; prod evidence settlements ~2,877 / direct_transfers ~589 / pullout_tasks ~155. Recommend one `epic-source-flows.md` (the filename your task referenced — doesn't exist yet).
2. **Auth & RBAC** (§ADR-2 + G1-G6 + §ADR-7 + §ADR-13 F1/F3/F4). Login/2FA, RLS isolation, flat-namespace RBAC + 33-resource catalog, tenant scope, API-Key+HMAC. users 685 / login_logs 36,832 / otp_logs 39,568.

**P1 (ratified ADR, NOT EVEN in README index — the deeper finds, 3 are NEW vs W1):**
3. **Callback Delivery core** (§ADR-9) — NEW. Only manual-resend exists (DEPOSIT-012/PAYOUT-007); the client-integrator contract (wire signature WC1-11, at-least-once + event_id, retry/dead-letter, callback_attempts, preconfigured-endpoint safety thread #223) has no story.
4. **Admin-API + Audit substrate** (§ADR-13) — NEW. 3-layer write invariant + canonical audit_log + RBAC resource-split + created_by triple; referenced piecemeal, no owning epic.
5. **Fleet-Control** (§ADR-14) — only in cross-repo.md:57.
6. **Monitoring/Alerting** (§ADR-15) — 32-alert catalog w/ product-meaningful SLOs; SRE-facing (maybe lighter treatment).

**P2 (under-surfaced contracts):**
7. **Idempotency** (§ADR-11) — NEW; fold a story into the Auth/Client-API epic.
8. **OTP & Trust** (README `_planned_`) — recommend folding into Auth & RBAC (it's mostly §ADR-2 G1-D TOTP; bank-OTP is bankbot-v2).

**P3 (where NOT to churn):** authored epics (deposit/payout/match/bot/topup/wallet) are internally complete — terminal taxonomy fully specified, 0 live AWAITING/RATIFICATION anchors, open-questions are ADR-scoped deferrals. README epic index (README.md:54-67) is **stale** vs ratified surface — add discoverability rows for #3/#4/#5/#6/#7. glossary needs new terms when epics land. §ADR-6 bot-infra = bankbot-v2, not a gateway gap. Do NOT revive PAYOUT-006 `rejected` (withdrawn thread #120).

**Depth vs W1 2026-05-25:** W1 listed 6 missing-epic candidates (settlement/pullout/direct-transfer/auth/fleet/monitoring). This pass adds **3 W1 missed** (Callback-core §ADR-9, Admin/Audit §ADR-13, Idempotency §ADR-11), notes the **README index is itself incomplete**, and **confirms the authored epics are clean** (so the add-work is all net-new epics, not rework).

needs_response=false — deliverable is the report for you to aggregate into campaign #225. Ready to run W1 on whichever surface(s) the user picks.
