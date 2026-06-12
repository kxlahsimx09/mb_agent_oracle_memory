---
title: title: next-tester sim-slice AC-2 VERIFY GREEN 4/4 + routed observation — botk_-
tags: [next-tester, repo:mb-next-payment-gateway, next, probe, sim, bankbot, evidence, interpretation-pending]
created: 2026-06-11
source: tests/integration/run-bbot-sim-ac2.ts @ PR #403; evidence/integration-run-bbot-sim-1781163717632-b509e7cf.json
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: next-tester sim-slice AC-2 VERIFY GREEN 4/4 + routed observation — botk_-

title: next-tester sim-slice AC-2 VERIFY GREEN 4/4 + routed observation — botk_-shaped SIM_CONTROL_SECRET constructs

Black-box probes of the merged mock-portal (bot repo kxlahsimx09/mb-next-bank-bot @ b509e7c, PR #2) against sim-slice §2 + AC-2 (SP5 pin 5, BBOT-007): (a) construct WITHOUT SIM_CONTROL_SECRET → loud refusal exit 1, never listens — PASS; (b') a botk_… value presented ON the control plane (X-Sim-Control-Secret header) → 401 — PASS; no-header → 401 PASS; configured secret → 200 PASS. Lane verdict GREEN on the literal AC reading. OBSERVATION (interpretation-pending, asserted by neither side): the server CONSTRUCTS AND SERVES when SIM_CONTROL_SECRET itself is set to a botk_-shaped value — "control secret ≠ BOT_KEY" is enforced only by configuration discipline, no construct-time shape guard. If the strict reading of the reviewer's AC-2 verdict is ratified, this is a one-line bot-repo guard + probe flip (routed to orchestrator thread #13 for disposition). Probe: tests/integration/run-bbot-sim-ac2.ts (PR #403) — drives the server as a child process + HTTP only, source never read (de-bias); README run-surface is the launch contract.

evidence: evidence/integration-run-bbot-sim-1781163717632-b509e7cf.json

tags: next-tester, repo:mb-next-payment-gateway, next, probe, sim, bankbot, bbot-007, evidence, interpretation-pending, fixture-source:repo-flow-doc

---
*Added via Oracle Learn*
