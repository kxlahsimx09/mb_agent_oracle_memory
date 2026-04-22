---
title: W10 pass 2026-04-22 maintenance — 2 new constraint entries (partner-sla + callback-webhook themes)
tags:
  - technical-writer
  - repo:cross
  - current
  - constraint
  - workflow-10
  - maintenance
  - same-day-second-run
source: docs/constraints.md @ 9660d7d + bank-bot @ b71aff4, W10 root trace 22a3e003-b8f3-4e01-8dbb-97207451ae28
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-22
---

# W10 pass 2026-04-22 maintenance — 2 new constraint entries (partner-sla + callback-webhook themes)

Second W10 pass on 2026-04-22 GMT+7, run immediately after the first-run
baseline (PR #283) merged. Targets the theme wheel's "rotate to least-covered"
rule — the first-run baseline left 9 of 15 themes at zero entries; this
maintenance pass attacks 4 of those (partner-sla, callback-webhook, regulatory,
queue-idempotency), of which 2 produced NEW entries that pass the
Classification-§4-test.

Owned by `pg-writer-oracle` (technical-writer instance for
mobiz-payment-gateway); register continues to cover both mobiz-payment-gateway
and bank-bot (see workflow-10 §Cross-repo scope).

## Delta

**New (2):** C-013, C-014.

| ID | Theme | Source | Tier | One-line statement |
|---|---|---|---|---|
| C-013 | partner-sla | Thunder API (slip-verification vendor) | soft | Thunder slip-verify API has panic-level failures + multi-second timeouts frequent enough that the deposit path must tolerate its failure; not covered by a hard SLA. |
| C-014 | callback-webhook | Telegram Bot API (legacy Markdown parse mode) | hard | Telegram `parse_mode=Markdown` returns HTTP 400 on unclosed `_ * ` [` runs from unescaped dynamic fields; failure is silent (no reason text). |

**Extended:** 0.
**Superseded:** 0.
**UNVERIFIED / AWAITING_THREAD:** 0 — both entries carry concrete citations
(PR numbers, commit hashes, `file:line@hash` pointers). No threads opened.

## Themes covered this pass

`partner-sla`, `callback-webhook`.

Themes swept but yielding no NEW or EXTEND this pass:

- `regulatory` — searches for BOT/KYC/AML/PDPA in memory returned 0 hits
  inside this repo's vault; Thai regulatory constraints exist in the
  business domain but have not yet been written to the vault in a form W10
  can harvest. Open question (not formalized as an arra_thread because the
  gap is "no evidence in vault yet", not "ambiguity in existing evidence"):
  **who authors the regulatory constraints and when** — likely waits for
  the first target-system ADR that touches KYC or data-retention.
- `queue-idempotency` — candidates surfaced (callback resend gap on
  deposit-auto-expire and payout-auto-cancel-pending-timeout; bank-statement
  dedup contract in bank-bot's `statement-push-error-handling-and-retry`
  flow), but the surfaced facts are design choices on our side, not external
  constraints. C-011 already absorbs the external fact that SCB statement
  descriptions don't reliably carry a request_id; the "we need idempotent
  callback resend" piece is a regression candidate owned by W4, not a W10
  constraint.

## Classification notes (per the §4-test)

**Thunder (C-013):**
- Externally sourced: ✅ Thunder is a 3rd-party OCR/slip-verify vendor.
- Not our reaction: ✅ Statement is "Thunder has panic failures"; our reaction
  (`defer recover()`, retry×2, best-effort save) is cited as the workaround,
  not the constraint.
- Survives a rewrite: ✅ tier=soft — a greenfield could renegotiate Thunder
  or swap vendors, but the class-constraint "3rd-party OCR APIs are flaky"
  survives. Captured in the `Target-system implication` field.
- Cite-able: ✅ `controllers/DepositController.go:1851-2060@37dfb26`, PR #219
  (`1d39193`), PR #221 (`68f82f5`), learning
  `2026-04-18_uploadslipadmin-hardening-three-independent-but.md`.

**Telegram (C-014):**
- Externally sourced: ✅ Telegram Bot API vendor contract.
- Not our reaction: ✅ Statement is "Telegram returns 400 on unescaped
  metacharacters"; our reaction (`escapeMD`) is cited as the workaround,
  not the constraint.
- Survives a rewrite: ✅ tier=hard — Telegram's parse-mode behavior is fixed
  by the vendor; any future system using Telegram's legacy Markdown mode
  inherits it. Switching to `parse_mode=HTML` or `parse_mode=MarkdownV2`
  does not dissolve the constraint — it just remaps the escape contract.
- Cite-able: ✅ `services/telegramNotify.go`, PR #162 (`bd10835`), learning
  `2026-04-16_name-telegram-direct-transfer-templates-esc.md`.

**Two candidates that were inspected and dropped as NOISE:**

1. "Callback resend needs idempotency on both payout-auto-cancel-pending-timeout
   and deposit-auto-expire-pending flows" — this is an internal regression
   candidate (W4-queued), surfaced by `services/callbackService.go:379-422`.
   The external fact it responds to ("merchant endpoints may process
   duplicate callbacks") is merchant-implementation-dependent and varies per
   merchant — not a universal constraint. Drop.
2. "Bank-bot statement push retry design has dedup contract with mobiz side"
   — the dedup is our contract, not an external fact. The external fact
   (SCB/KTB statements can be re-served across pages) is already captured
   by C-009 (future-dated rows) + C-011 (description-no-request_id). Drop.

## Traces

- Root: `22a3e003-b8f3-4e01-8dbb-97207451ae28` (W10 constraint-harvest pass
  2026-04-22 maintenance) — chained back to first-run root
  `5918b1ef-d3ca-420f-b230-feb882bc0508` via `arra_trace_link`.
- Children (one per NEW, linked via `parentTraceId` to root):
  - C-013 (Thunder): `9298dc45-d71f-4f88-b5df-c7d67c97c0d1`
  - C-014 (Telegram): `455e560c-a04e-4767-9c15-ca7b7945329a`

## Cursor

`docs/.constraints-cursor` updated to:

- `last-pass-at: 2026-04-22T16:25:00+07:00`
- `mobiz-commit-head: 9660d7d` (post-#283 merge)
- `bank-bot-commit-head: b71aff4`
- `memory-cursor: 2026-04-22T16:00:00+07:00`
- `last-constraint-id: C-014`
- `themes-covered-this-pass: partner-sla, callback-webhook`

## Cross-links

- `docs/current-system.md §8.1` — present (from first-run), no change needed.
- `docs/migration-notes.md §Preamble` — **file still absent**. Same
  known-gap as the first-run pass. Per the first-run retro's
  "what I'd change in workflow-10" item #2, the correct action is to flag
  and not manufacture a stub. Follow-up still owned by the first
  migration-notes authoring session.

## Observations (for next W10 run)

1. **Pass A surfaced both of today's NEW entries directly**; Pass B
   (git log) yielded zero (mobiz had only the W10 doc commit itself in the
   `cf1edb3..HEAD` range; bank-bot had two doc commits). Pass C (merged
   PRs since cursor) had candidates but all either re-encoded C-001..C-012
   evidence (PR #96 bank-bot KTB username rename = already in C-008) or
   were internal regression candidates. Pass D (AGENTS.md §9) added nothing —
   all §9 discipline rules encode reasons already in the register.
   Implication: on same-day maintenance runs (< 24h after a prior pass),
   Pass A is by far the highest-yield lane. A future run that spans weeks
   will see the ratio invert.
2. **The "regulatory" theme remains at 0.** The vault currently has no
   regulatory learnings for this codebase — the domain knowledge exists
   but hasn't been written down in a W10-harvestable form. A target-system
   ADR that touches KYC/AML/PDPA is the most likely trigger for populating
   this theme; deferring is the right call over inventing.
3. **First-run retro point 3 was right:** theme coverage needs to be
   cumulative-across-all-passes, not per-pass. This pass's §Theme coverage
   table is now explicitly cumulative and annotates per-pass deltas live
   in the per-pass learning (this file). If another writer picks this up
   cold, they should see the cumulative table first and the per-pass
   delta in the most recent learning.
4. **Bloat check:** 2 new entries this pass is right in the middle of the
   "healthy 2–5 per maintenance run" target; 0 extends is a mild signal
   that the first-run baseline was thorough enough that same-day re-harvest
   mostly confirms existing entries. If future passes consistently yield
   2+ extends per pass, the first-run evidence should be rewritten with
   more primary-source detail.
