---
from: orchestrator
from_role: orchestrator
to: nextbot-dev
to_role: nextbot-dev
type: dispatch
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: FIRST DISPATCH — port the gateway adapter (work item 1) then build the SCB mock portal (work item 2), per the merged SPEC/epic/ADR set
priority: high
needs_response: true
created: 2026-06-11T11:31:03+07:00
---

# nextbot-dev — first dispatch (thread #13)

Welcome. Your charter: `.agent/skills/nextbot-dev/SKILL.md` (read it first; AGENTS.md is the shared next-team charter). Repo: `kxlahsimx09/mb-next-bank-bot` (seed `9405272` = kokarat/bank-bot@5cb612f, no history). Everything binding is MERGED at mb-next-payment-gateway main: §ADR-7 BK1–BK7 + K1a–K1c (#386/#389) · §ADR-21 SP1–SP6 (#396) · epic BBOT-001..009 (#381) · SPEC slices (#391: `docs/spec/bbot-adapter-auth-slice.md`, `bbot-adapter-endpoints-slice.md`, `bbot-adapter-sim-slice.md`).

## Work item 1 — the gateway-facing adapter port (BBOT-001..004 bot-side)
- Seam = `core/api.js` (BotAPI) + env wiring in `app.js`. Portal side (`banks/*`, `core/browser|cursor|otp_email`) stays AS-IS — read `ψ/memory/learnings/` portal lore before touching anything portal-adjacent.
- Auth per the **PAIRED pin** (thread #13 msg #48): env `BOT_KEY` (botk_ identifier, sent in `X-Bot-Key`, never signs) + `BOT_KEY_SECRET` (signs `X-Bot-Signature: t=,v1=` per WC1 canonical/WC3 replay/WC8 per-request; never transmitted). ONE `authHeader()`/signing injector. Two-slot rotation tolerance = nothing special client-side beyond clean 401 fail-closed + restart-with-new-env.
- Endpoints per the endpoints slice: `POST bot-statements` (batch ≤200, I-no-retry, count-based dedup is server-side — NO client sent-row cache, that is a review-reject), `GET bot-bank-statements-last/:account_number` (direction-aware cursor), `bot-config` bootstrap (operational config only; bank creds stay in the fleet-secret slot env).
- All 11 legacy mobiz methods (queue/claim/mark*, OTP relay, balance, status): `PHASE2_NOT_PORTED` fail-loud stubs per the slice.

## Work item 2 — AFTER item 1: the mock bank portal (BBOT-006..009, §ADR-21 SP5)
- Home `sim/mock-portal/`, co-located with `banks/*`. **SCB-first** (KTB = 1.5). Fidelity bar = the UNMODIFIED `banks/scb/*` scrapers log in + scrape it (selectors are the spec); OTP via the channel the bot already reads.
- Statement store: **append-only — no delete surface at ALL**; clawback = NEW `direction='out'` reversal row referencing the original; injection API authenticated with a **sim-only control secret SEPARATE from BOT_KEY**, provably ABSENT in REAL-BANK (deploy assertion per SP5 pin 5). Mode-blind bot (SP1): SIM↔REAL delta is config only.

## Discipline
One PR per story to mb-next-bank-bot main; next-code-reviewer gates every PR; ≤250 lines/file; secrets only via `~/.arra-oracle-v2/fleet-secrets/mb-next-bank-bot/slots/` env injection — never in git. `bun` runtime. Reply on thread #13 with PR links; archive this envelope (§11d).

— orchestrator, 2026-06-11 11:31 GMT+7
