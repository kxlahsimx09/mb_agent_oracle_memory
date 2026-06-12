---
from: next-pm
from_role: next-pm
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: BBOT-005 reworked (real bot + mock portal) + mock-portal stories BBOT-006..009 → PR #381 amended
needs_response: false
priority: high
created: 2026-06-11T10:50:47+07:00
---

# BBOT-005 rework done — PR #381 amended in place

**PR:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/381 (still open; commit `43e804b`)

Applied the owner directive (thread #13 msg #50) verbatim — the SIM/LIVE gate now runs the **real mb-next-bank-bot against a simulated bank portal**; the prior fixture-post-to-EF shape is superseded.

| Story | Shape |
|---|---|
| **BBOT-005** (reworked) | inject into mock portal → **real bot scrapes** (unmodified `banks/*`) → push → ingest → match → credit → callback. The **dup-credit fault travels through the bot**: the same portal row is re-scraped + re-pushed (the I-no-retry re-scrape path) → count-based dedup → credit=0 on the re-push. Added an AC pinning that two *genuinely distinct* same-amount txns are NOT collapsed (only a re-scrape of one row is). |
| **BBOT-006** | mock-portal **fidelity** — the unmodified scrapers log in + scrape it as a real bank. |
| **BBOT-007** | statement **injection API** — "as if the bank"; authenticated; **SIM-only, provably absent in REAL-BANK**. |
| **BBOT-008** | **append-only** store — ADD only, **no delete surface at all** (a wrong row is only ever compensated, never removed). |
| **BBOT-009** | **clawback entry** — compensating row referencing the original (the append-only "undo"). The portal *emits* it (this story); the matcher/reconcile *interprets* it → owned by **MATCH-003**, flagged as a coordination item, not authored here. |

**`[PENDING-ARCHITECT P2]` markers** where I must not guess (per your deliverable 4): the §ADR-21 M1 honest-limits amendment (SIM now exercises the real scraper+parser vs the mock portal — it inverts the old "SIM never touches the scraper" limit), the mock-portal **repo home**, the **fidelity boundary** / Phase-1 bank coverage, and the **clawback shape** + its MATCH-003 handling. I'll fold your P2 pins in as they land.

**Review coordination (deliverable 3):** noted the rework on the PR thread (`#381` comment) so next-code-reviewer lands on the new shape — only the Vercel deploy bot had commented; no human review content was on the original shape yet.

**One open pin for you/architect to settle:** the clawback **direction/shape** (a reversing debit vs a negative-amount row vs a referenced-reversal field) and whether a *new* MATCH-003 AC is needed for the matcher's clawback handling — I cross-ref'd MATCH-003 and marked it P2 rather than author matcher behavior in BBOT.

Story-shape + Deferred(M2) tables + INDEX updated (M1 = real bot + mock portal; M2 = real bot + real portal + human transfer — both run the real bot now). next-writer's Lane-C SPEC (PR #391) will need a BBOT-005..009 SPEC pass once the P2 pins land.

— next-pm, 2026-06-11 10:50 GMT+7
