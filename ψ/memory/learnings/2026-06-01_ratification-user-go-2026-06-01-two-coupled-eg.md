---
title: RATIFICATION (user GO 2026-06-01) — two coupled egress/clock decisions for campa
tags: [system-architect, next-architect, nextteam, adr-20, adr-9, ratified, decision, user-go, virtual-clock, real-substrate, egress, ecs-fargate, nat-gateway, elastic-ip, env-topology, mb-next-payment-gateway]
created: 2026-06-01
source: docs/adr.md §ADR-20 (PR #293) + §ADR-9 §Amendment EG8-EG10 (PR #298); campaign nextteam; user GO 2026-06-01
project: github.com/soul-brews-studio/arra-oracle-v3
---

# RATIFICATION (user GO 2026-06-01) — two coupled egress/clock decisions for campa

RATIFICATION (user GO 2026-06-01) — two coupled egress/clock decisions for campaign nextteam, by next-architect. Filed under arra-oracle-v3 (mb-next slug still unregistered, brew-ops gotcha #2).

GATE 1 — §ADR-20 (Virtual-Clock + Real-Substrate Env Topology) RATIFIED `#decision` (user GO 2026-06-01). PR #293 (branch campaign/nextteam, commit 973aaf1), NOT merged (§9). All 13 sub-decisions (T1–T7 + E1–E6) + O1–O6 ratified per the architect recommendation, NO overrides, mirroring the §ADR-18 user-GO convention. LOCKED defaults:
- O1: DB-resident app_now() = single source of truth (DB-as-clock). Perf negligible (real-mode short-circuits to now(); money RPCs receive p_now so per-RPC clock reads = 0; next-tester A/B confirms).
- O2: default probe mode = frozen-step (deterministic); scaled reserved for soak.
- O3 (the one open CHOICE, locked at ratification, owner-amendable): the T6 not-compressible list is COMPLETE+LOCKED (CF rate-limit/KV, pg_cron cadence, EF cold-start, callback 5-min replay, external-mock timers). Real-1x cadence = (i) MANDATORY/gating before each epic-seal on test/perf + the investigator seal stack (V3 two-tier), PLUS (ii) RECOMMENDED nightly (non-gating) regression backstop on test/perf.
- O4: T7 discipline-only (next-code-reviewer clean/perf-smell dimension + grep recipe; NO blocking CI hook).
- O5: per-stack "EC2 gateway" = the §ADR-9 EG2 callback egress proxy (not the bank-bot host; test bank edge = mock-bank; §ADR-6 Hetzner = production browser host, not in test).
- O6: egress = shared/on-demand/direct-egress-default; seal stack SHARES the one proxy (stateless hop → E5-safe); lifecycle = egress up/down (ecs run-task/stop-task) + auto-stop-on-idle backstop; compute = on-demand containerized ECS task on Fargate, ephemeral public IP, NO NAT, NO EIP, ≈$0 idle.

GATE 2 — §ADR-9 §Amendment (production egress compute) AUTHORED + RATIFIED `#decision` (user GO 2026-06-01). PR #298 (branch arch/adr9-prod-egress-fargate, commit 2f3e20f, off main), NOT merged. EG8–EG10:
- EG8: production egress compute = always-on containerized ECS task on Fargate (supersedes EG2's EC2-VM compute; EG1/EG3/EG4/EG5/EG6 stand). One container/CI/deploy model shared with the nextteam test proxy; no VM to patch.
- EG9: stable whitelistable IP via NAT Gateway + Elastic IP (Fargate in a private subnet) — EG7's managed-NAT direction realized with Fargate; same-EIP carry-forward = zero merchant re-allowlist. Phase-1 default = single NAT GW = one whitelisted IP (single-AZ); EG5 retry substrate absorbs an AZ-failover gap (delayed-never-lost).
- EG10: HA escalation = dual-AZ/dual-EIP only on SLA demand (no clean single-IP multi-AZ NAT-GW pattern; self-managed-NAT-instance EIP-remap rejected — re-adds VM ops).
- PRODUCTION-ONLY: does NOT change the §ADR-20 E6 test-stack no-NAT model. Delivery contract (WC1-WC11), endpoint safety (CU1-CU8), redirect posture (RF1), egress-identity (EG1) all unchanged.

KEY DISTINCTION (durable): the stable-whitelistable-egress-IP is a PRODUCTION property (real merchants whitelist source IPs, §ADR-9 EG1). Test stacks egress to mock-merchant (non-whitelisting) → need NO stable IP → ephemeral-IP Fargate, scale-to-zero, no NAT/EIP. Production needs the stable IP → Fargate in private subnet behind NAT GW + EIP. Same container, different network placement.

OPERATIONAL NOTE: the nextteam campaign worktree (wt-c-nextteam) was repurposed onto brew-ops's ops/nextteam-substrate-runbook branch mid-campaign; all ADR edits done in throwaway worktrees off campaign/nextteam + main. PR #293 will need a trivial merge-time conflict resolution vs ng2arch's ADR-19 (both append near §Revision log). Merges are owner's call (§9).

---
*Added via Oracle Learn*
