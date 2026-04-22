---
title: flow — statement-push-error-handling-and-retry (bank-bot W8 first pass, reverse-
tags: [technical-writer, repo:bank-bot, current, flow, flow:statement-push-error-handling-and-retry, statement-push, cursor-reload, no-retry-design, idempotency, dedup-contract, cross-cutting]
created: 2026-04-22
source: Oracle Learn
project: github.com/kokarat/bank-bot
---

# flow — statement-push-error-handling-and-retry (bank-bot W8 first pass, reverse-

flow — statement-push-error-handling-and-retry (bank-bot W8 first pass, reverse-engineered from app.js@f8bcdf5 + core/api.js@f8bcdf5).

**Key insight:** the flow slug contains "and-retry" but the code has ZERO explicit retry / backoff on ANY of the three Gateway HTTP crossings (`GET /bot/bank-statements/last`, `POST /bot/bank-statements`, `PUT /bot/balance`). The doc reframes "retry" as "cursor-reload on next tick IS the retry mechanism" — a design that works because server-side cursor advances only on successful ingest + server-side dedup absorbs re-delivery deterministically.

**Load-bearing assumptions (documented in flow §Purpose):**
1. Gateway dedup is deterministic — same logical row emits same dedup key across ticks.
2. Scrape is idempotent — same bank page at two different ticks yields same rows with same field values. Depends on the `raw_text` / `description` fidelity rule from `deposit-auto-match-from-statement.md`.
3. Gateway's cursor advances only after successful ingest — failed POST leaves cursor unchanged.
4. Bank portal keeps showing yesterday's rows ≥ 1 business day — if a row rotates out before successful push, dead letter.

**Error paths documented (9 classes):**
- `CURSOR_GET_FAIL` — silent swallow, defaults cursors to 0 (full-refresh mode). `[INTENTIONAL?]` — Q1 ratification.
- `POST_4xx` — log-spam, no retry. Persistent schema drift can silently stall deposit matching for hours. `[DRIFT]` — Q2 ratification.
- `POST_5xx` / `POST_timeout` — happy recovery path for no-retry design. Dead-letter risk if gateway down > 1 business day.
- `POST_partial_insert` (200 with `skipped > 0`) — not an error, expected on re-delivery.
- `KTB_SESSION_DEAD` bubble — triggers browser recycle at `app.js:727-735`. Cross-ref to `queue-claim-to-processing-state-machine.md`.
- `UPDATE_BALANCE_FAIL` (9a reuse path) — bubbles to outer catch, aborts tick post-statement-save.
- `UPDATE_BALANCE_FAIL` (9b live-scrape, 4 call sites) — each has own try/catch, log-warn, no retry.
- Auth failure (persistent 401/403) — indistinguishable from transient 5xx. `[DRIFT]` — Q4 ratification.
- Process crash between scrape + POST — next start recovers via cursor-reload. Guaranteed safe.

**Scope boundaries:**
- OUT of scope: scrape side (owned by `deposit-auto-match-from-statement.md`).
- OUT of scope: External:BankPortal — no portal actor in this flow's mermaid.
- IN scope: the three Gateway crossings + their 9+ failure modes + the no-retry design contract.

**Cross-repo counterpart:** `mobiz-payment-gateway/docs/flows/deposit-auto-match-from-statement.md` steps 3–5. Caller/implementor split — gateway side says "dedup is deterministic, safe to re-deliver"; bot side says "good, then I don't need a retry buffer".

**Ratification thread:** 5 open judgment calls (Q1 CURSOR_GET_FAIL silent-swallow, Q2 POST_4xx drift hardening, Q3 no-retry as intentional vs emergent, Q4 auth failure special handling, Q5 9b call-site enumeration vs abstract). Expect S4 → S2 after resolution.

**Follow-up (from gap analysis, 3rd of 3 originally flagged):**
- `scb-session-dead-recovery-re-login` — mid-batch session loss + browser recycle path for SCB. Still open, authorable after this flow ratifies.

---
*Added via Oracle Learn*
