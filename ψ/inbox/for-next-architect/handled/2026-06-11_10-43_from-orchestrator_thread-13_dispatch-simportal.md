---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: dispatch
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: OWNER DIRECTIVE — SIM mode reworked: REAL mb-next-bank-bot runs, the BANK PORTAL is what gets simulated (append-only + clawback) → amend §ADR-21 M1 + pin mock-portal architecture
priority: high
needs_response: true
created: 2026-06-11T10:43:52+07:00
---

# SIM-portal rework (owner GO 2026-06-11, thread #13 msg #50)

Owner read BBOT-005 and re-ruled the SIM design. Verbatim intent:
- Mode SIM/LIVE must **run the NEW mb-next-bank-bot for real** (the actual portal-side scraper code path — kept AS-IS from seed `9405272`).
- What gets simulated is the **BANK PORTAL**: a simulated portal faithful to **what the bank-bot actually sees** (the unmodified `banks/*` scrapers must log in + scrape it successfully).
- Control surface: **ADD statements** as if a real bank transaction occurred · **NO statement deletion** (append-only, like a real bank) · **CLAWBACK entries supported** (compensating/reversal rows) — for realism.

## Deliverables

**P1 — §ADR-21 amendment.** M1 currently pins "Mode SIM fixture-posts a statement to the intake EF; portal-scrape explicitly NOT exercised in SIM". Amend: SIM-LIVE = inject statement into the simulated portal → REAL bot scrapes → `POST bot-statements` → cascade → finalize. Reconcile the knock-ons in the same pass: (a) the golden journey becomes true E2E including the scraper; (b) `MOCK_BANK_URL` / fault-(i) realization now lives at the portal-sim layer (dup statement = inject the same statement twice → bot re-scrapes → count-based dedup must hold); (c) M2 REAL-BANK narrows to "swap portal URL/creds to the real bank" — state what remains M2-only. Ratification class: this executes an owner directive — mark owner GO 2026-06-11, not provisional.

**P2 — Mock-portal architecture pin** (the component now needs a home + boundary):
- Which repo hosts the portal sim (mb-next-bank-bot alongside the scrapers it must mirror? separate? — you rule) + runtime shape (it must serve what Playwright `banks/ktb`/`banks/scb` selectors expect: login flow incl. OTP path?, dashboard, statement pages).
- **Fidelity boundary**: faithful to the selectors/flows in `banks/*` at seed `9405272` — pin Phase-1 bank coverage (one bank first? which — KTB or SCB — given their login/OTP complexity) vs both.
- **Statement-store invariants**: append-only (no delete API exists at all), clawback = a NEW compensating entry referencing the original (pin its shape — direction/sign/reference), injection API ("as if the bank") + its auth (it's a test-control surface — must never exist in REAL-BANK mode).
- How the gateway-side matcher sees clawback rows (OUT/reversal direction? unmatched-by-design? flag for MATCH-003 reconcile?) — name the gap if it needs an epic story rather than ruling it yourself.

**P3 —** next-pm is reworking BBOT-005 + adding mock-portal stories in parallel (same thread); hand them your P2 pins as they land so the stories don't drift.

`needs_response: true` — reply on thread #13 with the amendment PR + P2 pins, archive this envelope (§11d).

— orchestrator, 2026-06-11 10:43 GMT+7
