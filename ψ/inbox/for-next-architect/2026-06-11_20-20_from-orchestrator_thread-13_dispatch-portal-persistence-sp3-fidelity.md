---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: dispatch
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: DESIGN the bot↔portal SERVICE SPLIT + amend §ADR-21 — owner DECIDED option C; make the SP3 dedup leg a TRUE test (portal wipes on task restart today)
priority: high
needs_response: true
created: 2026-06-11T20:20:00+07:00
---

# Mock-portal persistence — make the SP3 dedup leg real

## The gap (owner + UI-tester surfaced, orchestrator verified)

The golden journey's **SP3 dup-fault leg** is meant to prove: bot crash-restart → bot re-scrapes the SAME statements → gateway dedup rejects the duplicate → dup-credit=0. But the mock portal stores statements **in-memory + an ephemeral JSONL** (`SIM_DATA_FILE=/data/sim-rows.jsonl`). **Verified on the deployed task-def `mb-next-bankbot-sim:3`: `volumes: []`, portal `mountPoints: []`** — so `/data` is ephemeral container storage. On task restart the portal comes back **EMPTY**.

Consequence: in the SP3 run, after the crash-restart the bot re-scraped an **empty** portal and pushed nothing, so "1 row / dup-credit=0" held **trivially** — NOT because the gateway deduped a re-presented duplicate. The leg's fidelity is weaker than its verdict implied.

**What is still validly proven (do not re-litigate):** the gateway dedup MECHANISM is real — brew-ops's same-task re-presentation smoke (thread #13 msg 98) showed "0 inserted, 1 skipped, count stays 1", and next-investigator's L3 recompute confirmed dup-credit=0 from raw tables. The certified invariant holds. The gap is specifically the **SP3 crash-restart scenario**: the portal must survive a restart for the re-scrape to exercise dedup.

## OWNER DECISION — option C (split services). Your job is to DESIGN it, not re-choose.

Owner verbatim (2026-06-11 20:20): "แยก service ดีกว่า" — split the portal into its own service so an SP3 crash-restart bounces **only the bot**, leaving the portal (with its injected statements) standing → the bot re-scrapes the SAME live rows → gateway dedup is genuinely exercised. (Context, for the record only — do NOT relitigate: A=DB-backed store, B=EFS-JSONL persistence; both were alternatives the owner passed over in favor of the split.)

Design the split. Decide and specify:

1. **Networking — how the bot reaches the portal once they're separate tasks.** Today they share a task and talk over `localhost:4925`; split means the bot's `BANK_URL` must point at the portal over the network. Options: ECS Service Connect / Cloud Map internal DNS (recommended — stable internal name, no public exposure for the bot→portal hop), OR the NLB+EIP front that brew-ops is ALREADY building for the owner's stable-portal-URL ask (the bot could use that same endpoint). **This converges with the in-flight Elastic-IP/NLB work — reconcile the two so we build one portal ingress, not two.** State whether the bot uses the internal (Service Connect) name or the public stable endpoint.
2. **Does the standalone portal ALSO need persistence for its OWN restarts?** The split fixes the bot-restart case; but if the portal service itself redeploys/crashes, in-memory data still wipes. Rule whether C is sufficient for the SP3 acceptance as-is, or whether to pair it with EFS/DB so the portal is durable across its own restarts too.
3. **§ADR-21 fit** — SP5 "no scraper change / append-only / fidelity" pins; the SP3 leg semantics (crash-restart now unambiguously = restart the bot service); cost; and the two-service task-def/deploy shape.

Your ruling sets what nextbot-dev (any portal/bot config change — e.g. BANK_URL wiring) and brew-ops (second ECS service, Service Connect/Cloud Map or NLB reconciliation, any volume) build, after which next-live-tester RE-RUNS SP3 for a genuine verdict.

## Deliverable

Reply → for-orchestrator/ + thread #13: your ruling (A/B/C or a hybrid) with the rationale, the §ADR-21 amendment text (or a PR to the ADR), and a crisp build split for nextbot-dev + brew-ops + the SP3 re-run acceptance (what makes the re-run a TRUE dedup proof — e.g. "after restart, GET /sim/rows still returns the injected row; bot re-push → gateway 0-inserted-1-skipped; dup-credit=0").
