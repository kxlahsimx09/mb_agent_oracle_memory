---
title: W1 baseline pass — §ADR-14 Fleet-Control Substrate (Hybrid: config-poll + Realti
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-14, fleet-control, hybrid-substrate, config-poll, realtime-broadcast, fleet-command-log, append-only-forensic-pattern-instance-4-durable-rule-confirmed, front-load-design-dir-baseline-pattern-instance-2, thread-45-closed-bridge, thread-80-opened, user-pushback-instance-25, user-wholesale-delegation, 12-ADRs-architecture-decision-phase-substantially-complete, phase-1-implementation-kickoff-unblocked, baseline, pass-1, provisional, ratification-pending, decision]
created: 2026-05-06
source: docs/adr.md@4c9fb38 §ADR-14 + docs/design/fleet-control/{README,broadcast-channel,command-catalog,audit-table}.md@4c9fb38; thread:#80 + thread:#45 (closed); evidence bundle in §Revision log
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 baseline pass — §ADR-14 Fleet-Control Substrate (Hybrid: config-poll + Realti

W1 baseline pass — §ADR-14 Fleet-Control Substrate (Hybrid: config-poll + Realtime broadcast) → 4 Phase-1 commands → `fleet_command_log` append-only audit (`#provisional`, thread #80 opened; thread #45 closed bridge).

Closes 12-day-old §ADR-8 deferral. Thread #45 opened 2026-04-24 with 4-option survey (defer-or-decide); user direction 2026-05-06 *"จัดการ §ADR-14 fleet-control ต่อเลย"* + *"ทำต่อเลยครับ adr 14"* → "decide now" path; substrate choice + Phase-1 command scope + audit table all ratified at architect-recommendation level pre-baseline; full ratification surface opened at thread #80.

Hybrid substrate matches semantic to path:
- State-change commands (F1 maintenance-override, F2 force-refresh-config) → config-poll path: admin EF UPDATE `bot_config` table; bot's existing 30s `pollLoop` reads diff + applies. Parity with mobiz current `app.js:1939-1949`. Latency ≤30s.
- Imperative commands (F3 reboot session, F4 halt-pool emergency) → Realtime broadcast path: admin EF `supabase.channel('bot:'||bank_account_id).send({...})` → bot's broadcast handler receives + applies + acks. Leverages §ADR-5 Realtime substrate. Latency ~100-300ms.
- F4 halt-pool emergency double-writes to `bot_config.halt_pool_until` config flag for Realtime-down protection.

F5 force-logout deferred Phase-2 — requires §ADR-7 amendment for session-token revocation primitive. Phase-1 substitute: admin revoke API key + container restart (operationally adequate for rare compromise).

Audit primitive: `fleet_command_log` append-only Postgres table. 2-row-per-command pattern (trigger + ack paired by command_id UUIDv4). No UPDATE/DELETE per P-001 (BEFORE UPDATE/DELETE triggers RAISE EXCEPTION). Pattern instance #4 of "append-only forensic table" after `audit_log` (§ADR-13 D2) / `callback_attempts` (§ADR-9 D6) / `slip_verify_attempts` (§ADR-4d D9). **At instance #4 the pattern is durable architectural rule confirmed** (W1 §Port-from-mobiz protocol rule 2 — 3-instance threshold = durable; this is instance #4 — promotion already happened at instance #3, this confirms continuing-durability).

Idempotency: bot-side dedup via command_id (UUIDv4) + in-memory Map TTL 5min. Realtime broadcast at-least-once → reconnect replay class; admin double-click also fires twice. 5-min window matches Realtime reconnect catchup query bound. Re-receive same command_id within window → log + skip apply (no duplicate ack written either).

Failure-mode fallback per command class:
- F4 halt-pool: double-write to `bot_config.halt_pool_until` flag → bot pollLoop applies via fallback path. Latency 30s but command DELIVERED.
- F3 reboot: no fallback (config flag for reboot creates restart-loop class; operator SSH path documented).
- F1/F2: already config-poll path; not affected by Realtime down.
- Bot reconnect catchup: on Realtime re-subscribe, bot queries `fleet_command_log` for unacked trigger rows targeting itself within last 5 min → applies + acks.

6 ratification sub-questions in thread #80 (E1-E6):
- E1 substrate split (hybrid: config-poll + Realtime broadcast); rec: yes; alternatives A-D (poll-only / EF-long-poll / don't-build / all-broadcast) all evaluated + rejected with rationale
- E2 Phase-1 command catalog (F1/F2/F3/F4; defer F5); rec: 4 commands as specified
- E3 auth model (admin JWT + RBAC fleet-control:* per command class per §ADR-13 D3 resource-split discipline)
- E4 audit table (`fleet_command_log` 2-row-per-command append-only, pattern instance #4)
- E5 idempotency primitive (bot-side dedup via command_id UUIDv4, in-memory TTL 5min)
- E6 failure-mode fallback (config-flag double-write for emergency only; bot reconnect catchup)

Patterns surfaced this pass:
1. **Append-only forensic table — instance #4** (durable architectural rule). `fleet_command_log` joins existing pattern. **Brew-ops handoff candidate** for W1 workflow doc rule list addition: "every state-mutation surface accepting external triggers gets append-only forensic per P-001."
2. **Front-load design-dir at baseline — instance #2** (after §ADR-15 baseline 2026-05-06 09:09 GMT+7). When substrate choice + scope + spec all crisp at baseline time, co-author design dir alongside ADR body. Saves pass-3 extraction cycle. Pattern continues durable.
3. **User wholesale-delegation when pre-baseline framing solid** — user-pushback-as-design-force instance #25 with 0 redirects this pass. Compare §ADR-15 baseline (Keep tool surfaced by user) and §ADR-15 ratify (D6 historical-incident sweep direction). When pre-baseline framing is solid (4 options matrix + recommendation rationale + cost projection + alternatives explicitly rejected), user can ratify wholesale without intermediate dialogue.
4. **Closes longest-open thread in repo** — thread #45 (12 days). Bridge-message pattern (#45 → #80) preserves narrative continuity per W1 thread-resolve protocol.

User-pushback-as-design-force instance count: 24 → 25. Pre-Input-5 instance count: 17 → 17 (no new code-read this pass).

Architecture-decision phase post-pass:
- 12 ADRs `#decision` (§ADR-1 through §ADR-13 + §ADR-4b/4d amendments + §ADR-4b D2 amendment + §ADR-15) + 1 live `#provisional` (§ADR-14, this pass)
- After thread #80 ratifies: 13 ADRs `#decision`; 0 live `#provisional` (return to clean state)
- **Last named architectural gap closed** — post-§ADR-14 ratification, all named §ADR-* placeholders are filled. Remaining work is Phase-2 amendments (force-logout / OpenTelemetry / etc.) + future-ADR placeholders triggered by Phase-1+ operational data.
- **Architecture-decision phase substantially complete on Phase-1 surface.**
- **Phase-1 implementation kickoff unblocked** — once PR #17 + PR #18 + PR #19 merge to main, `next-dev` developer agent activation per thread #66 unified proposal has full architectural surface available. Architect transitions from "baseline" mode to "review + amendment" mode.

Threads opened: #80. Threads closed: #45 (12-day deferral resolved bridge). Commit: `4c9fb38`. PR: #19 (stacked on PR #18 branch).

Next pass candidate: §ADR-14 ratification pass 2 when user ratifies thread #80 — all 6 sub-questions have architect rec; expect single-straight-ratify per §ADR-14 baseline scope clarity (matches §ADR-10 / §ADR-11 single-straight-ratify pattern).

---
*Added via Oracle Learn*
