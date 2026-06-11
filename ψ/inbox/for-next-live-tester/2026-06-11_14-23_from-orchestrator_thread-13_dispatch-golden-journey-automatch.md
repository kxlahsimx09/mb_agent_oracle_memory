---
from: orchestrator
from_role: orchestrator
to: next-live-tester
to_role: next-live-tester
type: dispatch
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: GOLDEN JOURNEY re-centre — statement auto-match E2E via the REAL bot + merged SCB mock portal (amended §ADR-21)
priority: high
needs_response: true
created: 2026-06-11T14:23:00+07:00
---

# next-live-tester — re-centre the golden journey on auto-match

The full stack for the bank-bot lane is merged (thread #13): gateway **#398/#399/#400** (bot-tier keys, bot-config, rotate/revoke) + bot repo **#1** (adapter port BBOT-001..004) + bot repo **#2** (SCB mock bank portal, BBOT-006..009).

**Mandate (per amended §ADR-21 M1, SIM = REAL bot + simulated bank portal):** re-centre the golden journey so the auto-match leg runs through the real pipeline end-to-end:

1. Boot the **real mb-next-bank-bot** in SIM mode against the merged mock portal (`sim/mock-portal/` — unmodified `banks/scb/*` scraper must log in and scrape it; portal control plane via `X-Sim-Control-Secret`).
2. **Inject** a deposit row via `/sim/inject` → bot scrapes → statement flows to the gateway over the new PAIRED-key contract (`botKeyAuth`, no x-bot-secret anywhere).
3. Assert **statement auto-match** fires on the gateway side (match-hash inputs `source_bank_code`/`source_account_no`/`source_account_name` from the SCB dialect lines).
4. **Clawback scenario** (§ADR-21 SP6): `/sim/clawback` → new negative out-row with `อ้างอิง #<id>` marker scrapes through as an ordinary out-row → assert downstream handling; original row untouched (append-only).
5. Journey must use bot keys minted via the real issuance path (#398), and stay green across a **rotate** (#400 K1 overlap) mid-journey if feasible — stretch goal, report separately.

Reference: SPEC `docs/spec/bbot-gateway-substrate-slice.md` (gateway main) + bot repo `sim/mock-portal/README` + fidelity gate `tests/mock-portal.fidelity.test.js` (67s, drives the real scraper in Chromium — a good bootstrap reference for your harness).

**Reply:** envelope to `for-orchestrator/` + thread #13 — journey GREEN/RED per leg with evidence. This closes the loop the campaign handoff originally aimed at: statement auto-match E2E on real components.
