---
title: design decision — §ADR-21 §Amendment 2026-06-11 (SS1–SS7): mock-portal SERVICE S
tags: [system-architect, repo:mb-next-payment-gateway, repo:cross, next, bank-bot, sim-portal, adr-21, sp3, dedup, fargate, ecs, nlb, decision]
created: 2026-06-11
source: next-architect_sp3split_amendment.md + thread #13 (owner directives 2026-06-11) — §ADR-21 §Amendment 2026-06-11 SS1–SS7
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# design decision — §ADR-21 §Amendment 2026-06-11 (SS1–SS7): mock-portal SERVICE S

design decision — §ADR-21 §Amendment 2026-06-11 (SS1–SS7): mock-portal SERVICE SPLIT for the SP3 crash-restart dedup leg. Owner directives (thread #13): option C (split the SCB mock portal and the real bank-bot scraper, today co-located in ONE Fargate task `mb-next-bankbot-sim:3` talking over localhost:4925 with volumes:[]/mountPoints:[] so the portal wipes on restart) into TWO ECS services on cluster `mb-next-bankbot`; AND the bot→portal hop goes over the PUBLIC INTERNET (fidelity to prod where the real bot scrapes a real bank over the internet) — Service Connect/Cloud Map REJECTED.

Ruling: C is GATE-SUFFICIENT for the SP3 acceptance (the SP3 lever restarts the BOT service only, the portal stays up with its injected rows → the bot re-scrapes the SAME live rows → real count-based dedup in submit_statements_batch under pg_advisory_xact_lock). EFS-backed SIM_DATA_FILE (=/data/sim-rows.jsonl, which the portal already replays append-only at boot) is RECOMMENDED hardening for the portal's OWN incidental restarts but is NOT a gate blocker — zero portal code change. If EFS is deferred, the SP3 run carries an SS6 portal-task-generation-invariant guard.

Networking: bot BANK_URL=http://<EIP>:4925; the in-flight brew-ops NLB+Elastic-IP (policy mb-next-bankbot-netedge, target-type ip / TCP 4925 / vpc-04b0ee094dbe5a731 / TCP health check / single-AZ single-EIP + cross-zone) IS THE ONE INGRESS — after the split its target group registers against the PORTAL-ONLY service, not the combined task. Build one ingress, not two; the stable EIP survives portal task replacement so the bot's BANK_URL never changes.

SP3 re-run acceptance (TRUE dedup proof): inject R (POST /sim/inject, X-Sim-Control-Secret) → bot run#1 credits once → restart the BOT service ONLY → GET /sim/rows STILL returns R (the new positive assert that excludes the prior trivial hold, where an empty portal yielded an empty re-scrape) → bot re-scrapes → gateway 0 inserted / 1 skipped → next-investigator L3 dup-credit=0 from raw sinuw (count stays 1, one deposit_credit, callback once) + portal task generation unchanged. L2a flips AMBER→GREEN.

SP5 pins UNCHANGED: no scraper change (banks/* AS-IS seed 9405272); store append-only/no-delete; injection plane X-Sim-Control-Secret SIM-only, ABSENT in REAL-BANK. SP5 lockstep is SOURCE co-location (portal in mb-next-bank-bot sim/mock-portal/ next to banks/*), NOT runtime — the runtime split does not violate it. Security: public exposure = the same two planes already public (simviewer login + X-Sim-Control-Secret), no NEW surface, mirrors prod; M2/REAL-BANK unaffected (no sim portal, BANK_URL→real bank URL).

Build split: brew-ops splits into 2 services + retargets the NLB+EIP at the portal-only service + bot BANK_URL=EIP + (rec.) EFS at /data + BOT_RESTART_CMD→bot-only. nextbot-dev: BANK_URL from env (no scraper change) + confirm the portal binds 0.0.0.0:4925 not 127.0.0.1 (the one likely real touch — a co-located portal may bind loopback; the NLB target needs a routable bind). next-live-tester re-runs SS6 remote/split mode; next-investigator L3 unchanged. Cost net-new ≈ one Fargate task; the NLB+EIP (~$16–20/mo) is NOT new to this decision.

Amendment text/artifact: next-architect_sp3split_amendment.md (drop-in §ADR-21 §Amendment block + revision-log guidance; ADR PR lands on arch/adr21-sp3split off main on request, kept out of the live working tree). Reported: thread #13 msg 123 + for-orchestrator + for-next-live-tester envelopes.

---
*Added via Oracle Learn*
