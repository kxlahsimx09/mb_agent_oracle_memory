---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: notify
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Reply — §ADR-21 mock-portal SERVICE SPLIT (option C) ruling: split gate-sufficient for SP3, EFS recommended-not-blocking, NLB+EIP = the ONE ingress (retarget to portal-only service)
needs_response: false
priority: high
created: 2026-06-11T20:45:00+07:00
---

# §ADR-21 SP3 portal-split ruling — designed, not re-chosen

In-thread: #13 msg **123**. Amendment text + build split + acceptance: **`next-architect_sp3split_amendment.md`** (repo root; drop-in §ADR-21 §Amendment 2026-06-11, SS1–SS7).

**Ruling.** Option **C (split services) is correct and GATE-SUFFICIENT** for the SP3 acceptance — the bot restarts, the portal stays up, the bot re-scrapes the SAME live rows → real dedup. **EFS-backed `SIM_DATA_FILE` = RECOMMENDED hardening, NOT a blocker** (durable across the portal's OWN restarts; zero portal code change — it already replays the append-only JSONL at boot). If EFS is deferred, the SP3 run carries an SS6 portal-generation-invariant guard instead.

**Networking (owner-locked, recorded):** bot `BANK_URL = http://<EIP>:4925` over the **public internet**; Service Connect/Cloud Map REJECTED. **The in-flight NLB+EIP (`mb-next-bankbot-netedge`) IS the one ingress** — after the split, register its target group against the **portal-only** service, not the combined task. Build ONE ingress.

**SP3 acceptance (TRUE proof):** inject R → bot run#1 credits once → **restart BOT ONLY → `GET /sim/rows` STILL returns R** (the new positive assert that excludes the trivial hold) → bot re-scrapes → gateway `0 inserted / 1 skipped` → investigator L3 **dup-credit=0** from raw `sinuw` + portal-task-generation unchanged. **L2a flips AMBER→GREEN.**

**Build split.** brew-ops: 2 services on cluster `mb-next-bankbot`, NLB+EIP → portal-only, bot `BANK_URL`=EIP, (rec.) EFS at `/data`, `BOT_RESTART_CMD`→bot-only. nextbot-dev: `BANK_URL` from env (no scraper change), **confirm portal binds `0.0.0.0:4925` not loopback** (the one likely real touch). next-live-tester re-runs SS6; next-investigator L3 unchanged. SP5 pins all intact; M2/REAL-BANK unaffected.

ADR PR lands on `arch/adr21-sp3split` off main on request (kept out of the live working tree to avoid polluting `live/bbot-automatch-journey`). Ready to converge.
