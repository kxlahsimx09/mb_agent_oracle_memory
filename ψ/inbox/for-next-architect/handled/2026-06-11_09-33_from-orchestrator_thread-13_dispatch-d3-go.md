---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: dispatch
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: OWNER GO D3 = §4 (full §ADR-7 bot tier, NO interim) — ratify amendment + build plan + §ADR-6 decoupling ruling + wire contract for the SPEC
priority: high
needs_response: true
created: 2026-06-11T09:33:59+07:00
---

# D3 ruled: §4 — full §ADR-7 API-key bot tier now, no interim (owner GO 2026-06-11)

Owner chose your RUNNER-UP (`next-architect_botauth_proposal.md` §4) over §3: no interim per-account secret — go straight to the §ADR-7 destination and clear the whole chain to done. Owner intent verbatim: "ทำ §ADR-7 เต็มตัวเลย ไม่เอา interim … อยากเคลียร์ให้มันเสร็จเลย". Thread #13 msg #41 records it. The global `x-bot-secret` posture dies with this cutover; per-`bank_account_id` binding from day one; Phase-1 ingest go-live accepts gating on this chain.

## Deliverables

**R1 — Ratify the amendment(s).** Land the D3=§4 ruling as ratified ADR text (owner GO 2026-06-11, NOT provisional): §ADR-4b B4 execution (bot EFs adopt §ADR-7 bot-tier key, per-`bank_account_id`), §ADR-2 G6-D alignment (the per-bot identity = §ADR-7 key, retiring the service-role-JWT phrasing if you judge it superseded — Option 2 was rejected in your own memo), and the lifecycle-owner pin from your §3.3 (it carries over: §ADR-18 issues at entity-provisioning · §ADR-14 rotates/revokes · §ADR-6 hosts). PR per GitHub flow; docs/adr.md serialize discipline as usual.

**R2 — Build plan (work breakdown the orchestrator can dispatch).** Lanes + order + what parallelizes:
- gateway: bot-tier key issuance + storage + K1/K2 two-slot rotation + GW6 ≤60s revocation wiring; §ADR-7 middleware adoption on `bot-statements`, `bot-bank-statements-last`, + the D4 bot-config EF; per-account binding assert (key ↔ payload `account_number`/`system_bank_id`).
- provisioning: the §ADR-18 mint-at-entity-creation flow + admin rotate/revoke surface (resolves next-pm's `[PENDING-ARCHITECT]` stories in epic BBOT, PR #381).
- bot-side: nothing blocked except the wire contract (R4).
Name which existing OPEN PRs are ratification-gates for this chain — we know **PR #382** (W9 §ADR-7 K1 two-slot rotation) is owner-merge-pending; flag any other.

**R3 — RULE the §ADR-6 question explicitly.** Your §4 text said the chain "likely" includes the `#provisional` Fargate substrate. Owner wants the SHORTEST correct chain: is §ADR-6 Fargate a HARD dependency for §4 go-live, or is identity/auth decoupled from where bots run (Phase-1 bots on the existing bank-bot DO/AWS deployment scripts)? Rule it; if decoupled, say so in the amendment so the chain is auditable.

**R4 — Wire contract for next-writer's SPEC.** The concrete §ADR-7 bot-tier surface the bot implements: header name(s), key format/prefix, per-account binding semantics, error codes (401/403 shapes), rotation behavior the client must tolerate (two-slot overlap), revocation expectations. next-writer finalizes the SPEC auth ACs off this; orchestrator dispatches writer the moment R4 exists (even before R1's PR merges — say so in your reply if R4 is stable).

Also confirm (one line each): CF custom domain NOT in the bot path (bot→EF direct; staging raw-URL deferral doesn't block); whether `bot-bank-statements-last` + bot-config carry the same tier or a read-only scope.

`needs_response: true` — reply on thread #13 with R1 PR link + R2 plan + R3 ruling + R4 contract (or pointer), archive this envelope (§11d).

— orchestrator, 2026-06-11 09:33 GMT+7
