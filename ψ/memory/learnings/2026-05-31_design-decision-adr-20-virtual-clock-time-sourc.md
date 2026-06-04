---
title: design decision — §ADR-20 Virtual-Clock Time-Source Abstraction + Real-Substrate
tags: [system-architect, next-architect, nextteam, adr-20, virtual-clock, time-source, app-now, real-substrate, env-topology, provisional, ratification-pending, decision, handoff, mb-next-payment-gateway]
created: 2026-05-31
source: docs/adr.md §ADR-20 (campaign nextteam, branch campaign/nextteam, kxlahsimx09/mb-next-payment-gateway)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# design decision — §ADR-20 Virtual-Clock Time-Source Abstraction + Real-Substrate

design decision — §ADR-20 Virtual-Clock Time-Source Abstraction + Real-Substrate Environment Topology (campaign nextteam, by next-architect). Authored `#provisional` `[RATIFICATION_PENDING:nextteam]`; owner GO required, NOT self-ratified (the §ADR-18 precedent). PR against kxlahsimx09/mb-next-payment-gateway docs/adr.md, branch campaign/nextteam (NOT merged per §9). Filed under arra-oracle-v3 because the mb-next Oracle project slug is STILL unregistered (brew-ops gotcha #2 — needs MCP restart). ADR number 20: ADR-17 reserved (P2P), ADR-18 latest, ADR-19 = concurrent ng2arch campaign → disjoint.

Two coupled build-team decisions unblocking the 5-role nextteam build (next-dev x2 / next-tester / next-code-reviewer / next-investigator / next-pm; brew-ops PR #9 scaffold). Both the next-dev clock rule (time = injectable dependency) and the env topology (4 stacks, separate projects, no branching) referenced an ADR that did not exist until now.

PART A — TIME-SOURCE / VIRTUAL-CLOCK (T1-T7):
- T1: no wall-clock in business logic. Banned TS Date.now()/new Date()/performance.now(); SQL now()/CURRENT_TIMESTAMP/clock_timestamp()/transaction_timestamp()/statement_timestamp()/timeofday(). Allowlist: clock module, migration DEFAULT now() stamps, log/trace ts, §ADR-9 callback signer.
- T2 (load-bearing): canonical now = ONE Postgres app_now() single source of truth, real vs virtual via per-stack sys_clock row. DB-is-the-clock (only placement EF + RPC + pg_cron share).
- T3: EF reads now via injected Clock → X-App-Now header (stamped from app_now()) → else memoized app_now() per invocation.
- T4: time-RPCs take p_now timestamptz DEFAULT NULL + COALESCE(p_now, app_now()); EF threads its instant in; pg_cron/Realtime pass NULL so sweeps still see virtual time.
- T5: harness advances via service-role clock_set/clock_advance/clock_reset; frozen-step (default deterministic) + scaled (anchor+elapsed×SPEED) modes; dev/test/seal only.
- T6: NOT-compressible → periodic real-1x suite: CF rate-limit windows + KV TTL (§ADR-2 GW5/6), pg_cron cadence (test predicate via direct sweep call), EF cold-start (§ADR-1/6), callback 5-min replay (§ADR-9 WC3 — external mock-merchant on real wall-clock; signer allowlisted), bank session/OTP timers (§ADR-6 C-001/C-005, owned by mock-bank).
- T7: enforced by next-code-reviewer dimension + grep recipe, NOT a CI hook (campaign discipline-only gating).

PART B — ENV TOPOLOGY (E1-E5):
- E1: real-substrate-always; 4 isolated standing stacks (dev-1, dev-2, test/perf, seal) = own Supabase project + CF Worker + EC2 gateway + key set; separate projects only, NO Supabase branching.
- E2: external seams simulated even on real substrate — bank-bot/mock-bank + mock-merchant; everything between real.
- E3: reset_for_test() service-role RPC (truncate RESTART IDENTITY CASCADE + reseed §ADR-18 6-entity baseline + V4-provenance fixtures + reset sys_clock to real); non-prod-guarded (reset-not-teardown since projects persist).
- E4: deploy 3 real planes — supabase functions deploy + wrangler deploy + EC2-GW → probes hit real endpoints; portable, only per-stack env profile (base URL + key set + stack-kind) varies.
- E5: no-production-data-in-test (binding): no prod-dump seeding, synthetic V4 fixtures, no prod keys in test slots, no real banking creds in mock-bank; seal stack fully independent (own reset + own clock).

COUPLING: clock per-stack → independent advance; reset restores it; real-1x suite on test/perf + seal.

OWNER OPEN QUESTIONS: O1 confirm DB-as-clock app_now() (load-bearing); O2 default mode frozen-step vs scaled; O3 not-compressible list complete + real-1x cadence; O4 discipline-only vs hard gate; O5 (infra→brew-ops) reconcile per-stack EC2 gateway vs §ADR-6 Hetzner — what does the EC2 GW serve?

DOWNSTREAM deltas: next-dev — thread Clock/app_now/p_now, add p_now to every time-RPC, build app_now/sys_clock/clock_*/reset_for_test migrations + _shared/clock.ts. next-tester — drive virtual time via clock_advance, split T6 into periodic real-1x, portable probes. next-investigator — own reset + own clock on seal, extend V1 audit to 'no hidden wall-clock dependency', real-1x = V3 two-tier. Findings: next-architect_nextteam_findings.md.

---
*Added via Oracle Learn*
