---
title: epic authored — fleet-control — 4 stories, all S2.
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, epic, fleet-control, s2-ratified, campaign-228, thread-230, repo:cross]
created: 2026-05-26
source: docs/requirements/epic-fleet-control.md@writer/fleet-control-adr14
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# epic authored — fleet-control — 4 stories, all S2.

epic authored — fleet-control — 4 stories, all S2.

Subsystem: fleet-control (operator command channel to the bank-bot fleet)
Net-new epic from campaign #228 / sub-thread #230 (P1, sequential pass 2 — authored off latest merged main after #249 merged). Translates §ADR-14 (Fleet-Control Substrate, #decision thread #80) into human-readable operator-facing stories.

Stories (all S2):
- FLEET-001 hybrid substrate (D1): state-change commands ride durable config-poll (~30s), urgent events broadcast on bot:<bank_account_id> channel (~seconds). Reuses §ADR-1/§ADR-5 substrate; no new infra.
- FLEET-002 Phase-1 4-command catalogue (D2): F1 maintenance-override + F2 force-refresh-config (poll) / F3 reboot-session + F4 halt-pool (broadcast); F5 force-logout deferred Phase-2 (needs §ADR-7 session-token revocation); Phase-1 substitute = revoke API key + container restart.
- FLEET-003 RBAC + audit (D3/D4): fleet-control:{maintenance,config,reboot,emergency} per-command-class least-privilege (resource-split per §ADR-13 D3); bot channel subscription auth (each bot own channel only); fleet_command_log append-only 2-row-per-command (issue+ack paired by command_id), no UPDATE/DELETE — append-only forensic pattern instance #4.
- FLEET-004 failure-safety (D5/D6): emergency-only config-flag fallback (halt-pool double-write, ~30s if broadcast down; NO fallback for reboot to avoid restart loop); bot-side command_id dedup (5-min TTL); reconnect catchup (unacked commands in window); restart-aware catchup (reboot issued < PROCESS_START_TIME → no_op_post_restart, avoids redundant reboot of freshly-restarted bot — user-flagged E6 concern).

CROSS-REPO: gateway issues + audits; bankbot v2 executes (bot-side execution = browser-session recycle, work-intake freeze). cross-repo.md already documents the fleet-control surface (§ADR-14 line). Stories framed operator-facing; cross-repo column = gateway + bot for FLEET-001/002/004, gateway-only for FLEET-003 (audit/RBAC are gateway-side).

Files: docs/requirements/epic-fleet-control.md (new) + glossary.md (+fleet command) + INDEX.md (+Fleet-Control section) + README.md (+row after Admin-API & Audit). Mermaid 1/1 PASS; MDX clean.

PROCESS: branched off latest merged main (001331b, has #249) per sequential cadence — clean, no conflict. PR opened; pausing for merge before Monitoring §ADR-15.

---
*Added via Oracle Learn*
